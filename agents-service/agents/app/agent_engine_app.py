import os
import logging
import argparse
import google.auth
import vertexai
from vertexai.preview import reasoning_engines
from google.adk.agents import Agent
from google.api_core import exceptions
from agents.app.utils import gcs
import asyncio
import uuid
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai.types import Content, Part

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")


class AgentApp(reasoning_engines.ReasoningEngine):
    """
    Wrapper to make a Google ADK Agent compatible with Vertex AI Reasoning Engine.
    """
    def __init__(self, agent: Agent):
        self.project_id = None
        self.location = None
        self.remote_agent_addresses = None
        
        self._agent = agent
        self._runner: Runner | None = None
        self._session_service = InMemorySessionService()

    def set_up(self):
        """
        This method runs ONCE on the Vertex AI backend when the agent is initialized.
        We use it to set the environment variables for the agent's runtime process.
        """
        logging.info("Running set_up() on the backend...")

        if self.project_id and self.location:
            os.environ["GOOGLE_CLOUD_PROJECT"] = self.project_id
            os.environ["GOOGLE_CLOUD_LOCATION"] = self.location
            os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "true"
            logging.info(f"Set runtime GOOGLE_CLOUD_PROJECT to: {os.environ['GOOGLE_CLOUD_PROJECT']}")
        
        if self.remote_agent_addresses:
            os.environ["REMOTE_AGENT_ADDRESSES"] = self.remote_agent_addresses
            logging.info(f"Set runtime REMOTE_AGENT_ADDRESSES to: {os.environ['REMOTE_AGENT_ADDRESSES']}")

        if self._runner is None:
            self._runner = Runner(
                app_name=self._agent.name,
                agent=self._agent,
                session_service=self._session_service,
            )
            logging.info(f"ADK Runner for agent '{self._agent.name}' initialized successfully on backend.")


    async def query(self, **kwargs) -> dict:
        """
        Asynchronous query method. The Reasoning Engine runtime will await this
        coroutine directly.
        """
        if not self._runner:
            self.set_up()

        text_input = kwargs.get("text")
        if not text_input:
            logging.error("Query received without 'text' input.")
            return {"error": "Input 'text' is missing from the query."}
        
        logging.info(f"Received query: '{text_input}'")

        user_id = str(uuid.uuid4())
        session = await self._session_service.create_session(
            user_id=user_id, app_name=self._agent.name
        )
        logging.info(f"Created session {session.id} for query.")
        
        message = Content(parts=[Part(text=text_input)])
        
        full_response_parts = []
        try:
            async for event in self._runner.run_async(
                session_id=session.id, user_id=user_id, new_message=message
            ):
                if getattr(event, "content", None) and event.content.parts:
                    text_part = event.content.parts[0].text
                    if text_part:
                        full_response_parts.append(text_part)
        except Exception as e:
            logging.error(f"Error during agent execution: {e}", exc_info=True)
            return {"error": f"An error occurred during agent execution: {e}"}

        full_response = "".join(full_response_parts)
        logging.info("Agent generated full response.")
        
        logging.info(f"Agent runner returned: {full_response}")
        return {"response": full_response}

def deploy_to_agent_engine(
    project_id: str,
    location: str,
    agent_name: str,
    agent_to_deploy: Agent,
):
    """Packages and deploys a Google ADK agent to Vertex AI Agent Engine."""
    
    staging_bucket = f"gs://{project_id}-agent-engine-staging"
    gcs.create_bucket_if_not_exists(staging_bucket, project_id, location)
    vertexai.init(project=project_id, location=location, staging_bucket=staging_bucket)

    deployment_app = AgentApp(agent=agent_to_deploy)
    
    remote_agent_addresses = os.getenv("REMOTE_AGENT_ADDRESSES")
    if not remote_agent_addresses:
        raise ValueError("CRITICAL: REMOTE_AGENT_ADDRESSES environment variable not set.")
        
    deployment_app.project_id = project_id
    deployment_app.location = location
    deployment_app.remote_agent_addresses = remote_agent_addresses
    logging.info(f"Attaching config to AgentApp instance: project='{project_id}', location='{location}'")
    
    extra_packages = ["./agents"]
    
    deployment_config = {
        "reasoning_engine": deployment_app,
        "display_name": agent_name,
        "description": agent_to_deploy.description,
        "requirements": ["google-adk", "python-dotenv"],
        "extra_packages": extra_packages,
    }

    logging.info(f"Starting deployment of agent '{agent_name}' to Agent Engine...")

    try:
        existing_agents = reasoning_engines.ReasoningEngine.list(
            filter=f'display_name="{agent_name}"'
        )
        if existing_agents:
            remote_agent = existing_agents[0]
            logging.info(f"Found existing agent '{agent_name}'. Updating it...")
            operation = remote_agent.update(**deployment_config)
        else:
            logging.info(f"No existing agent found. Creating new agent '{agent_name}'...")
            operation = reasoning_engines.ReasoningEngine.create(**deployment_config)

        logging.info("Waiting for deployment operation to complete... This may take 5-10 minutes.")
        final_agent = operation
        logging.info(f"Agent '{agent_name}' deployed successfully!")
        logging.info(f"Resource Name: {final_agent.resource_name}")
        return final_agent

    except exceptions.InvalidArgument as e:
        logging.error(f"Build failed during agent deployment: {e}", exc_info=True)
        raise
    except Exception as e:
        logging.error(f"An unexpected error occurred during deployment: {e}", exc_info=True)
        raise

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Deploy Maestro Agent to Vertex AI Agent Engine")
    parser.add_argument("--project-id", help="GCP project ID")
    parser.add_argument("--location", default="us-central1", help="GCP region")
    parser.add_argument("--agent-name", default="maestro-wellness-agent", help="Display name for the agent")
    parser.add_argument("--remote-agents", required=True, help="Comma-separated URLs of specialist agents")
    args = parser.parse_args()

    project_id = args.project_id
    if not project_id:
        _, project_id = google.auth.default()

    os.environ["REMOTE_AGENT_ADDRESSES"] = args.remote_agents

    from agents.maestro.agent import root_agent as maestro_agent
    
    deploy_to_agent_engine(
        project_id=project_id,
        location=args.location,
        agent_name=args.agent_name,
        agent_to_deploy=maestro_agent,
    )