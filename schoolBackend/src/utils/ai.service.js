const Groq = require("groq-sdk");
const { GoogleGenerativeAI } = require("@google/generative-ai");
require("dotenv").config();

// Initialize Groq (Primary for ALL tasks - Text and Vision)
const groq = process.env.GROQ_API_KEY
    ? new Groq({ apiKey: process.env.GROQ_API_KEY })
    : null;

// Initialize Gemini (Kept only as a legacy fallback)
const genAI = process.env.GEMINI_API_KEY
    ? new GoogleGenerativeAI(process.env.GEMINI_API_KEY)
    : null;

if (groq) {
    console.log("🚀 Groq AI CORE initialized. Using llama-3.1 & llama-3.2-vision.");
} else {
    console.warn("⚠️ GROQ_API_KEY missing. AI features will be limited.");
}

/**
 * AI Homework Helper (Text or Image)
 */
exports.analyzeHomework = async (prompt, imageBase64 = null) => {
    try {
        if (!groq) throw new Error("Groq API key missing in .env");

        const messages = [
            {
                role: "user",
                content: [
                    { type: "text", text: (prompt || "Solve this homework problem step by step.") + " IMPORTANT: Provide the answer in clear, simple plain text. DO NOT use LaTeX formatting (like $, \\frac, etc.). Use standard symbols like /, *, -, + and provide a student-friendly explanation." },
                ],
            }
        ];

        if (imageBase64) {
            messages[0].content.push({
                type: "image_url",
                image_url: {
                    url: `data:image/jpeg;base64,${imageBase64}`,
                },
            });
        }

        console.log(`→ Homework Helper: Using Groq Llama 4 Scout Vision`);

        const chatCompletion = await groq.chat.completions.create({
            messages,
            model: "meta-llama/llama-4-scout-17b-16e-instruct",
            temperature: 0.1,
        });

        return chatCompletion.choices[0]?.message?.content;

    } catch (err) {
        console.error("Homework Helper Error:", err.message);

        if (genAI) {
            try {
                console.log("→ Fallback: Attempting Gemini 1.5 Flash...");
                const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
                const parts = [prompt];
                if (imageBase64) {
                    parts.push({ inlineData: { data: imageBase64, mimeType: "image/jpeg" } });
                }
                const result = await model.generateContent(parts);
                const response = await result.response;
                return response.text() + "\n\n*(Note: Gemini fallback used)*";
            } catch (gemErr) {
                console.error("Gemini Fallback also failed:", gemErr.message);
            }
        }

        return `AI Error: ${err.message}. Please verify models in your Groq/Gemini console.`;
    }
};

/**
 * AI Doubt Solver
 */
exports.solveDoubt = async (studentQuery, context = "") => {
    try {
        if (!groq) throw new Error("Groq API key missing");

        const fullPrompt = `You are a helpful school teaching assistant. 
        Context: ${context}
        Student Question: ${studentQuery}
        Provide a clear explanation suitable for a student. 
        IMPORTANT: Use simple plain text. DO NOT use LaTeX formatting or complex mathematical symbols.`;

        console.log("→ Doubt Solver: Using Groq (llama-3.3-70b-versatile)");

        const chatCompletion = await groq.chat.completions.create({
            messages: [{ role: "user", content: fullPrompt }],
            model: "llama-3.3-70b-versatile",
        });

        return chatCompletion.choices[0]?.message?.content;
    } catch (err) {
        console.error("Doubt Solver Error:", err.message);
        return `Trouble answering: ${err.message}`;
    }
};

/**
 * AI Study Planner
 */
exports.generateStudyPlan = async (studentData) => {
    try {
        if (!groq) throw new Error("Groq API key missing");

        const prompt = `Based on: ${JSON.stringify(studentData)}, generate a weekly study plan.
        Focus on weak subjects and upcoming exams.
        JSON format: { "Monday": ["Task 1", "Task 2"], ... }`;

        console.log("→ Study Planner: Using Groq (llama-3.3-70b-versatile)");

        const chatCompletion = await groq.chat.completions.create({
            messages: [{ role: "user", content: prompt }],
            model: "llama-3.3-70b-versatile",
            response_format: { type: "json_object" }
        });

        return chatCompletion.choices[0]?.message?.content;
    } catch (err) {
        console.error("Study Planner Error:", err.message);
        return "{}";
    }
};
