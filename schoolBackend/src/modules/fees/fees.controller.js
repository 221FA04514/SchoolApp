const { success, error } = require("../../utils/response");
const {
  getFeeSummary,
  getFeePayments,
  recordFeePayment,
} = require("./fees.service");

/**
 * Student fee summary
 */
exports.getMyFees = async (req, res, next) => {
  try {
    const { role, userId } = req.user;

    if (role !== "student") {
      return error(res, "Access denied", 403);
    }

    const summary = await getFeeSummary(userId);
    const payments = await getFeePayments(userId);

    return success(
      res,
      { summary, payments },
      "Fees data fetched"
    );
  } catch (err) {
    next(err);
  }
};

/**
 * Admin/Teacher records fee payment
 */
exports.recordPayment = async (req, res, next) => {
  try {
    const { role } = req.user;
    const { student_id, amount_paid, payment_date, payment_mode } = req.body;

    if (role !== "admin" && role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    if (!student_id || !amount_paid || !payment_date || !payment_mode) {
      return error(res, "All fields are required", 400);
    }

    await recordFeePayment({
      student_id,
      amount_paid,
      payment_date,
      payment_mode,
    });

    return success(res, null, "Fee payment recorded successfully");
  } catch (err) {
    next(err);
  }
};

/**
 * Student pays fees online (Mock)
 */
exports.payOnline = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { amount_paid, payment_mode } = req.body;

    if (role !== "student") {
      return error(res, "Access denied. Only students can pay online.", 403);
    }

    if (!amount_paid || amount_paid <= 0) {
      return error(res, "Invalid amount", 400);
    }

    // 1. Check due amount
    const summary = await getFeeSummary(userId);
    if (amount_paid > summary.due) {
      return error(res, `Amount exceeds due fees (₹${summary.due})`, 400);
    }

    // 2. Record payment
    await recordFeePayment({
      student_id: userId,
      amount_paid,
      payment_date: new Date(),
      payment_mode: payment_mode || "Online",
    });

    return success(res, null, "Payment successful (Mock)");
  } catch (err) {
    next(err);
  }
};

