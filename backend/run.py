import os
from dotenv import load_dotenv

load_dotenv()  # reads .env before Config is evaluated

from app import create_app

app = create_app()

if __name__ == "__main__":
    debug_mode = os.getenv("FLASK_DEBUG", "1") == "1"
    app.run(host="0.0.0.0", port=app.config["PORT"], debug=debug_mode)