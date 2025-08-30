#!/bin/bash

# Production-Grade DevOps Pipeline Setup Script
# This script sets up the complete infrastructure for continuous performance testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT=${ENVIRONMENT:-"production"}
KUBERNETES_CONTEXT=${KUBERNETES_CONTEXT:-"production-cluster"}

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed"
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        error "kubectl is not installed"
    fi
    
    # Check Java
    if ! command -v java &> /dev/null; then
        error "Java is not installed"
    fi
    
    # Check Maven
    if ! command -v mvn &> /dev/null; then
        error "Maven is not installed"
    fi
    
    log "Prerequisites check passed"
}

# Create necessary directories
create_directories() {
    log "Creating necessary directories..."
    
    mkdir -p "$PROJECT_ROOT"/{logs,data,ssl}
    mkdir -p "$PROJECT_ROOT"/jmeter/{results,reports,logs}
    mkdir -p "$PROJECT_ROOT"/monitoring/{prometheus,rules,grafana,alertmanager}
    mkdir -p "$PROJECT_ROOT"/k8s/{secrets,configs}
    
    log "Directories created successfully"
}

# Setup monitoring stack
setup_monitoring() {
    log "Setting up monitoring stack..."
    
    cd "$PROJECT_ROOT/monitoring"
    
    # Start monitoring services
    docker-compose up -d prometheus grafana alertmanager elasticsearch logstash kibana
    
    # Wait for services to be ready
    log "Waiting for monitoring services to be ready..."
    sleep 30
    
    # Check service health
    check_service_health "prometheus" "http://localhost:9090/-/healthy"
    check_service_health "grafana" "http://localhost:3000/api/health"
    check_service_health "elasticsearch" "http://localhost:9200/_cluster/health"
    
    log "Monitoring stack setup completed"
}

# Setup Kubernetes cluster
setup_kubernetes() {
    log "Setting up Kubernetes cluster..."
    
    # Check if cluster exists
    if ! kubectl cluster-info &> /dev/null; then
        warn "Kubernetes cluster not accessible. Please ensure your cluster is running."
        return
    fi
    
    # Set context
    kubectl config use-context "$KUBERNETES_CONTEXT" || warn "Could not set Kubernetes context"
    
    # Create namespaces
    kubectl apply -f "$PROJECT_ROOT/k8s/namespace.yml"
    
    # Create secrets (you should replace these with actual values)
    create_kubernetes_secrets
    
    # Deploy application
    kubectl apply -f "$PROJECT_ROOT/k8s/app-deployment.yml"
    
    # Wait for deployment
    log "Waiting for application deployment..."
    kubectl wait --for=condition=available --timeout=300s deployment/sample-app -n production
    
    log "Kubernetes setup completed"
}

# Create Kubernetes secrets
create_kubernetes_secrets() {
    log "Creating Kubernetes secrets..."
    
    # Database credentials
    kubectl create secret generic db-credentials \
        --from-literal=username=monitoring \
        --from-literal=password=monitoring123 \
        --namespace=production \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # TLS certificates (self-signed for development)
    kubectl create secret tls sample-app-tls \
        --cert="$PROJECT_ROOT/ssl/cert.pem" \
        --key="$PROJECT_ROOT/ssl/key.pem" \
        --namespace=production \
        --dry-run=client -o yaml | kubectl apply -f - || warn "Could not create TLS secret"
    
    log "Kubernetes secrets created"
}

