# Hackspace

Hackspace is a hackathon platform. Organizers publish rounds, students submit work, evaluators score it with a rubric and optional Gemini review, and admins publish results.

The repository is two services:

| Directory | Role |
|-----------|------|
| [`hackspace-frontend`](hackspace-frontend) | React 19 and Vite. Students, evaluators, and admins use this app. |
| [`hackspace-backend`](hackspace-backend) | FastAPI. Firebase Auth, Firestore, Cloud Storage, and Gemini. |

Production runs both on Cloud Run in `asia-south1`. The browser talks only to the frontend. nginx forwards `/api` to the backend.

## What people can do

- **Students** register, join a published round solo or as a team, and submit once per round.
- **Evaluators** work only on assigned submissions. They can run AI review and send a score for admin approval.
- **Admins** create hackathons, publish rounds, assign evaluators, approve scores, and publish leaderboards.

Students see a report and score only after an admin publishes that evaluation.

## Local setup

Use Python 3.12 for the API and a current Node.js for the app. Copy the examples and fill in the Firebase project you are using. Do not commit `.env` or a service-account JSON file.

**API** — from `hackspace-backend/`:

```bash
python3.12 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
cp .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Interactive API docs: http://127.0.0.1:8000/docs

**App** — from `hackspace-frontend/`:

```bash
npm install
npm run dev
```

Open http://127.0.0.1:5173. The dev server proxies API calls to port 8000. Phone sign-in requires `127.0.0.1`, not `localhost`.

With `SEED_ON_STARTUP=true`, the first API start creates the super admin described in `hackspace-backend/app/utils/seeder.py`.

## Documentation

| Document | Contents |
|----------|----------|
| [docs/frontend.md](docs/frontend.md) | App setup, env vars, and production `/api` proxy |
| [docs/backend.md](docs/backend.md) | API reference, auth, hackathons, submissions, and evaluation |
| [docs/architecture.md](docs/architecture.md) | Services, Firestore, jobs, and request flow |
| [docs/deployment.md](docs/deployment.md) | Cloud Build, Secret Manager, and the two Cloud Run services |

## Deploy

Each app has its own `cloudbuild.yaml`. A push to `master` builds that app when its Cloud Build trigger is connected. The frontend image serves the Vite build and proxies `/api` to `hackspace-backend`. Secrets stay in Secret Manager.

The full setup is in [docs/deployment.md](docs/deployment.md).

## Development commands

From `hackspace-backend/`:

```bash
pytest
black .
flake8 app
```

From `hackspace-frontend/`:

```bash
npm run lint
npm run build
```

## License

[MIT](LICENSE)
