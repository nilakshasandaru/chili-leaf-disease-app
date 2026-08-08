import os
from datetime import timedelta

basedir = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))


class Config:
    # --- Local MySQL settings (used when DATABASE_URL isn't set) ---
    DB_USER = os.getenv("DB_USER", "root")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "")
    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_PORT = os.getenv("DB_PORT", "3306")
    DB_NAME = os.getenv("DB_NAME", "chili_doctor")

    # Render (and most cloud hosts) provide a single DATABASE_URL for the
    # managed PostgreSQL instance. SQLAlchemy needs the "postgresql://"
    # scheme, but Render still hands out the older "postgres://" form.
    _render_db = os.getenv("DATABASE_URL", "")
    if _render_db.startswith("postgres://"):
        _render_db = _render_db.replace("postgres://", "postgresql://", 1)

    SQLALCHEMY_DATABASE_URI = _render_db or (
        f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # --- JWT ---
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "dev-secret-change-me")
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=7)

    # --- Uploads ---
    UPLOAD_FOLDER = os.path.join(basedir, os.getenv("UPLOAD_FOLDER", "uploads"))
    MAX_CONTENT_LENGTH = 8 * 1024 * 1024
    ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}

    # --- ML model ---
    MODEL_PATH = os.getenv(
        "MODEL_PATH", "app/ml/saved_models/chili_disease_model.h5"
    )

    # --- Server ---
    PORT = int(os.getenv("PORT", "5001"))

    # --- Email ---
    MAIL_SERVER = os.getenv("MAIL_SERVER", "smtp.gmail.com")
    MAIL_PORT = int(os.getenv("MAIL_PORT", "587"))
    MAIL_USE_TLS = True
    MAIL_USERNAME = os.getenv("MAIL_USERNAME", "")
    MAIL_PASSWORD = os.getenv("MAIL_PASSWORD", "")
    MAIL_DEFAULT_SENDER = os.getenv("MAIL_DEFAULT_SENDER", MAIL_USERNAME or "no-reply@chilidoctor.local")

    APP_BASE_URL = os.getenv("APP_BASE_URL", f"http://127.0.0.1:{PORT}")