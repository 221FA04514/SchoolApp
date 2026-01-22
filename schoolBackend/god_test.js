const Groq = require("groq-sdk");
const { GoogleGenerativeAI } = require("@google/generative-ai");
require('dotenv').config();
const fs = require('fs');

async function testGroq() {
    console.log("Starting Groq Test...");
    let res = "--- GROQ TEST ---\n";
    const groqKey = process.env.GROQ_API_KEY;
    if (!groqKey) return res + "GROQ_API_KEY missing\n";

    const groq = new Groq({ apiKey: groqKey });
    const models = ["llama-3.2-11b-vision", "llama-3.2-90b-vision", "llama-3.3-70b-versatile", "llama-3.1-8b-instant"];

    for (const m of models) {
        console.log(`Testing Groq model: ${m}`);
        try {
            await groq.chat.completions.create({
                messages: [{ role: "user", content: "hi" }],
                model: m,
                max_tokens: 5
            });
            console.log(`Groq model ${m}: OK`);
            res += `${m}: OK\n`;
        } catch (e) {
            console.log(`Groq model ${m}: FAIL (${e.message})`);
            res += `${m}: FAIL (${e.message})\n`;
        }
    }
    return res;
}

async function testGemini() {
    console.log("Starting Gemini Test...");
    let res = "\n--- GEMINI TEST ---\n";
    const geminiKey = process.env.GEMINI_API_KEY;
    if (!geminiKey) return res + "GEMINI_API_KEY missing\n";

    const genAI = new GoogleGenerativeAI(geminiKey);
    // Standard names for 2025
    const models = ["gemini-1.5-flash", "gemini-1.5-pro", "gemini-2.0-flash", "gemini-2.0-flash-exp"];

    for (const m of models) {
        console.log(`Testing Gemini model: ${m}`);
        try {
            const model = genAI.getGenerativeModel({ model: m });
            const result = await model.generateContent("hi");
            await result.response;
            console.log(`Gemini model ${m}: OK`);
            res += `${m}: OK\n`;
        } catch (e) {
            console.log(`Gemini model ${m}: FAIL (${e.message})`);
            res += `${m}: FAIL (${e.message})\n`;
        }
    }
    return res;
}

async function run() {
    console.log("Discovery Script Started");
    let final = "";
    try {
        final += await testGroq();
    } catch (e) { console.error("Groq Test Error:", e); }

    try {
        final += await testGemini();
    } catch (e) { console.error("Gemini Test Error:", e); }

    console.log("Writing results to final_discovery_results.txt");
    fs.writeFileSync('final_discovery_results.txt', final);
    console.log("Finished.");
}

run();
