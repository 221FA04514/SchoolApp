const Groq = require("groq-sdk");
require('dotenv').config();

async function run() {
    console.log("Starting model list...");
    const key = process.env.GROQ_API_KEY;
    console.log("Key first 5 chars:", key ? key.substring(0, 5) : "NONE");

    const groq = new Groq({ apiKey: key });
    try {
        const list = await groq.models.list();
        console.log("API CALL SUCCESS");
        console.log(JSON.stringify(list, null, 2));
    } catch (e) {
        console.log("API CALL FAILED");
        console.error("Error Name:", e.name);
        console.error("Error Message:", e.message);
        if (e.response) {
            console.error("Response data:", JSON.stringify(e.response.data, null, 2));
            console.error("Response status:", e.response.status);
        }
    }
    console.log("Finished.");
}

run();
