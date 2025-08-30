#!/bin/bash

# JMeter Performance Test Runner
# Production-Grade DevOps Pipeline

set -e

# Configuration
JMETER_HOME=${JMETER_HOME:-"/opt/apache-jmeter"}
TEST_PLANS_DIR="./test-plans"
RESULTS_DIR="./results"
REPORTS_DIR="./reports"
LOGS_DIR="./logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test parameters
HOST=${HOST:-"localhost"}
PORT=${PORT:-"8080"}
PROTOCOL=${PROTOCOL:-"http"}
USERS=${USERS:-"100"}
DURATION=${DURATION:-"300"}
RAMPUP=${RAMPUP:-"60"}

# Create directories
mkdir -p "$RESULTS_DIR" "$REPORTS_DIR" "$LOGS_DIR"

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%M-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    if ! command -v java &> /dev/null; then
        error "Java is not installed"
    fi
    
    if [ ! -d "$JMETER_HOME" ]; then
        error "JMeter not found at $JMETER_HOME"
    fi
    
    log "Prerequisites check passed"
}

# Run load test
run_load_test() {
    local test_plan="$1"
    local test_name="$2"
    
    log "Running $test_name test..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local result_file="$RESULTS_DIR/${test_name}_${timestamp}.jtl"
    local report_dir="$REPORTS_DIR/${test_name}_${timestamp}"
    local log_file="$LOGS_DIR/${test_name}_${timestamp}.log"
    
    # Execute JMeter test
    "$JMETER_HOME/bin/jmeter" \
        -n \
        -t "$test_plan" \
        -l "$result_file" \
        -e -o "$report_dir" \
        -Jhost="$HOST" \
        -Jport="$PORT" \
        -Jprotocol="$PROTOCOL" \
        -Jusers="$USERS" \
        -Jduration="$DURATION" \
        -Jrampup="$RAMPUP" \
        -j "$log_file" \
        -Jjmeter.save.saveservice.response_data=true \
        -Jjmeter.save.saveservice.samplerData=true \
        -Jjmeter.save.saveservice.requestHeaders=true \
        -Jjmeter.save.saveservice.url=true \
        -Jjmeter.save.saveservice.thread_counts=true \
        -Jjmeter.save.saveservice.timestamp_format=yyyy/MM/dd HH:mm:ss.SSS
    
    if [ $? -eq 0 ]; then
        log "$test_name test completed successfully"
        log "Results: $result_file"
        log "Report: $report_dir"
        log "Logs: $log_file"
    else
        error "$test_name test failed"
    fi
}

# Run stress test
run_stress_test() {
    log "Running stress test..."
    
    # Increase load for stress testing
    local stress_users=$((USERS * 2))
    local stress_duration=$((DURATION * 2))
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local result_file="$RESULTS_DIR/stress_test_${timestamp}.jtl"
    local report_dir="$REPORTS_DIR/stress_test_${timestamp}"
    local log_file="$LOGS_DIR/stress_test_${timestamp}.log"
    
    "$JMETER_HOME/bin/jmeter" \
        -n \
        -t "$TEST_PLANS_DIR/stress-test.jmx" \
        -l "$result_file" \
        -e -o "$report_dir" \
        -Jhost="$HOST" \
        -Jport="$PORT" \
        -Jprotocol="$PROTOCOL" \
        -Jusers="$stress_users" \
        -Jduration="$stress_duration" \
        -Jrampup="$RAMPUP" \
        -j "$log_file"
    
    if [ $? -eq 0 ]; then
        log "Stress test completed successfully"
    else
        error "Stress test failed"
    fi
}

# Run spike test
run_spike_test() {
    log "Running spike test..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local result_file="$RESULTS_DIR/spike_test_${timestamp}.jtl"
    local report_dir="$REPORTS_DIR/spike_test_${timestamp}"
    local log_file="$LOGS_DIR/spike_test_${timestamp}.log"
    
    "$JMETER_HOME/bin/jmeter" \
        -n \
        -t "$TEST_PLANS_DIR/spike-test.jmx" \
        -l "$result_file" \
        -e -o "$report_dir" \
        -Jhost="$HOST" \
        -Jport="$PORT" \
        -Jprotocol="$PROTOCOL" \
        -Jusers="$USERS" \
        -Jduration="60" \
        -Jrampup="10" \
        -j "$log_file"
    
    if [ $? -eq 0 ]; then
        log "Spike test completed successfully"
    else
        error "Spike test failed"
    fi
}

# Generate summary report
generate_summary() {
    log "Generating summary report..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local summary_file="$REPORTS_DIR/summary_${timestamp}.txt"
    
    {
        echo "Performance Test Summary"
        echo "========================"
        echo "Date: $(date)"
        echo "Host: $HOST:$PORT"
        echo "Protocol: $PROTOCOL"
        echo "Users: $USERS"
        echo "Duration: $DURATION seconds"
        echo "Ramp-up: $RAMPUP seconds"
        echo ""
        echo "Test Results:"
        echo "-------------"
        
        for result_file in "$RESULTS_DIR"/*.jtl; do
            if [ -f "$result_file" ]; then
                local test_name=$(basename "$result_file" .jtl)
                echo "- $test_name: $result_file"
            fi
        done
        
        echo ""
        echo "Reports:"
        echo "--------"
        
        for report_dir in "$REPORTS_DIR"/*/; do
            if [ -d "$report_dir" ]; then
                echo "- $(basename "$report_dir")"
            fi
        done
    } > "$summary_file"
    
    log "Summary report generated: $summary_file"
}

# Main execution
main() {
    log "Starting JMeter Performance Test Suite"
    log "====================================="
    
    check_prerequisites
    
    # Run different types of tests
    run_load_test "$TEST_PLANS_DIR/load-test.jmx" "load"
    run_stress_test
    run_spike_test
    
    generate_summary
    
    log "All tests completed successfully!"
    log "Check $REPORTS_DIR for detailed reports"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            HOST="$2"
            shift 2
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --users)
            USERS="$2"
            shift 2
            ;;
        --duration)
            DURATION="$2"
            shift 2
            ;;
        --rampup)
            RAMPUP="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --host HOST       Target host (default: localhost)"
            echo "  --port PORT       Target port (default: 8080)"
            echo "  --users USERS     Number of users (default: 100)"
            echo "  --duration SEC    Test duration in seconds (default: 300)"
            echo "  --rampup SEC      Ramp-up time in seconds (default: 60)"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Execute main function
main "$@"