# Setup JMeter
setup_jmeter() {
    log "Setting up JMeter..."
    
    cd "$PROJECT_ROOT"
    
    # Make JMeter script executable
    chmod +x jmeter/run-tests.sh
    
    # Create JMeter configuration
    cat > jmeter/jmeter.properties << EOF
# JMeter Configuration for Production Testing
jmeter.save.saveservice.response_data=true
jmeter.save.saveservice.samplerData=true
jmeter.save.saveservice.requestHeaders=true
jmeter.save.saveservice.url=true
jmeter.save.saveservice.thread_counts=true
jmeter.save.saveservice.timestamp_format=yyyy/MM/dd HH:mm:ss.SSS
jmeter.save.saveservice.latency=true
jmeter.save.saveservice.connect_time=true
jmeter.save.saveservice.bytes=true
jmeter.save.saveservice.sent_bytes=true
jmeter.save.saveservice.responseHeaders=true
jmeter.save.saveservice.requestHeaders=true
jmeter.save.saveservice.encoding=false
jmeter.save.saveservice.assertion_results_failure_message=true
jmeter.save.saveservice.assertions_results=true
jmeter.save.saveservice.subresults=true
jmeter.save.saveservice.response_data_on_error=true
jmeter.save.saveservice.thread_name=true
jmeter.save.saveservice.time=true
jmeter.save.saveservice.timestamp=true
jmeter.save.saveservice.success=true
jmeter.save.saveservice.label=true
jmeter.save.saveservice.code=true
jmeter.save.saveservice.message=true
jmeter.save.saveservice.threadName=true
jmeter.save.saveservice.dataType=true
jmeter.save.saveservice.encoding=false
jmeter.save.saveservice.assertions=true
jmeter.save.saveservice.subresults=true
jmeter.save.saveservice.responseData=false
jmeter.save.saveservice.samplerData=false
jmeter.save.saveservice.xml=false
jmeter.save.saveservice.fieldNames=true
jmeter.save.saveservice.responseHeaders=false
jmeter.save.saveservice.requestHeaders=false
jmeter.save.saveservice.responseDataOnError=false
jmeter.save.saveservice.saveAssertionResultsFailureMessage=true
jmeter.save.saveservice.assertionsResultsToSave=0
jmeter.save.saveservice.bytes=true
jmeter.save.saveservice.sentBytes=true
jmeter.save.saveservice.url=true
jmeter.save.saveservice.thread_counts=true
jmeter.save.saveservice.idle_time=true
jmeter.save.saveservice.connect_time=true
EOF
    
    log "JMeter setup completed"
}

# Setup Jenkins
setup_jenkins() {
    log "Setting up Jenkins..."
    
    # Check if Jenkins is running
    if ! curl -s http://localhost:8080 &> /dev/null; then
        warn "Jenkins is not accessible. Please ensure Jenkins is running on port 8080."
        return
    fi
    
    # Create Jenkins job configuration
    create_jenkins_job
    
    log "Jenkins setup completed"
}

