const multer = require('multer');
const path = require('path');
const fs = require('fs');

// 📁 Créer le dossier si nécessaire
const uploadDir = path.join(__dirname, '../uploads/photo_profil');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// 🎯 Configuration du stockage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, `${uniqueSuffix}${ext}`);
  }
});

// 🛡️ Filtre pour types d'images autorisés
const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();
  const mime = file.mimetype.toLowerCase();
  console.log('Extension:', ext, 'Mimetype:', mime);

  const allowedExts = ['.jpeg', '.jpg', '.png', '.webp', '.bmp', '.gif', '.tiff', '.heic'];
  const allowedMimes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'image/bmp',
    'image/gif',
    'image/tiff',
    'image/heic',
    'application/octet-stream' // optionnel, voir plus bas
  ];

  if (allowedExts.includes(ext) && allowedMimes.includes(mime)) {
    cb(null, true);
  } else {
    cb(new Error('Type de fichier non autorisé. Formats acceptés : jpeg, jpg, png, webp, bmp, gif, tiff, heic.'));
  }
};

// 📦 Configuration de multer
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Limite : 5MB
  fileFilter
});

module.exports = upload;