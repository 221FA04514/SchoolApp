
const axios = require('axios');

async function testPayment() {
    const loginUrl = 'http://localhost:5000/api/v1/auth/login';
    const payUrl = 'http://localhost:5000/api/v1/fees/pay-online';

    try {
        // 1. Login to get token
        console.log("Logging in as student...");
        // Assuming standard student credentials, or I might need to check seed data
        // trying a common one or I'll check the DB if this fails.
        // Based on previous contexts, 'student' / '123456' might work, or I need to find a valid user.
        // I'll try 'student@school.com' / '123456' or similar if 'student' is username.
        // Let's first check if I can find a valid student from the DB or previous logs.
        // For now, I'll try a generic login payload.
        const loginRes = await axios.post(loginUrl, {
            email: "student@test.com",
            password: "123456"
        });

        const token = loginRes.data.data.token;
        console.log("Got token:", token ? "Yes" : "No");

        // 2. Try Payment
        console.log("Attempting payment...");
        const payRes = await axios.post(payUrl, {
            amount_paid: 100,
            payment_mode: "Online"
        }, {
            headers: { Authorization: `Bearer ${token}` }
        });

        console.log("Payment Response:", payRes.data);

        // 3. Test 404 to see if it returns HTML
        console.log("Testing 404...");
        try {
            await axios.get('http://localhost:5000/api/v1/fees/non_existent_route');
        } catch (e) {
            if (e.response && typeof e.response.data === 'string' && e.response.data.includes('<!DOCTYPE html>')) {
                console.log("404 returns HTML!");
            } else {
                console.log("404 returns:", e.response ? e.response.data : e.message);
            }
        }

    } catch (err) {
        if (err.response) {
            console.log("Error Status:", err.response.status);
            console.log("Error Data:", err.response.data);
            // Log HTML if present
            if (typeof err.response.data === 'string' && err.response.data.includes('<!DOCTYPE html>')) {
                console.log("--- HTML RESPONSE STARTED ---");
                console.log(err.response.data.substring(0, 500)); // First 500 chars
                console.log("--- HTML RESPONSE ENDED ---");
            }
        } else {
            console.log("Error:", err.message);
        }
    }
}

testPayment();
