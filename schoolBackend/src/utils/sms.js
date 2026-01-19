const twilio = require("twilio");

/**
 * Helper to get Twilio client dynamically
 */
const getClient = () => {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;

    if (!accountSid || !authToken) return null;
    return twilio(accountSid, authToken);
};

const getServiceSid = () => process.env.TWILIO_VERIFY_SERVICE_SID;

/**
 * Starts a verification (sends SMS OTP)
 */
exports.startVerification = async (to) => {
    const client = getClient();
    const verifyServiceSid = getServiceSid();

    try {
        if (!client || !verifyServiceSid) {
            console.warn("[VERIFY SKIPPED] Missing details:");
            console.warn(`- SID: ${process.env.TWILIO_ACCOUNT_SID ? 'OK' : 'MISSING'}`);
            console.warn(`- TOKEN: ${process.env.TWILIO_AUTH_TOKEN ? 'OK' : 'MISSING'}`);
            console.warn(`- SERVICE_SID: ${process.env.TWILIO_VERIFY_SERVICE_SID ? 'OK' : 'MISSING'}`);

            console.log(`\n--- SIMULATED VERIFY START ---\nTo: ${to}\n------------------------------\n`);
            return { success: true, simulated: true };
        }

        const verification = await client.verify.v2.services(verifyServiceSid)
            .verifications
            .create({ to: to, channel: 'sms' });

        console.log(`[VERIFY START] SID: ${verification.sid} to ${to}`);
        return { success: true, sid: verification.sid };
    } catch (err) {
        console.error(`[VERIFY START ERROR] Failed for ${to}:`, err.message);
        return { success: false, error: err.message };
    }
};

/**
 * Checks a verification code
 */
exports.checkVerification = async (to, code) => {
    const client = getClient();
    const verifyServiceSid = getServiceSid();

    try {
        if (!client || !verifyServiceSid) {
            console.warn("[VERIFY CHECK SKIPPED] Simulation mode. Accepting code '123456' as valid.");
            if (code === "123456") return { success: true, status: 'approved', simulated: true };
            return { success: false, error: "Invalid simulated code" };
        }

        const check = await client.verify.v2.services(verifyServiceSid)
            .verificationChecks
            .create({ to: to, code: code });

        console.log(`[VERIFY CHECK] Status: ${check.status} for ${to}`);
        return { success: true, status: check.status };
    } catch (err) {
        if (err.status === 404) return { success: false, error: "Invalid or expired code" };
        console.error(`[VERIFY CHECK ERROR] Failed for ${to}:`, err.message);
        return { success: false, error: err.message };
    }
};
