# 🔗 Jenkins Webhook Configuration for Git Repository

## 📋 **GitHub/GitLab Webhook Setup**

### **1. In Your Git Repository (GitHub/GitLab/Bitbucket):**

1. Go to your repository settings
2. Navigate to **Webhooks** or **Integrations**
3. Click **Add webhook** or **New webhook**

### **2. Webhook Configuration:**

```
URL: http://your-jenkins-url/github-webhook/post
Content-Type: application/json
Secret: [Leave empty for now]
Events: 
  ✅ Push events
  ✅ Pull request events
  ✅ Branch creation
  ✅ Branch deletion
```

### **3. Jenkins Job Configuration:**

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
   - **Branch Specifier**: `*/main` or `*/master`
   - **Script Path**: `jenkins/Jenkinsfile`

### **4. Test the Webhook:**

1. Make a small change to your code
2. Commit and push:
   ```bash
   git add .
   git commit -m "Test webhook trigger"
   git push origin main
   ```
3. Check Jenkins - it should automatically start building!

## 🎯 **What Happens When You Push Code:**

1. **Code Push** → Git Repository
2. **Webhook Triggered** → Jenkins receives notification
3. **Jenkins Pipeline Starts** → Automatic build begins
4. **Pipeline Stages Execute** → Build, Test, Performance Test, Deploy

## 🔧 **Troubleshooting:**

- **Webhook not working?** Check Jenkins URL accessibility
- **Build not starting?** Verify webhook configuration in Git
- **Pipeline errors?** Check Jenkins logs and configuration

## 📊 **Monitor Your Pipeline:**

- **Jenkins Dashboard**: http://localhost:8080
- **Pipeline View**: See all stages in real-time
- **Build History**: Track success/failure rates
