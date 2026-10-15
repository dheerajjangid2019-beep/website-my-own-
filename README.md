# Bhawani Interior website

This repository contains the static website in `frontend/` and a dependency-free Node.js backend in `backend/server.js`. The backend serves the website, stores consultation requests in SQLite, protects the lead dashboard with an admin session, and can proxy AI Designer requests to Gemini.

## Run locally

Requirements: Node.js 24.x.

1. Copy `.env.example` to `.env`.
2. Set `ADMIN_PASSWORD` in `.env` to a private password of at least 12 characters.
3. Optionally set `GEMINI_API_KEY` to enable the AI Designer. The key is used only by the backend.
4. From the project directory, run `npm start` or double-click `Start Website.bat` on Windows.
5. Open the URL printed in the terminal. The checked-in example uses port 3000; your local `.env` may use a different port.

When `NODE_ENV=development`, the backend watches `frontend/` and refreshes the open browser automatically after you save HTML, CSS, JavaScript, or image changes. Keep the server window open and leave the browser preview on the same site URL. Changes to `backend/server.js` need a server restart; press `Ctrl+C` in the server window, then start it again. Do not set `NODE_ENV=development` on the production host.

The first run creates `backend/data/website.sqlite`. The admin dashboard uses the password from `ADMIN_PASSWORD`; lead access is protected by an HTTP-only, same-site session cookie. Sessions expire after eight hours or when the server restarts.

## API

- `GET /api/health` — service status
- `POST /api/leads` — validate and save a consultation request
- `POST /api/admin/login` — authenticate and create an admin session
- `POST /api/admin/logout` — end the current session
- `GET /api/admin/leads` — list leads (admin session required)
- `DELETE /api/admin/leads/:id` — delete a lead (admin session required)
- `POST /api/chat` — send design chat messages to Gemini (requires `GEMINI_API_KEY`)

Keep `.env` and `backend/data/` private. For production, configure `NODE_ENV=production`, `ADMIN_PASSWORD`, and `DATA_DIR` in the host dashboard. Set `DATA_DIR` to the host's persistent disk mount path and use a paid service that supports persistent storage. The server binds to `0.0.0.0` in production and uses the host-provided `PORT`; locally it binds only to `127.0.0.1`. Serve the site over HTTPS so the admin session cookie is marked Secure.
