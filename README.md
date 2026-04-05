# Task Management Platform

Task Management Platform built for the Jr SDE assignment using:

- FastAPI microservices
- PostgreSQL
- classic SQLAlchemy tables + imperative mappings
- JWT authentication with backend session tracking
- React + TypeScript
- custom CSS without UI frameworks

## Overview

The project has:

- an auth service for registration, login, profile, password change, and logout
- a task service for task management, comments, attachments, analytics, and dashboard APIs
- a React frontend with dedicated screens for dashboard, tasks, task editor, analytics, profile, login, and registration

## Tech Stack

### Backend

- FastAPI
- SQLAlchemy
- Pydantic
- PostgreSQL
- JWT

### Frontend

- React
- TypeScript
- Vite
- React Router

## Implemented Features

### Authentication

- User registration
- User login
- Current user profile
- Edit profile
- Change password
- Logout endpoint
- JWT validation on protected routes
- Session table for server-side logout/revocation checks

### Tasks

- Create task
- Edit task
- Soft delete task
- Full-page task editor
- Board view
- List view
- Search, sort, pagination
- Multi-select filters for:
  - assigned to
  - state
  - priority
  - tags
- Bulk task creation from CSV
- CSV template download
- CSV export

### Task Collaboration

- Add comments
- Edit own comments
- Delete own comments
- Upload attachments
- Download attachments
- Delete attachments

### Dashboard and Analytics

- Workspace dashboard with dedicated backend API
- Dashboard summary cards
- Due timeline
- Due soon view
- Team pulse
- Recently touched tasks
- Analytics overview statistics
- Task status donut chart
- Priority breakdown
- User performance metrics
- Task trends over time

### UI/UX

- Responsive layout
- Custom styling
- Loading states
- Error states
- Empty states
- Confirmation dialogs for destructive actions
- Drag-and-drop file upload support

## Current Data Model Notes

- `tasks.state_id` is a foreign key to `task_states_master.id`
- `tasks.priority_id` is a foreign key to `task_priorities_master.id`
- tags are stored through a many-to-many join table:
  - `task_tags(task_id, tag_id)`
- user auth sessions are stored in:
  - `user_sessions`

The API still returns readable values like `state`, `priority`, and `tags` for frontend use.

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

## Running Locally

### 1. Backend Setup

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

Make sure PostgreSQL is running and update `backend/.env` if needed.

Run the services:

```bash
uvicorn microservices.auth_server:app --reload --port 3000
uvicorn microservices.task_server:app --reload --port 3001
```

### 2. Frontend Setup

```bash
cd frontend
npm install
cp .env.example .env
npm run dev
```

Frontend runs at:

- [http://localhost:4200](http://localhost:4200)

## Docker Setup

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
docker compose up
```

Services:

- Frontend: [http://localhost:4200](http://localhost:4200)
- Auth API: [http://localhost:3000](http://localhost:3000)
- Task API: [http://localhost:3001](http://localhost:3001)

## API Documentation

Swagger docs:

- Auth service: [http://localhost:3000/docs](http://localhost:3000/docs)
- Task service: [http://localhost:3001/docs](http://localhost:3001/docs)

OpenAPI exports:

- Auth OpenAPI JSON: [http://localhost:3000/openapi.json](http://localhost:3000/openapi.json)
- Task OpenAPI JSON: [http://localhost:3001/openapi.json](http://localhost:3001/openapi.json)

## Architecture Notes

- Authentication and task management are split into separate FastAPI services.
- Backend uses classic SQLAlchemy `Table` definitions with imperative mapping.
- Task master data is stored in dedicated master tables for states, priorities, and tags.
- Attachments are stored locally in the `uploads/` directory.
- Backend includes startup migration logic for moving older task state/priority/tag storage into the current FK-based schema.
- Dashboard has a dedicated backend overview endpoint instead of building the page from raw task list calls.

## Important Defaults

- Frontend port: `4200`
- Auth service port: `3000`
- Task service port: `3001`

## Notes for Reviewers

- Register a user from the UI or through the auth API before using the app.
- Swagger documentation is available at the `/docs` endpoints listed above.
- Logout is backed by a server-side session table, so revoked sessions no longer validate on protected routes.
