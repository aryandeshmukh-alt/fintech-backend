# Fintech Backend: Transaction Risk & Fraud Detection Engine

A secure, high-performance Ruby on Rails API for real-time transaction processing, automated risk assessment, and fraud detection.

## Technical Stack

- **Framework:** Ruby on Rails 8.1.2 (API Only)
- **Database:** PostgreSQL with UUID support
- **Authentication:** Secure Cookie-based Sessions (HttpOnly/SameSite)
- **Background Jobs:** SolidQueue (Rails 8 defaults)
- **Security:** bcrypt, SHA-256 device hashing, industry-standard SQL injection protection

## Quick Start for Developers

To get a perfect clone of this backend on your local machine, follow these exact steps:

### 1. Prerequisites
- **Ruby:** `3.2.0+`
- **PostgreSQL:** `14+` (Make sure your Postgres service is running)

### 2. Setup Procedure
```bash
# Clone the repository
git clone <repository-url>
cd fintech-backend

# Install dependencies
bundle install

# Initialize all databases (Primary + Job Queue)
# This will create your databases and run all migrations
bin/rails db:prepare
```

### 3. Verify the Installation
Start the server:
```bash
bin/rails server
```
The API is now active at `http://localhost:3000`.

---

## Database Inspection Guide

To check the state of your database and verify your data, use these commands:

### A. Find Your Database Names
Open `config/database.yml`. By default:
- **Primary Data:** `fintech_development` (Transactions, Users, Evaluations)
- **Background Jobs:** `fintech_development_queue` (Queue status, Scheduled reports)

### B. List All Tables
Run this in your terminal to see every table in your primary database:
```bash
bin/rails runner "puts ActiveRecord::Base.connection.tables"
```

### C. View Content (The Easy Way)
You don't need to know SQL. Use the Rails Runner to print data directly:
```bash
# View all Users
bin/rails runner "User.all.each { |u| p u.attributes }"

# View recent Transactions
bin/rails runner "Transaction.order(created_at: :desc).limit(5).each { |t| p t.attributes }"

# View Fraud Decisions
bin/rails runner "FraudEvaluation.all.each { |fe| p fe.attributes }"
```

### D. Entering the SQL Console
If you prefer standard SQL, just type:
```bash
bin/rails dbconsole
```
Inside the prompt, type `\dt` to list tables or `SELECT * FROM users;` to see data. Type `\q` to exit.

### 3. Environment Variables
Create a `.env` file in the root directory if you need to override default database settings:
```env
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_HOST=localhost
```

### 4. Running the Server
```bash
bin/rails server
```
The API will be available at `http://localhost:3000`.

## Core Features

### Real-time Risk Assessment
Every transaction passes through a multi-rule engine that calculates a risk score based on:
- **Transaction Amount:** Flags unusually high values.
- **Spending Baseline:** Detects deviations from user's average behavior.
- **Velocity:** Monitors rapid-fire transactions within 60-second windows.
- **Device trust:** Tracks and hashes device signatures (MAC IDs) using SHA-256 for persistent identification.

### Automated Decisioning
Transactions are automatically categorized:
- **SUCCESS:** Low risk score (< 30).
- **FLAGGED:** Medium risk score (30-70).
- **BLOCKED:** High risk score (> 70).

### User Feedback Loop
Allows users to provide "Ground Truth" data on fraud decisions (marking them as accurate or inaccurate), enabling future machine learning improvements.

## API Documentation for Frontend Integration

Formal API specifications are located in the `docs/` directory.

### Postman Collection
For rapid testing and integration, import the Master Collection:
`postman/MASTER_COLLECTION.json`

## Project Structure

- `app/services/`: Contains `TransactionRiskEvaluator` (Core logic).
- `app/mailers/`: Handles automated alerts for blocked transactions.
- `app/controllers/api/v1/`: Versioned API endpoints for Auth, Transactions, and Feedback.
## System Architecture & Data Flow

The Fintech Risk Engine operates as an asynchronous, multi-layered filtration system. Below is the step-by-step lifecycle of a transaction.

### 1. Ingestion Layer
- **Endpoint:** `POST /api/v1/transactions`
- **Identity:** The `current_user` is identified via secure session cookies.
- **Enrichment:** The server captures the `ip_address` and performs SHA-256 hashing on the `device_id` (MAC/Hardware ID) to maintain privacy while ensuring persistent tracking.

### 2. Risk Evaluation Engine (`TransactionRiskEvaluator`)
The transaction is passed to the core service which executes five distinct safety rules:
1.  **First Transaction Check:** Flags if this is the user's first transaction above a specific threshold.
2.  **Amount Deviation:** Compares the amount against the user's 30-day historical average.
3.  **Velocity Control:** Checks for unusual transaction volume (rapid-fire attempts) in the last 60 seconds.
4.  **Device Trust:** Verifies if the hashed `device_id` has been previously used by this user.
5.  **Device Identity:** Ensures a non-null device identifier is present.

### 3. Decisioning & Persistence
- Based on the cumulative risk score, a `FraudEvaluation` record is created.
- **SUCCESS (< 30):** Transaction status remains Success.
- **FLAGGED (30-70):** Transaction is marked as Flagged for review; backend stats are updated.
- **BLOCKED (> 70):** Transaction is marked as Blocked; a `403 Forbidden` response is sent.

### 4. Notification & Alerts (Asynchronous)
- If a transaction is **BLOCKED**, the `TransactionRiskEvaluator` triggers `TransactionMailer.blocked_alert`.
- This job is pushed to the **SolidQueue Background Worker** (stored in a dedicated PostgreSQL database).
- The worker sends a secure email alert to the user's registered address.

### 5. Human-in-the-Loop Feedback
- Users can view their transaction history via `GET /api/v1/transactions`.
- If a user identifies an error in the risk decision, they submit feedback via `POST /api/v1/transactions/:id/feedback`.
- This data is used for auditing and refining future risk thresholds.

### 6. Recurring Intelligence
- **SolidQueue Scheduler:** Runs every Monday at 08:00 AM.
- **WeeklyReportJob:** Collects 7-day transaction volumes, average spending, and security alert counts.
- **Delivery:** Generates and sends a comprehensive report to each active user.
