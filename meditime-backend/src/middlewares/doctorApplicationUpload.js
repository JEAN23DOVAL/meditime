const multer = require('multer');
const path = require('path');
const fs = require('fs');

const uploadDir = path.join(__dirname, '../uploads/doctor_application');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, `${file.fieldname}-${uniqueSuffix}${path.extname(file.originalname)}`);
  }
});

const fileFilter = (req, file, cb) => {
  const allowedImage = ['.jpeg', '.jpg', '.png', '.webp', '.bmp', '.gif', '.tiff', '.heic'];
  const allowedPdf = ['.pdf'];
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