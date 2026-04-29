const aws = require('aws-sdk');
const multer = require('multer');
const multerS3 = require('multer-s3');
const fs = require('fs');
const path = require('path');

// Configure AWS only if credentials exist
if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
    aws.config.update({
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        region: process.env.AWS_REGION || 'us-east-1'
    });
}

const s3 = new aws.S3();

const uploadToS3 = (folder) => {
    // FALLBACK: Use Local Storage if S3 bucket is not configured
    if (!process.env.AWS_S3_BUCKET || !process.env.AWS_ACCESS_KEY_ID) {
        console.log(`[Storage] Cloud bucket not configured. Using local storage for "${folder}"`);
        
        const storage = multer.diskStorage({
            destination: (req, file, cb) => {
                const uploadPath = path.join(__dirname, '../../uploads', folder);
                // Ensure directory exists
                if (!fs.existsSync(uploadPath)) {
                    fs.mkdirSync(uploadPath, { recursive: true });
                }
                cb(null, uploadPath);
            },
            filename: (req, file, cb) => {
                const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
                cb(null, uniqueSuffix + '-' + file.originalname);
            }
        });

        return multer({ 
            storage: storage,
            limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
        });
    }

    // PRODUCTION: Use AWS S3
    return multer({
        storage: multerS3({
            s3: s3,
            bucket: process.env.AWS_S3_BUCKET,
            acl: 'public-read',
            metadata: function (req, file, cb) {
                cb(null, { fieldName: file.fieldname });
            },
            key: function (req, file, cb) {
                cb(null, `${folder}/${Date.now().toString()}-${file.originalname}`);
            }
        })
    });
};

module.exports = { uploadToS3, s3 };
