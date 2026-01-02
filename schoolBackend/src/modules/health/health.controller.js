const { success } = require("../../utils/response");

exports.healthCheck = (req, res) => {
  success(res, { status: "OK" }, "Backend is running");
};
