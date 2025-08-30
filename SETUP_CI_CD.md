# 🚀 **Complete CI/CD Pipeline Setup Guide**

## 🎯 **What You'll Achieve:**

When you push code to your Git repository, this pipeline will automatically:

1. **🔍 Code Push** → Git Repository
2. **⚙️ Jenkins Pipeline** → Build + Unit Tests + JMeter Performance Tests
3. **🧪 JMeter** → Performance Testing (Load, Stress, Spike)
4. **📊 Prometheus** → Collects Performance Metrics
5. **📈 Grafana** → Visualizes Metrics in Real-time
6. **🚀 Jenkins Decision** → Deploy to Docker (only if tests pass)

## 📋 **Prerequisites:**

- ✅ Docker Desktop installed
- ✅ Java 17+ installed
- ✅ Maven installed
- ✅ Jenkins MSI installer (recommended)
- ✅ Git repository (GitHub/GitLab/Bitbucket)

## 🚀 **Step-by-Step Setup:**

### **Step 1: Start the Monitoring Infrastructure**

```bash
cd monitoring
docker-compose up -d
```

**Verify Services:**
- Grafana: http://localhost:3000 (admin/admin123)
- Prometheus: http://localhost:9090
- Kibana: http://localhost:5601

### **Step 2: Install Jenkins**

1. **Download Jenkins MSI installer** from [jenkins.io](https://jenkins.io)
2. **Run the installer** as Administrator
3. **Follow the setup wizard**
4. **Install recommended plugins** when prompted

### **Step 3: Configure Jenkins Pipeline**

1. **Create New Pipeline Job:**
   - Go to Jenkins → New Item
   - Name: `devops-performance-pipeline`
   - Type: Pipeline
   - Click OK

2. **Configure Pipeline:**
   - **Build Triggers**: ✅ GitHub hook trigger for GITScm polling
   - **Pipeline**: From SCM
   - **SCM**: Git
   - **Repository URL**: Your Git repository URL
   - **Branch Specifier**: `*/main`
   - **Script Path**: `jenkins/Jenkinsfile`

### **Step 4: Set Up Git Repository**

1. **Initialize Git:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: DevOps Performance Pipeline"
   ```

2. **Create Remote Repository:**
   - Go to GitHub/GitLab/Bitbucket
   - Create new repository
   - Copy the repository URL

3. **Connect to Remote:**
   ```bash
   git remote add origin YOUR_REPOSITORY_URL
   git branch -M main
   git push -u origin main
   ```

### **Step 5: Configure Webhook**

1. **In Your Git Repository:**
   - Go to Settings → Webhooks
   - Add webhook:
     - URL: `http://your-jenkins-url/github-webhook/post`
     - Content-Type: `application/json`
     - Events: Push, Pull Request

2. **Test Webhook:**
   ```bash
   # Make a small change
   echo "# Test" >> README.md
   git add README.md
   git commit -m "Test webhook trigger"
   git push origin main
   ```

## 🧪 **Testing the Pipeline:**

### **Manual Test:**
```bash
# Build the application
mvn clean package

# Run tests
mvn test

# Run performance tests
cd jmeter
./run-tests.sh --host localhost --port 8080 --users 50
```

### **Automatic Test:**
1. Push code to repository
2. Watch Jenkins automatically start building
3. Monitor pipeline stages in real-time
4. Check results in Grafana dashboards

## 📊 **Monitoring & Dashboards:**

### **Grafana Dashboards:**
- **Pipeline Metrics**: Build times, success rates
- **Performance Metrics**: Response times, throughput
- **Application Health**: CPU, memory, container stats

### **Prometheus Metrics:**
- JMeter test results
- Application performance data
- Infrastructure metrics

### **Jenkins Pipeline View:**
- Real-time stage execution
- Build history and trends
- Performance test results

## 🔧 **Troubleshooting:**

### **Common Issues:**
1. **Webhook not working**: Check Jenkins URL accessibility
2. **Build failures**: Verify Maven and Java setup
3. **Performance test failures**: Check JMeter configuration
4. **Deployment issues**: Verify Docker and Kubernetes setup

### **Health Checks:**
```bash
# Check monitoring stack
docker ps

# Check Jenkins
curl http://localhost:8080

# Check application
curl http://localhost:8080/health
```

## 🎉 **Success Indicators:**

Your pipeline is working when you see:
- ✅ Jenkins builds starting automatically on code push
- ✅ All pipeline stages completing successfully
- ✅ Performance tests passing SLA thresholds
- ✅ Application deploying to Docker containers
- ✅ Real-time metrics in Grafana dashboards

## 📈 **Next Steps:**

1. **Customize Performance Thresholds** in Jenkinsfile
2. **Add More Test Scenarios** in JMeter
3. **Configure Alerting** in Prometheus
4. **Set Up Production Deployment** strategies
5. **Implement Blue-Green Deployments**

---

## 🆘 **Need Help?**

- **Documentation**: Check `/docs/` directory
- **Examples**: See `/examples/` directory
- **Issues**: Create GitHub issue with logs
- **Community**: Join our DevOps community

---

**🎉 Congratulations! You now have a production-grade CI/CD pipeline that automatically tests performance on every code change!**
