# AML_MAS_PresentationPlanner
Multi Agent System for automatic presentation creation

# Set up with docker
### 1. Get a server
### 2. Install docker
### 3. Create .env file (see `.env.example`)
### 4. Run `docker compose up` in the docker_setup folder
### 5. Open your n8n instance according to your .env file
### 6. Create a new workflow and import `Presentation_Creator_v4_final_version.json`
### 7. Create or enter credentials where needed (follow specific credential guide in n8n, shows up when prompted to enter credentials)
### 8. NOTE: For Google Drive usage, you have to set up a correct DNS entry so the Google API gets a correct Callback URL (localhost does **NOT** work.) If you do not want to use that, feel free to set up another file storage. Even uploading a file in the chat works and should be enough, as the file gets parsed and saved into the vector store in the beginning anyways.
### 9. Start Workflow via the Chat node with the following prompt: 
 "Please generate a presentation about our multi agent system and focus on our used architecture description and pattern from anthropic: Orchestrator, Evaluator, Prompt Chaining. 
Also mention our use cases, why we decided to work with n8n and the limits. Do not reference any images or diagrams and create a agenda at the beginning. Create a markdown file with the presentation output."


# Set up from scratch
## How to run the Presentation Creation Multi Agent System with n8n:
### 1. Get a server
We have used a dedicated Hetzner Server. 2 GB RAM is enough.
### 2. Set up n8n
https://docs.n8n.io/hosting/installation/docker/
### 3. Set up PostgreSQL
https://www.docker.com/blog/how-to-use-the-postgres-docker-official-image/
### 4. Set up .env file
Set up your .env file according to the documentations of the services
### 5. Add marp-service to docker-compoes file and put all services in same network
### 6. Make sure your n8n instance is reachable through a DNS entry
### 7. Open n8n, create a new workflow and import the file `Presentation_Creator_v4_final_version.json` found in this repo.
### 8. Create or enter credentials where needed (follow credential guide in n8n)
### 9. Start Workflow via the Chat node with the following prompt: 
 "Please generate a presentation about our multi agent system and focus on our used architecture description and pattern from anthropic: Orchestrator, Evaluator, Prompt Chaining. 
Also mention our use cases, why we decided to work with n8n and the limits. Do not reference any images or diagrams and create a agenda at the beginning. Create a markdown file with the presentation output."
