\# Chili Doctor — Admin Dashboard



React admin panel for managing the treatment guidelines shown to farmers in the

mobile app.



\## Setup



```bash

npm install

npm run dev

```



Opens at `http://localhost:3000`.



\## Backend URL



Set the API base URL in `src/api.js`:



```js

export const BASE\_URL = 'https://chili-doctor-backend.onrender.com/api'

```



Use `http://127.0.0.1:5001/api` instead when running against a local backend.



\## Login



Admin accounts only — farmer accounts are rejected with an "admin access required"

message. The seeded admin account is `admin@chilidoctor.com`.



\## Features



\- \*\*Login\*\* — authenticates against `/api/auth/login` and checks the account role

\- \*\*List\*\* — shows all treatment guidelines (`GET /api/treatments`)

\- \*\*Add\*\* — creates a guideline for a disease and stage (`POST /api/treatments`)

\- \*\*Edit\*\* — updates the recommendation text (`PUT /api/treatments/<id>`)

\- \*\*Delete\*\* — removes a guideline (`DELETE /api/treatments/<id>`)



The JWT is stored in `localStorage` and attached to every request by an Axios

interceptor. A 401 response clears the session and returns to the login page.



\## Build



```bash

npm run build

```



Outputs to `dist/`. Deployed on Vercel with the root directory set to

`admin\_dashboard`.

