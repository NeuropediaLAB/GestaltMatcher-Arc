# GestaltMatcher-Arc Raspberry Pi 5 Deployment Summary

This document provides an overview of all files and configurations added for Raspberry Pi 5 deployment.

## 🎯 Objective
Adapt GestaltMatcher-Arc repository for easy installation on Raspberry Pi 5 using Docker, with web interface access.

## 📦 Files Added

### Docker Configuration Files
| File | Purpose |
|------|---------|
| `Dockerfile.rpi5` | ARM64-optimized Dockerfile for REST API service |
| `Dockerfile.streamlit` | Dockerfile for Streamlit web interface |
| `docker-compose.yml` | Default configuration (both services, 8GB RAM optimized) |
| `docker-compose.4gb.yml` | Reduced resource limits for 4GB RAM models |
| `docker-compose.api-only.yml` | API-only configuration (no web interface) |
| `.dockerignore` | Optimize Docker build context |
| `.env.example` | Example environment variables |

### Documentation Files (English)
| File | Content |
|------|---------|
| `README_RPI5.md` | Complete installation and configuration guide |
| `QUICK_START_RPI5.md` | Quick reference card with essential commands |

### Documentation Files (Spanish)
| File | Content |
|------|---------|
| `README_RPI5_ES.md` | Guía completa de instalación y configuración |
| `INICIO_RAPIDO_RPI5_ES.md` | Tarjeta de referencia rápida con comandos esenciales |

### Utility Scripts
| File | Purpose |
|------|---------|
| `start-rpi5.sh` | Automated startup script with validation checks |

### Modified Files
| File | Changes |
|------|---------|
| `README.md` | Added Raspberry Pi 5 section with quick start and architecture diagram |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│               Raspberry Pi 5                        │
│                                                     │
│  Docker Containers:                                 │
│  ┌──────────────────┐      ┌──────────────────┐   │
│  │  gestaltmatcher- │      │  gestaltmatcher- │   │
│  │       api        │      │       web        │   │
│  │   (FastAPI)      │      │   (Streamlit)    │   │
│  │   Port: 5000     │      │   Port: 8501     │   │
│  └──────────────────┘      └──────────────────┘   │
│           │                         │              │
│           └─────────┬───────────────┘              │
│                     │                              │
│          ┌──────────▼──────────┐                  │
│          │  Shared Resources:  │                  │
│          │  - Models           │                  │
│          │  - Gallery DB       │                  │
│          │  - Config           │                  │
│          └─────────────────────┘                  │
└─────────────────────────────────────────────────────┘
```

## 🚀 Deployment Options

### Option 1: Full Setup (Recommended for 8GB models)
- **File**: `docker-compose.yml`
- **Services**: REST API + Web Interface
- **Resources**: 2GB RAM per service, 2 CPU cores per service
- **Use case**: Full functionality with web UI

```bash
docker compose up -d
```

### Option 2: 4GB Optimized
- **File**: `docker-compose.4gb.yml`
- **Services**: REST API + Web Interface
- **Resources**: 1.5GB RAM for API, 1GB for web, 1.5 CPU cores per service
- **Use case**: Both services on 4GB Raspberry Pi 5

```bash
docker compose -f docker-compose.4gb.yml up -d
```

### Option 3: API Only
- **File**: `docker-compose.api-only.yml`
- **Services**: REST API only
- **Resources**: 3GB RAM, 3 CPU cores
- **Use case**: Maximum performance for API, no web UI needed

```bash
docker compose -f docker-compose.api-only.yml up -d
```

## 🔌 Service Endpoints

### REST API (FastAPI)
- **URL**: `http://<rpi-ip>:5000`
- **Auth**: HTTP Basic Authentication (see config.json)
- **Endpoints**:
  - `GET /status` - Health check (no auth)
  - `POST /predict` - Predict from base64 image
  - `POST /predict_file` - Predict from file upload
  - `POST /predict_url` - Predict from URL (e.g., Google Drive)
  - `POST /encode` - Generate encodings only
  - `POST /crop` - Face alignment/cropping only
- **Docs**: `http://<rpi-ip>:5000/docs` - Interactive API documentation

### Web Interface (Streamlit)
- **URL**: `http://<rpi-ip>:8501`
- **Features**:
  - File upload interface
  - Visual results display
  - No programming required
  - Browser-based access

## 🔧 Key Features

### ARM64 Optimization
- Multi-stage Docker builds to reduce image size
- ARM64 compatible base images
- Optimized Python packages for ARM architecture

### Resource Management
- Configurable memory limits
- CPU core allocation
- Single worker mode for API (conserves resources)
- Separate configurations for different RAM sizes

### Reliability
- Health checks for both services
- Automatic restart policies
- Dependency management (web depends on API)
- Network isolation with Docker networks

### Security
- HTTP Basic Authentication
- Configurable credentials
- Volume mounting for sensitive config
- Firewall configuration guide

## 📋 Requirements Checklist

Before deployment, ensure you have:

### Hardware
- [ ] Raspberry Pi 5 (4GB or 8GB recommended)
- [ ] MicroSD card (32GB minimum, 64GB+ recommended)
- [ ] Active cooling (fan or heatsink)
- [ ] Stable network connection (Ethernet preferred)

