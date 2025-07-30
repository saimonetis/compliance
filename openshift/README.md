# OpenShift Deployment for Compliance Dashboard

This directory contains all the necessary files to deploy the Compliance Dashboard to an OpenShift cluster and make it accessible via the internet.

## 🚀 Quick Start

### Prerequisites
- OpenShift CLI (`oc`) installed and configured
- Access to an OpenShift cluster with project creation permissions
- Internet connectivity for image builds

### One-Command Deployment

```bash
./openshift/build-and-deploy.sh
```

This script will:
1. ✅ Verify OpenShift CLI access
2. 🏗️ Create/switch to `compliance-dashboard` project  
3. 📦 Build the Docker image using OpenShift BuildConfig
4. 🚀 Deploy all resources using kustomize
5. 🌐 Create an internet-accessible route with HTTPS
6. 📋 Display the dashboard URL

## 📁 Files Overview

| File | Purpose |
|------|---------|
| `build-and-deploy.sh` | Automated deployment script |
| `Dockerfile` | Container image definition with nginx |
| `nginx.conf` | Nginx configuration for serving HTML files |
| `deployment.yaml` | Kubernetes deployment manifest |
| `service.yaml` | Service to expose the deployment |
| `route.yaml` | OpenShift route for external access |
| `namespace.yaml` | Dedicated namespace |
| `kustomization.yaml` | Kustomize configuration |
| `configmap.yaml` | ConfigMap for additional configuration |

## 🔧 Manual Deployment

If you prefer manual deployment:

### 1. Login to OpenShift
```bash
oc login <your-openshift-cluster-url>
```

### 2. Create Project
```bash
oc new-project compliance-dashboard
```

### 3. Build Image
```bash
oc new-build --binary --name=compliance-dashboard --image-stream=nginx:alpine
oc start-build compliance-dashboard --from-dir=. --follow
```

### 4. Deploy Resources
```bash
oc apply -k openshift/
```

### 5. Check Deployment
```bash
oc get all -n compliance-dashboard
oc get route -n compliance-dashboard
```

## 🌐 Accessing the Dashboard

Once deployed, get the route URL:

```bash
oc get route compliance-dashboard-route -n compliance-dashboard -o jsonpath='{.spec.host}'
```

The dashboard will be accessible at: `https://<route-host>/`

## 🔍 Monitoring and Troubleshooting

### View Pod Status
```bash
oc get pods -n compliance-dashboard
```

### View Logs
```bash
oc logs -f deployment/compliance-dashboard -n compliance-dashboard
```

### Check Route
```bash
oc describe route compliance-dashboard-route -n compliance-dashboard
```

### Scale Deployment
```bash
oc scale deployment/compliance-dashboard --replicas=3 -n compliance-dashboard
```

## 🛡️ Security Features

- **Non-root container**: Runs as user ID 1001
- **HTTPS-only access**: Route redirects HTTP to HTTPS
- **Security headers**: X-Frame-Options, X-Content-Type-Options, etc.
- **Resource limits**: Memory and CPU limits configured
- **Health checks**: Liveness and readiness probes

## 🏗️ Architecture

```
Internet → OpenShift Router → Route → Service → Deployment → Pod(s) → Nginx → HTML Files
```

- **Route**: Provides HTTPS endpoint and SSL termination
- **Service**: Load balances traffic to pods
- **Deployment**: Manages pod replicas and rolling updates
- **Pods**: Run nginx containers serving the dashboard

## 🔄 Updates and Maintenance

### Update Dashboard Content
1. Modify HTML files
2. Rebuild and redeploy:
   ```bash
   ./openshift/build-and-deploy.sh
   ```

### Update Configuration
1. Modify manifests in `openshift/` directory
2. Apply changes:
   ```bash
   oc apply -k openshift/
   ```

## 🗑️ Cleanup

To remove the entire deployment:

```bash
oc delete project compliance-dashboard
```

Or remove specific resources:

```bash
oc delete -k openshift/
```

## ❓ Common Issues

### Build Fails
- Check if you're in the right directory (should contain `*.html` files)
- Verify OpenShift CLI access: `oc whoami`

### Route Not Accessible
- Check if route was created: `oc get route -n compliance-dashboard`
- Verify pods are running: `oc get pods -n compliance-dashboard`

### Permission Issues
- Ensure you have project creation permissions in OpenShift
- Contact your cluster administrator if needed

## 📞 Support

For issues with the deployment:
1. Check the troubleshooting section above
2. Review pod logs for errors
3. Open an issue in the GitHub repository 