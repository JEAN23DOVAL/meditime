const multer = require('multer');
const path = require('path');
const fs = require('fs');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // On suppose que tu envoies patient_id dans le formData
    const userId = req.body.patient_id || 'unknown';
    const baseDir = path.join(__dirname, '../uploads/consultations', userId.toString());
    // Crée le dossier s'il n'existe pas
    fs.mkdirSync(baseDir, { recursive: true });
    cb(null, baseDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + '-' + file.originalname);
  }
});

const allowedFiles = ['.jpg', '.jpeg', '.png', '.pdf'];
const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();
  if (allowedFiles.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error('Type de fichier non autorisé'));
  }
};

const upload = multer({ storage, fileFilter, limits: { fileSize: 10 * 1024 * 1024 } });

module.exports = upload.array('attachments', 10); // max 10 fichiers