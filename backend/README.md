\# Chili Doctor — Flask Backend



REST API for the Chili Leaf Disease Detection App: authentication, image upload,

TensorFlow inference, and treatment guideline management.



\## Folder Structure

backend/

├── run.py Entry point (creates tables + seed data on first run)

├── seed.py Standalone seeding script

├── requirements-core.txt Core dependencies (no TensorFlow)

├── requirements-ml.txt TensorFlow, needed only for /api/diagnose

├── .env.example Copy to .env and fill in real values

├── render.yaml Render deployment config

├── app/

│ ├── init.py Application factory + error handlers

│ ├── config.py Settings loaded from environment variables

│ ├── extensions.py db, migrate, jwt, cors, mail instances

│ ├── models.py User, LeafImage, Diagnosis, TreatmentGuideline

│ ├── auth/routes.py Register, email verification, login

│ ├── api/routes.py Diagnose, history, treatment guidelines

│ └── ml/predictor.py Image preprocessing + CNN inference

└── uploads/ Uploaded leaf images



\## Local Setup



\*\*1. Create the database\*\*



```sql

CREATE DATABASE chili\_doctor CHARACTER SET utf8mb4;

```



\*\*2. Virtual environment and dependencies\*\*



```bash

python -m venv venv

venv\\Scripts\\activate          # Windows

source venv/bin/activate       # macOS / Linux



pip install -r requirements-core.txt

pip install -r requirements-ml.txt   # only needed for /api/diagnose

```



\*\*3. Environment file\*\*



```bash

cp .env.example .env

```



Fill in your MySQL password and a JWT secret key. Leave `MAIL\_USERNAME` blank to

skip real email sending — the verification link is printed to the console instead,

which is fine for local testing.



\*\*4. Create the tables\*\*



```bash

set FLASK\_APP=run.py           # Windows

export FLASK\_APP=run.py        # macOS / Linux



flask db init

flask db migrate -m "initial tables"

flask db upgrade

```



\*\*5. Seed the starting data\*\*



```bash

python seed.py

```



Creates an admin account (`admin@chilidoctor.com`) and eight treatment guidelines.



\*\*6. Run\*\*



```bash

python run.py

```



Test with `curl http://localhost:5001/api/health`.



\## API Endpoints



| Method | Endpoint | Auth | Description |

|---|---|---|---|

| GET | `/api/health` | — | Service health check |

| POST | `/api/auth/register` | — | Create an account (inactive until verified) |

| GET | `/api/auth/verify/<token>` | — | Activate an account |

| POST | `/api/auth/login` | — | Authenticate, returns a JWT |

| POST | `/api/diagnose` | JWT | Upload a leaf image (multipart, field name `image`) |

| GET | `/api/history` | JWT | Past diagnoses, optional `?from=` / `?to=` filters |

| GET | `/api/treatments` | JWT | All treatment guidelines |

| GET | `/api/treatment/<disease>/<stage>` | JWT | One guideline |

| POST | `/api/treatments` | JWT (admin) | Create a guideline |

| PUT | `/api/treatments/<id>` | JWT (admin) | Update a guideline |

| DELETE | `/api/treatments/<id>` | JWT (admin) | Delete a guideline |



\## Machine Learning Model



Place the trained model at `app/ml/saved\_models/chili\_disease\_model.h5`.



The model is a 9-class classifier (Healthy, plus four diseases at early and late

stages). `app/ml/predictor.py` loads it lazily on the first prediction request and

maps the predicted class to a disease type and stage.



If the class order from training differs from the alphabetical default, update

`CLASS\_NAMES` in `predictor.py` to match the `class\_indices` printed by Keras

during training.



\## Deployment Notes



Deployed on Render with a managed PostgreSQL database. The same code runs against

MySQL locally — `config.py` uses `DATABASE\_URL` when it is set, and falls back to

the local MySQL settings otherwise.

