require('dotenv').config();
const Groq = require("groq-sdk");

async function testGroq() {
    const key = process.env.GROQ_API_KEY;
    if (!key || key === "YOUR_GROQ_API_KEY") {
        console.error("❌ No Groq API key found in .env (GROQ_API_KEY)");
        return;
    }

    console.log(`Connecting to Groq with key ending in: ...${key.slice(-5)}`);
    const groq = new Groq({ apiKey: key });

    try {
        const chatCompletion = await groq.chat.completions.create({
            messages: [
                {
                    role: "user",
                    content: "Hello, are you working?",
                },
            ],
            model: 'llama-3.3-70b-versatile',
        });

        console.log("✅ SUCCESS! Groq Response:", chatCompletion.choices[0]?.message?.content);
    } catch (err) {
        console.error("❌ FAILED!");
        console.error("Error Message:", err.message);
    }
}

testGroq();