# Create Jenkins job
create_jenkins_job() {
    log "Creating Jenkins job configuration..."
    
    # This would typically be done through Jenkins API or UI
    # For now, we'll create a job configuration file
    cat > "$PROJECT_ROOT/jenkins/job-config.xml" << EOF
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description>Production-Grade DevOps Pipeline for Continuous Performance Testing</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <jenkins.model.BuildDiscarderProperty>
      <strategy class="hudson.tasks.LogRotator">
        <daysToKeep>30</daysToKeep>
        <numToKeep>50</numToKeep>
        <artifactDaysToKeep>-1</artifactDaysToKeep>
        <artifactNumToKeep>-1</artifactNumToKeep>
      </strategy>
    </jenkins.model.BuildDiscarderProperty>
  </properties>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@4.11.0">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>YOUR_GIT_REPOSITORY_URL</url>
        <credentialsId>git-credentials</credentialsId>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/main</name>
      </hudson.plugins.git.BranchSpec>
      <hudson.plugins.git.BranchSpec>
        <name>*/develop</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers>
    <hudson.triggers.SCMTrigger>
      <spec>H/5 * * * *</spec>
    </hudson.triggers.SCMTrigger>
  </triggers>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>echo "Build started at \$(date)"</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers>
    <hudson.tasks.junit.JUnitResultArchiver plugin="junit@1.53">
      <testResults>**/surefire-reports/*.xml</testResults>
      <allowEmptyResults>true</allowEmptyResults>
    </hudson.tasks.junit.JUnitResultArchiver>
    <hudson.plugins.performance.PerformancePublisher plugin="performance@3.20">
      <errorFailedThreshold>0</errorFailedThreshold>
      <errorUnstableThreshold>0</errorUnstableThreshold>
      <relativeFailedThresholdPositive>0.0</relativeFailedThresholdPositive>
      <relativeFailedThresholdNegative>0.0</relativeFailedThresholdNegative>
      <relativeUnstableThresholdPositive>0.0</relativeUnstableThresholdPositive>
      <relativeUnstableThresholdNegative>0.0</relativeUnstableThresholdNegative>
      <nthBuildNumber>0</nthBuildNumber>
      <modeRelativeThresholds>false</modeRelativeThresholds>
      <configType>ART</configType>
      <xml>false</xml>
      <modeOfThreshold>false</modeOfThreshold>
      <failBuildIfNoResultFile>false</failBuildIfNoResultFile>
      <compareBuildPrevious>false</compareBuildPrevious>
    </hudson.plugins.performance.PerformancePublisher>
  </publishers>
  <buildWrappers/>
</project>
EOF
    
    log "Jenkins job configuration created"
}

# Check service health
check_service_health() {
    local service_name="$1"
    local health_url="$2"
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$health_url" &> /dev/null; then
            log "$service_name is healthy"
            return 0
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            warn "$service_name health check failed after $max_attempts attempts"
            return 1
        fi
        
        sleep 2
        attempt=$((attempt + 1))
    done
}

# Generate SSL certificates
generate_ssl_certificates() {
    log "Generating SSL certificates..."
    
    cd "$PROJECT_ROOT/ssl"
    
    # Generate self-signed certificate for development
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout key.pem -out cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" || warn "Could not generate SSL certificates"
    
    log "SSL certificates generated"
}

# Setup environment variables
setup_environment() {
    log "Setting up environment variables..."
    
    cat > "$PROJECT_ROOT/.env" << EOF
# Environment Configuration
ENVIRONMENT=$ENVIRONMENT
KUBERNETES_CONTEXT=$KUBERNETES_CONTEXT

# Application Configuration
APP_NAME=sample-app
APP_VERSION=1.0.0
DOCKER_REGISTRY=localhost:5000

# Performance Testing Configuration
JMETER_MASTER_URL=http://localhost:1099
PERFORMANCE_THRESHOLD_RESPONSE_TIME=2000
PERFORMANCE_THRESHOLD_ERROR_RATE=0.5
PERFORMANCE_THRESHOLD_THROUGHPUT=1000

# Security Configuration
SONARQUBE_URL=http://localhost:9000
OWASP_ZAP_URL=http://localhost:8080

# Kubernetes Configuration
KUBERNETES_NAMESPACE=production
KUBERNETES_CONTEXT=$KUBERNETES_CONTEXT

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sample_app
DB_USERNAME=monitoring
DB_PASSWORD=monitoring123

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379

# Monitoring Configuration
PROMETHEUS_URL=http://localhost:9090
GRAFANA_URL=http://localhost:3000
KIBANA_URL=http://localhost:5601
ELASTICSEARCH_URL=http://localhost:9200
EOF
    
    log "Environment variables configured"
}

# Main setup function
main() {
    log "Starting Production-Grade DevOps Pipeline Setup"
    log "=============================================="
    
    # Check prerequisites
    check_prerequisites
    
    # Create directories
    create_directories
    
    # Generate SSL certificates
    generate_ssl_certificates
    
    # Setup environment
    setup_environment
    
    # Setup monitoring stack
    setup_monitoring
    
    # Setup JMeter
    setup_jmeter
    
    # Setup Kubernetes
    setup_kubernetes
    
    # Setup Jenkins
    setup_jenkins
    
    log "Setup completed successfully!"
    log ""
    log "Next steps:"
    log "1. Configure your Git repository URL in jenkins/job-config.xml"
    log "2. Update monitoring/alertmanager/alertmanager.yml with your notification settings"
    log "3. Run performance tests: ./jmeter/run-tests.sh"
    log "4. Access monitoring dashboards:"
    log "   - Grafana: http://localhost:3000 (admin/admin123)"
    log "   - Prometheus: http://localhost:9090"
    log "   - Kibana: http://localhost:5601"
    log "   - Jenkins: http://localhost:8080"
    log ""
    log "For production deployment, ensure:"
    log "- Proper SSL certificates are configured"
    log "- Secrets are properly managed"
    log "- Monitoring alerts are configured"
    log "- Backup and disaster recovery procedures are in place"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --kubernetes-context)
            KUBERNETES_CONTEXT="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --environment ENV        Environment name (default: production)"
            echo "  --kubernetes-context CTX Kubernetes context (default: production-cluster)"
            echo "  --help                   Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Execute main function
main "$@"
