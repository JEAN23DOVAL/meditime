const { Payment, Rdv, Doctor, User } = require('../models');
const { calculatePaymentShares } = require('../utils/paymentCalculation');
const axios = require('axios');
const { notifyRdvStatus } = require('../utils/rdvNotification');

// Endpoint pour recevoir le callback CinetPay
exports.cinetpayCallback = async (req, res) => {
  try {
    const data = req.body || req.query;
    const { transaction_id, cpm_trans_status, cpm_payment_date } = data;

    // Retrouver le paiement par transaction_id
    const payment = await Payment.findOne({ where: { cinetpay_transaction_id: transaction_id } });
    if (!payment) return res.status(404).json({ message: 'Paiement non trouvé' });

    if (cpm_trans_status === 'success') {
      payment.status = 'success';
      payment.paid_at = cpm_payment_date ? new Date(cpm_payment_date) : new Date();
      await payment.save();

      // Crée le RDV si pas déjà créé
      if (!payment.rdv_id) {
        const rdv = await Rdv.create({
          patient_id: payment.patient_id,
          doctor_id: payment.doctor_id,
          specialty: payment.specialty,
          date: payment.date,
          motif: payment.motif,
          duration_minutes: payment.duration_minutes,
          status: 'pending'
        });
        payment.rdv_id = rdv.id;
        await payment.save();

        // Notifie le médecin d'une nouvelle demande de RDV
        notifyRdvStatus(req.app, rdv, null).catch(console.error);
      }
    } else {
      payment.status = 'failed';
      await payment.save();
    }

    res.status(200).send('OK');
  } catch (error) {
    console.error('Erreur callback CinetPay:', error);
    res.status(500).send('Erreur serveur');
  }
};

// Démarre un paiement CinetPay et retourne l'URL de paiement
exports.initiatePayment = async (req, res) => {
  try {
    const { patient_id, doctor_id, specialty, date, motif, duration_minutes } = req.body;
    if (!patient_id || !doctor_id || !specialty || !date) {
      return res.status(400).json({ message: 'Champs obligatoires manquants' });
    }

    // Récupère le médecin et son tarif
    const doctor = await Doctor.findOne({ where: { idUser: doctor_id } });
    if (!doctor) return res.status(404).json({ message: 'Médecin introuvable' });
    const price = doctor.pricePerHour;

    // Calcule les parts
    const shares = calculatePaymentShares(price);

    // Génère un transaction_id unique
    const transactionId = `rdv_${doctor_id}_${patient_id}_${Date.now()}`;

    // Prépare la transaction CinetPay
    const cinetpayPayload = {
      apikey: process.env.CINETPAY_API_KEY,
      site_id: process.env.CINETPAY_SITE_ID,
      transaction_id: transactionId,
      amount: shares.totalToPay,
      currency: 'XAF',
      description: `Paiement RDV Meditime`,
      return_url: process.env.CINETPAY_RETURN_URL,
      notify_url: process.env.CINETPAY_NOTIFY_URL,
      customer_name: req.user?.firstName || 'Patient',
      customer_surname: req.user?.lastName || '',
      customer_email: req.user?.email || '',
      customer_phone_number: req.user?.phone || '',
      channels: 'ALL',
    };

    // Vérifie la configuration CinetPay
    if (!process.env.CINETPAY_API_KEY || !process.env.CINETPAY_SITE_ID || !process.env.CINETPAY_RETURN_URL || !process.env.CINETPAY_NOTIFY_URL) {
      return res.status(500).json({ message: 'Configuration CinetPay incomplète. Vérifiez le .env.' });
    }

    // Appel API CinetPay (sandbox ou prod)
    const cinetpayRes = await axios.post('https://api-checkout.cinetpay.com/v2/payment', cinetpayPayload);
    const paymentUrl = cinetpayRes.data.data.payment_url;

    // Enregistre le paiement en BDD (sans RDV)
    await Payment.create({
      patient_id,
      doctor_id,
      amount: shares.totalToPay,
      platform_fee: shares.platformFee,
      doctor_amount: shares.doctorAmount,
      status: 'pending',
      cinetpay_transaction_id: transactionId,
      payment_method: 'cinetpay',
      specialty,
      date,
      motif,
      duration_minutes: duration_minutes || 60
    });

    res.json({
      paymentUrl,
      transactionId
    });
  } catch (error) {
    console.error('Erreur initiatePayment:', error);
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};
