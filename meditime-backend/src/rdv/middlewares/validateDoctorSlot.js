const { body, validationResult } = require('express-validator');

function compareSlots(startDay, startHour, startMinute, endDay, endHour, endMinute) {
  // startDay et endDay sont des dates au format YYYY-MM-DD
  const start = new Date(`${startDay}T${String(startHour).padStart(2, '0')}:${String(startMinute).padStart(2, '0')}:00`);
  const end = new Date(`${endDay}T${String(endHour).padStart(2, '0')}:${String(endMinute).padStart(2, '0')}:00`);
  return start < end;
}

const validateDoctorSlot = [
  body('doctorId').isInt().withMessage('doctorId requis'),
  body('startDay').isString().notEmpty(),
  body('startHour').isInt({ min: 0, max: 23 }),
  body('startMinute').isInt({ min: 0, max: 59 }),
  body('endDay').isString().notEmpty(),
  body('endHour').isInt({ min: 0, max: 23 }),
  body('endMinute').isInt({ min: 0, max: 59 }),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }
    const { startDay, startHour, startMinute, endDay, endHour, endMinute } = req.body;
    if (!compareSlots(startDay, startHour, startMinute, endDay, endHour, endMinute)) {
      return res.status(400).json({ message: 'Le créneau est invalide (début doit précéder la fin)' });
    }
    next();
  }
];

module.exports = validateDoctorSlot;