require('dotenv').config();
const { GoogleGenerativeAI } = require("@google/generative-ai");

async function testKey() {
    const key = process.env.GEMINI_API_KEY;
    if (!key || key === "YOUR_GEMINI_API_KEY") {
        console.error("❌ No API key found in .env (GEMINI_API_KEY)");
        return;
    }

    console.log(`Connecting with key ending in: ...${key.slice(-5)}`);
    const genAI = new GoogleGenerativeAI(key);

    const modelsToTest = ["gemini-1.5-flash", "gemini-1.5-flash-latest", "gemini-pro"];

    for (const modelName of modelsToTest) {
        console.log(`--- Testing model: ${modelName} ---`);
        try {
            const model = genAI.getGenerativeModel({ model: modelName });
            const result = await model.generateContent("Hello, are you working?");
            const response = await result.response;
            console.log(`✅ ${modelName} SUCCESS:`, response.text().substring(0, 50) + "...");
            console.log("🚀 RECOMMENDATION: Use this model name in ai.service.js");
            return;
        } catch (err) {
            console.error(`❌ ${modelName} FAILED:`, err.message);
        }
    }

    console.log("\n💡 ALL MODELS FAILED. This usually means the API key is not active yet or restricted.");
}

testKey();
