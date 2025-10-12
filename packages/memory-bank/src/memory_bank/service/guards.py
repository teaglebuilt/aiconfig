from fastapi import Header, HTTPException
from typing import Optional
from memory_bank.settings import get_settings

settings = get_settings()
GM_API_KEY = settings.GM_API_KEY


async def auth(x_key: Optional[str] = Header(None, alias="X-Global-Memory-Key")) -> None:
    if GM_API_KEY and x_key != GM_API_KEY:
        raise HTTPException(status_code=401, detail="Invalid X-Global-Memory-Key")
