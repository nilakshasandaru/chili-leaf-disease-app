# Chili Doctor — Admin Dashboard (React + Vite + Bootstrap)

## Setup

```bash
cd chili_admin_dashboard
npm install
npm run dev
```

Opens at `http://localhost:3000`.

## Before running

Edit `src/api.js` and make sure `BASE_URL` points at your Flask backend:

```js
export const BASE_URL = 'http://127.0.0.1:5001/api'
```

- Running the dashboard and Flask backend on the **same PC**: `127.0.0.1:5001` is correct.
- Running the dashboard from a different machine: use the backend PC's LAN IP instead (e.g. `http://172.31.99.152:5001/api`).

## Login

Use the admin account created by `seed.py` in the Flask backend:
- Email: `admin@chilidoctor.com`
- Password: `ChangeThisPassword123`

## What it does

- Login page — authenticates against `/api/auth/login`, checks the account has `role: admin`.
- Dashboard — lists all treatment guidelines (`GET /api/treatments`), with Add / Edit / Delete.
- Add — creates a new guideline for a disease + stage (`POST /api/treatments`).
- Edit — updates the recommendation text only (`PUT /api/treatments/<id>`) — the backend only supports editing the recommendation field, not the disease/stage.
- Delete — removes a guideline (`DELETE /api/treatments/<id>`).

The JWT token is stored in `localStorage` and attached to every request automatically.
