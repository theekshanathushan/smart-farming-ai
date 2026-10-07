import json
import urllib.request
import urllib.error

api_key = "AQ.Ab8RN6KcX1dAQQKNY4R51waIXfO-WP6VWfcxqIId3BuRy58WFw"

payload = {
    "contents": [{"parts": [{"text": "You are AgriAI. Tell me in 1 sentence what is optimal irrigation for tomato."}]}]
}
data = json.dumps(payload).encode("utf-8")

models = [
    "gemini-3.1-flash-lite",
    "gemini-3.1-flash-lite-preview",
    "gemini-3-flash-preview",
    "gemini-3.1-pro-preview",
]

for model in models:
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            result = json.loads(response.read().decode("utf-8"))
            text = result.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
            print(f"SUCCESS on {model}: {text.strip()}")
    except urllib.error.HTTPError as e:
        print(f"HTTP ERROR {e.code} on {model}: {e.read().decode('utf-8')[:150]}")
    except Exception as e:
        print(f"EXCEPTION on {model}: {e}")
