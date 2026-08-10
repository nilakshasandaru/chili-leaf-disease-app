
# Chili Leaf Disease Detection App

Mobile application for early and late-stage classification of chili leaf diseases using deep learning.

**Team: Innovatex** — Rajarata University of Sri Lanka, Department of Physical Sciences
ICT/CS Group Project (ICT3411 / COM3405)

---

## Live Deployment

| Component | URL |
|---|---|
| Backend API | https://chili-doctor-backend.onrender.com |
| Admin Dashboard | https://chili-doctor-admin.vercel.app |
| Mobile App | Android APK (see Releases / shared link) |

**Admin login:** `admin@chilidoctor.com`

> The backend runs on a free hosting tier and spins down after ~15 minutes of
> inactivity. The first request after an idle period can take 30–60 seconds.

---

## Project Structure

---

## Tech Stack

**Backend** — Flask, SQLAlchemy, Flask-Migrate, Flask-JWT-Extended, Flask-Mail, Flask-CORS
**Database** — MySQL (local development) / PostgreSQL (deployed)
**Mobile** — Flutter (Dart), http, image_picker, shared_preferences, url_launcher
**Admin** — React, Vite, Bootstrap, Axios, React Router
**ML** — TensorFlow/Keras, MobileNetV2 transfer learning
**Hosting** — Render (backend + database), Vercel (admin dashboard)

---

## Machine Learning Model

A single 9-class CNN classifies a leaf image as Healthy, or as one of four
diseases at either an early or late stage:

| Disease | Stages |
|---|---|
| Leaf Curl | Early / Late |
| Cercospora Spot | Early / Late |
| Yellowing | Early / Late |
| Bacterial Spot | Early / Late |

**Architecture:** MobileNetV2 (ImageNet pretrained, frozen) → GlobalAveragePooling2D
→ Dense(128, ReLU) → Dropout(0.3) → Dense(9, Softmax), followed by a fine-tuning
phase on the last 30 base layers.

**Dataset:** 9,539 images across 9 categories, split 70% train / 15% validation / 15% test.

**Result:** Test accuracy **90.05%**, test loss 0.3365 on a held-out set of 1,427 images.

---

## Backend Setup (local development)

```bash
cd backend
python -m venv venv
venv\Scripts\activate          # Windows
pip install -r requirements-core.txt
pip install -r requirements-ml.txt   # TensorFlow, only needed for /api/diagnose

cp .env.example .env           # then fill in your database password
```

Create the database, then run:

```bash
python run.py
```

The server starts on the port set in `.env` (default 5001).

### API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register` | — | Create an account (inactive until verified) |
| GET | `/api/auth/verify/<token>` | — | Activate an account via the emailed link |
| POST | `/api/auth/login` | — | Authenticate, returns a JWT |
| POST | `/api/diagnose` | JWT | Upload a leaf image, returns the diagnosis |
| GET | `/api/history` | JWT | Past diagnoses (supports `?from=` / `?to=` date filters) |
| GET | `/api/treatments` | JWT | All treatment guidelines |
| GET | `/api/treatment/<disease>/<stage>` | JWT | One guideline |
| POST/PUT/DELETE | `/api/treatments...` | JWT (admin) | Manage guidelines |

---

## Mobile App Setup

```bash
cd mobile_app
flutter pub get
```

Set the backend URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://chili-doctor-backend.onrender.com/api';
```

Then run on a connected device, or build a release APK:

```bash
flutter run -d <device-id>
flutter build apk --release
```

---

## Admin Dashboard Setup

```bash
cd admin_dashboard
npm install
npm run dev
```

Set the backend URL in `src/api.js`:

```js
export const BASE_URL = 'https://chili-doctor-backend.onrender.com/api'
```

---

## Database Schema

| Table | Purpose |
|---|---|
| `users` | Accounts, hashed passwords, role, activation status |
| `leaf_images` | Uploaded image metadata and file paths |
| `diagnoses` | Prediction results: disease type, stage, confidence |
| `treatment_guidelines` | Admin-managed recommendations per disease + stage |

Relationships: a user has many leaf images; each leaf image has one diagnosis;
each diagnosis maps to a treatment guideline by disease type and stage.

---

## Team

| Name | Registration Number | Index |
|---|---|---|
| M.K.N.S. Mihiran | ASP/2022/098 | 5854 |
| E.L. Binura | ASB/2022/057 | 5777 |
| A.M.S.R. Weerakoon | ASP/2022/063 | 5866 |
| R.A.O.D. Ranasinghe | ASP/2022/093 | 5953 |
| R.M. Mahavithana | ASP/2022/087 | 5896 |