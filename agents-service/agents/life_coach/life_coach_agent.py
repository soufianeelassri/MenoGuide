from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai.types import Content, Part
from agents.common.task_manager import AgentWithTaskManager
from agents.life_coach.agent import get_agent
from typing import AsyncIterable, Dict, Any

class LifeCoachAgent(AgentWithTaskManager):
    """A2A Wrapper for the Life Coach Agent."""

    def __init__(self):
        self._runner: Runner | None = None
        self._session_service = InMemorySessionService()
        self._sessions: Dict[str, Any] = {}

    async def _initialize_runner(self):
        """Initializes the ADK Runner with the agent's config."""
        if self._runner is None:
            agent_instance = await get_agent()
            self._runner = Runner(
                app_name=agent_instance.name,
                agent=agent_instance,
                session_service=self._session_service,
            )
            print("Life Coach Agent Runner initialized.")

    def get_processing_message(self) -> str:
        return "Creating a safe space and preparing to support you through this journey..."

    async def run(self, user_id: str, message: str) -> AsyncIterable[Dict[str, Any]]:
        """Runs the agent and yields its responses."""
        await self._initialize_runner()

        if user_id not in self._sessions:
            session = await self._session_service.create_session(
                user_id=user_id,
                app_name="life_coach"
            )
            self._sessions[user_id] = session
            print(f"Life Coach Agent: Created new session '{session.id}' for user '{user_id}'")
        else:
            session = self._sessions[user_id]
            print(f"Life Coach Agent: Reusing session '{session.id}' for user '{user_id}'")

        content = Content(parts=[Part(text=message)])
        print(f"Life Coach Agent: Starting run for user '{user_id}' with session '{session.id}'")

        try:
            async for event in self._runner.run_async(
                session_id=session.id,
                user_id=user_id,
                new_message=content,
            ):
                if getattr(event, "content", None) and event.content.parts:
                    text = event.content.parts[0].text
                    print(f"Life Coach Agent: Yielding response part -> {text[:100]}...")
                    yield {"type": "text", "text": text}
                else:
                    print(f"Life Coach Agent: Received non-text event: {event}")
        except Exception as e:
            print(f"Life Coach Agent: Error during run_async: {e}")
            yield {"type": "error", "text": f"An error occurred: {e}"}