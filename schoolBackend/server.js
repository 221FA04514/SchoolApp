require("dotenv").config();
const http = require("http");
const app = require("./src/app");
const { initSocket } = require("./src/config/socket");
const { updateFrontendIp } = require("./src/utils/ipManager");

// Auto-update frontend IP on startup
updateFrontendIp();

const PORT = process.env.PORT || 8080;
const server = http.createServer(app);

// Initialize Socket.io
initSocket(server);

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});
