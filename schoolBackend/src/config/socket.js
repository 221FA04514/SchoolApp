const { Server } = require("socket.io");

let io;

const initSocket = (server) => {
    io = new Server(server, {
        cors: {
            origin: "*", // Allow Flutter apps/web clients
            methods: ["GET", "POST"]
        }
    });

    io.on("connection", (socket) => {
        console.log(`[SOCKET] User connected: ${socket.id}`);

        // Join a private room based on userId (for targeted notifications)
        socket.on("join", (userId) => {
            socket.join(`user_${userId}`);
            console.log(`[SOCKET] User ${userId} joined their private room.`);
        });

        socket.on("disconnect", () => {
            console.log(`[SOCKET] User disconnected: ${socket.id}`);
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
