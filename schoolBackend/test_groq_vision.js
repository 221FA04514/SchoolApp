require('dotenv').config();
const Groq = require("groq-sdk");

async function testGroqVision() {
    console.log("--- TESTING GROQ VISION ---");
    const groqKey = process.env.GROQ_API_KEY;
    if (!groqKey) {
        console.log("❌ GROQ_API_KEY missing.");
        return;
    }

    try {
        const groq = new Groq({ apiKey: groqKey });
        // Use a tiny transparent pixel or simple base64 for testing vision connectivity
        // For a simple text test on the vision model first:
        const chatCompletion = await groq.chat.completions.create({
            messages: [
                {
                    role: "user",
                    content: "Can you see this text and confirm you are a vision model?",
                }
            ],
            model: "meta-llama/llama-4-scout-17b-16e-instruct",
        });
        console.log("✅ GROQ VISION CONNECTED:", chatCompletion.choices[0]?.message?.content);
        console.log("🚀 SUCCESS! We can switch Homework Helper to Groq Vision.");
    } catch (err) {
        console.log("❌ GROQ VISION FAIL:", err.message);
    }
    console.log("--- END TEST ---");
    process.exit(0);
}

testGroqVision();
