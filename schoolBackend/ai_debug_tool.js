require('dotenv').config();
const { GoogleGenerativeAI } = require("@google/generative-ai");
const Groq = require("groq-sdk");

async function diagnostic() {
    console.log("--- START DIAGNOSTIC ---");

    const groqKey = process.env.GROQ_API_KEY;
    console.log("Groq Key Found:", !!groqKey);

    if (groqKey) {
        try {
            const groq = new Groq({ apiKey: groqKey });
            const chatCompletion = await groq.chat.completions.create({
                messages: [{ role: "user", content: "Hi" }],
                model: "llama-3.1-8b-instant",
            });
            console.log("✅ GROQ OK:", chatCompletion.choices[0]?.message?.content);
        } catch (err) {
            console.log("❌ GROQ FAIL:", err.message);
        }
    }

    const geminiKey = process.env.GEMINI_API_KEY;
    console.log("Gemini Key Found:", !!geminiKey);
    if (geminiKey) {
        try {
            const genAI = new GoogleGenerativeAI(geminiKey);
            const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash-latest" });
            const result = await model.generateContent("Hi");
            const response = await result.response;
            console.log("✅ GEMINI OK:", response.text().substring(0, 50));
        } catch (err) {
            console.log("❌ GEMINI FAIL:", err.message);
        }
    }

    console.log("--- END DIAGNOSTIC ---");
    process.exit(0);
}

diagnostic().catch(err => {
    console.error("FATAL:", err);
    process.exit(1);
});
