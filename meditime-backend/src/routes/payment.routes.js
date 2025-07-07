const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment.controller');

// Callback CinetPay réel
router.post('/cinetpay-callback', paymentController.cinetpayCallback);

// Paiement réel
router.post('/initiate', paymentController.initiatePayment);

// --- Route de simulation locale ---
if (process.env.NODE_ENV !== 'production') {
  router.post('/simulate-success', async (req, res) => {
    const { transaction_id } = req.body;
    if (!transaction_id) return res.status(400).json({ message: 'transaction_id requis' });
    req.body.cpm_trans_status = 'success';
    req.body.cpm_payment_date = new Date().toISOString();
    const { cinetpayCallback } = require('../controllers/payment.controller');
    await cinetpayCallback(req, res);
  });
}

module.exports = router;
