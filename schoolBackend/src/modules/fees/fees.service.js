const pool = require("../../config/db");

/**
 * Get fee summary for student
 */
exports.getFeeSummary = async (student_id) => {
  const [feeRows] = await pool.query(
    `
    SELECT total_amount
    FROM fees
    WHERE student_id = ?
    `,
    [student_id]
  );
  const fee = feeRows[0];

  const [payments] = await pool.query(
    `
    SELECT COALESCE(SUM(amount_paid), 0) AS paid
    FROM fee_payments
    WHERE student_id = ?
    `,
    [student_id]
  );

  const total = fee ? Number(fee.total_amount) : 0;
  const paid = (payments && payments.length > 0) ? Number(payments[0].paid) : 0;
  const due = total - paid;

  return { total, paid, due };
};

/**
 * Get fee payment history
 */
exports.getFeePayments = async (student_id) => {
  const [rows] = await pool.query(
    `
    SELECT amount_paid, payment_date, payment_mode
    FROM fee_payments
    WHERE student_id = ?
    ORDER BY payment_date DESC
    `,
    [student_id]
  );

  // 🔹 Convert DECIMAL (string) → Number for frontend
  return rows.map((r) => ({
    amount_paid: Number(r.amount_paid),
    payment_date: r.payment_date,
    payment_mode: r.payment_mode,
  }));
};

/**
 * Record fee payment (Admin/Teacher)
 */
exports.recordFeePayment = async ({
  student_id,
  amount_paid,
  payment_date,
  payment_mode,
}) => {
  await pool.query(
    `
    INSERT INTO fee_payments
      (student_id, amount_paid, payment_date, payment_mode)
    VALUES (?, ?, ?, ?)
    `,
    [student_id, amount_paid, payment_date, payment_mode.toLowerCase()]
  );
};
