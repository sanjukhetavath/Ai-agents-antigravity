from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.models import ChatRequest, ChatResponse, HealthResponse
from app.config import settings
from app.agent import create_agent, run_agent

app = FastAPI(title=settings.app_name, version=settings.app_version)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Lazy loading of agent
agent_executor = None

@app.on_event("startup")
async def startup_event():
    global agent_executor
    agent_executor = create_agent()

@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(status="ok", version=settings.app_version)

@app.get("/")
async def root():
    return {"message": f"Welcome to {settings.app_name} API"}

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    if not settings.openai_api_key:
        raise HTTPException(status_code=500, detail="OpenAI API key not configured")
        
    try:
        response_text = run_agent(agent_executor, request.message, request.history)
        # Note: tools_used is a placeholder here as extracting exact tools used 
        # requires parsing the intermediate steps from AgentExecutor
        return ChatResponse(response=response_text, tools_used=[])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
