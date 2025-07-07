const multer = require('multer');
const storage = require('../utils/cloudinaryStorage');

const fileFilter = (req, file, cb) => {
  const allowedExts = ['.jpeg', '.jpg', '.png', '.webp', '.bmp', '.gif', '.tiff', '.heic'];
  const ext = require('path').extname(file.originalname).toLowerCase();
  if (allowedExts.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error('Type de fichier non autorisé. Formats acceptés : jpeg, jpg, png, webp, bmp, gif, tiff, heic.'));
  }
};

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter
});

module.exports = upload;