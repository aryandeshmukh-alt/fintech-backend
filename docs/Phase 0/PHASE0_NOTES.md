# Phase 0: Foundation & Sanity Check ✅

## Goal
Project boots, DB connected, Postman can hit a health endpoint.

## What's Done

### 1. Rails API Project Setup
- Created Rails API-only application with PostgreSQL
- Clean project structure optimized for backend
- No asset pipeline, no views (pure API)

### 2. Database Configuration
- PostgreSQL 16 connected
- Database credentials from `.env` file
- Both development and test databases created
- Dynamic configuration using environment variables

### 3. Essential Gems Added
```
- bcrypt (password hashing)
- rspec-rails (testing)
- pundit (authorization)
- rack-attack (rate limiting)
- dotenv-rails (environment variables)
- sidekiq (async jobs)
- kaminari (pagination)
- rack-cors (CORS handling)
- active_model_serializers (JSON serialization)
```

### 4. Environment Configuration
- `.env` and `.env.example` files for local development
- Database host, port, user, password configurable
- Redis configuration for Sidekiq
- Rate limiting and fintech-specific settings

### 5. Health Check Endpoint
```
GET /api/v1/health

Response:
{
  "status": "ok",
  "timestamp": "2026-02-03T10:18:40.201Z",
  "environment": "development",
  "database": "connected"
}
```

## Verification

### Test the Health Endpoint
```bash
curl -s http://localhost:3000/api/v1/health | python3 -m json.tool
```

### Expected Response
```json
{
  "status": "ok",
  "timestamp": "2026-02-03T10:18:40.201Z",
  "environment": "development",
  "database": "connected"
}
```

## Project Structure
```
fintech-backend/
├── app/
│   ├── controllers/
│   │   ├── api/v1/
│   │   │   └── health_controller.rb      # Health check endpoint
│   │   └── application_controller.rb     # Base controller with Pundit
│   ├── models/
│   ├── jobs/
│   ├── services/
│   ├── validators/
│   ├── policies/
│   └── serializers/
├── config/
│   ├── database.yml                      # PostgreSQL config
│   └── routes.rb                         # API routes
├── db/
├── spec/                                 # RSpec tests (Phase 8)
├── .env                                  # Local environment variables
├── .env.example                          # Template for ENV variables
├── Gemfile                               # Dependencies
└── Dockerfile                            # Docker configuration
```

## Key Files Created/Modified

### 1. Gemfile
All dependencies for the project phases are included upfront for predictability.

### 2. config/database.yml
Updated to use environment variables for flexibility.

### 3. config/routes.rb
Added `/api/v1/health` endpoint.

### 4. app/controllers/application_controller.rb
Base controller with Pundit authorization and cookie support.

### 5. app/controllers/api/v1/health_controller.rb
Health check that verifies:
- Rails is running
- PostgreSQL connection is alive
- Current environment and timestamp

## Postman Collection
File: `postman/Phase0-Foundation.json`

Import this collection into Postman to test:
- GET /api/v1/health

## Next Steps → Phase 1

Once Phase 0 is green ✅, we'll implement:
- User model with password hashing
- Authentication (registration, login, logout)
- HttpOnly cookie-based sessions
- Current user middleware

### Start Phase 1 when ready!
