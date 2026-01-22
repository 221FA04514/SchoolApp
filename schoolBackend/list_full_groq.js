const Groq = require("groq-sdk");
require('dotenv').config();
const fs = require('fs');

async function run() {
    const key = process.env.GROQ_API_KEY;
    if (!key) return;
    const groq = new Groq({ apiKey: key });
    try {
        const list = await groq.models.list();
        fs.writeFileSync('groq_models_full.json', JSON.stringify(list, null, 2));
    } catch (e) {
        fs.writeFileSync('groq_error.txt', e.message);
    }
}
run();
