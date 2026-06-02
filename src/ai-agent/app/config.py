from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "ai-agent"
    app_version: str = "0.1.0"
    log_level: str = "INFO"
    openai_api_key: str = ""
    openai_model: str = "gpt-4o-mini"

    class Config:
        env_file = ".env"

settings = Settings()
