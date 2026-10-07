import json
import urllib.request

api_key = "AQ.Ab8RN6KcX1dAQQKNY4R51waIXfO-WP6VWfcxqIId3BuRy58WFw"

model = "gemini-3.1-flash-lite"
url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:streamGenerateContent?alt=sse&key={api_key}"

payload = {
    "contents": [{"parts": [{"text": "Hello! Give 2 agricultural tips."}]}]
}
data = json.dumps(payload).encode("utf-8")

req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})

print(f"Testing streamGenerateContent on {model}...")
with urllib.request.urlopen(req, timeout=10) as response:
    for line in response:
        decoded = line.decode("utf-8").strip()
        if decoded.startswith("data:"):
            data_json = json.loads(decoded[5:].strip())
            text = data_json.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
            print(f"CHUNK: {repr(text)}")
print("Stream finished successfully!")
