const express = require("express");
const router = express.Router();
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const resourceController = require("./resources.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

const { uploadToS3 } = require("../../utils/s3_storage");

const upload = uploadToS3("resources");


router.post("/upload", authMiddleware, upload.single("file"), resourceController.uploadResource);
router.get("/", authMiddleware, resourceController.getResources);
router.delete("/:id", authMiddleware, resourceController.deleteResource);

module.exports = router;
