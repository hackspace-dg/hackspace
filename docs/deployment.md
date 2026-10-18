# Deployment

Hackspace runs as two Cloud Run services in **asia-south1**.

| Service | Config | What it does |
|---------|--------|----------------|
| `hackspace-backend` | `hackspace-backend/cloudbuild.yaml` | FastAPI on port 8080. Firebase, GCS, and Gemini come from environment variables and Secret Manager. |
| `hackspace-frontend` | `hackspace-frontend/cloudbuild.yaml` | Built Vite app behind nginx. Listens on `$PORT` (8080). Sends React routes to `index.html`. Proxies `/api/` to the backend and strips the `/api` prefix. |

The browser never calls the backend hostname. Login cookies are set on the frontend host.

```text
Browser
  → https://hackspace-frontend-….run.app/api/auth/login
  → nginx
  → https://hackspace-backend-….run.app/auth/login
```

Both Cloud Build files set `dir` to their app folder because the GitHub checkout root is the repository, not the app.

## One-time Google Cloud setup

Project used by this repository: **hackspace-dg**. Region: **asia-south1**.

1. Enable Cloud Build, Artifact Registry, Cloud Run, Secret Manager, Cloud Tasks, Cloud Storage, IAM, Logging, and Vertex AI.
2. Create a Cloud Build service account and grant it Artifact Registry admin, Storage admin, Cloud Tasks admin, Cloud Run admin, Secret Manager accessor, Logs writer, and Service Account User.
3. Grant the Cloud Run runtime service account Secret Manager accessor, Cloud Tasks enqueuer, and Vertex AI user.
4. Grant the Firebase Admin service account Storage object admin. Video uploads use that key.
5. Create these Secret Manager secrets before the first backend build: `FIREBASE_PROJECT_ID`, `FIREBASE_PRIVATE_KEY`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_WEB_API_KEY`, `FIREBASE_DATABASE_URL`, `INTERNAL_JOB_SECRET`, `SMTP_USERNAME`, `SMTP_PASSWORD`.

Do not put `.env` or the Firebase service-account JSON in the image or in git.

## Triggers

Connect `hackspace-dg/hackspace` and create one trigger per service, both on `^master$`. Set **Included files** so a push rebuilds only the app that changed. Without that filter, every commit to `master` starts both builds.

| Trigger | Config file | Included files |
|---------|-------------|----------------|
| `hackspace-backend` | `hackspace-backend/cloudbuild.yaml` | `hackspace-backend/**` |
| `hackspace-frontend` | `hackspace-frontend/cloudbuild.yaml` | `hackspace-frontend/**` |

A commit that changes only `docs/` or `README.md` starts neither build. A commit that changes both app folders starts both. In the console this is **Cloud Build → Triggers → Edit → Included files**. Clicking **Run** on a trigger still builds that service even when no matching file changed.

Leave the frontend substitution `_BACKEND_URL` empty. The build reads the live `hackspace-backend` URL. After the frontend deploys, that same build sets the backend `ALLOWED_ORIGINS` to the frontend URL, sets `COOKIE_SAMESITE=lax`, and updates CORS on `gs://$PROJECT_ID-hackathon-evaluations`.

Add the frontend hostname, without `https://`, under Firebase **Authentication → Settings → Authorized domains**. Phone sign-in needs that domain. Email login does not.

`ENVIRONMENT=production` turns off `/docs`. Check the backend with `/health`.

## Local versus cloud

| | Local | Cloud Run |
|--|--------|-----------|
| API | `http://127.0.0.1:8000` | `hackspace-backend` |
| App | Vite on `http://127.0.0.1:5173` | `hackspace-frontend` |
| API base | empty; Vite proxies path prefixes | `/api`; nginx proxies |
| Cookies | `COOKIE_SAMESITE=lax` | `lax`, because the proxy is same-origin |
| Seed | `SEED_ON_STARTUP=true` creates the super admin | first backend build may set this true once, then leave it false |
