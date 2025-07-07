const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('./cloudinary');

const storage = new CloudinaryStorage({
  cloudinary,
  params: async (req, file) => ({
    folder: 'meditime_uploads',
    resource_type: 'auto',
    public_id: `${Date.now()}-${file.originalname}`,
  }),
});

module.exports = storage;