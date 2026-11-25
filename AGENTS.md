# Bank Soal — Project Instructions

## 1. Project Overview

Bank Soal is a web-based question bank and learning platform designed for managing educational questions, conducting practice sessions and timed exercises, and tracking student performance.

The project uses a monorepo structure with three primary directories:

- `deployment/` — Infrastructure and deployment configuration.
- `backend/` — Laravel REST API.
- `frontend/` — Next.js web application.

The system is designed to support three user roles:

- **Admin** — Manages users, subjects, topics, questions, exercises, and reports.
- **Editor** — Manages questions, options, hints, explanations, and question imports/exports.
- **Student (Siswa/Peserta)** — Participates in practice sessions and exercises and views personal learning reports.

Each user has exactly one role.

---

## 2. Technology Stack

Use the following technology stack unless explicitly instructed otherwise.

### Backend

- Laravel
- PHP
- Laravel Sanctum for API authentication
- PostgreSQL
- REST API architecture

### Frontend

- Next.js
- React
- TypeScript
- Tailwind CSS
- Next.js App Router

### Infrastructure

- Docker Engine
- Docker Compose
- Debian 13 VM running on Proxmox
- Nginx
- PostgreSQL running in Docker

### Important Rules

- Do not introduce additional frameworks or infrastructure services without a clear technical reason.
- Do not assume framework versions. Inspect the existing project configuration before making version-specific changes.
- Preserve the existing dependency versions unless an upgrade is explicitly requested or technically necessary.
- Use npm for Node.js package management.
- Do not introduce Yarn or pnpm unless explicitly requested.

---

## 3. Repository Structure

The expected repository structure is:

```text
bank-soal/
│
├── AGENTS.md
│
├── deployment/
│   ├── compose.yaml
│   ├── .env
│   ├── .env.example
│   │
│   ├── docker/
│   │   ├── php/
│   │   ├── nginx/
│   │   ├── postgres/
│   │   └── node/
│   │
│   ├── data/
│   │   ├── postgres/
│   │   ├── backups/
│   │   └── ...
│   │
│   ├── scripts/
│   └── README.md
│
├── backend/
│
├── frontend/
│
├── .gitignore
└── README.md
```

The structure may evolve as the project grows, but preserve the separation of responsibilities.

### Directory Responsibilities

| Directory | Responsibility |
|---|---|
| `deployment/` | Docker, infrastructure, environment configuration, scripts, and deployment documentation |
| `backend/` | Laravel application and API |
| `frontend/` | Next.js application and user interface |

Do not place application business logic inside `deployment/`.

Do not place infrastructure configuration randomly inside `backend/` or `frontend/`.

---

## 4. Infrastructure and Docker Guidelines

### Development Environment

The primary development environment runs on a Debian 13 VM hosted on Proxmox.

The developer accesses the VM remotely using VS Code Remote SSH from a MacBook.

Docker Compose is the primary service orchestration mechanism.

### Persistent Data

All project-specific persistent data must be stored inside the project directory, preferably under:

`deployment/data/`

Examples:

- PostgreSQL data: `deployment/data/postgres/`
- Database backups: `deployment/data/backups/`
- Redis persistence, if introduced: `deployment/data/redis/`
- Nginx logs, if explicitly persisted: `deployment/data/nginx/`

Use Docker bind mounts for persistent project data.

Do not use Docker named volumes for application data that is expected to be backed up or managed inside the project directory.

Docker images, container writable layers, and Docker Engine metadata may remain in Docker's system storage.

### Docker Compose Rules

- Keep the primary Compose configuration under `deployment/`.
- Keep Dockerfiles and service-specific configuration under `deployment/docker/`.
- Use service names for internal container-to-container communication.
- Avoid hardcoding container IP addresses.
- Use Docker networks to isolate internal services.
- Add healthchecks where appropriate.
- Use persistent mounts for database data.
- Do not expose internal services publicly unless explicitly required.
- Never commit actual secrets or environment files.
- Keep `.env.example` synchronized with the environment variables required by the application.

### Service Architecture

The planned services are:

- `postgres` — PostgreSQL database.
- `backend` — PHP-FPM / Laravel runtime.
- `backend-nginx` — Nginx entry point for the API.
- `frontend` — Next.js runtime.
- `redis` — Optional cache and queue infrastructure.
- Queue worker and scheduler — To be introduced when required.

Do not introduce optional services before they are needed.

---

## 5. Database Guidelines

PostgreSQL is the primary relational database.

The database design uses the following principles:

- A user has one role through `users.role_id`.
- Role-based access control uses roles, permissions, and role-permission relationships.
- Questions have stable identities.
- Question revisions are stored in `question_versions`.
- Published question versions must be treated as immutable.
- Editing a published question creates a new version.
- Exercises use fixed question packages.
- Exercise questions reference specific question versions.
- Learning sessions preserve the exact question versions used when the session started.
- Student answers are stored as transactional records.
- Historical learning sessions and answers must be preserved.

