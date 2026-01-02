const express = require("express");
const cors = require("cors");
const errorHandler = require("./middlewares/error.middleware");

const app = express();

/* ---------- GLOBAL MIDDLEWARES ---------- */

// Allow cross-origin requests (Flutter app, Postman, etc.)
app.use(cors());

// Parse incoming JSON requests
app.use(express.json());

app.use(
  "/api/v1/announcements",
  require("./modules/announcements/announcements.routes")
);
app.use(
  "/api/v1/attendance",
  require("./modules/attendance/attendance.routes")
);

app.use(
  "/api/v1/fees",
  require("./modules/fees/fees.routes")
);
app.use(
  "/api/v1/messages",
  require("./modules/messages/messages.routes")
);
app.use(
  "/api/v1/results",
  require("./modules/results/results.routes")
);


/* ---------- ROUTES ---------- */

// Authentication routes (login, profile, etc.)
app.use("/api/v1/auth", require("./modules/auth/auth.routes"));
app.use("/api/v1/dashboard", require("./modules/dashboard/dashboard.routes"));


// Health check (already created in Phase 0)
app.use("/api/v1/health", require("./modules/health/health.routes"));

/* ---------- ERROR HANDLER (MUST BE LAST) ---------- */

// Global error handler
app.use(errorHandler);

module.exports = app;
