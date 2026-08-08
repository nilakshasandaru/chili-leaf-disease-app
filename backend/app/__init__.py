import os
from flask import Flask, jsonify
from app.config import Config
from app.extensions import db, migrate, jwt, cors, mail


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

    # --- init extensions ---
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    cors.init_app(app, resources={r"/api/*": {"origins": "*"}})
    mail.init_app(app)

    # --- register blueprints ---
    from app.auth.routes import auth_bp
    from app.api.routes import api_bp

    app.register_blueprint(auth_bp, url_prefix="/api/auth")
    app.register_blueprint(api_bp, url_prefix="/api")

    @app.get("/api/health")
    def health_check():
        return {"status": "ok"}, 200

    @app.errorhandler(404)
    def handle_404(e):
        return jsonify({"error": "The requested resource was not found."}), 404

    @app.errorhandler(413)
    def handle_413(e):
        return jsonify({"error": "The uploaded file is too large. Maximum size is 8 MB."}), 413

    @app.errorhandler(500)
    def handle_500(e):
        app.logger.exception("Unhandled server error")
        return jsonify({"error": "Something went wrong on our end. Please try again shortly."}), 500

    return app