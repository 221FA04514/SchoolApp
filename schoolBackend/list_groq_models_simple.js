const Groq = require("groq-sdk");
require('dotenv').config();

console.log("--- GROQ MODEL DISCOVERY ---");
async function run() {
    const key = process.env.GROQ_API_KEY;
    console.log("Key present:", !!key);
    if (!key) return;

    const groq = new Groq({ apiKey: key });
    try {
        console.log("Calling groq.models.list()...");
        const list = await groq.models.list();
        console.log("Models found:", list.data.length);
        list.data.forEach(m => {
            console.log(`- ${m.id}`);
        });
    } catch (e) {
        console.error("Error:", e.message);
    }
    console.log("--- END ---");
}
run();
