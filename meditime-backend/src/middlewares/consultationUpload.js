const multer = require('multer');
const storage = require('../utils/cloudinaryStorage');

const allowedFiles = ['.jpg', '.jpeg', '.png', '.pdf'];
const fileFilter = (req, file, cb) => {
  const ext = require('path').extname(file.originalname).toLowerCase();
  if (allowedFiles.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error('Type de fichier non autorisé'));
  }
};

const upload = multer({ storage, fileFilter, limits: { fileSize: 10 * 1024 * 1024 } });

module.exports = upload.array('attachments', 10); // max 10 fichiers