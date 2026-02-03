# Fintech Transaction Risk Engine

**A production-grade backend system for real-time fraud detection and transaction risk scoring**

## Overview

This is a comprehensive Ruby on Rails API backend that implements a real-world fintech transaction processing system with intelligent fraud detection. Designed with inspiration from systems used by Visa, Stripe, and Razorpay.

### What It Does
- User registration, authentication, and session management
- Transaction processing with risk evaluation
- Real-time fraud detection using configurable rules
- Async event-driven architecture with background jobs
- Complete audit trail for compliance
- Role-based access control (RBAC)
- Rate limiting and abuse prevention

### Real-World Applications
- Banking platforms
- Investment managers
- Payment processors
- Fintech apps
- Fraud analysis systems

## Technology Stack

| Component | Technology |
|-----------|------------|
| **Framework** | Rails 8.1.2 (API-only) |
| **Database** | PostgreSQL 16 |
| **Job Queue** | Sidekiq + Redis |
| **Authentication** | HttpOnly Cookies (Session-based) |
| **Authorization** | Pundit (RBAC) |
| **Rate Limiting** | Rack Attack |
| **Testing** | RSpec |
| **Documentation** | Postman Collections |

## Project Phases

```
Phase 0 ✅ → Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7 → Phase 8
Foundation | Auth  | Users    | Txns     | Risk     | Async   | Logs   | Security| Tests
```

### Phase 0: Foundation & Sanity Check ✅
- [x] Rails API project setup
- [x] PostgreSQL connection
- [x] Health check endpoint
- [x] Environment configuration

### Phase 1: Authentication (Next)
- [ ] User model with password hashing
- [ ] Registration endpoint
- [ ] Login endpoint
- [ ] Logout endpoint
- [ ] Session-based auth with HttpOnly cookies

### Phase 2: User & Account Baseline
- [ ] User behavior tracking
- [ ] Average transaction amount calculation
- [ ] Background jobs for metrics

### Phase 3: Transaction Ingestion
- [ ] Transaction creation API
- [ ] Pagination
- [ ] Input validation
- [ ] Immutable transaction records

### Phase 4: Risk Engine
- [ ] Fraud rule engine
- [ ] Risk scoring (0-100)
- [ ] Transaction status assignment (allowed/flagged/blocked)
- [ ] Fraud flag persistence

### Phase 5: Event-Driven & Async
- [ ] Background job processing
- [ ] Event streaming
- [ ] Idempotent operations
- [ ] Retry logic

### Phase 6: Audit Logs & Observability
- [ ] Audit trail
- [ ] Compliance logging
- [ ] Admin dashboards

### Phase 7: Security & Abuse Protection
- [ ] Rate limiting
- [ ] CSRF hardening
- [ ] IP/Device tracking

### Phase 8: Tests & Hardening
- [ ] Request specs
- [ ] Model specs
- [ ] Security scan
- [ ] Code quality checks

## Quick Start

### Prerequisites
```bash
Ruby 3.2+
PostgreSQL 16+
Redis (for Sidekiq)
Bundler
```

### Installation

1. **Clone and setup**
```bash
cd /home/aryan/Desktop/fintech-backend
bundle install
```

2. **Configure environment**
```bash
cp .env.example .env
# Update .env with your PostgreSQL credentials
```

3. **Create databases**
```bash
rails db:create
rails db:migrate
```

4. **Start Redis (in another terminal)**
```bash
redis-server
```

5. **Start Rails server**
```bash
rails server -p 3000 -b 0.0.0.0
```

6. **Start Sidekiq (in another terminal)**
```bash
bundle exec sidekiq
```

### Verify Installation

Test the health endpoint:
```bash
curl -s http://localhost:3000/api/v1/health | python3 -m json.tool
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2026-02-03T10:18:40.201Z",
  "environment": "development",
  "database": "connected"
}
```

## API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Response Format
All responses follow a standard format:
```json
{
  "status": "success|error",
  "message": "User-friendly message",
  "data": {},
  "error": null
}
```

### Current Endpoints (Phase 0)

#### Health Check
```
GET /health

Response (200 OK):
{
  "status": "ok",
  "timestamp": "2026-02-03T10:18:40.201Z",
  "environment": "development",
  "database": "connected"
}
```

## Next Steps

1. ✅ Phase 0: Foundation complete
2. → **Phase 1: Authentication** - User registration and login
3. → Phase 2: User profiles and behavior tracking
4. → Phase 3: Transaction creation
5. → Phase 4: Risk evaluation engine
6. → Phase 5: Async processing
7. → Phase 6: Audit logging
8. → Phase 7: Security hardening
9. → Phase 8: Comprehensive testing

## Status

**Phase 0 Complete ✅**

**Last Updated**: February 3, 2026

* Deployment instructions

* ...
