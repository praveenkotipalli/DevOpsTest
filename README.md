# 🚀 **DevOps Performance Pipeline - Complete CI/CD Solution**

A production-grade CI/CD pipeline that automatically tests performance on every code change, with comprehensive monitoring and observability.

## 🎯 **What This Pipeline Does:**

When you push code to your Git repository, this pipeline automatically:

1. **🔍 Code Push** → Git Repository
2. **⚙️ Jenkins Pipeline** → Build + Unit Tests + JMeter Performance Tests
3. **🧪 JMeter** → Performance Testing (Load, Stress, Spike)
4. **📊 Prometheus** → Collects Performance Metrics
5. **📈 Grafana** → Visualizes Metrics in Real-time
6. **🚀 Jenkins Decision** → Deploy to Docker (only if tests pass)

## 🏗️ **Architecture Overview**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Source Code   │───▶│  Jenkins CI/CD  │───▶│   Docker/K8s    │
│   Repository    │    │    Pipeline     │    │   Deployment    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │ JMeter Cluster  │
                       │ Performance     │
                       │ Testing         │
                       └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   Monitoring    │
                       │   Stack         │
                       │ (Prometheus +   │
                       │  Grafana + ELK) │
                       └─────────────────┘
```

## 🚀 **Quick Start**

### **1. Start Monitoring Infrastructure**
```bash
cd monitoring
docker-compose up -d
```

### **2. Install Jenkins**
- Download Jenkins MSI installer from [jenkins.io](https://jenkins.io)
- Run as Administrator
- Install recommended plugins

### **3. Configure Pipeline**
- Create new pipeline job in Jenkins
- Configure Git repository and webhook
- Use `jenkins/Jenkinsfile` as pipeline script

### **4. Set Up Git Repository**
```bash
git init
git add .
git commit -m "Initial commit: DevOps Performance Pipeline"
git remote add origin YOUR_REPOSITORY_URL
git push -u origin main
```

### **5. Test the Pipeline**
- Make a code change
- Push to repository
- Watch Jenkins automatically build and test!

## 📊 **Access Your Services**

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | http://localhost:3000 | `admin` / `admin123` |
| **Prometheus** | http://localhost:9090 | No login required |
| **Kibana** | http://localhost:5601 | No login required |
| **Jenkins** | http://localhost:8080 | Set during installation |

## 🔧 **What's Included**

### **✅ Complete Infrastructure**
- **Monitoring**: Prometheus + Grafana + ELK Stack
- **Performance Testing**: JMeter with distributed testing
- **CI/CD**: Jenkins pipeline with quality gates
- **Deployment**: Docker with auto-scaling
- **Security**: OWASP ZAP, SonarQube integration

### **✅ Production Features**
- **High Availability**: Multi-replica deployments
- **Auto-scaling**: HPA based on CPU/memory
- **Health Checks**: Liveness, readiness, startup probes
- **Security**: RBAC, secrets management, TLS
- **Monitoring**: Real-time metrics, alerting, logging

### **✅ Performance Testing**
- **Load Testing**: Simulate 100+ concurrent users
- **Stress Testing**: Find breaking points
- **Spike Testing**: Handle traffic spikes
- **Thresholds**: SLA enforcement (2s response, <0.5% errors)

## 📁 **Project Structure**

```
├── src/                    # Spring Boot application source
├── jenkins/               # Jenkins pipeline definitions
├── jmeter/                # JMeter test plans and scripts
├── monitoring/            # Prometheus, Grafana, ELK stack
├── k8s/                  # Kubernetes manifests
├── docker/                # Docker configurations
├── scripts/               # Utility scripts
├── SETUP_CI_CD.md         # Complete setup guide
└── README.md              # This file
```

## 🧪 **Testing Your Pipeline**

### **Manual Testing**
```bash
# Build application
mvn clean package

# Run tests
mvn test

# Run performance tests
cd jmeter
./run-tests.sh --host localhost --port 8080 --users 50
```

### **Automatic Testing**
1. Push code to repository
2. Watch Jenkins automatically start building
3. Monitor pipeline stages in real-time
4. Check results in Grafana dashboards

## 📈 **Success Metrics**

Your pipeline is working when you see:
- ✅ Jenkins builds completing successfully
- ✅ Performance tests passing SLA thresholds
- ✅ Applications auto-scaling based on load
- ✅ Real-time monitoring dashboards populated
- ✅ Alerts firing for SLA breaches

## 🔒 **Security & Compliance**

- **RBAC**: Role-based access control for all components
- **Secrets Management**: HashiCorp Vault integration
- **Vulnerability Scanning**: OWASP ZAP, Snyk integration
- **Audit Logging**: Complete audit trail for compliance

## 🚨 **Troubleshooting**

### **Common Issues**
1. **Pipeline Failures**: Check Jenkins logs and build artifacts
2. **Performance Test Failures**: Verify JMeter cluster health
3. **Deployment Issues**: Check Docker and Kubernetes logs
4. **Monitoring Gaps**: Verify Prometheus targets and Grafana data sources

### **Health Checks**
```bash
# Check monitoring stack
docker ps

# Check Jenkins
curl http://localhost:8080

# Check application
curl http://localhost:8080/health
```

## 📈 **Next Steps**

1. **Customize Configuration**
   - Update performance thresholds
   - Configure notification settings
   - Set up external databases

2. **Production Deployment**
   - Replace self-signed certificates with proper SSL
   - Configure backup and disaster recovery
   - Set up proper secrets management

3. **Advanced Features**
   - Set up distributed JMeter cluster
   - Configure multi-environment deployments
   - Implement chaos engineering tests

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests and documentation
5. Submit a pull request

## 📄 **License**

MIT License - see LICENSE file for details

## 🆘 **Support**

- **Documentation**: Check `SETUP_CI_CD.md` for complete setup guide
- **Issues**: Create GitHub issue with logs
- **Examples**: See `/examples/` directory

---

**🎉 Built with ❤️ for production-grade DevOps and continuous performance testing!**

**Your CI/CD pipeline is now ready to automatically test performance on every code change!** 🚀
