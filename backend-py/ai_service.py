"""Günlük soru ve ileride chat için AI yardımcıları."""

import os
from datetime import date
from typing import Optional

from constants import AI_MODEL

# Yerel / demo: API anahtarı yoksa statik soru havuzu
_FALLBACK_QUESTIONS = [
    "Bugün evcil dostunuz nasıl hissediyor gibi görünüyor?",
    "Son 24 saatte iştahında bir değişiklik fark ettiniz mi?",
    "Bugün ne kadar su içtiğini gözlemlediniz mi?",
    "Egzersiz veya oyun süresi alışılmış düzeyde miydi?",
    "Davranışında dikkat çeken bir şey oldu mu?",
]


def daily_question_for(day: Optional[date] = None) -> str:
    """Verilen gün için günlük soru metni (deterministik demo)."""
    target = day or date.today()
    index = target.toordinal() % len(_FALLBACK_QUESTIONS)
    return _FALLBACK_QUESTIONS[index]


async def generate_daily_question() -> str:
    """
    OPENAI_API_KEY tanımlıysa ileride gerçek model çağrısı yapılabilir;
    şimdilik demo havuzu kullanılır.
    """
    if not os.getenv("OPENAI_API_KEY"):
        return daily_question_for()

    # Genişletme noktası: httpx ile OpenAI / başka sağlayıcı
    _ = AI_MODEL
    return daily_question_for()
