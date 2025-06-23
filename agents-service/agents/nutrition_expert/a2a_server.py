import os
import json
import asyncio
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import StreamingResponse
from dotenv import load_dotenv

from agents.common.types import AgentCard, AgentCapabilities, AgentSkill
from agents.nutrition_expert.nutrition_agent import NutritionAgent

load_dotenv()

HOST = os.environ.get("A2A_HOST", "0.0.0.0")
PORT = int(os.environ.get("PORT", 8080))
PUBLIC_URL = os.environ.get("PUBLIC_URL", f"http://{HOST}:{PORT}")

app = FastAPI(
    title="Nutrition Expert Agent (A2A)",
    description="A2A server for the Menopause Wellness Nutrition Expert Agent.",
    version="1.0.0",
)

nutrition_agent_instance = NutritionAgent()

@app.get("/agent-card", response_model=AgentCard)
def get_agent_card():
    """Provides the agent's public capabilities card."""
    skill = AgentSkill(
        id="menopause_nutrition",
        name="Menopause Nutrition Advice",
        description="Provides personalized dietary advice for menopause symptoms based on a knowledge base.",
        tags=["nutrition", "menopause", "health"],
        examples=["What can I eat to help with hot flashes?", "Tell me about supplements for sleep issues."],
    )
    capabilities = AgentCapabilities(streaming=True)
    agent_card = AgentCard(
        name="Nutrition Expert",
        description="Provides personalized, evidence-based dietary advice for menopause symptoms.",
        url=f"{PUBLIC_URL}",
        version="1.0.0",
        defaultInputModes=["text"],
        defaultOutputModes=["text"],
        capabilities=capabilities,
        skills=[skill],
    )
    return agent_card

@app.post("/v1/tasks")
async def create_task(request: Request):
    """Creates a new task for the agent. (Simplified for this use case)"""
    data = await request.json()
    user_id = data.get("user_id")
    if not user_id:
        raise HTTPException(status_code=400, detail="user_id is required")
    return {"task_id": user_id, "status": "processing"}

@app.get("/v1/tasks/{task_id}/updates")
async def get_task_updates(task_id: str, request: Request):
    """Streams updates (agent responses) for a given task."""
    message = request.query_params.get("message", "User is seeking advice.")

    async def stream_generator():
        async for update in nutrition_agent_instance.run(user_id=task_id, message=message):
            yield f"data: {json.dumps(update)}\n\n"
        yield f"data: {json.dumps({'type': 'end_of_stream'})}\n\n"

    return StreamingResponse(stream_generator(), media_type="text/event-stream")

@app.get("/")
def read_root():
    return {"status": "Nutrition Expert Agent is running"}