const { Doctor, User, DoctorSlot } = require('../models');
const { Op, fn, col, where } = require('sequelize');

async function searchDoctors({
  search,
  specialty,
  city,
  available,
  minPrice,
  maxPrice,
  gender,
  sortBy,
  order = 'ASC'
}) {
  const doctorWhere = {};
  const userWhere = { role: 'doctor' };

  // if (specialty) doctorWhere.specialite = specialty;
  if (minPrice) doctorWhere.pricePerHour = { [Op.gte]: minPrice };
  if (maxPrice) doctorWhere.pricePerHour = { ...(doctorWhere.pricePerHour || {}), [Op.lte]: maxPrice };
  if (gender) userWhere.gender = gender;
  // if (city) userWhere.city = city;

  if (search) {
    doctorWhere[Op.or] = [
      where(fn('LOWER', col('Doctor.specialite')), Op.like, `%${search.toLowerCase()}%`),
      where(fn('LOWER', col('user.lastName')), Op.like, `%${search.toLowerCase()}%`),
      where(fn('LOWER', col('user.firstName')), Op.like, `%${search.toLowerCase()}%`),
      where(fn('LOWER', col('user.city')), Op.like, `%${search.toLowerCase()}%`)
    ];
  }

  const include = [
    {
      model: User,
      as: 'user',
      where: userWhere,
      attributes: { exclude: ['password'] }
    }
  ];

  if (available === 'true' || available === true) {
    include.push({
      model: DoctorSlot,
      as: 'slots',
      where: { status: 'active' },
      required: true
    });
  }

  let orderArr = [];
  if (sortBy === 'price') orderArr = [['pricePerHour', order]];
  else if (sortBy === 'note') orderArr = [['note', order]];
  else orderArr = [['created_at', 'DESC']];

  return Doctor.findAll({
    where: doctorWhere,
    include,
    order: orderArr,
    distinct: true,
    subQuery: false
  });
}

module.exports = { searchDoctors };