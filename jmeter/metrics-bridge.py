#!/usr/bin/env python3
"""
JMeter to Prometheus Metrics Bridge
Converts JMeter test results to Prometheus-compatible metrics
"""

import os
import csv
import json
import time
from datetime import datetime
from pathlib import Path

def parse_jmeter_results(jtl_file):
    """Parse JMeter JTL file and extract metrics"""
    metrics = {
        'total_requests': 0,
        'successful_requests': 0,
        'failed_requests': 0,
        'total_response_time': 0,
        'min_response_time': float('inf'),
        'max_response_time': 0,
        'response_codes': {},
        'errors': []
    }
    
    if not os.path.exists(jtl_file):
        print(f"Warning: JTL file {jtl_file} not found")
        return metrics
    
    try:
        with open(jtl_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            
            for row in reader:
                metrics['total_requests'] += 1
                
                # Response code analysis
                response_code = row.get('responseCode', '0')
                metrics['response_codes'][response_code] = metrics['response_codes'].get(response_code, 0) + 1
                
                # Success/failure counting
                if response_code == '200':
                    metrics['successful_requests'] += 1
                else:
                    metrics['failed_requests'] += 1
                    metrics['errors'].append({
                        'label': row.get('label', 'Unknown'),
                        'response_code': response_code,
                        'response_message': row.get('responseMessage', 'No message')
                    })
                
                # Response time analysis
                try:
                    response_time = float(row.get('elapsed', 0))
                    metrics['total_response_time'] += response_time
                    metrics['min_response_time'] = min(metrics['min_response_time'], response_time)
                    metrics['max_response_time'] = max(metrics['max_response_time'], response_time)
                except (ValueError, TypeError):
                    pass
                    
    except Exception as e:
        print(f"Error parsing JTL file: {e}")
    
    # Calculate averages
    if metrics['total_requests'] > 0:
        metrics['avg_response_time'] = metrics['total_response_time'] / metrics['total_requests']
        metrics['success_rate'] = metrics['successful_requests'] / metrics['total_requests']
    else:
        metrics['avg_response_time'] = 0
        metrics['success_rate'] = 0
    
    # Handle edge case for min response time
    if metrics['min_response_time'] == float('inf'):
        metrics['min_response_time'] = 0
    
    return metrics

def generate_prometheus_metrics(metrics, test_name):
    """Generate Prometheus-compatible metrics"""
    timestamp = int(time.time() * 1000)
    
    prometheus_metrics = f"""# JMeter Performance Test Results - {test_name}
# Generated at {datetime.now().isoformat()}
# HELP jmeter_total_requests Total number of requests made
# TYPE jmeter_total_requests counter
jmeter_total_requests{{test="{test_name}"}} {metrics['total_requests']}

# HELP jmeter_successful_requests Number of successful requests
# TYPE jmeter_successful_requests counter
jmeter_successful_requests{{test="{test_name}"}} {metrics['successful_requests']}

# HELP jmeter_failed_requests Number of failed requests
# TYPE jmeter_failed_requests counter
jmeter_failed_requests{{test="{test_name}"}} {metrics['failed_requests']}

# HELP jmeter_success_rate Success rate as a percentage
# TYPE jmeter_success_rate gauge
jmeter_success_rate{{test="{test_name}"}} {metrics['success_rate']:.4f}

# HELP jmeter_avg_response_time Average response time in milliseconds
# TYPE jmeter_avg_response_time gauge
jmeter_avg_response_time{{test="{test_name}"}} {metrics['avg_response_time']:.2f}

# HELP jmeter_min_response_time Minimum response time in milliseconds
# TYPE jmeter_min_response_time gauge
jmeter_min_response_time{{test="{test_name}"}} {metrics['min_response_time']:.2f}

# HELP jmeter_max_response_time Maximum response time in milliseconds
# TYPE jmeter_max_response_time gauge
jmeter_max_response_time{{test="{test_name}"}} {metrics['max_response_time']:.2f}

# HELP jmeter_test_timestamp Test execution timestamp
# TYPE jmeter_test_timestamp gauge
jmeter_test_timestamp{{test="{test_name}"}} {timestamp}
"""
    
    # Add response code metrics
    for code, count in metrics['response_codes'].items():
        prometheus_metrics += f"""
# HELP jmeter_response_code_count Count of responses by status code
# TYPE jmeter_response_code_count counter
jmeter_response_code_count{{test="{test_name}",code="{code}"}} {count}
"""
    
    return prometheus_metrics

def main():
    """Main function to process JMeter results"""
    results_dir = Path("results")
    
    if not results_dir.exists():
        print("Results directory not found. Creating...")
        results_dir.mkdir(exist_ok=True)
    
    # Process different test types
    test_types = ['load-test', 'stress-test', 'spike-test']
    
    for test_type in test_types:
        jtl_file = results_dir / f"{test_type}.jtl"
        
        if jtl_file.exists():
            print(f"Processing {test_type} results...")
            
            # Parse JMeter results
            metrics = parse_jmeter_results(str(jtl_file))
            
            # Generate Prometheus metrics
            prometheus_metrics = generate_prometheus_metrics(metrics, test_type)
            
            # Save Prometheus metrics
            metrics_file = results_dir / f"{test_type}_prometheus_metrics.txt"
            with open(metrics_file, 'w') as f:
                f.write(prometheus_metrics)
            
            print(f"✅ Generated Prometheus metrics for {test_type}")
            print(f"   - Total requests: {metrics['total_requests']}")
            print(f"   - Success rate: {metrics['success_rate']:.2%}")
            print(f"   - Avg response time: {metrics['avg_response_time']:.2f}ms")
            
        else:
            print(f"⚠️  No results found for {test_type}")
    
    # Create a combined metrics file
    print("\nCreating combined metrics file...")
    combined_metrics = "# Combined JMeter Metrics\n"
    combined_metrics += f"# Generated at {datetime.now().isoformat()}\n\n"
    
    for test_type in test_types:
        metrics_file = results_dir / f"{test_type}_prometheus_metrics.txt"
        if metrics_file.exists():
            with open(metrics_file, 'r') as f:
                combined_metrics += f.read() + "\n"
    
    combined_file = results_dir / "combined_prometheus_metrics.txt"
    with open(combined_file, 'w') as f:
        f.write(combined_metrics)
    
    print(f"✅ Combined metrics saved to {combined_file}")
    print("\n🎉 JMeter to Prometheus metrics conversion complete!")

if __name__ == "__main__":
    main()
