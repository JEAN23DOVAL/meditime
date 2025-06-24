function formatPhotoUrl(photo, req, folder = 'photo_profil') {
  if (!photo) return null;
  if (photo.startsWith('http') || photo.startsWith('/uploads/')) return photo;
  // Si req n'est pas fourni, fallback sur process.env.BASE_URL
  let baseUrl;
  if (req && req.protocol && req.get) {
    baseUrl = `${req.protocol}://${req.get('host')}`;
  } else if (process.env.BASE_URL) {
    baseUrl = process.env.BASE_URL;
  } else {
    baseUrl = 'http://localhost:3000';
  }
  return `${baseUrl}/uploads/${folder}/${photo}`;
}

module.exports = formatPhotoUrl;