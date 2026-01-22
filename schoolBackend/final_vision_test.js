const Groq = require("groq-sdk");
require('dotenv').config();
const fs = require('fs');

async function run() {
    const key = process.env.GROQ_API_KEY;
    const groq = new Groq({ apiKey: key });
    try {
        const res = await groq.chat.completions.create({
            messages: [{ role: "user", content: "hi" }],
            model: "meta-llama/llama-4-scout-17b-16e-instruct",
            max_tokens: 5
        });
        fs.writeFileSync('vision_test_result.txt', "Llama 4 Scout: OK\nResponse: " + res.choices[0].message.content);
    } catch (e) {
        fs.writeFileSync('vision_test_result.txt', "Llama 4 Scout: FAIL (" + e.message + ")");
    }
}
run();
