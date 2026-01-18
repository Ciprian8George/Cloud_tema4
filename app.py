import os
import logging
from flask import Flask, request, jsonify, render_template
from openai import AzureOpenAI
from dotenv import load_dotenv

# Încărcare variabile environment
load_dotenv()

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# --- Configurare Client Azure ---
def get_openai_client():
    api_key = os.environ.get("AZURE_OPENAI_API_KEY")
    endpoint = os.environ.get("AZURE_OPENAI_ENDPOINT")

    if not api_key or not endpoint:
        logging.error("LIPSA CREDENTIALE: Verifica Environment Variables in Azure!")
        return None

    return AzureOpenAI(
        azure_endpoint=endpoint,
        api_key=api_key,
        # GPT-4.1 Nano este preview, folosim o versiune API recenta
        api_version="2024-08-01-preview"
    )

# Numele deployment-ului (îl setăm în scriptul de infra)
DEPLOYMENT_NAME = os.environ.get("DEPLOYMENT_NAME", "nano-tema")

@app.route('/', methods=['GET'])
def home():
    return render_template('index.html')

@app.route('/info', methods=['GET'])
def info():
    return jsonify({
        "status": "online",
        "model": DEPLOYMENT_NAME,
        "backend": "Azure OpenAI GPT-4.1 Nano"
    })

@app.route('/prompt', methods=['POST'])
def prompt():
    client = get_openai_client()
    if not client:
        return jsonify({"error": "Eroare configurare server (API Key/Endpoint lipsa)"}), 500

    data = request.get_json()
    user_prompt = data.get('prompt', '')

    if not user_prompt.strip():
        return jsonify({"error": "Promptul nu poate fi gol"}), 400

    try:
        logging.info(f"Trimitere request catre modelul: {DEPLOYMENT_NAME}")
        
        # Folosim CHAT completions pentru GPT-4.1 Nano
        response = client.chat.completions.create(
            model=DEPLOYMENT_NAME,
            messages=[
                {"role": "system", "content": "You are a helpful assistant specialized in creative writing."},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0.7,
            max_tokens=300
        )
        
        result_text = response.choices[0].message.content
        return jsonify({"result": result_text})

    except Exception as e:
        logging.error(f"OpenAI Error: {str(e)}")
        # Returnam eroarea exactă ca să știm ce să depanăm
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)