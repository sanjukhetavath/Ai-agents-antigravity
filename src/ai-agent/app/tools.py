from langchain.tools import tool
from langchain_community.tools import DuckDuckGoSearchRun
from datetime import datetime

search_tool = DuckDuckGoSearchRun()

@tool
def calculator(expression: str) -> str:
    """Evaluates a mathematical expression."""
    try:
        # Warning: eval is dangerous in production, use a safe parser instead
        # For this prototype, using eval carefully with restricted globals
        allowed_names = {"__builtins__": None}
        return str(eval(expression, allowed_names, {}))
    except Exception as e:
        return f"Error evaluating expression: {str(e)}"

@tool
def get_current_time(query: str = "") -> str:
    """Returns the current date and time."""
    return str(datetime.now())

def get_all_tools():
    return [search_tool, calculator, get_current_time]
