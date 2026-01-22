const Groq = require("groq-sdk");
require('dotenv').config();
const fs = require('fs');

async function run() {
    const key = process.env.GROQ_API_KEY;
    const groq = new Groq({ apiKey: key });
    try {
        const list = await groq.models.list();
        const visionModels = list.data.filter(m => m.id.includes("vision") || m.id.includes("llama-4") || m.id.includes("pixtral"));
        fs.writeFileSync('vision_candidates.txt', visionModels.map(m => m.id).join('\n'));
    } catch (e) {
        fs.writeFileSync('vision_candidates.txt', "ERROR: " + e.message);
    }
}
run();
