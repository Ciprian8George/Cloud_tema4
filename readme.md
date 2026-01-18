# Cloud Computing - Homework 4: Azure OpenAI Plugin

This project implements a RESTful Web API that acts as an AI Plugin for creative writing. It integrates with **Azure OpenAI** to process user prompts and generate creative text responses.

The application is built using **Flask (Python)** and deployed on **Azure App Service**.

## 🚀 Public API URL
**Base URL:** `https://tema4fe222eapp.azurewebsites.net/` and '/promt' as target.


## 📝 Plugin Functionality
This API serves as a **Creative Writing Assistant**. It accepts a text prompt from the user—such as a request to invent a word, write a poem, or describe a feeling—and uses a fine-tuned or specific Azure OpenAI model to generate a relevant response. It is trained in finance.

It exposes two main endpoints:
1.  **Status/Info**: To check connectivity and model details.
2.  **Prompt**: To send requests to the AI model.

---

## 🤖 Azure OpenAI Configuration
* **Service Used:** Azure OpenAI Service
* **Model Deployed:** GPT-4.1 Nano (Preview) [cite: 85]
* **Deployment Name:** `nano-tema`
* **Authentication:** API Key and Endpoint injected via Azure App Service Environment Variables[cite: 49, 68].

---

## 📡 API Endpoints & Examples

### 1. Get Plugin Info
Returns information about the API status and the underlying model.

* **URL:** `/info`
* **Method:** `GET` [cite: 41]

**Example Response:**
```json
{
  "backend": "Azure OpenAI GPT-4.1 Nano",
  "model": "nano-tema",
  "status": "online"
}

### 2. POST /prompt
Accepts a JSON body with the prompt and returns the AI's response.

Request:

JSON
{
  "prompt": "Inventează un cuvânt pentru sentimentul de liniște dinaintea furtunii."
}
Response:

JSON
{
  "result": "Furtunalm (n.) - Starea de pace înșelătoare și electrică ce precede un haos iminent."
}
'''
## ⚠️ Error Handling
The API implements explicit error handling for common scenarios.

## How to trigger an error:

### 1. Invalid/Empty Prompt (400 Bad Request) Send a POST request with an empty string or just spaces.
'''
Trigger: Send {"prompt": ""} to /prompt.

Response:

JSON
{
  "error": "Promptul nu poate fi gol"
}
'''
### 2. Method Not Allowed (405) Try to access /prompt via a GET request instead of POST.

Response: HTML error page or JSON indicating method not allowed.

☁️ Deployment Implementation
The project is deployed on Azure App Service (Linux).

Infrastructure: Created using Azure CLI scripts (az group create, az appservice plan create, az webapp create).

Runtime: Python 3.10.

Build Process: The source code is deployed using the zip deployment method. Azure Oryx automatically detects the requirements.txt file and installs the necessary dependencies (flask, openai, gunicorn).

AI: Because of the Azure policy the AI had to be fined tuned to allow deployment in allowed regions. GPT-4.1 NANO was used and trained on a sample dataset about investment.

Security: API Keys are injected into the container environment via az webapp config appsettings.