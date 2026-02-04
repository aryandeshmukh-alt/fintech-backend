# Fintech Risk Engine: API Specification (v1)

This document provides a comprehensive guide for frontend developers to integrate with the Fintech Backend API.

## 1. General Configuration

- **API Base URL**: `http://localhost:3000/api/v1`
- **Request Format**: `Content-Type: application/json`
- **Authentication**: **HttpOnly Cookies**. 
    - **Important**: Your HTTP client (Axios, Fetch, etc.) MUST be configured with `withCredentials: true` or `credentials: 'include'`.
    - Authorization is handled by the server session; no Bearer token is required in headers.

---

## 2. Authentication Flow

### **A. Register User**
`POST /auth/register`

- **Request Body**:
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```
- **Response (201 Created)**: Automatically logs the user in.
```json
{
  "status": "success",
  "data": { "id", "email", "first_name", "last_name", "role", "status" }
}
```

### **B. Login**
`POST /auth/login`

- **Request Body**: `{ "email": "...", "password": "..." }`
- **Response (200 OK)**: Sets the session cookie.

### **C. Check Current Session (Me)**
`GET /auth/me`
- **Usage**: Call this on app load to check if a user session is active.
- **Response**: `200 OK` (User Data) or `401 Unauthorized`.

### **D. Logout**
`DELETE /auth/logout`

---

## 3. Transaction Management

### **A. Create Transaction**
`POST /transactions`

- **Request Body**:
```json
{
  "transaction": {
    "amount": 5000.00,
    "device_id": "client_provided_unique_id",
    "payment_method": "upi"
  }
}
```
- **Fields**:
    - `amount`: Decimal (Greater than 0).
    - `device_id`: Any unique string (MAC, UUID, Browser Fingerprint). *Backend hashes this for privacy.*
    - `payment_method`: `card`, `upi`, `bank_transfer`, `wallet`.
- **Decision Responses**:
    - `201 Created`: Transaction processed successfully or flagged.
    - `403 Forbidden`: Transaction BLOCKED by risk engine.

### **B. Transaction History (with Pagination & Stats)**
`GET /transactions?page=1&per_page=10`

- **Response**:
```json
{
  "status": "success",
  "data": {
    "transactions": [
      {
        "id", "amount", "payment_method", "device_id", "status", "risk_score", "created_at"
      }
    ],
    "pagination": { "current_page", "total_pages", "total_count" },
    "user_stats": { "total_transactions", "total_volume", "average_spending" }
  }
}
```

---

## 4. Fraud Feedback Loop

### **Submit Feedback**
`POST /transactions/:transaction_id/feedback`

- **Usage**: Triggered when a user views a transaction and wants to confirm it was legitimate or report an error.
- **Request Body**:
```json
{
  "feedback": {
    "is_accurate": true,
    "user_feedback": "Detailed comment here"
  }
}
```

---

## 5. Standard Error Format

All errors across the API follow this consistent format:
```json
{
  "status": "error",
  "message": "Human readable error message",
  "data": null,
  "error": ["Detail 1", "Detail 2"]
}
```

---

## 6. Implementation Notes for Frontend
- **Real-time Updates**: When a transaction returns a `blocked` status, the user will also receive an email alert.
- **Rules Triggered**: The `index` and `create` responses include `rules_triggered` in the data map, allowing you to show the user exactly why a transaction was flagged (e.g., "Amount Deviation High").
- **Backend Analytics**: Do NOT calculate totals on the client. Use the `user_stats` provided in the Transaction History response for dashboard summaries.
