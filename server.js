const express = require('express');
require('dotenv').config();

const app = express();
app.use(express.json());

// Dynamic Port Configuration matching our Jenkins & Docker requirements
const PORT = process.env.APP_PORT || 8081;

// Mock Database for ATM Accounts (In-Memory Processing)
const accounts = {
    "account-ramji-101": {
        pin: process.env.ATM_SECURE_PIN || "1234",
        balance: 50000,
        holder: "Saurabh Pal"
    }
};

// --- FIX: Added root route for browser accessibility ---
app.get('/', (req, res) => {
    res.status(200).send("ATM-Project is Running Successfully!");
});

// Root standard endpoint for health checks
app.get('/api/atm/health', (req, res) => {
    res.status(200).json({ status: "UP", project: "ATM-Project", timestamp: new Date() });
});

// 1. Balance Enquiry API Endpoint
app.post('/api/atm/balance', (req, res) => {
    const { accountId, pin } = req.body;

    if (!accounts[accountId]) {
        return res.status(404).json({ error: "Invalid Account Number" });
    }

    if (accounts[accountId].pin !== pin) {
        return res.status(401).json({ error: "Unauthorized! Incorrect ATM PIN" });
    }

    res.status(200).json({
        accountHolder: accounts[accountId].holder,
        currentBalance: `₹${accounts[accountId].balance}`
    });
});

// 2. Cash Withdrawal API Endpoint (With Safety Check Limits)
app.post('/api/atm/withdraw', (req, res) => {
    const { accountId, pin, amount } = req.body;

    if (!accounts[accountId]) {
        return res.status(404).json({ error: "Invalid Account Number" });
    }

    if (accounts[accountId].pin !== pin) {
        return res.status(401).json({ error: "Unauthorized! Incorrect ATM PIN" });
    }

    if (amount <= 0) {
        return res.status(400).json({ error: "Invalid amount specified" });
    }

    if (accounts[accountId].balance < amount) {
        return res.status(400).json({ error: "Transaction Declined: Insufficient ATM Balance" });
    }

    // Deduct Balance Safely
    accounts[accountId].balance -= amount;

    res.status(200).json({
        status: "Success",
        msg:
