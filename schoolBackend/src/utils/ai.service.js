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
 * Strips LaTeX and math formatting to ensure a student-friendly output.
 */
function cleanAiResponse(text) {
    if (!text) return text;
    let cleaned = text
        .replace(/\\\(/g, '')             // \(
        .replace(/\\\)/g, '')             // \)
        .replace(/\\\[/g, '')             // \[
        .replace(/\\\]/g, '')             // \]
        .replace(/\$/g, '')               // $
        .replace(/\\frac\{([^}]*)\}\{([^}]*)\}/g, '$1/$2') // \frac{a}{b} -> a/b
        .replace(/\\dfrac\{([^}]*)\}\{([^}]*)\}/g, '$1/$2')
        .replace(/\\div/g, '/')
        .replace(/\\times/g, '*')
        .replace(/\\cdot/g, '*')
        .replace(/\\ast/g, '*')
        .replace(/\\sqrt\{([^}]*)\}/g, 'sqrt($1)')
        .replace(/\\pm/g, '+/-')
        .replace(/\\text\{([^}]*)\}/g, '$1')
        .replace(/\\quad/g, ' ')
        .replace(/\\mathrm\{([^}]*)\}/g, '$1')
        .replace(/\\mathbf\{([^}]*)\}/g, '$1')
        .replace(/\\boldsymbol\{([^}]*)\}/g, '$1')
        .replace(/\\circ/g, '°')
        .replace(/\\theta/g, 'theta')
        .replace(/\\alpha/g, 'alpha')
        .replace(/\\beta/g, 'beta')
        .replace(/\\gamma/g, 'gamma')
        .replace(/\\pi/g, 'pi')
        .replace(/_\{([^}]*)\}/g, '$1') // Subscripts
        .replace(/\^\{([^}]*)\}/g, '^$1') // Superscripts
        .replace(/\\{2,}/g, '\n')        // \\ -> newline
        .replace(/```latex[\s\S]*?```/g, '') // Remove nested latex blocks if any
        .replace(/```[\s\S]*?```/g, (match) => match.replace(/\\/g, '')); // Clean backslashes in code blocks

    // Clean up excessive math formatting artifacts
    cleaned = cleaned
        .replace(/\{(\d+)\}/g, '$1') // Remove stray braces around numbers like {2}
        .replace(/([a-zA-Z0-9])\s*([\/\*\+\-\^])\s*([a-zA-Z0-9])/g, '$1 $2 $3'); // Clean spacing around operators

    // Final purge of any stray backslashes while preserving some symbols if necessary
    return cleaned.replace(/\\/g, '').trim();
}

/**
 * AI Homework Helper (Text or Image)
 */
exports.analyzeHomework = async (prompt, imageBase64 = null) => {
    try {
        if (!groq) throw new Error("Groq API key missing in .env");

        const messages = [
            {
                role: "system",
                content: `You are a friendly school teaching assistant. 
                STRICT RULE: Every answer must be in 100% plain text. 
                - NO LaTeX like \frac, \div, or $. 
                - For math, use: / for division, * for multiplication, ^ for powers.
                - Example: 1/2 instead of \frac{1}{2}.
                - Break down answers into simple numbered steps.`
            },
            {
                role: "user",
                content: [
                    { type: "text", text: prompt || "Solve this homework problem step by step." },
                ],
            }
        ];

        if (imageBase64) {
            messages[1].content.push({
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

        return cleanAiResponse(chatCompletion.choices[0]?.message?.content);

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
                return cleanAiResponse(response.text()) + "\n\n*(Note: Gemini fallback used)*";
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

        const fullPrompt = `You are a friendly school teaching assistant. 
        Context: ${context}
        Student Question: ${studentQuery}
        
        Provide a clear, simple explanation. 
        RULES:
        1. Use ONLY simple plain text. 
        2. DO NOT use LaTeX formatting or symbols like $, \\\\frac, \\\\sqrt, etc.
        3. Use standard symbols like /, *, -, +, ^.
        4. Be encouraging and helpful.`;

        console.log("→ Doubt Solver: Using Groq (llama-3.3-70b-versatile)");

        const chatCompletion = await groq.chat.completions.create({
            messages: [{ role: "user", content: fullPrompt }],
            model: "llama-3.3-70b-versatile",
        });

        return cleanAiResponse(chatCompletion.choices[0]?.message?.content);
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

/**
 * AI Homework Generator (Teacher)
 */
exports.generateSmartHomework = async ({ subject, topic, difficulty, count = 5 }) => {
    try {
        if (!groq) throw new Error("Groq API key missing");

        const prompt = `Generate ${count} school homework questions for:
        Subject: ${subject}
        Topic: ${topic}
        Difficulty: ${difficulty}
        
        RULES:
        1. Return as a JSON array of objects: [{ "question": "...", "answer": "..." }]
        2. Use plain text only. No LaTeX.
        3. Make it appropriate for school students.`;

        console.log(`→ Homework Generator: ${subject} - ${topic} (${difficulty})`);

        const chatCompletion = await groq.chat.completions.create({
            messages: [{ role: "user", content: prompt }],
            model: "llama-3.3-70b-versatile",
            response_format: { type: "json_object" }
        });

        return chatCompletion.choices[0]?.message?.content;
    } catch (err) {
        console.error("Homework Generator Error:", err.message);
        return "[]";
    }
};

/**
 * AI Announcement Refiner (Teacher)
 */
exports.refineAnnouncement = async (draft) => {
    try {
        if (!groq) throw new Error("Groq API key missing");

        const prompt = `Refine this school announcement to be professional, warm, and clear.
        Draft: ${draft}
        
        RULES:
        1. Keep it concise.
        2. Use a professional yet friendly tone.
        3. Return ONLY the refined text.`;

        const chatCompletion = await groq.chat.completions.create({
            messages: [{ role: "user", content: prompt }],
            model: "llama-3.3-70b-versatile",
        });

        return chatCompletion.choices[0]?.message?.content.trim();
    } catch (err) {
        console.error("Announcement Refiner Error:", err.message);
        return draft;
    }
};

/**
 * AI Performance Insights (Teacher)
 */
exports.getPerformanceInsights = async (studentName, data) => {
    try {
        if (!groq) throw new Error("Groq API key missing");

        const prompt = `Analyze this student's data and provide brief teacher insights (strengths, weaknesses, alerts).
        Student: ${studentName}
        Data: ${JSON.stringify(data)}
        
        RULES:
        1. Max 3 bullet points.
        2. Be constructive.
        3. Mention any alerts (e.g., low attendance or declining marks).`;

        const chatCompletion = await groq.chat.completions.create({
            messages: [{ role: "user", content: prompt }],
            model: "llama-3.3-70b-versatile",
        });

        return chatCompletion.choices[0]?.message?.content.trim();
    } catch (err) {
        console.error("Performance Insights Error:", err.message);
        return "Unable to generate insights at this time.";
    }
};
