const express = require("express");
const cors = require("cors");
const errorHandler = require("./middlewares/error.middleware");

const app = express();

/* ---------- GLOBAL MIDDLEWARES ---------- */

// Allow cross-origin requests (Flutter app, Postman, etc.)
app.use(cors());

// Parse incoming JSON requests (Increased limit for AI images)
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Serve uploaded files
app.use("/uploads", express.static("uploads"));

// Request logger for debugging
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

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
app.use("/api/v1/sections", require("./modules/sections/sections.routes"));

app.use("/api/v1/homework", require("./modules/homework/homework.routes"));

app.use("/api/v1/timetable", require("./modules/timetable/timetable.routes"));
app.use("/api/v1/admin", require("./modules/admin/admin.routes"));

/* ---------- ROUTES ---------- */

// Authentication routes (login, profile, etc.)
app.use("/api/v1/auth", require("./modules/auth/auth.routes"));
app.use("/api/v1/dashboard", require("./modules/dashboard/dashboard.routes"));
app.use("/api/v1/notifications", require("./modules/notifications/notifications.routes"));
app.use("/api/v1/ai", require("./modules/ai/ai.routes"));
app.use("/api/v1/resources", require("./modules/resources/resources.routes"));
app.use("/api/v1/quizzes", require("./modules/quizzes/quizzes.routes"));
app.use("/api/v1/online-exams", require("./modules/online_exams/online_exams.routes"));
app.use("/api/v1/leaves", require("./modules/leaves/leaves.routes"));

// Health check (already created in Phase 0)
app.use("/api/v1/health", require("./modules/health/health.routes"));

/* ---------- ERROR HANDLER (MUST BE LAST) ---------- */

// Global error handler
app.use(errorHandler);

module.exports = app;
