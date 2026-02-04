# Frontend Integration Guide: Fintech Risk Engine API

This document provides the technical specifications required for integrating the frontend application with the Backend API.

## Base Configuration

- **API Base URL:** `http://localhost:3000/api/v1`
- **Content-Type:** `application/json`
- **Session Auth:** The API uses **HttpOnly Cookies**. Your fetch/axios requests MUST include `credentials: 'include'` (or `withCredentials: true`) to maintain the user's session.

---

## Authentication Endpoints

### 1. User Registration
`POST /auth/register`
- **Payload:** `{ "user": { "email", "password", "password_confirmation", "first_name", "last_name" } }`
- **Response:** `201 Created` on success. Automatically sets session cookie.

### 2. User Login
`POST /auth/login`
- **Payload:** `{ "email", "password" }`
- **Response:** `200 OK`. Sets session cookie.

### 3. Check Session Status (Me)
`GET /auth/me`
- **Response:** Returns the current logged-in user profile or `401 Unauthorized`. Use this on app initialization.

---

## Transaction Endpoints

### 1. Create Transaction
`POST /transactions`
- **Payload:** 
  ```json
  {
    "transaction": {
      "amount": 150.50,
      "device_id": "client_provided_mac_or_id",
      "payment_method": "upi"
    }
  }
  ```
- **Allowed Payment Methods:** `card`, `upi`, `bank_transfer`, `wallet`.
- **Note:** `device_id` should be a unique identifier from the user's browser/device. The backend hashes this for privacy.

### 2. List Transaction History
`GET /transactions?page=1&per_page=20`
- **Response Structure:**
  ```json
  {
    "status": "success",
    "data": {
      "transactions": [...],
      "pagination": { "current_page", "total_pages", "total_count" },
      "user_stats": { "total_transactions", "total_volume", "average_spending" }
    }
  }
  ```

---

## Feedback Loop

### 1. Submit Feedback
`POST /transactions/:transaction_id/feedback`
- **Payload:**
  ```json
  {
    "feedback": {
      "is_accurate": true,
      "user_feedback": "Description of why the user confirms/denies fraud"
    }
  }
  ```
- **Use Case:** Trigger this when a user views a "Flagged" or "Blocked" transaction in their history and wants to provide clarification.

---

## Error Handling

The API returns standard HTTP status codes:
- `401 Unauthorized`: Session expired or invalid credentials.
- `403 Forbidden`: Transaction was BLOCKED by the risk engine.
- `422 Unprocessable Entity`: Validation failures (e.g., duplicate email).
- `404 Not Found`: Entity does not exist.

All error responses follow this format:
```json
{
  "status": "error",
  "message": "Human readable message",
  "data": null,
  "errors": ["Specific detail 1", "Specific detail 2"]
}
```
