// utils/paymentCalculation.js

/**
 * Calcule la part plateforme, la part médecin et les frais CinetPay selon le barème fourni.
 * @param {number} price - Prix de la consultation (XAF)
 * @returns {object} - { platformFee, doctorAmount, cinetpayFee, totalToPay }
 */
function calculatePaymentShares(price) {
  // Barème plateforme
  let platformFee = 0;
  if (price <= 10000) {
    platformFee = 1000;
  } else if (price <= 20000) {
    platformFee = price * 0.10;
  } else if (price <= 50000) {
    platformFee = price * 0.08;
  } else {
    platformFee = price * 0.05;
  }
  platformFee = Math.round(platformFee);

  // Part médecin (avant frais CinetPay)
  let doctorAmount = price - platformFee;

  // Frais CinetPay (exemple : 2% + 100 XAF)
  const cinetpayFee = Math.round(doctorAmount * 0.02 + 100);

  // Part médecin finale
  const doctorNet = doctorAmount - cinetpayFee;

  // Total à payer par le patient (plateforme + médecin)
  const totalToPay = price;

  return {
    platformFee,
    doctorAmount,
    cinetpayFee,
    doctorNet,
    totalToPay
  };
}

module.exports = { calculatePaymentShares };
