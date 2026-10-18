# Hackspace frontend

Commands in this document run from `hackspace-frontend/`.

React + Vite application for the Hackspace API. Students register and submit hackathon work, evaluators score assigned submissions, and admins run hackathons, users, and reviews.

## Tech stack

- React 19 and Vite 8, with the React Compiler
- react-router-dom, with role-based route guards
- Cookie auth. The backend sets an HttpOnly `access_token` and a readable `csrf_token`
- CSS in the app. There is no component library

## Local development

The API must already be running on port 8000. See [backend.md](backend.md).

```bash
npm install
npm run dev       # http://127.0.0.1:5173
npm run build
npm run preview
npm run lint
```

Open **http://127.0.0.1:5173**. Vite is bound to `127.0.0.1` because Firebase Phone Auth rejects `localhost`.

Create `.env` (gitignored). Leave the API base empty so the browser stays on the Vite host:

```env
VITE_API_BASE_URL=
VITE_API_TARGET=http://127.0.0.1:8000

VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_APP_ID=
```

`.env.development` is loaded in dev mode and must use the same `VITE_API_TARGET`. Vite proxies `/auth`, `/admin`, `/hackathons`, `/submissions`, and the other API prefixes to that target. The login cookie is stored for `127.0.0.1`.

## Production

`npm run build` reads `.env.production`:

```env
VITE_API_BASE_URL=/api
```

The Cloud Run image serves the built files with nginx. The browser calls `/api/...` on the frontend host. nginx removes `/api` and forwards the request to `hackspace-backend`, then passes `Set-Cookie` back so the cookies belong to the frontend host. Details are in [deployment.md](deployment.md).

## Layout

```text
src/
├── api/            # client and endpoint modules
├── components/     # ui, layout, routing, evaluation, hackathons
├── context/        # AuthContext via GET /auth/me
├── hooks/
├── pages/          # auth, student, evaluator, admin
├── utils/
├── App.jsx
└── main.jsx
```

Screens and API paths are the product. Deploy files (`Dockerfile`, `nginx.conf.template`, `cloudbuild.yaml`) do not change them.
