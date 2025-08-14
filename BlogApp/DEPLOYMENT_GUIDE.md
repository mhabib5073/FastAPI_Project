# FastAPI Blog Application - Docker Deployment Guide for Ubuntu VMware

This guide will help you deploy your FastAPI blog application using Docker on Ubuntu VMware.

## Prerequisites

### 1. Ubuntu VMware Setup
- Ubuntu 20.04 LTS or later
- At least 2GB RAM and 20GB disk space
- Network connectivity

### 2. Install Docker and Docker Compose

```bash
# Update package index
sudo apt update

# Install required packages
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
sudo apt update

# Install Docker Engine
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add your user to docker group (optional, to run docker without sudo)
sudo usermod -aG docker $USER
```

**Note:** After adding yourself to the docker group, log out and log back in for the changes to take effect.

## Deployment Steps

### 1. Transfer Application Files

Transfer your BlogApp directory to your Ubuntu VMware instance using one of these methods:

**Option A: Using SCP (if SSH is enabled)**
```bash
scp -r /path/to/BlogApp username@ubuntu-vm-ip:/home/username/
```

**Option B: Using Git (recommended)**
```bash
# On Ubuntu VM
git clone <your-repository-url>
cd BlogApp
```

**Option C: Using shared folders or USB**

### 2. Prepare the Environment

```bash
# Navigate to your application directory
cd BlogApp

# Create data directory for database persistence
mkdir -p data

# Set proper permissions
chmod 755 data
```

### 3. Build and Run with Docker Compose

**Basic deployment (FastAPI only):**
```bash
# Build and start the application
docker-compose up -d

# Check if containers are running
docker-compose ps

# View logs
docker-compose logs -f
```

**With Nginx reverse proxy:**
```bash
# Build and start with nginx
docker-compose --profile with-nginx up -d

# Check status
docker-compose ps
```

### 4. Verify Deployment

```bash
# Test the API directly
curl http://localhost:8000/blog

# If using nginx
curl http://localhost/blog

# Check application health
curl http://localhost:8000/blog
```

## Configuration Options

### Environment Variables

You can customize the deployment by setting environment variables:

```bash
# Create .env file
cat > .env << EOF
DATABASE_URL=sqlite:///./data/blog.db
PYTHONPATH=/app
EOF
```

### Port Configuration

To change the exposed port, modify `docker-compose.yml`:
```yaml
ports:
  - "8080:8000"  # Change 8080 to your desired port
```

## Management Commands

### Start/Stop Services
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart services
docker-compose restart
```

### View Logs
```bash
# View all logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View logs for specific service
docker-compose logs fastapi-blog
```

### Update Application
```bash
# Pull latest changes (if using git)
git pull

# Rebuild and restart
docker-compose down
docker-compose up -d --build
```

## Troubleshooting

### Common Issues

1. **Port already in use:**
   ```bash
   # Check what's using the port
   sudo netstat -tulpn | grep :8000
   
   # Kill the process or change port in docker-compose.yml
   ```

2. **Permission denied for database:**
   ```bash
   # Fix permissions
   sudo chown -R $USER:$USER data/
   chmod 755 data/
   ```

3. **Container won't start:**
   ```bash
   # Check logs
   docker-compose logs fastapi-blog
   
   # Check container status
   docker ps -a
   ```

### Health Checks

The application includes health checks. Monitor them with:
```bash
# Check container health
docker ps

# View detailed health status
docker inspect fastapi-blog-app | grep -A 10 Health
```

## Security Considerations

1. **Firewall Configuration:**
   ```bash
   # Enable UFW firewall
   sudo ufw enable
   
   # Allow specific ports
   sudo ufw allow 8000/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

2. **Regular Updates:**
   ```bash
   # Update system packages
   sudo apt update && sudo apt upgrade -y
   
   # Update Docker images
   docker-compose pull
   docker-compose up -d
   ```

## Production Recommendations

1. Use environment variables for sensitive configuration
2. Set up SSL/TLS certificates for HTTPS
3. Configure log rotation
4. Set up monitoring and alerting
5. Regular backups of the database
6. Use Docker secrets for sensitive data

## Backup and Restore

### Backup Database
```bash
# Create backup
cp data/blog.db backup/blog_$(date +%Y%m%d_%H%M%S).db
```

### Restore Database
```bash
# Stop application
docker-compose down

# Restore database
cp backup/blog_YYYYMMDD_HHMMSS.db data/blog.db

# Start application
docker-compose up -d
```

Your FastAPI blog application should now be running successfully on your Ubuntu VMware instance!
