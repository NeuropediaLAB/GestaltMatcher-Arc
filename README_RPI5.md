# GestaltMatcher-Arc: Raspberry Pi 5 Installation Guide

This guide explains how to install and run GestaltMatcher-Arc on a Raspberry Pi 5 using Docker, with both REST API and web interface access.

## Prerequisites

### Hardware Requirements
- **Raspberry Pi 5** (4GB or 8GB RAM recommended)
- **MicroSD card**: 32GB minimum, 64GB+ recommended
- **Cooling**: Active cooling recommended (the service can be CPU-intensive)
- **Network**: Ethernet or WiFi connection

### Software Requirements
- **Raspberry Pi OS**: 64-bit (Bookworm or newer)
- **Docker**: Version 20.10 or newer
- **Docker Compose**: Version 2.0 or newer

## Installation Steps

### 1. Install Docker on Raspberry Pi 5

```bash
# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to the docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install docker-compose-plugin -y

# Reboot to apply group changes
sudo reboot
```

After reboot, verify Docker installation:
```bash
docker --version
docker compose version
```

### 2. Clone the Repository

```bash
cd ~
git clone https://github.com/xukrutdonut/GestaltMatcher-Arc.git
cd GestaltMatcher-Arc
```

### 3. Obtain Required Model Files

**IMPORTANT**: Due to ethical reasons, the pretrained models are not publicly available. You need to obtain them first. Contact the authors (see main README.md) to get access to:

**Pretrained models** (save in `./saved_models/`):
1. `Resnet50_Final.pth` (for face alignment)
2. `s1_glint360k_r50_512d_gmdb__v1.1.0_bs64_size112_channels3_last_model.pth` (model 1 for encoding)
3. `s2_glint360k_r100_512d_gmdb__v1.1.0_bs128_size112_channels3_last_model.pth` (model 2 for encoding)
4. `glint360k_r100.onnx` (model 3 for encoding)

**Metadata** (save in `./data/`):
1. `image_gene_and_syndrome_metadata_20082024.p` (image metadata)

**Encodings** (save in `./data/gallery_encodings/`):
1. `GMDB_gallery_encodings_20082024_v1.1.0_service.pkl` (image encodings)

### 4. Configure Authentication

Edit `config.json` to set your credentials:
```bash
nano config.json
```

Change the default username and password:
```json
{
    "username": "your_secure_username",
    "password": "your_secure_password"
}
```

### 5. Build and Run with Docker Compose

```bash
# Build the Docker images (this may take 15-30 minutes on Raspberry Pi 5)
docker compose build

# Start the services
docker compose up -d

# Check if services are running
docker compose ps
```

## Accessing the Services

### Web Interface (Streamlit)
- **URL**: `http://<raspberry-pi-ip>:8501`
- **Default port**: 8501
- **Usage**: User-friendly web interface for uploading images and viewing results

To find your Raspberry Pi's IP address:
```bash
hostname -I
```

### REST API (FastAPI)
- **URL**: `http://<raspberry-pi-ip>:5000`
- **Default port**: 5000
- **Documentation**: `http://<raspberry-pi-ip>:5000/docs` (FastAPI auto-generated docs)
- **Authentication**: HTTP Basic Auth (use credentials from config.json)

#### API Endpoints

1. **Status Check** (no auth required)
   ```bash
   curl http://<raspberry-pi-ip>:5000/status
   ```

2. **Predict from Base64 Image**
   ```bash
   curl -X POST http://<raspberry-pi-ip>:5000/predict \
     -u username:password \
     -H "Content-Type: application/json" \
     -d '{"img": "<base64-encoded-image>"}'
   ```

3. **Predict from File Upload**
   ```bash
   curl -X POST http://<raspberry-pi-ip>:5000/predict_file \
     -u username:password \
     -F "file=@/path/to/image.jpg"
   ```

4. **Predict from URL** (e.g., Google Drive)
   ```bash
   curl -X POST http://<raspberry-pi-ip>:5000/predict_url \
     -u username:password \
     -H "Content-Type: application/json" \
     -d '{"url": "https://drive.google.com/file/d/YOUR_FILE_ID/view"}'
   ```

## Managing the Services

### View Logs
```bash
# All services
docker compose logs -f

# API only
docker compose logs -f gm-api

# Web interface only
docker compose logs -f gm-web
```

### Stop Services
```bash
docker compose down
```

### Restart Services
```bash
docker compose restart
```

### Update to Latest Version
```bash
git pull
docker compose build
docker compose up -d
```

## Performance Optimization for Raspberry Pi 5

### Memory Management
The docker-compose.yml is configured with 2GB memory limits per service. If you have the 4GB model and experience issues:

```yaml
# In docker-compose.yml, adjust mem_limit:
mem_limit: 1g  # Reduce to 1GB if needed
```

### CPU Allocation
Services are limited to 2 CPU cores by default. For the 4-core Raspberry Pi 5:

```yaml
# In docker-compose.yml
cpus: 1.5  # Adjust as needed
```

### Reduce Workers
The API is configured with 1 worker for Raspberry Pi. This is already optimized, but you can adjust in `Dockerfile.rpi5`:

```dockerfile
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000", "--workers", "1"]
```

## Troubleshooting

### Service Won't Start
1. Check logs: `docker compose logs`
2. Verify model files are in correct locations
3. Ensure adequate disk space: `df -h`
4. Check memory usage: `free -h`

### Out of Memory Issues
```bash
# Increase swap file size
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Set CONF_SWAPSIZE=2048 (2GB)
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

### Slow Performance
- Ensure adequate cooling (check temperature: `vcgencmd measure_temp`)
- Close unnecessary services
- Use ethernet instead of WiFi
- Consider using only the API service without the web interface

### Port Already in Use
```bash
# Check what's using the ports
sudo lsof -i :5000
sudo lsof -i :8501

# Change ports in docker-compose.yml if needed
```

## Network Access

### Access from Other Devices
Both services are accessible from any device on your network using the Raspberry Pi's IP address.

### External Access (Advanced)
To access from outside your network:

1. **Port Forwarding**: Configure your router to forward ports 5000 and 8501
2. **Dynamic DNS**: Use a service like DuckDNS for a stable hostname
3. **Reverse Proxy**: Use Nginx or Caddy for HTTPS support

Example Nginx configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8501;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /api {
        proxy_pass http://localhost:5000;
    }
}
```

## Security Recommendations

1. **Change default credentials** in config.json
2. **Use strong passwords** for authentication
3. **Enable firewall**:
   ```bash
   sudo apt-get install ufw
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 5000/tcp  # API
   sudo ufw allow 8501/tcp  # Web
   sudo ufw enable
   ```
4. **Keep system updated**:
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   ```
5. **Use HTTPS** in production (with reverse proxy)

## Backup and Maintenance

### Backup Configuration
```bash
tar -czf gestaltmatcher-backup.tar.gz config.json data/
```

### Monitor Disk Space
```bash
# Check disk usage
df -h

# Clean up old Docker images
docker system prune -a
```

### Monitor System Resources
```bash
# Install monitoring tools
sudo apt-get install htop

# Run htop to monitor CPU/RAM
htop
```

## Support

For issues specific to Raspberry Pi 5 deployment, please check:
1. This README_RPI5.md file
2. Main README.md for general documentation
3. GitHub Issues: https://github.com/xukrutdonut/GestaltMatcher-Arc/issues

For model access and general questions:
- Email: thsieh@uni-bonn.de or la60312@gmail.com

## License
[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-nc/4.0/)
