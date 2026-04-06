# Task Management Platform

Task Management Platform built for the assignment using FastAPI microservices, PostgreSQL, React, TypeScript, and custom CSS.

## Overview

This project is split into:

- an **auth service** for login, profile management, password changes, OTP-based registration, and logout
- a **task service** for task CRUD, board/list views, comments, attachments, analytics, dashboard data, CSV import, and CSV export
- a **React frontend** for dashboard, tasks, task detail/edit, analytics, profile, login, and registration

## Tech Stack

### Backend

- FastAPI
- SQLAlchemy
- Pydantic
- PostgreSQL
- JWT + server-side session validation

### Frontend

- React with hooks
- TypeScript
- Vite
- React Router
- Custom CSS

## Core Features

### Authentication

- Login
- OTP-based registration through email
- Current user profile
- Edit profile
- Change password
- Logout with backend session revocation
- Protected routes with JWT validation on every request

### Tasks

- Create task
- Edit task
- Soft delete task
- Full-page task editor
- List view
- Board view
- Search
- Sorting
- Pagination
- Multi-select filters
- Bulk create from CSV
- CSV template download
- CSV export

### Collaboration

- Add comments
- Edit own comments
- Delete own comments
- Upload attachments
- Download attachments
- Delete attachments

### Dashboard and Analytics

- Workspace dashboard with dedicated dashboard API
- Dashboard summary cards
- Due timeline
- Due soon tasks
- Team pulse
- Recently updated tasks
- Analytics overview
- Status distribution
- Priority breakdown
- User performance metrics
- Trend charts

## Architecture Decisions

### 1. Why FastAPI

FastAPI was chosen for the backend because it supports rapid API development while still keeping the code structured and production-like.

Reason:

- built-in request and response validation through Pydantic
- automatic Swagger / OpenAPI documentation
- clean dependency injection for authentication and protected routes
- fits well for separating auth and task services without adding a lot of framework complexity

### 2. Split into two backend microservices

The backend is separated into:

- **Auth service** on port `3000`
- **Task service** on port `3001`

Reason:

- keeps authentication concerns isolated from task management
- makes API boundaries clearer

### 3. Master tables for state, priority, and tags

Tasks do **not** store raw state/priority strings as the source of truth.

Instead:

- `tasks.state_id -> task_states_master.id`
- `tasks.priority_id -> task_priorities_master.id`
- tags use many-to-many through `task_tags(task_id, tag_id)`

Reason:

- normalized schema
- better referential integrity
- easier filtering and reporting

### 4. JWT with backend session validation

Authentication uses JWT, but logout is not purely client-side.

The system also stores sessions in `user_sessions`, and protected routes validate:

- token signature
- token expiry
- active session row

Reason:

- supports real logout / revocation
- prevents old logged-out tokens from remaining valid

### 5. Dedicated APIs for dashboard and board view

The frontend does not build everything from the generic task list endpoint.

Examples:

- `/api/dashboard/overview`
- `/api/tasks/board`

Reason:

- cleaner frontend
- less overfetching
- easier to tailor responses to each screen

## Data Model Summary

Key entities:

- `users`
- `user_sessions`
- `registration_otps`
- `tasks`
- `comments`
- `attachments`
- `task_states_master`
- `task_priorities_master`
- `tags_master`
- `task_tags`

Important relationships:

- `tasks.creator_id -> users.id`
- `tasks.assigned_to_id -> users.id`
- `tasks.state_id -> task_states_master.id`
- `tasks.priority_id -> task_priorities_master.id`
- `comments.task_id -> tasks.id`
- `comments.author_id -> users.id`
- `attachments.task_id -> tasks.id`
- `attachments.uploaded_by_id -> users.id`
- `task_tags.task_id -> tasks.id`
- `task_tags.tag_id -> tags_master.id`

## Project Structure

```text
backend/
  businesslogic/
  common/
  config/
  datamodels/
  handlers/
  microservices/
frontend/
  src/
uploads/
docker-compose.yml
README.md
```

## Setup Instructions

### Prerequisites

Install:

- Python 3.9
- Node.js v24.14.1
- PostgreSQL 18

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd "Task Management System"
```

### 2. Backend setup

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

### 3. Frontend setup

```bash
cd frontend
npm install
cp .env.example .env
```

### 4. Create the database

Create a PostgreSQL database named `task_management_system`, then restore the backup SQL file from the `database/` folder.

```bash
createdb task_management_system
psql -d task_management_system -f database/dump-task_management_system.sql
```

If you are using a custom PostgreSQL user, run:

```bash
createdb -U postgres task_management_system
psql -U postgres -d task_management_system -f database/dump-task_management_system.sql
```

Then make sure `backend/.env` points to the same database:

- database name: `task_management_system`
- user: `postgres`
- host: `localhost`
- port: `5432`


### Frontend (`frontend/.env`)

```env
VITE_AUTH_API_URL=http://localhost:3000/api
VITE_TASK_API_URL=http://localhost:3001/api
```

## How To Run The Application

### Run backend services

Open one terminal:

```bash
cd backend
source .venv/bin/activate
uvicorn microservices.auth_server:app --reload --port 3000
```

Open a second terminal:

```bash
cd backend
source .venv/bin/activate
uvicorn microservices.task_server:app --reload --port 3001
```

### Run frontend

Open a third terminal:

```bash
cd frontend
npm run dev
```

### Default local URLs

- Frontend: [http://localhost:4200](http://localhost:4200)
- Auth API: [http://localhost:3000](http://localhost:3000)
- Task API: [http://localhost:3001](http://localhost:3001)

## Docker

To run with Docker:

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
docker compose up
```

Docker services:

- Frontend: [http://localhost:4200](http://localhost:4200)
- Auth API: [http://localhost:3000](http://localhost:3000)
- Task API: [http://localhost:3001](http://localhost:3001)
- PostgreSQL: `localhost:5432`

Important:

- `docker-compose.yml` currently uses its own Postgres container defaults:
  - `POSTGRES_PASSWORD=postgres`
  - `POSTGRES_DB=task_management`
- if you run with Docker, make sure `backend/.env` matches the container values, or provide `DATABASE_URL` explicitly

## API Documentation

Swagger UI:

- Auth service: [http://localhost:3000/docs](http://localhost:3000/docs)
- Task service: [http://localhost:3001/docs](http://localhost:3001/docs)

OpenAPI JSON:

- Auth service: [http://localhost:3000/openapi.json](http://localhost:3000/openapi.json)
- Task service: [http://localhost:3001/openapi.json](http://localhost:3001/openapi.json)

## Assumptions Made

- All authenticated users can view and work with the shared task workspace
- Ownership-based authorization is enforced where it matters most for this project:
  - users can only edit/delete their own comments
- Attachments are stored on the local filesystem instead of cloud object storage
- The app uses IST (`Asia/Kolkata`) as the backend business timezone
- Registration requires OTP email delivery and does not allow direct account creation without verification
- Task tags are reusable master records, not free-form per-task string blobs


## Reviewer Notes

- Start both backend services and the frontend before using the app.
- Register a user through the UI to begin testing.
- Swagger docs are available at the `/docs` endpoints listed above.


## Test Credentials
Username: satwickmanepalli@gmail.com
Password: Satwick@789
