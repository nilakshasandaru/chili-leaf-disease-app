import os
import uuid
from datetime import datetime
from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from werkzeug.utils import secure_filename

from app.extensions import db
from app.models import User, LeafImage, Diagnosis, TreatmentGuideline
from app.ml.predictor import predict

api_bp = Blueprint("api", __name__)


def _allowed_file(filename):
    ext = filename.rsplit(".", 1)[-1].lower() if "." in filename else ""
    return ext in current_app.config["ALLOWED_EXTENSIONS"]


def _uid():
    return int(get_jwt_identity())


def _current_user():
    return User.query.get(_uid())


@api_bp.post("/diagnose")
@jwt_required()
def diagnose():
    if "image" not in request.files:
        return jsonify({"error": "No image file provided (field name must be 'image')"}), 400

    file = request.files["image"]
    if file.filename == "" or not _allowed_file(file.filename):
        return jsonify({"error": "Please upload a .png/.jpg/.jpeg image"}), 400

    filename = f"{uuid.uuid4().hex}_{secure_filename(file.filename)}"
    filepath = os.path.join(current_app.config["UPLOAD_FOLDER"], filename)
    file.save(filepath)

    leaf_image = LeafImage(user_id=_uid(), filename=filename, filepath=filepath)
    db.session.add(leaf_image)
    db.session.commit()

    try:
        result = predict(filepath)
    except Exception as exc:
        return jsonify({"error": f"Prediction failed: {exc}"}), 500

    diagnosis = Diagnosis(
        user_id=_uid(),
        leaf_image_id=leaf_image.id,
        is_healthy=result["is_healthy"],
        disease_type=result["disease_type"],
        stage=result["stage"],
        confidence=result["confidence"],
    )
    db.session.add(diagnosis)
    db.session.commit()

    return jsonify(diagnosis.to_dict()), 201


@api_bp.get("/history")
@jwt_required()
def history():
    query = Diagnosis.query.filter_by(user_id=_uid())

    from_str = request.args.get("from")
    to_str = request.args.get("to")

    if from_str:
        try:
            from_date = datetime.strptime(from_str, "%Y-%m-%d")
        except ValueError:
            return jsonify({"error": "Invalid 'from' date - use YYYY-MM-DD"}), 400
        query = query.filter(Diagnosis.created_at >= from_date)

    if to_str:
        try:
            to_date = datetime.strptime(to_str, "%Y-%m-%d")
        except ValueError:
            return jsonify({"error": "Invalid 'to' date - use YYYY-MM-DD"}), 400
        to_date = to_date.replace(hour=23, minute=59, second=59)
        query = query.filter(Diagnosis.created_at <= to_date)

    diagnoses = query.order_by(Diagnosis.created_at.desc()).all()
    return jsonify([d.to_dict() for d in diagnoses]), 200


@api_bp.get("/treatment/<disease_type>/<stage>")
@jwt_required()
def get_treatment(disease_type, stage):
    guideline = TreatmentGuideline.query.filter_by(
        disease_type=disease_type, stage=stage
    ).first()
    if not guideline:
        return jsonify({"error": "No guideline found for this disease/stage"}), 404
    return jsonify(guideline.to_dict()), 200


@api_bp.get("/treatments")
@jwt_required()
def list_treatments():
    guidelines = TreatmentGuideline.query.order_by(
        TreatmentGuideline.disease_type, TreatmentGuideline.stage
    ).all()
    return jsonify([g.to_dict() for g in guidelines]), 200


def _require_admin():
    user = _current_user()
    return user is not None and user.role == "admin"


@api_bp.post("/treatments")
@jwt_required()
def create_treatment():
    if not _require_admin():
        return jsonify({"error": "Admin access required"}), 403

    data = request.get_json(silent=True) or {}
    disease_type = data.get("disease_type")
    stage = data.get("stage")
    recommendation = data.get("recommendation")

    if not disease_type or not stage or not recommendation:
        return jsonify({"error": "disease_type, stage and recommendation are required"}), 400

    guideline = TreatmentGuideline(
        disease_type=disease_type, stage=stage, recommendation=recommendation
    )
    db.session.add(guideline)
    db.session.commit()
    return jsonify(guideline.to_dict()), 201


@api_bp.put("/treatments/<int:guideline_id>")
@jwt_required()
def update_treatment(guideline_id):
    if not _require_admin():
        return jsonify({"error": "Admin access required"}), 403

    guideline = TreatmentGuideline.query.get_or_404(guideline_id)
    data = request.get_json(silent=True) or {}
    guideline.recommendation = data.get("recommendation", guideline.recommendation)
    db.session.commit()
    return jsonify(guideline.to_dict()), 200


@api_bp.delete("/treatments/<int:guideline_id>")
@jwt_required()
def delete_treatment(guideline_id):
    if not _require_admin():
        return jsonify({"error": "Admin access required"}), 403

    guideline = TreatmentGuideline.query.get_or_404(guideline_id)
    db.session.delete(guideline)
    db.session.commit()
    return jsonify({"message": "Deleted"}), 200