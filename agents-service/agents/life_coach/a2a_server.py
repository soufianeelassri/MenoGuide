import os
import json
import asyncio
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import StreamingResponse
from dotenv import load_dotenv

from agents.common.types import AgentCard, AgentCapabilities, AgentSkill
from agents.life_coach.life_coach_agent import LifeCoachAgent

load_dotenv()

HOST = os.environ.get("A2A_HOST", "0.0.0.0")
PORT = int(os.environ.get("PORT", 8080))
PUBLIC_URL = os.environ.get("PUBLIC_URL", f"http://{HOST}:{PORT}")

app = FastAPI(
    title="Life Coach Agent (A2A)",
    description="A2A server for the Menopause Wellness Life Coach Agent.",
    version="1.0.0",
)

life_coach_agent_instance = LifeCoachAgent()

@app.get("/agent-card", response_model=AgentCard)
def get_agent_card():
    """Provides the agent's public capabilities card."""
    skill = AgentSkill(
        id="menopause_life_coaching",
        name="Menopause Life Coaching",
        description="Provides emotional support and life coaching for navigating menopause challenges.",
        tags=["life coaching", "menopause", "emotional support", "wellness"],
        examples=["I'm feeling overwhelmed with mood swings", "How can I cope with the stress of menopause?", "I need help managing my anxiety during this transition"],
    )
    capabilities = AgentCapabilities(streaming=True)
    agent_card = AgentCard(
        name="Life Coach",
        description="Provides empathetic support and life coaching guidance for emotional challenges during menopause.",
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
    message = request.query_params.get("message", "User is seeking life coaching support.")

    async def stream_generator():
        async for update in life_coach_agent_instance.run(user_id=task_id, message=message):
            yield f"data: {json.dumps(update)}\n\n"
        yield f"data: {json.dumps({'type': 'end_of_stream'})}\n\n"

    return StreamingResponse(stream_generator(), media_type="text/event-stream")

@app.get("/")
def read_root():
    return {"status": "Life Coach Agent is running"}