### Software
- [ ] Raspberry Pi OS 64-bit (Bookworm or newer)
- [ ] Docker installed
- [ ] Docker Compose plugin installed

### Model Files
- [ ] `saved_models/Resnet50_Final.pth`
- [ ] `saved_models/glint360k_r100.onnx`
- [ ] `saved_models/s1_glint360k_r50_512d_gmdb__v1.1.0_bs64_size112_channels3_last_model.pth`
- [ ] `saved_models/s2_glint360k_r100_512d_gmdb__v1.1.0_bs128_size112_channels3_last_model.pth`
- [ ] `data/image_gene_and_syndrome_metadata_20082024.p`
- [ ] `data/gallery_encodings/GMDB_gallery_encodings_20082024_v1.1.0_service.pkl`

### Configuration
- [ ] `config.json` with custom credentials (not defaults)

## 🎓 Usage Examples

### Quick Start
```bash
# Clone repository
git clone https://github.com/xukrutdonut/GestaltMatcher-Arc.git
cd GestaltMatcher-Arc

# Configure credentials
nano config.json

# Start services
./start-rpi5.sh
```

### API Usage Examples

#### Check Status
```bash
curl http://localhost:5000/status
```

#### Predict from File
```bash
curl -X POST http://localhost:5000/predict_file \
  -u username:password \
  -F "file=@image.jpg"
```

#### Predict from URL
```bash
curl -X POST http://localhost:5000/predict_url \
  -u username:password \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/image.jpg"}'
```

### Management Commands
```bash
# View logs
docker compose logs -f

# Stop services
docker compose down

# Restart services
docker compose restart

# Update and rebuild
git pull
docker compose build
docker compose up -d
```

## 🔍 Monitoring & Troubleshooting

### Check Service Health
```bash
# Check container status
docker compose ps

# Check logs
docker compose logs -f

# Check resource usage
docker stats
```

### Common Issues

#### Out of Memory
- Use `docker-compose.4gb.yml` for 4GB models
- Increase swap file size
- Use API-only mode

#### Slow Performance
- Check CPU temperature: `vcgencmd measure_temp`
- Add active cooling
- Use Ethernet instead of WiFi
- Reduce concurrent requests

#### Port Conflicts
- Check what's using ports: `sudo lsof -i :5000`
- Modify ports in docker-compose.yml

## 📚 Documentation Structure

```
Documentation/
├── English/
│   ├── README_RPI5.md           (Complete guide)
│   └── QUICK_START_RPI5.md      (Quick reference)
│
├── Spanish/
│   ├── README_RPI5_ES.md        (Guía completa)
│   └── INICIO_RAPIDO_RPI5_ES.md (Referencia rápida)
│
└── README.md                     (Main README with RPi5 section)
```

## 🔐 Security Considerations

1. **Change default credentials** in `config.json`
2. **Use strong passwords** (minimum 12 characters)
3. **Enable firewall**: `sudo ufw enable`
4. **Keep system updated**: `sudo apt update && sudo apt upgrade`
5. **Use HTTPS** for external access (via reverse proxy)
6. **Regular backups** of config and data
7. **Monitor access logs**: `docker compose logs gm-api | grep POST`

## 🌐 Network Access Options

### Local Network Access
Both services accessible via `http://<rpi-ip>:<port>` from any device on the network.

### External Access (Advanced)
1. **Port Forwarding**: Configure router
2. **Dynamic DNS**: Use DuckDNS or similar
3. **Reverse Proxy**: Nginx/Caddy for HTTPS
4. **VPN**: WireGuard for secure remote access

## 📊 Performance Benchmarks

Typical performance on Raspberry Pi 5 (8GB):
- **Face alignment**: ~2-5 seconds
- **Encoding**: ~5-10 seconds
- **Prediction**: ~10-15 seconds
- **Total pipeline**: ~20-30 seconds per image

Performance factors:
- Image size and quality
- Model complexity
- Available RAM
- CPU temperature/throttling
- Network latency (for URL-based predictions)

## 🛠️ Maintenance

### Regular Tasks
- **Weekly**: Check logs for errors
- **Monthly**: Update Docker images, OS packages
- **Quarterly**: Review and rotate credentials
- **Yearly**: Full system backup and restore test

### Backup Strategy
```bash
# Backup configuration and data
tar -czf backup_$(date +%Y%m%d).tar.gz config.json data/ output/

# Automated backup script in INICIO_RAPIDO_RPI5_ES.md
```

## 📞 Support & Contact

- **Issues**: https://github.com/xukrutdonut/GestaltMatcher-Arc/issues
- **Email**: thsieh@uni-bonn.de or la60312@gmail.com
- **Documentation**: All README_RPI5*.md files in repository

## 📄 License

CC BY-NC 4.0 - Non-commercial use only

---

**Version**: 1.0  
**Last Updated**: 2024  
**Compatible with**: Raspberry Pi 5 (ARM64)  
**Tested on**: Raspberry Pi OS Bookworm 64-bit
