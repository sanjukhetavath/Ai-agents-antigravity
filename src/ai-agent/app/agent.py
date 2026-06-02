from langchain_openai import ChatOpenAI
from langchain.agents import AgentExecutor, create_openai_tools_agent
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.messages import HumanMessage, AIMessage
from app.tools import get_all_tools
from app.config import settings

def create_agent():
    if not settings.openai_api_key:
        print("WARNING: OPENAI_API_KEY is not set. Agent will fail if called.")
        
    llm = ChatOpenAI(
        model=settings.openai_model,
        temperature=0,
        api_key=settings.openai_api_key or "dummy"
    )
    
    tools = get_all_tools()
    
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a helpful AI agent. Use your tools to answer the user's questions."),
        MessagesPlaceholder(variable_name="chat_history"),
        ("user", "{input}"),
        MessagesPlaceholder(variable_name="agent_scratchpad"),
    ])
    
    agent = create_openai_tools_agent(llm, tools, prompt)
    agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
    
    return agent_executor

def run_agent(agent_executor, message: str, history: list):
    chat_history = []
    for h in history:
        if h.get("role") == "user":
            chat_history.append(HumanMessage(content=h.get("content")))
        elif h.get("role") == "assistant":
            chat_history.append(AIMessage(content=h.get("content")))
            
    response = agent_executor.invoke({
        "input": message,
        "chat_history": chat_history
    })
    
    return response["output"]
