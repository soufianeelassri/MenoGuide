from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai.types import Content, Part
from agents.common.task_manager import AgentWithTaskManager
from agents.community_connector.agent import get_agent
from typing import AsyncIterable, Dict, Any

class CommunityConnectorAgent(AgentWithTaskManager):
    """A2A Wrapper for the Community Connector Agent."""

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
            print("Community Connector Agent Runner initialized.")

    def get_processing_message(self) -> str:
        return "Searching for communities and resources to connect you with others who understand your journey..."

    async def run(self, user_id: str, message: str) -> AsyncIterable[Dict[str, Any]]:
        """Runs the agent and yields its responses."""
        await self._initialize_runner()

        if user_id not in self._sessions:
            session = await self._session_service.create_session(
                user_id=user_id,
                app_name="community_connector"
            )
            self._sessions[user_id] = session
            print(f"Community Connector Agent: Created new session '{session.id}' for user '{user_id}'")
        else:
            session = self._sessions[user_id]
            print(f"Community Connector Agent: Reusing session '{session.id}' for user '{user_id}'")

        content = Content(parts=[Part(text=message)])
        print(f"Community Connector Agent: Starting run for user '{user_id}' with session '{session.id}'")

        try:
            async for event in self._runner.run_async(
                session_id=session.id,
                user_id=user_id,
                new_message=content,
            ):
                if getattr(event, "content", None) and event.content.parts:
                    text = event.content.parts[0].text
                    print(f"Community Connector Agent: Yielding response part -> {text[:100]}...")
                    yield {"type": "text", "text": text}
                else:
                    print(f"Community Connector Agent: Received non-text event: {event}")
        except Exception as e:
            print(f"Community Connector Agent: Error during run_async: {e}")
            yield {"type": "error", "text": f"An error occurred: {e}"}