### Important Database Rules

- Preserve database constraints and foreign-key relationships.
- Use PostgreSQL-specific features when appropriate, such as JSONB, partial indexes, and composite foreign keys.
- Use transactions for operations that modify multiple related records.
- Avoid deleting historical learning data.
- Use soft deletion for appropriate master and question entities.
- Do not duplicate information unnecessarily.
- Do not introduce a separate reporting table when reports can be derived reliably from transactional records.

### Schema Changes

The PostgreSQL schema design is the reference for future database implementation.

Before changing an existing table, constraint, index, or relationship:

1. Inspect the current schema.
2. Understand the reason for the change.
3. Identify its impact on existing relationships and historical records.
4. Explain any proposed structural changes.
5. Keep the database design and Laravel migrations consistent.

Do not silently redesign the database schema.

Keep PostgreSQL DDL discussions separate from Laravel migration implementation unless the task explicitly requires both.

---

## 6. Application Business Rules

The following rules are fundamental to the application.

### Authentication and Authorization

- Use Laravel Sanctum for API authentication.
- Enforce authorization on the backend.
- Frontend route protection is not a replacement for backend authorization.
- A user has one role only.
- Use permissions to control access to protected operations.
- Never trust role or permission values supplied by the frontend.

### Practice Mode

- Students can practice questions.
- Hints are available during practice.
- Feedback is provided only after the practice session ends.
- Practice sessions support a session timer and per-question timer.
- Students can retry incorrectly answered questions.
- Retry sessions preserve the original question version.

### Exercise Mode

- Exercises use a fixed question package.
- Published exercise packages must not change unexpectedly.
- Exercise sessions are timed.
- Correct answers and explanations are only revealed after submission or expiration.
- Students can review questions, answers, and explanations after completing an exercise.

### Timer Rules

Two timer mechanisms are used:

1. **Session timer**
   - Uses an absolute deadline.
   - Continues running regardless of the currently displayed question.
   - Cannot be paused.

2. **Per-question timer**
   - Tracks the active time spent on an individual question.
   - Pauses when the student navigates away.
   - Resumes using the remaining time when the student returns.
   - Must not reset when navigating between questions.

The backend is the source of truth for timer calculations.

Do not rely exclusively on browser timers for scoring, expiration, or session validation.

Avoid writing timer state to the database every second. Use timestamps and accumulated elapsed time.

### Scoring

- Calculate scores on the backend.
- Never trust client-submitted correctness or awarded points.
- Do not expose correct answers while a session is active.
- Validate all submitted answers against the question version used in the session.

---

## 7. Backend Development Guidelines

The backend is a Laravel API-only application.

### General Principles

- Follow Laravel conventions where practical.
- Keep controllers focused on HTTP request handling.
- Move complex business logic into appropriate service or action classes.
- Use Form Requests for request validation.
- Use API Resources for consistent response serialization.
- Use policies or an equivalent authorization mechanism.
- Use database transactions for multi-step business operations.
- Use dependency injection rather than manually constructing dependencies.
- Avoid unnecessary abstractions and premature optimization.

### API Design

- Use RESTful resource conventions.
- Keep response structures consistent.
- Use appropriate HTTP status codes.
- Validate request payloads on the server.
- Handle errors consistently.
- Avoid exposing internal implementation details in API responses.
- Use pagination for potentially large collections.
- Avoid returning unnecessary fields.

### Security

- Hash passwords using Laravel's supported password hashing mechanisms.
- Protect authenticated endpoints.
- Validate ownership of student resources.
- Prevent students from accessing other students' sessions or reports.
- Prevent unauthorized access to unpublished questions and answer keys.
- Never expose secrets, tokens, or sensitive data in logs.

---

## 8. Frontend Development Guidelines

The frontend uses Next.js App Router, React, TypeScript, and Tailwind CSS.

### General Principles

- Use TypeScript.
- Prefer explicit types over `any`.
- Use Server Components by default.
- Use Client Components only when browser-side interactivity or client-side state is required.
- Keep components small and focused.
- Separate UI components from business logic.
- Reuse components where there is a clear benefit.
- Avoid unnecessary global state.
- Use consistent loading, error, and empty states.

### API Integration

- Treat the Laravel backend as the source of truth.
- Do not duplicate business rules in the frontend.
- Centralize API communication where appropriate.
- Handle authentication and API errors consistently.
- Do not expose private backend credentials through public environment variables.
- Never calculate authoritative scores or correctness exclusively on the client.

### UI and UX

- Prioritize clarity and usability.
- Keep forms accessible and properly validated.
- Provide meaningful feedback for user actions.
- Ensure responsive layouts.
- Use consistent design patterns across Admin, Editor, and Student interfaces.

---

## 9. Coding Standards

All code should prioritize:

1. Readability.
2. Maintainability.
3. Correctness.
4. Security.
5. Testability.
6. Simplicity.

### General