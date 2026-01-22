require('dotenv').config();
const Groq = require("groq-sdk");

async function listModels() {
    console.log("Fetching models started...");
    const groqKey = process.env.GROQ_API_KEY;
    console.log("Using API Key:", groqKey ? groqKey.substring(0, 10) + "..." : "MISSING");

    const groq = new Groq({ apiKey: groqKey });
    try {
        const response = await groq.models.list();
        console.log("Models list response received.");
        if (response && response.data) {
            console.log("Found " + response.data.length + " models.");
            response.data.forEach(m => {
                if (m.id.includes("vision") || m.id.includes("llama-3.2")) {
                    console.log(`[MATCH] - ${m.id}`);
                } else {
                    console.log(`- ${m.id}`);
                }
            });
        } else {
            console.log("No data found in response:", JSON.stringify(response));
        }
    } catch (err) {
        console.error("Error listing models:", err.message);
    }
    console.log("Fetching models finished.");
}

listModels();
