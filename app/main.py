from flask import Flask
from prometheus_client import COunter, generate_latest

app = Flask(__name__)
REQUESTS = COunter('http_requests_total', 'Total HTTP Requests', ['endpoint', 'status'])

@app.route('/health')
def health():
    REQUESTS.labels(endpoint='/health', status='200').inc()
    return 'OK', 200

@app.route('/metrics')
def metrics():
    return generate_latest(), 200

@app.route('/hello')
def hello():
    REQUESTS.labels(endpoint='/hello', status='200').inc()
    return 'Service Operating', 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)