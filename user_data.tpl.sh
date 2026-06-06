#!/bin/bash
# 0. Create Swap Space (t2.micro only has 1GB RAM, kind needs more)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# 1. Update and install Docker
apt-get update
apt-get install -y docker.io
usermod -aG docker ubuntu

# 2. Install kind & kubectl
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# 3. Create the Mini Dashboard source files
mkdir -p /root/app
cd /root/app

cat << 'FILE_EOF' > index.html
${index_html}
FILE_EOF

cat << 'FILE_EOF' > styles.css
${styles_css}
FILE_EOF

cat << 'FILE_EOF' > app.js
${app_js}
FILE_EOF

cat << 'FILE_EOF' > data.json
${data_json}
FILE_EOF

cat << 'FILE_EOF' > Dockerfile
${dockerfile}
FILE_EOF

# Build the Docker image locally
docker build -t mini-dashboard:latest .

# 4. Create kind configuration with extra port mapping
cat << 'KIND_EOF' > /root/kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
KIND_EOF

# Initialize the cluster
kind create cluster --config /root/kind-config.yaml

# 5. Load the locally built docker image into the kind cluster
kind load docker-image mini-dashboard:latest

# 6. Deploy the application into K8s
cat << 'APP_EOF' > /root/app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dashboard-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: dashboard
  template:
    metadata:
      labels:
        app: dashboard
    spec:
      containers:
      - name: web
        image: mini-dashboard:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: dashboard-service
spec:
  type: NodePort
  selector:
    app: dashboard
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30000
APP_EOF

kubectl apply -f /root/app.yaml
