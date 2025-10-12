import os
from functools import lru_cache

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    GM_DB: str = os.path.expanduser("~/.global-memory/lancedb")
    GM_API_KEY: str = "GM_API_KEY"
    GM_API_PORT: int = 5057
    GM_API_HOST: str = "0.0.0.0"
    GM_API_DEBUG: bool = False
    GM_API_RELOAD: bool = False
    GM_API_RELOAD_DELAY: int = 1
    GM_API_RELOAD_DIR: str = "."
    GM_API_RELOAD_POLL_INTERVAL: int = 1
    GM_API_RELOAD_POLL_TIMEOUT: int = 1


settings = Settings()


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return settings
