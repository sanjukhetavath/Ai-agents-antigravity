from pydantic import BaseModel
from typing import List, Optional

class ChatRequest(BaseModel):
    message: str
    history: Optional[List[dict]] = []

class ChatResponse(BaseModel):
    response: str
    tools_used: Optional[List[str]] = []

class HealthResponse(BaseModel):
    status: str
    version: str
