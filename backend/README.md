# Chili Doctor — Flask Backend

## Folder structure

```
flask_backend/
├── run.py                     # app start කරන entry point
├── seed.py                    # admin user + sample treatments දාන script එක
├── requirements.txt
├── .env.example                # meke copy karala .env ekak hadanna
├── app/
│   ├── __init__.py            # create_app() — app factory
│   ├── config.py               # .env eken settings read karanawa
│   ├── extensions.py           # db, migrate, jwt, cors instances
│   ├── models.py                # 4 tables: User, LeafImage, Diagnosis, TreatmentGuideline
│   ├── auth/routes.py           # /api/auth/register, /api/auth/login
│   ├── api/routes.py            # /api/diagnose, /api/history, /api/treatments...
│   └── ml/predictor.py          # TensorFlow model load + 2-stage prediction
├── migrations/                  # flask db init karama methana files generate wenawa
└── uploads/                     # uploaded leaf images save wena folder eka
```

## Step by step — local machine එකේ run කරන විදිහ

### 1. MySQL database එක හදන්න
```sql
CREATE DATABASE chili_doctor CHARACTER SET utf8mb4;
```

### 2. Python virtual environment + packages
```bash
cd flask_backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 3. `.env` file එක හදන්න
```bash
cp .env.example .env
```
`.env` file එක open කරලා ඔයාගේ MySQL password එකයි, `JWT_SECRET_KEY` එකයි දාන්න.
(TensorFlow model file දෙක train කරන් ඉවර වෙනකම් `HEALTH_MODEL_PATH` /
`DISEASE_MODEL_PATH` වැරදිලා තිබුනත් කමක් නෑ — auth/history/treatment
endpoints ok විදිහට වැඩ කරයි, `/api/diagnose` විතරක් fail වෙන්නේ.)

### 4. Database tables හදන්න (migrations)
```bash
export FLASK_APP=run.py
flask db init          # මුල් වතාවට විතරයි — migrations/ folder එක හදනවා
flask db migrate -m "initial tables"
flask db upgrade        # මේකෙන් actual tables MySQL එකේ create වෙනවා
```

### 5. Sample data දාන්න (admin user + treatment guidelines)
```bash
python seed.py
```
මේකෙන් `admin@chilidoctor.com` / `ChangeThisPassword123` කියලා admin
login එකක් හදනවා — production එකට යනකොට password එක මාරු කරන්න.

### 6. Server එක run කරන්න
```bash
python run.py
```
Server එක `http://localhost:5000` වල run වෙනවා. Test කරන්න:
```bash
curl http://localhost:5000/api/health
```

## Endpoints සියල්ල

| Method | Endpoint | Auth | විස්තරය |
|---|---|---|---|
| POST | `/api/auth/register` | - | name, email, password |
| POST | `/api/auth/login` | - | email, password → token |
| POST | `/api/diagnose` | JWT | multipart image → prediction |
| GET | `/api/history` | JWT | logged-in user ගේ past diagnoses |
| GET | `/api/treatments` | JWT | guidelines ඔක්කොම |
| GET | `/api/treatment/<disease_type>/<stage>` | JWT | එක guideline එකක් |
| POST/PUT/DELETE | `/api/treatments...` | JWT (admin role) | React admin dashboard එකෙන් use කරන්න |

## තව ඕන දේවල්

1. **Model train කරන්න** — `app/ml/saved_models/` folder එකට ඔයාගේ
   `.h5` files දෙක දාන්න (health_classifier.h5, disease_classifier.h5).
   `predictor.py` එකේ input shape/output parsing එක ඔයාගේ model
   architecture එකට match වෙන විදිහට adjust කරන්න.
2. **Flutter side** — `upload_screen.dart` එකෙන් `http.post` කරලා
   `/api/diagnose` එකට image එක multipart request එකක් විදිහට යවන්න,
   login/register වලින් ලැබෙන token එක `shared_preferences` එකේ save
   කරලා ඊළඟ requests වල `Authorization: Bearer <token>` header එකට දාන්න.
3. **React admin** — login කරලා token save කරලා, `/api/treatments`
   endpoints call කරලා guidelines manage කරන්න.
