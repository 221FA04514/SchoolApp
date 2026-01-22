const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const resourceController = require("./resources.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

// Configure Storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const dir = "uploads/resources";
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
        cb(null, dir);
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`);
    }
});

const upload = multer({ storage });

router.post("/upload", authMiddleware, upload.single("file"), resourceController.uploadResource);
router.get("/", authMiddleware, resourceController.getResources);
router.delete("/:id", authMiddleware, resourceController.deleteResource);

module.exports = router;
