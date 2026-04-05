# Task Management Platform

Task management platform built from the provided assignment with:

- `FastAPI` backend
- `PostgreSQL` database
- `Classic SQLAlchemy` datamodels and query style
- `JWT` authentication
- `React + TypeScript` frontend
- Two backend microservices:
  - `auth_server.py`
  - `task_server.py`

## Implemented Features

- User registration, login, and current profile
- Task CRUD with soft delete
- Bulk task creation
- Board view with drag-and-drop state changes
- List view with filtering, searching, sorting, and pagination
- Task detail drawer with:
  - ID
  - Title
  - Assigned to
  - State
  - Start date
  - End date
  - Target date
  - Description
  - Priority
  - Created date
  - File attachments
  - Estimated effort
  - Actual effort derived from start/end dates
- Comments on tasks
- File uploads with validation
- Analytics dashboard and export
- Responsive custom blue UI inspired by Azure Boards

## Project Structure

```text
backend/
  auth_service/
    auth_server.py
  task_service/
    task_server.py
  businesslogic/
  common/
  config/
  datamodels/
  handlers/
frontend/
  src/
docs/
uploads/
```

## Backend Setup

1. Create a Python virtual environment.
2. Install dependencies:

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

3. Copy the environment file:

```bash
cp .env.example .env
```

4. Make sure PostgreSQL is running and update `.env` if needed.

5. Run the microservices:

```bash
uvicorn auth_service.auth_server:app --reload --port 3000
uvicorn task_service.task_server:app --reload --port 3001
```

## Frontend Setup

```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```

Frontend default URL: `http://localhost:4200`

## Docker Setup

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
docker compose up
```

## API Documentation

FastAPI Swagger docs:

- Auth service: `http://localhost:3000/docs`
- Task service: `http://localhost:3001/docs`

## Architecture Decisions

- Split authentication and task management into separate FastAPI apps to match the microservice requirement.
- Shared database configuration and classic SQLAlchemy mappings live in a common backend layer.
- Classic SQLAlchemy `Table` definitions plus imperative mapping are used instead of declarative models.
- File uploads are stored locally in the `uploads/` directory for simplicity.
- Actual effort is calculated from `start_date` and `end_date`.
- The frontend uses a board/list dual-mode task experience instead of separate disconnected screens.

## Assumptions

- `assigned_to` is stored as a user reference when available.
- File storage is local for the assignment implementation.
- Actual effort is expressed in hours using calendar-day difference between start and end dates.
- Rate limiting is implemented in-memory for the task service.
- Comments support plain text only.

## Suggested Demo Credentials

Register a user from the UI, or create one through `/api/auth/register`, then use the same account across the app.
