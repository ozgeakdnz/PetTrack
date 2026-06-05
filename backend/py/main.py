from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from constants import CORS_ORIGINS, HOST, PORT
from routers import entries, questions

app = FastAPI(
    title="PetTrack Python API",
    description="İkinci backend: günlük soru ve diary entries (FastAPI)",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(entries.router, prefix="/api/entries", tags=["entries"])
app.include_router(questions.router, prefix="/api/questions", tags=["questions"])


@app.get("/health")
def health():
    return {"status": "ok", "service": "pettrack-py"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host=HOST, port=PORT, reload=True)
