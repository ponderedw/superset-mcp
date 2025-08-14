import os
database_password = os.environ.get("DATABASE_PASSWORD")
database_host = os.environ.get("DATABASE_HOST")
database_name = os.environ.get("DATABASE_NAME")
database_user = os.environ.get("DATABASE_USER")
admin_password = os.environ.get("ADMIN_PASSWORD")

FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
    "DASHBOARD_CROSS_FILTERS": True,
    "DRILL_TO_DETAIL": True
}

ENABLE_PROXY_FIX = True
SECRET_KEY = "YOUR_OWN_RANDOM_GENERATED_STRING"

SQLALCHEMY_DATABASE_URI = f"postgresql+psycopg2://{database_user}:{database_password}@{database_host}:5432/{database_name}"
SQLALCHEMY_ECHO = True
