from datetime import date

from fastapi import APIRouter
from pydantic import BaseModel

from ai_service import generate_daily_question

router = APIRouter()


class DailyQuestionOut(BaseModel):
    date: str
    question: str


@router.get("/daily", response_model=DailyQuestionOut)
async def daily_question() -> DailyQuestionOut:
    today = date.today()
    question = await generate_daily_question()
    return DailyQuestionOut(date=today.isoformat(), question=question)
