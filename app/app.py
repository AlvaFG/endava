import os
import time
import socket
from datetime import datetime

from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter("app_requests_total", "Total requests", ["method", "endpoint", "status"])
REQUEST_LATENCY = Histogram("app_request_latency_seconds", "Request latency", ["endpoint"])

@app.before_request
def before_request():
    from flask import request, g
    g.start_time = time.time()

@app.after_request
def after_request(response):
    from flask import request, g
    latency = time.time() - g.start_time
    REQUEST_COUNT.labels(request.method, request.path, response.status_code).inc()
    REQUEST_LATENCY.labels(request.path).observe(latency)
    return response

@app.route("/health")
def health():
    return jsonify({"status": "healthy", "timestamp": datetime.utcnow().isoformat()})

@app.route("/info")
def info():
    return jsonify({
        "hostname": socket.gethostname(),
        "ip": socket.gethostbyname(socket.gethostname()),
        "version": os.getenv("APP_VERSION", "1.0.0"),
        "environment": os.getenv("APP_ENV", "development"),
        "pod_name": os.getenv("HOSTNAME", "unknown"),
        "pod_namespace": os.getenv("POD_NAMESPACE", "unknown"),
    })

@app.route("/metrics")
def metrics():
    from flask import Response
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

@app.route("/")
def root():
    return jsonify({
        "app": "endava-demo",
        "description": "Platform Engineering Demo - Endava v2.0",
        "endpoints": ["/health", "/info", "/metrics"],
    })

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
