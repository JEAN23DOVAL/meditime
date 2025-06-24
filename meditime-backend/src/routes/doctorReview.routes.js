const express = require('express');
const router = express.Router();
const doctorReviewController = require('../controllers/doctorReview.controller');
const auth = require('../middlewares/authMiddleware');

router.post('/', auth, doctorReviewController.createReview);
router.get('/doctor/:doctor_id', doctorReviewController.getReviewsByDoctor);

module.exports = router;