import re
import threading
from flask import Blueprint, request, jsonify, render_template_string, current_app
from flask_jwt_extended import create_access_token
from flask_mail import Message
from app.extensions import db, mail
from app.models import User

auth_bp = Blueprint("auth", __name__)

EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


def _validate_email(email):
    return bool(EMAIL_RE.match(email))


def _validate_password(password):
    if len(password) < 8:
        return False, "Password must be at least 8 characters long."
    if not re.search(r"[A-Za-z]", password):
        return False, "Password must include at least one letter."
    if not re.search(r"[0-9]", password):
        return False, "Password must include at least one number."
    return True, None


def _verification_link(user):
    return f"{current_app.config['APP_BASE_URL']}/api/auth/verify/{user.verification_token}"


def _email_body(user, link):
    return (
        f"Hi {user.name},\n\n"
        f"Please verify your Chili Doctor account by opening this link:\n{link}\n\n"
        f"If you didn't create this account, you can ignore this email."
    )


def _send_via_elastic_email(user, link):
    import requests
    response = requests.post(
        "https://api.elasticemail.com/v2/email/send",
        data={
            "apikey": current_app.config["ELASTIC_EMAIL_API_KEY"],
            "from": current_app.config["ELASTIC_EMAIL_FROM"],
            "fromName": "Chili Doctor",
            "to": user.email,
            "subject": "Verify your Chili Doctor account",
            "bodyText": _email_body(user, link),
        },
        timeout=15,
    )
    result = response.json()
    if not result.get("success"):
        raise Exception(f"Elastic Email error: {result.get('error')}")


def _send_via_resend(user, link):
    import resend
    resend.api_key = current_app.config["RESEND_API_KEY"]
    resend.Emails.send({
        "from": current_app.config["RESEND_FROM_EMAIL"],
        "to": [user.email],
        "subject": "Verify your Chili Doctor account",
        "text": _email_body(user, link),
    })


def _send_via_smtp(user, link):
    msg = Message(
        subject="Verify your Chili Doctor account",
        recipients=[user.email],
        body=_email_body(user, link),
    )
    mail.send(msg)


def _send_verification_email(user):
    link = _verification_link(user)

    try:
        if current_app.config.get("ELASTIC_EMAIL_API_KEY"):
            _send_via_elastic_email(user, link)
            print(f"[MAIL] Verification email sent to {user.email} via Elastic Email", flush=True)
            return True

        if current_app.config.get("RESEND_API_KEY"):
            _send_via_resend(user, link)
            print(f"[MAIL] Verification email sent to {user.email} via Resend", flush=True)
            return True

        if current_app.config.get("MAIL_USERNAME"):
            _send_via_smtp(user, link)
            print(f"[MAIL] Verification email sent to {user.email} via SMTP", flush=True)
            return True

        print(f"\n[DEV] Verification link for {user.email}:\n{link}\n", flush=True)
        return True

    except Exception as exc:
        current_app.logger.error(f"Failed to send verification email: {exc}")
        print(f"\n[DEV] Email send failed, verification link for {user.email}:\n{link}\n", flush=True)
        return False


def _send_verification_email_async(app_obj, user_id):
    with app_obj.app_context():
        user = User.query.get(user_id)
        if user:
            _send_verification_email(user)


@auth_bp.post("/register")
def register():
    data = request.get_json(silent=True) or {}
    name = data.get("name", "").strip()
    email = data.get("email", "").strip().lower()
    password = data.get("password", "")

    if not name or not email or not password:
        return jsonify({"error": "name, email and password are required"}), 400

    if not _validate_email(email):
        return jsonify({"error": "Please enter a valid email address."}), 400

    password_ok, password_error = _validate_password(password)
    if not password_ok:
        return jsonify({"error": password_error}), 400

    if User.query.filter_by(email=email).first():
        return jsonify({"error": "An account with this email already exists"}), 409

    user = User(name=name, email=email, role="farmer", is_active=False)
    user.set_password(password)
    user.generate_verification_token()
    db.session.add(user)
    db.session.commit()

    link = _verification_link(user)

    app_obj = current_app._get_current_object()
    threading.Thread(
        target=_send_verification_email_async,
        args=(app_obj, user.id),
        daemon=True,
    ).start()

    return jsonify({
        "message": "Account created. Please check your email to verify your account before logging in.",
        "user": user.to_dict(),
        "verification_link": link,
    }), 201


@auth_bp.get("/verify/<token>")
def verify_email(token):
    user = User.query.filter_by(verification_token=token).first()

    page = """
    <html><body style="font-family: sans-serif; text-align:center; padding-top: 80px;">
    <h2>{{ title }}</h2><p>{{ message }}</p>
    </body></html>
    """

    if not user:
        return render_template_string(page, title="Invalid link", message="This verification link is invalid or has already been used."), 400

    user.is_active = True
    user.verification_token = None
    db.session.commit()

    return render_template_string(page, title="Account verified!", message="You can now log in from the Chili Doctor app.")


@auth_bp.post("/login")
def login():
    data = request.get_json(silent=True) or {}
    email = data.get("email", "").strip().lower()
    password = data.get("password", "")

    user = User.query.filter_by(email=email).first()
    if not user or not user.check_password(password):
        return jsonify({"error": "Invalid email or password"}), 401

    if not user.is_active:
        return jsonify({"error": "Your account is not activated. Please verify your email first."}), 403

    token = create_access_token(identity=str(user.id))
    return jsonify({"token": token, "user": user.to_dict()}), 200