const express = require("express");
const app = express();
const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Test server running on port ${PORT}`);
});
setTimeout(() => {
    console.log("Shutting down test server");
    process.exit(0);
}, 5000);
