const { User, Rdv, Consultation, DoctorReview, DoctorApplication, Message } = require('../../models');
const { Op, fn, col, literal } = require('sequelize');
const { emitToAdmins } = require('../../utils/wsEmitter');
const { Parser } = require('json2csv');
const PDFDocument = require('pdfkit');
const stream = require('stream');

// Helper pour générer la période
function getDateRange(period, nb = 30) {
  const now = new Date();
  let start;
  if (period === 'day') {
    start = new Date(now);
    start.setDate(now.getDate() - nb + 1);
  } else if (period === 'week') {
    start = new Date(now);
    start.setDate(now.getDate() - nb * 7 + 1);
  } else if (period === 'month') {
    start = new Date(now);
    start.setMonth(now.getMonth() - nb + 1);
  }
  return { start, end: now };
}

exports.getStats = async (req, res) => {
  try {
    // Période (day/week/month)
    const period = req.query.period || 'day';
    const nb = parseInt(req.query.nb, 10) || 30;
    const { start, end } = getDateRange(period, nb);

    // Format date selon la période
    let dateFormat;
    if (period === 'day') dateFormat = '%Y-%m-%d';
    else if (period === 'week') dateFormat = '%Y-%u'; // année-semaine
    else dateFormat = '%Y-%m';

    // Inscriptions par rôle
    const registrations = await User.findAll({
      attributes: [
        [fn('DATE_FORMAT', col('createdAt'), dateFormat), 'period'],
        'role',
        [fn('COUNT', col('idUser')), 'count']
      ],
      where: { createdAt: { [Op.between]: [start, end] } },
      group: ['period', 'role'],
      raw: true
    });

    // RDV créés
    const rdvs = await Rdv.findAll({
      attributes: [
        [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
        [fn('COUNT', col('id')), 'count']
      ],
      where: { created_at: { [Op.between]: [start, end] } },
      group: ['period'],
      raw: true
    });

    // Consultations réalisées
    const consultations = await Consultation.findAll({
      attributes: [
        [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
        [fn('COUNT', col('id')), 'count']
      ],
      where: { created_at: { [Op.between]: [start, end] } },
      group: ['period'],
      raw: true
    });

    // Avis déposés
    const reviews = await DoctorReview.findAll({
      attributes: [
        [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
        [fn('COUNT', col('id')), 'count']
      ],
      where: { created_at: { [Op.between]: [start, end] } },
      group: ['period'],
      raw: true
    });

    // Demandes médecin
    const doctorApplications = await DoctorApplication.findAll({
      attributes: [
        [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
        [fn('COUNT', col('id')), 'count']
      ],
      where: { created_at: { [Op.between]: [start, end] } },
      group: ['period'],
      raw: true
    });

    // Messages envoyés
    const messages = await Message.findAll({
      attributes: [
        [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
        [fn('COUNT', col('id')), 'count']
      ],
      where: { created_at: { [Op.between]: [start, end] } },
      group: ['period'],
      raw: true
    });

    // RDV par statut
    const rdvStatusStats = await Rdv.findAll({
      attributes: [
        [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
        'status',
        [fn('COUNT', col('id')), 'count']
      ],
      where: { created_at: { [Op.between]: [start, end] } },
      group: ['period', 'status'],
      raw: true
    });

    // Demandes médecin par statut
    const doctorApplicationsStatus = await DoctorApplication.findAll({
      attributes: [
        [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
        'status',
        [fn('COUNT', col('id')), 'count']
      ],
      where: { created_at: { [Op.between]: [start, end] } },
      group: ['period', 'status'],
      raw: true
    });

    // Médecins actifs (ayant eu au moins 1 RDV sur la période)
    const activeDoctors = await Rdv.count({
      where: {
        created_at: { [Op.between]: [start, end] }
      },
      distinct: true,
      col: 'doctor_id'
    });

    // Taux de no-show et d’annulation sur les RDV
    const totalRdvs = await Rdv.count({
      where: { created_at: { [Op.between]: [start, end] } }
    });
    const noShowCount = await Rdv.count({
      where: {
        created_at: { [Op.between]: [start, end] },
        status: { [Op.in]: ['no_show', 'doctor_no_show'] }
      }
    });
    const cancelledCount = await Rdv.count({
      where: {
        created_at: { [Op.between]: [start, end] },
        status: 'cancelled'
      }
    });
    const noShowRate = totalRdvs > 0 ? (noShowCount / totalRdvs) * 100 : 0;
    const cancellationRate = totalRdvs > 0 ? (cancelledCount / totalRdvs) * 100 : 0;

    const stats = {
      registrations,
      rdvs,
      consultations,
      reviews,
      doctorApplications,
      messages,
      rdvStatusStats,
      doctorApplicationsStatus,
      activeDoctors,
      noShowRate,
      cancellationRate
    };

    // Émettre l'événement aux admins
    emitToAdmins(req.app, 'stats_update', { stats });

    res.json(stats);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur', error: error.message });
  }
};

// Helper pour générer les stats (extrait du getStats pour réutilisation)
async function computeStats({ period, nb, start, end }) {
  // Période (day/week/month)
  period = period || 'day';
  nb = parseInt(nb, 10) || 30;
  let dateRange;
  if (start && end) {
    dateRange = { start: new Date(start), end: new Date(end) };
  } else {
    dateRange = getDateRange(period, nb);
  }
  start = dateRange.start;
  end = dateRange.end;

  let dateFormat;
  if (period === 'day') dateFormat = '%Y-%m-%d';
  else if (period === 'week') dateFormat = '%Y-%u';
  else dateFormat = '%Y-%m';

  const registrations = await User.findAll({
    attributes: [
      [fn('DATE_FORMAT', col('createdAt'), dateFormat), 'period'],
      'role',
      [fn('COUNT', col('idUser')), 'count']
    ],
    where: { createdAt: { [Op.between]: [start, end] } },
    group: ['period', 'role'],
    raw: true
  });

  const rdvs = await Rdv.findAll({
    attributes: [
      [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
      [fn('COUNT', col('id')), 'count']
    ],
    where: { created_at: { [Op.between]: [start, end] } },
    group: ['period'],
    raw: true
  });

  const consultations = await Consultation.findAll({
    attributes: [
      [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
      [fn('COUNT', col('id')), 'count']
    ],
    where: { created_at: { [Op.between]: [start, end] } },
    group: ['period'],
    raw: true
  });

  const reviews = await DoctorReview.findAll({
    attributes: [
      [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
      [fn('COUNT', col('id')), 'count']
    ],
    where: { created_at: { [Op.between]: [start, end] } },
    group: ['period'],
    raw: true
  });

  const doctorApplications = await DoctorApplication.findAll({
    attributes: [
      [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
      [fn('COUNT', col('id')), 'count']
    ],
    where: { created_at: { [Op.between]: [start, end] } },
    group: ['period'],
    raw: true
  });

  const messages = await Message.findAll({
    attributes: [
      [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
      [fn('COUNT', col('id')), 'count']
    ],
    where: { created_at: { [Op.between]: [start, end] } },
    group: ['period'],
    raw: true
  });

  const rdvStatusStats = await Rdv.findAll({
    attributes: [
      [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
      'status',
      [fn('COUNT', col('id')), 'count']
    ],
    where: { created_at: { [Op.between]: [start, end] } },
    group: ['period', 'status'],
    raw: true
  });

  const doctorApplicationsStatus = await DoctorApplication.findAll({
    attributes: [
      [fn('DATE_FORMAT', col('created_at'), dateFormat), 'period'],
      'status',
      [fn('COUNT', col('id')), 'count']
    ],
    where: { created_at: { [Op.between]: [start, end] } },
    group: ['period', 'status'],
    raw: true
  });

  const activeDoctors = await Rdv.count({
    where: {
      created_at: { [Op.between]: [start, end] }
    },
    distinct: true,
    col: 'doctor_id'
  });

  const totalRdvs = await Rdv.count({
    where: { created_at: { [Op.between]: [start, end] } }
  });
  const noShowCount = await Rdv.count({
    where: {
      created_at: { [Op.between]: [start, end] },
      status: { [Op.in]: ['no_show', 'doctor_no_show'] }
    }
  });
  const cancelledCount = await Rdv.count({
    where: {
      created_at: { [Op.between]: [start, end] },
      status: 'cancelled'
    }
  });
  const noShowRate = totalRdvs > 0 ? (noShowCount / totalRdvs) * 100 : 0;
  const cancellationRate = totalRdvs > 0 ? (cancelledCount / totalRdvs) * 100 : 0;

  return {
    registrations,
    rdvs,
    consultations,
    reviews,
    doctorApplications,
    messages,
    rdvStatusStats,
    doctorApplicationsStatus,
    activeDoctors,
    noShowRate,
    cancellationRate
  };
}

// --- EXPORT CSV ---
exports.exportStatsCsv = async (req, res) => {
  try {
    const { period, nb, start, end } = req.query;
    const stats = await computeStats({ period, nb, start, end });

    // On va exporter les RDVs et Consultations par période
    const fields = [
      { label: 'Période', value: 'period' },
      { label: 'RDV créés', value: 'rdvCount' },
      { label: 'Consultations', value: 'consultationCount' },
      { label: 'Avis', value: 'reviewCount' },
      { label: 'Demandes médecin', value: 'doctorApplicationCount' },
      { label: 'Messages', value: 'messageCount' }
    ];

    // Fusionne les stats par période
    const periods = Array.from(new Set([
      ...stats.rdvs.map(r => r.period),
      ...stats.consultations.map(r => r.period),
      ...stats.reviews.map(r => r.period),
      ...stats.doctorApplications.map(r => r.period),
      ...stats.messages.map(r => r.period)
    ])).sort();

    const data = periods.map(period => ({
      period,
      rdvCount: stats.rdvs.find(r => r.period === period)?.count || 0,
      consultationCount: stats.consultations.find(r => r.period === period)?.count || 0,
      reviewCount: stats.reviews.find(r => r.period === period)?.count || 0,
      doctorApplicationCount: stats.doctorApplications.find(r => r.period === period)?.count || 0,
      messageCount: stats.messages.find(r => r.period === period)?.count || 0
    }));

    const parser = new Parser({ fields });
    const csv = parser.parse(data);

    res.header('Content-Type', 'text/csv');
    res.attachment('stats.csv');
    return res.send(csv);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur export CSV', error: error.message });
  }
};

// --- EXPORT PDF ---
exports.exportStatsPdf = async (req, res) => {
  try {
    const { period, nb, start, end } = req.query;
    const stats = await computeStats({ period, nb, start, end });

    // Création du PDF
    const doc = new PDFDocument({ margin: 36, size: 'A4' });
    const passThrough = new stream.PassThrough();
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'attachment; filename=stats.pdf');
    doc.pipe(passThrough);

    doc.fontSize(20).text('Statistiques Méditime', { align: 'center' });
    doc.moveDown();
    doc.fontSize(12).text(`Période : ${period || 'day'} (${nb || 30})`, { align: 'left' });
    if (start && end) doc.text(`Du ${new Date(start).toLocaleDateString()} au ${new Date(end).toLocaleDateString()}`);

    doc.moveDown();

    // Tableau synthétique
    doc.fontSize(14).text('Synthèse par période', { underline: true });
    doc.moveDown(0.5);

    // Table header
    const tableHeaders = ['Période', 'RDV', 'Consultations', 'Avis', 'Demandes médecin', 'Messages'];
    const periods = Array.from(new Set([
      ...stats.rdvs.map(r => r.period),
      ...stats.consultations.map(r => r.period),
      ...stats.reviews.map(r => r.period),
      ...stats.doctorApplications.map(r => r.period),
      ...stats.messages.map(r => r.period)
    ])).sort();

    // Table rows
    doc.fontSize(10);
    doc.text(tableHeaders.join(' | '));
    doc.moveDown(0.2);
    periods.forEach(period => {
      doc.text([
        period,
        stats.rdvs.find(r => r.period === period)?.count || 0,
        stats.consultations.find(r => r.period === period)?.count || 0,
        stats.reviews.find(r => r.period === period)?.count || 0,
        stats.doctorApplications.find(r => r.period === period)?.count || 0,
        stats.messages.find(r => r.period === period)?.count || 0
      ].join(' | '));
    });

    doc.moveDown();

    // KPIs globaux
    doc.fontSize(12).text('KPIs globaux', { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(10).text(`Médecins actifs : ${stats.activeDoctors}`);
    doc.text(`Taux no-show : ${stats.noShowRate.toFixed(1)}%`);
    doc.text(`Taux annulation : ${stats.cancellationRate.toFixed(1)}%`);

    doc.end();
    passThrough.pipe(res);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur export PDF', error: error.message });
  }
};