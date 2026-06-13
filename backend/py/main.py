import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from constants import CORS_ORIGINS, HOST, PORT
from routers import entries, questions

app = FastAPI(
    title="PetTrack AI Service",
    description="Python API: günlük soru ve diary entries (FastAPI)",
    version="0.1.0",
)

# Vercel: FRONTEND_ORIGIN veya CORS_ORIGINS ile sınırla; yoksa tüm origin'lere izin ver.
# Not: allow_origins=["*"] ile allow_credentials=True birlikte kullanılamaz.
_vercel = os.getenv("VERCEL") == "1"
_frontend = os.getenv("FRONTEND_ORIGIN", "http://localhost:1575").strip()
_cors_env = os.getenv("CORS_ORIGINS", "").strip()
if _cors_env:
    _origins = [o.strip() for o in _cors_env.split(",") if o.strip()]
elif _vercel and _frontend:
    _origins = [_frontend, "http://localhost:1575"]
else:
    _origins = CORS_ORIGINS

app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins if _origins else ["*"],
    allow_credentials=bool(_origins and _origins != ["*"]),
    allow_methods=["*"],
    allow_headers=["*"],
)

# Yerel geliştirme (port 1572)
app.include_router(questions.router, prefix="/api/questions", tags=["questions"])
app.include_router(entries.router, prefix="/api/entries", tags=["entries"])

# Vercel yönlendirmesi: /api/ai/* → py/main.py
app.include_router(questions.router, prefix="/api/ai/questions", tags=["questions-ai"])
app.include_router(entries.router, prefix="/api/ai/entries", tags=["entries-ai"])


@app.get("/health")
def health():
    return {"status": "ok", "service": "pettrack-py"}


@app.get("/api/ai/health")
def health_ai():
    return {"status": "ok", "service": "pettrack-py", "mount": "/api/ai"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host=HOST, port=PORT, reload=True)
