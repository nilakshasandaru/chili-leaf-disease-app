from datetime import datetime, timezone
import secrets
from werkzeug.security import generate_password_hash, check_password_hash
from app.extensions import db


def _now():
    return datetime.now(timezone.utc)


def _gen_token():
    return secrets.token_urlsafe(32)


def _iso_utc(dt):
    """MySQL stores naive datetimes, so tag them as UTC before serializing.
    Without the timezone marker the mobile app can't convert to local time."""
    if dt is None:
        return None
    return dt.replace(tzinfo=timezone.utc).isoformat()


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), nullable=False, default="farmer")

    is_active = db.Column(db.Boolean, nullable=False, default=False)
    verification_token = db.Column(db.String(64), unique=True, nullable=True)

    created_at = db.Column(db.DateTime, default=_now)

    leaf_images = db.relationship("LeafImage", backref="user", lazy=True)
    diagnoses = db.relationship("Diagnosis", backref="user", lazy=True)

    def set_password(self, raw_password):
        self.password_hash = generate_password_hash(raw_password)

    def check_password(self, raw_password):
        return check_password_hash(self.password_hash, raw_password)

    def generate_verification_token(self):
        self.verification_token = _gen_token()
        return self.verification_token

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "role": self.role,
            "is_active": self.is_active,
            "created_at": _iso_utc(self.created_at),
        }


class LeafImage(db.Model):
    __tablename__ = "leaf_images"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    filename = db.Column(db.String(255), nullable=False)
    filepath = db.Column(db.String(500), nullable=False)
    uploaded_at = db.Column(db.DateTime, default=_now)

    diagnosis = db.relationship("Diagnosis", backref="leaf_image", uselist=False)

    def to_dict(self):
        return {
            "id": self.id,
            "filename": self.filename,
            "uploaded_at": _iso_utc(self.uploaded_at),
        }


class Diagnosis(db.Model):
    __tablename__ = "diagnoses"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    leaf_image_id = db.Column(db.Integer, db.ForeignKey("leaf_images.id"), nullable=False)

    is_healthy = db.Column(db.Boolean, nullable=False)
    disease_type = db.Column(db.String(50), nullable=True)
    stage = db.Column(db.String(20), nullable=True)
    confidence = db.Column(db.Float, nullable=False, default=0.0)

    created_at = db.Column(db.DateTime, default=_now)

    def to_dict(self):
        return {
            "id": self.id,
            "leaf_image_id": self.leaf_image_id,
            "is_healthy": self.is_healthy,
            "disease_type": self.disease_type,
            "stage": self.stage,
            "confidence": round(self.confidence, 4),
            "created_at": _iso_utc(self.created_at),
        }


class TreatmentGuideline(db.Model):
    __tablename__ = "treatment_guidelines"
    __table_args__ = (
        db.UniqueConstraint("disease_type", "stage", name="uq_disease_stage"),
    )

    id = db.Column(db.Integer, primary_key=True)
    disease_type = db.Column(db.String(50), nullable=False)
    stage = db.Column(db.String(20), nullable=False)
    recommendation = db.Column(db.Text, nullable=False)
    updated_at = db.Column(db.DateTime, default=_now, onupdate=_now)

    def to_dict(self):
        return {
            "id": self.id,
            "disease_type": self.disease_type,
            "stage": self.stage,
            "recommendation": self.recommendation,
            "updated_at": _iso_utc(self.updated_at),
        }