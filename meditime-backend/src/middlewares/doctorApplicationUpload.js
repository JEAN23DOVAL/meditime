const multer = require('multer');
const storage = require('../utils/cloudinaryStorage');
const path = require('path');

const allowedImage = ['.jpeg', '.jpg', '.png', '.webp', '.bmp', '.gif', '.tiff', '.heic'];
const allowedPdf = ['.pdf'];

const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();
  if (
    (['cniFront', 'cniBack', 'certification'].includes(file.fieldname) && allowedImage.includes(ext)) ||
    (['cvPdf', 'casierJudiciaire'].includes(file.fieldname) && allowedPdf.includes(ext))
  ) {
    cb(null, true);
  } else {
    cb(new Error('Type de fichier non autorisé'));
  }
};

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter
});

module.exports = upload.fields([
  { name: 'cniFront', maxCount: 1 },
  { name: 'cniBack', maxCount: 1 },
  { name: 'certification', maxCount: 1 },
  { name: 'cvPdf', maxCount: 1 },
  { name: 'casierJudiciaire', maxCount: 1 }
]);