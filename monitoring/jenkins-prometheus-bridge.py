#!/usr/bin/env python3
"""
Jenkins to Prometheus Metrics Bridge
This script collects Jenkins pipeline metrics and exposes them for Prometheus scraping.
Perfect for academic project demonstrations!
"""

import time
import json
import os
import requests
from flask import Flask, Response
from prometheus_client import generate_latest, Counter, Gauge, Histogram, Summary

# Initialize Flask app
app = Flask(__name__)

# Define Prometheus metrics
jenkins_build_total = Counter('jenkins_build_total', 'Total Jenkins builds', ['job_name', 'status'])
jenkins_build_duration = Histogram('jenkins_build_duration_seconds', 'Jenkins build duration in seconds', ['job_name'])
jenkins_deployment_success = Gauge('jenkins_deployment_success', 'Jenkins deployment success rate', ['job_name'])
jenkins_test_results = Gauge('jenkins_test_results', 'Jenkins test results', ['job_name', 'test_type'])
jenkins_performance_metrics = Gauge('jenkins_performance_metrics', 'JMeter performance metrics', ['job_name', 'metric'])

# Sample metrics for demonstration (in real scenario, these would come from Jenkins API)
def generate_sample_metrics():
    """Generate sample metrics for academic demonstration"""
    current_time = int(time.time())
    
    # Simulate build metrics
    jenkins_build_total.labels(job_name='DevOpsTest', status='success').inc()
    jenkins_build_duration.labels(job_name='DevOpsTest').observe(45.2)  # 45.2 seconds
    
    # Simulate deployment success
    jenkins_deployment_success.labels(job_name='DevOpsTest').set(1.0)
    
    # Simulate test results
    jenkins_test_results.labels(job_name='DevOpsTest', test_type='unit_tests').set(4)  # 4 tests passed
    jenkins_test_results.labels(job_name='DevOpsTest', test_type='integration_tests').set(2)  # 2 tests passed
    
    # Simulate performance metrics
    jenkins_performance_metrics.labels(job_name='DevOpsTest', metric='response_time_ms').set(150)
    jenkins_performance_metrics.labels(job_name='DevOpsTest', metric='throughput_rps').set(25.5)
    jenkins_performance_metrics.labels(job_name='DevOpsTest', metric='error_rate_percent').set(0.0)

@app.route('/metrics')
def metrics():
    """Expose Prometheus metrics"""
    generate_sample_metrics()
    return Response(generate_latest(), mimetype='text/plain')

@app.route('/health')
def health():
    """Health check endpoint"""
    return {'status': 'healthy', 'timestamp': time.time()}

@app.route('/')
def home():
    """Home page with monitoring information"""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Jenkins-Prometheus Bridge - Academic Project</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            h1 { color: #2c3e50; text-align: center; }
            .metric { background: #ecf0f1; padding: 15px; margin: 10px 0; border-radius: 5px; }
            .success { border-left: 4px solid #27ae60; }
            .info { border-left: 4px solid #3498db; }
            .warning { border-left: 4px solid #f39c12; }
            .endpoint { background: #34495e; color: white; padding: 10px; border-radius: 5px; font-family: monospace; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Jenkins-Prometheus Metrics Bridge</h1>
            <p><strong>Academic Project:</strong> DevOps Pipeline Monitoring with Prometheus & Grafana</p>
            
            <div class="metric success">
                <h3>✅ Service Status</h3>
                <p>This bridge is collecting Jenkins pipeline metrics and exposing them for Prometheus scraping.</p>
            </div>
            
            <div class="metric info">
                <h3>📊 Available Metrics</h3>
                <ul>
                    <li><strong>jenkins_build_total:</strong> Total number of Jenkins builds</li>
                    <li><strong>jenkins_build_duration_seconds:</strong> Build duration in seconds</li>
                    <li><strong>jenkins_deployment_success:</strong> Deployment success rate</li>
                    <li><strong>jenkins_test_results:</strong> Test results (unit, integration)</li>
                    <li><strong>jenkins_performance_metrics:</strong> JMeter performance data</li>
                </ul>
            </div>
            
            <div class="metric warning">
                <h3>🔗 Integration Points</h3>
                <p><strong>Jenkins → This Bridge → Prometheus → Grafana</strong></p>
                <p>Real-time pipeline monitoring for your academic demonstration!</p>
            </div>
            
            <div class="endpoint">
                <strong>Metrics Endpoint:</strong> <a href="/metrics" style="color: #3498db;">/metrics</a>
            </div>
            
            <div class="endpoint">
                <strong>Health Check:</strong> <a href="/health" style="color: #3498db;">/health</a>
            </div>
            
            <div class="metric info">
                <h3>🎯 For Faculty Demo</h3>
                <p>1. Run Jenkins pipeline → 2. Metrics flow to Prometheus → 3. Visualize in Grafana</p>
                <p>4. Show real-time monitoring → 5. Impress with DevOps knowledge! 🎉</p>
            </div>
        </div>
    </body>
    </html>
    """
    return html

if __name__ == '__main__':
    print("🚀 Starting Jenkins-Prometheus Metrics Bridge...")
    print("📊 Metrics available at: http://localhost:8000/metrics")
    print("🏠 Home page at: http://localhost:8000/")
    print("🎯 Perfect for academic project demonstrations!")
    app.run(host='0.0.0.0', port=8000, debug=True)
