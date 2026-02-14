const { Server } = require("socket.io");

let io;

const initSocket = (server) => {
    io = new Server(server, {
        cors: {
            origin: "*", // Allow Flutter apps/web clients
            methods: ["GET", "POST"]
        }
    });

    io.use((socket, next) => {
        const token = socket.handshake.headers.token || socket.handshake.auth.token;
        if (!token) {
            return next(new Error("Authentication error"));
        }
        try {
            const jwt = require("jsonwebtoken");
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            socket.user = decoded;
            next();
        } catch (err) {
            next(new Error("Authentication error"));
        }
    });

    io.on("connection", (socket) => {
        if (!socket.user) return; // Should not happen due to middleware

        console.log(`[SOCKET] User connected: ${socket.user.userId}`);

        // Auto-join private room
        socket.join(`user_${socket.user.userId}`);
        console.log(`[SOCKET] User ${socket.user.userId} auto-joined room user_${socket.user.userId}`);

        socket.on("disconnect", () => {
            console.log(`[SOCKET] User disconnected: ${socket.user.userId}`);
        });
    });

    return io;
};

const getIO = () => {
    if (!io) {
        throw new Error("Socket.io not initialized!");
    }
    return io;
};

/**
 * Send a notification to a specific user via Socket.io
 */
const sendNotification = (userId, data) => {
    if (io) {
        io.to(`user_${userId}`).emit("notification", data);
        console.log(`[SOCKET] Notification sent to user_${userId}`);
    }
};

/**
 * Broadcast a message to a section
 */
const broadcastToSection = (sectionId, event, data) => {
    if (io) {
        // Concept: Everyone in section X joins room `section_X`
        io.to(`section_${sectionId}`).emit(event, data);
    }
};

module.exports = { initSocket, getIO, sendNotification, broadcastToSection };
