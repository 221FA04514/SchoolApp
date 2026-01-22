const Groq = require("groq-sdk");
const { GoogleGenerativeAI } = require("@google/generative-ai");
require('dotenv').config();
const fs = require('fs');

async function run() {
    let output = "--- GROQ MODELS ---\n";
    const groqKey = process.env.GROQ_API_KEY;
    if (groqKey) {
        const groq = new Groq({ apiKey: groqKey });
        try {
            const list = await groq.models.list();
            output += list.data.map(m => m.id).join('\n') + "\n";
        } catch (e) {
            output += "GROQ ERROR: " + e.message + "\n";
        }
    } else {
        output += "GROQ_API_KEY missing\n";
    }

    output += "\n--- GEMINI MODELS ---\n";
    const geminiKey = process.env.GEMINI_API_KEY;
    if (geminiKey) {
        const genAI = new GoogleGenerativeAI(geminiKey);
        try {
            // We can't easily list models with the default GenAI object in some versions 
            // but we can try to use the model object
            const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
            output += "Gemini SDK initialized. Attempting to list via discovery...\n";
            // Newer SDKs might have a way, but let's just try to generate a tiny response to test
            const result = await model.generateContent("hi");
            output += "gemini-1.5-flash: WORKING\n";
        } catch (e) {
            output += "gemini-1.5-flash ERROR: " + e.message + "\n";
        }
    } else {
        output += "GEMINI_API_KEY missing\n";
    }

    fs.writeFileSync('all_models_discovery.txt', output);
    console.log("Discovery results written to all_models_discovery.txt");
}

run();
