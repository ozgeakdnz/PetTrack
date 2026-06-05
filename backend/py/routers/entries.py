from datetime import datetime, timezone
from typing import Dict, List, Optional
from uuid import uuid4

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

router = APIRouter()

_entries: Dict[str, dict] = {}


class EntryCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    body: str = Field(default="", max_length=5000)
    pet_id: Optional[str] = None


class EntryUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=200)
    body: Optional[str] = Field(default=None, max_length=5000)
    pet_id: Optional[str] = None


class EntryOut(BaseModel):
    id: str
    title: str
    body: str
    pet_id: Optional[str]
    created_at: str
    updated_at: str


def _serialize(entry: dict) -> EntryOut:
    return EntryOut(**entry)


@router.get("", response_model=List[EntryOut])
def list_entries() -> List[EntryOut]:
    items = sorted(_entries.values(), key=lambda e: e["created_at"], reverse=True)
    return [_serialize(e) for e in items]


@router.get("/{entry_id}", response_model=EntryOut)
def get_entry(entry_id: str) -> EntryOut:
    entry = _entries.get(entry_id)
    if not entry:
        raise HTTPException(status_code=404, detail="Entry not found")
    return _serialize(entry)


@router.post("", response_model=EntryOut, status_code=201)
def create_entry(payload: EntryCreate) -> EntryOut:
    now = datetime.now(timezone.utc).isoformat()
    entry_id = str(uuid4())
    entry = {
        "id": entry_id,
        "title": payload.title,
        "body": payload.body,
        "pet_id": payload.pet_id,
        "created_at": now,
        "updated_at": now,
    }
    _entries[entry_id] = entry
    return _serialize(entry)


@router.patch("/{entry_id}", response_model=EntryOut)
def update_entry(entry_id: str, payload: EntryUpdate) -> EntryOut:
    entry = _entries.get(entry_id)
    if not entry:
        raise HTTPException(status_code=404, detail="Entry not found")

    data = payload.model_dump(exclude_unset=True)
    for key, value in data.items():
        entry[key] = value
    entry["updated_at"] = datetime.now(timezone.utc).isoformat()
    return _serialize(entry)


@router.delete("/{entry_id}", status_code=204)
def delete_entry(entry_id: str) -> None:
    if entry_id not in _entries:
        raise HTTPException(status_code=404, detail="Entry not found")
    del _entries[entry_id]
