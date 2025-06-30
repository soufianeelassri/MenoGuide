# Agents Service for MenoGuide+

## Overview

The **Agents Service** is a core backend component of the MenoGuide+ platform, providing intelligent, agent-based support for menopause wellness. It orchestrates multiple specialized AI agents to deliver evidence-based guidance, emotional support, and community connections for users navigating menopause.

This service is built using [Google ADK](https://github.com/google/adk) and FastAPI, and is designed for easy deployment via Docker.

---

## Architecture

- **Main API**: FastAPI app exposing endpoints for agent interactions.
- **Agents**: Modular AI agents, each with a specific focus:
  - **Maestro**: Central orchestrator, routes user queries to the appropriate specialist agent.
  - **Nutrition Expert**: Provides evidence-based dietary and nutrition guidance for menopause symptoms.
  - **Life Coach**: Offers emotional support and life coaching strategies.
  - **Community Connector**: Connects users to online communities, local support groups, and curated resources.
- **Google ADK**: Used for agent orchestration, session management, and integration with Google Cloud AI services.

---

## Setup & Installation

### Prerequisites
- Python 3.12+
- [Google ADK](https://github.com/google/adk) dependencies (see requirements.txt)
- Access to Google Cloud project and Vertex AI (for production)

### Local Development
1. **Clone the repository**
2. **Install dependencies:**
   - Copy the example requirements file to a real one:
     ```bash
     cp agents/requirements.example.txt agents/requirements.txt
     pip install -r agents/requirements.txt
     ```
3. **Set environment variables:**
   - Copy the example environment file and adjust values as needed for your setup:
     ```bash
     cp prod.env.example.yaml prod.env.yaml
     # Edit prod.env.yaml with your actual credentials and configuration
     ```
4. **Run the service:**
   ```bash
   python main.py
   ```

---

## Environment Variables

The service uses the following environment variables (see `prod.env.example.yaml` for a template):

- `GOOGLE_CLOUD_PROJECT`: Google Cloud project ID
- `GOOGLE_CLOUD_LOCATION`: Google Cloud region (e.g., us-central1)
- `GOOGLE_GENAI_USE_VERTEXAI`: Set to "true" to use Vertex AI
- `DATA_STORE_ID`: Path to the RAG knowledge base in Google Cloud
- `MAESTRO_AGENT_RESOURCE_NAME`: Resource name for the Maestro agent

---

## Docker Usage

To build and run the service in Docker:

```bash
docker build -t menoguide-agents-service .
docker run -p 8080:8080 --env-file prod.env.yaml menoguide-agents-service
```

---

## Agents Overview

### Maestro (Orchestrator)
- Welcomes users, gathers context, and routes queries to the appropriate specialist agent.
- Ensures a smooth, empathetic user experience.

### Nutrition Expert
- Provides personalized, evidence-based dietary advice for menopause symptoms.
- Uses a RAG knowledge base for up-to-date nutrition research.
- Emphasizes that advice is complementary and not a substitute for medical care.

### Life Coach
- Offers emotional support and life coaching strategies.
- Helps users manage stress, mood swings, and emotional challenges.
- Clearly states it is not a substitute for professional mental health support.

### Community Connector
- Connects users to online communities, local support groups, and curated content.
- Helps users find relevant healthcare professionals and shared experiences.
- Does not endorse specific providers; users must verify suitability themselves.

---

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.
