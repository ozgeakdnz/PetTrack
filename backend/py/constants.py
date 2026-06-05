import os
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parent / ".env")

HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "1572"))

_default_origins = [
    os.getenv("FRONTEND_ORIGIN", "http://localhost:1575"),
    os.getenv("MOBILE_ORIGIN", "http://localhost"),
]
CORS_ORIGINS = [
    origin.strip()
    for origin in os.getenv("CORS_ORIGINS", ",".join(_default_origins)).split(",")
    if origin.strip()
]

AI_MODEL = os.getenv("AI_MODEL", "gpt-4o-mini")
