import os
from dotenv import load_dotenv

load_dotenv()

from app import create_app
from app.extensions import db

app = create_app()

# On a fresh cloud database the tables won't exist yet, and Render's free
# tier has no shell to run migrations from - so create them (and seed the
# starting data) on startup if they're missing.
with app.app_context():
    db.create_all()

    from app.models import User, TreatmentGuideline

    if not User.query.filter_by(email="admin@chilidoctor.com").first():
        admin = User(name="Admin", email="admin@chilidoctor.com",
                     role="admin", is_active=True)
        admin.set_password("ChangeThisPassword123")
        db.session.add(admin)

    SAMPLE_GUIDELINES = [
        ("Leaf Curl", "early", "Remove and destroy affected leaves. Spray with neem oil (5ml/litre) every 7 days. Ensure proper spacing between plants for airflow."),
        ("Leaf Curl", "late", "Remove severely affected plants to stop spread. Apply a systemic insecticide to control whitefly vectors. Consult local agri office for approved chemical options."),
        ("Cercospora Spot", "early", "Remove infected leaves. Apply a copper-based fungicide. Avoid overhead irrigation to reduce leaf wetness."),
        ("Cercospora Spot", "late", "Apply fungicide at 10-14 day intervals. Improve field drainage. Rotate crops next season to reduce soil-borne spores."),
        ("Yellowing", "early", "Check soil nitrogen levels and apply balanced fertilizer. Ensure consistent watering schedule."),
        ("Yellowing", "late", "Test soil for nutrient deficiency or root disease. Apply corrective fertilizer and consider a foliar feed."),
        ("Bacterial Spot", "early", "Remove affected leaves and avoid working in the field when plants are wet. Apply copper-based bactericide."),
        ("Bacterial Spot", "late", "Remove and destroy heavily infected plants. Rotate with non-host crops. Use certified disease-free seed next season."),
    ]

    for disease_type, stage, recommendation in SAMPLE_GUIDELINES:
        exists = TreatmentGuideline.query.filter_by(
            disease_type=disease_type, stage=stage
        ).first()
        if not exists:
            db.session.add(TreatmentGuideline(
                disease_type=disease_type, stage=stage,
                recommendation=recommendation))

    db.session.commit()

if __name__ == "__main__":
    debug_mode = os.getenv("FLASK_DEBUG", "1") == "1"
    app.run(host="0.0.0.0", port=app.config["PORT"], debug=debug_mode)