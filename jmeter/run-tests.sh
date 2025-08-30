#!/bin/bash

# JMeter Performance Test Runner with Prometheus Integration
# This script runs JMeter tests and generates metrics for monitoring

set -e

echo "🚀 Starting JMeter Performance Testing with Prometheus Integration..."

# Configuration
JMETER_HOME=${JMETER_HOME:-"/usr/local/apache-jmeter"}
TEST_PLANS_DIR="test-plans"
RESULTS_DIR="results"
REPORTS_DIR="reports"
METRICS_DIR="metrics"

# Create directories if they don't exist
mkdir -p "$RESULTS_DIR" "$REPORTS_DIR" "$METRICS_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to run a JMeter test
run_jmeter_test() {
    local test_name=$1
    local test_file=$2
    local output_file="$RESULTS_DIR/${test_name}.jtl"
    local report_dir="$REPORTS_DIR/${test_name}"
    
    print_status "Running $test_name test..."
    
    if [ ! -f "$test_file" ]; then
        print_error "Test file $test_file not found!"
        return 1
    fi
    
    # Run JMeter test
    if command -v jmeter >/dev/null 2>&1; then
        jmeter -n \
            -t "$test_file" \
            -l "$output_file" \
            -e -o "$report_dir" \
            -Jjmeter.save.saveservice.output_format=xml \
            -Jjmeter.save.saveservice.response_data=true \
            -Jjmeter.save.saveservice.samplerData=true \
            -Jjmeter.save.saveservice.requestHeaders=true \
            -Jjmeter.save.saveservice.url=true \
            -Jjmeter.save.saveservice.thread_counts=true \
            -Jjmeter.save.saveservice.timestamp_format=yyyy/MM/dd HH:mm:ss.SSS
    else
        print_error "JMeter not found in PATH. Please install JMeter or set JMETER_HOME."
        return 1
    fi
    
    if [ $? -eq 0 ]; then
        print_success "$test_name test completed successfully!"
        print_status "Results saved to: $output_file"
        print_status "HTML report generated at: $report_dir"
    else
        print_error "$test_name test failed!"
        return 1
    fi
}

# Function to generate Prometheus metrics
generate_metrics() {
    print_status "Generating Prometheus metrics from JMeter results..."
    
    # Check if Python 3 is available
    if command -v python3 >/dev/null 2>&1; then
        # Run the metrics bridge script
        if [ -f "metrics-bridge.py" ]; then
            python3 metrics-bridge.py
            print_success "Prometheus metrics generated successfully!"
        else
            print_warning "metrics-bridge.py not found. Skipping metrics generation."
        fi
    else
        print_warning "Python 3 not found. Skipping metrics generation."
        print_status "Please install Python 3 to enable metrics generation."
    fi
}

# Function to display test summary
show_summary() {
    echo ""
    echo "📊 Performance Test Summary"
    echo "=========================="
    
    for test_file in "$RESULTS_DIR"/*.jtl; do
        if [ -f "$test_file" ]; then
            test_name=$(basename "$test_file" .jtl)
            echo ""
            echo "Test: $test_name"
            echo "Results: $test_file"
            
            # Count total requests
            if command -v python3 >/dev/null 2>&1; then
                total_requests=$(python3 -c "
import csv
import sys
try:
    with open('$test_file', 'r') as f:
        reader = csv.DictReader(f)
        count = sum(1 for row in reader)
    print(count)
except:
    print('Error reading file')
")
                echo "Total Requests: $total_requests"
            fi
            
            # Check if HTML report exists
            report_dir="$REPORTS_DIR/$test_name"
            if [ -d "$report_dir" ]; then
                echo "HTML Report: $report_dir/index.html"
            fi
        fi
    done
    
    echo ""
    echo "📈 Prometheus Metrics"
    echo "====================="
    for metrics_file in "$RESULTS_DIR"/*_prometheus_metrics.txt; do
        if [ -f "$metrics_file" ]; then
            echo "Metrics: $metrics_file"
        fi
    done
}

# Main execution
main() {
    print_status "Starting JMeter Performance Testing Suite..."
    
    # Check if JMeter is available
    if ! command -v jmeter >/dev/null 2>&1; then
        print_warning "JMeter not found in PATH. Trying to use JMETER_HOME..."
        if [ -n "$JMETER_HOME" ] && [ -f "$JMETER_HOME/bin/jmeter" ]; then
            export PATH="$JMETER_HOME/bin:$PATH"
            print_status "Using JMeter from JMETER_HOME: $JMETER_HOME"
        else
            print_error "JMeter not found. Please install JMeter or set JMETER_HOME."
            exit 1
        fi
    fi
    
    # Run tests
    tests=(
        "load-test:test-plans/load-test.jmx"
        "stress-test:test-plans/stress-test.jmx"
        "spike-test:test-plans/spike-test.jmx"
    )
    
    for test_spec in "${tests[@]}"; do
        IFS=':' read -r test_name test_file <<< "$test_spec"
        if [ -f "$test_file" ]; then
            run_jmeter_test "$test_name" "$test_file"
        else
            print_warning "Test file $test_file not found. Skipping $test_name test."
        fi
    done
    
    # Generate metrics
    generate_metrics
    
    # Show summary
    show_summary
    
    print_success "🎉 All performance tests completed!"
    print_status "Check the results directory for detailed reports and metrics."
}

# Run main function
main "$@"
