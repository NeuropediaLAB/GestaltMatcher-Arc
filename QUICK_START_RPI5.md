# 🍓 GestaltMatcher-Arc - Raspberry Pi 5 Quick Start

## One-Line Installation (after obtaining models)

```bash
curl -fsSL https://get.docker.com | sh && \
sudo usermod -aG docker $USER && \
sudo apt-get install -y docker-compose-plugin && \
echo "⚠️ Please log out and log back in, then run: ./start-rpi5.sh"
```

## Essential Commands

| Action | Command |
|--------|---------|
| **Start services** | `./start-rpi5.sh` or `docker compose up -d` |
| **Start (4GB model)** | `docker compose -f docker-compose.4gb.yml up -d` |
| **Start (API only)** | `docker compose -f docker-compose.api-only.yml up -d` |
| **Stop services** | `docker compose down` |
| **View logs** | `docker compose logs -f` |
| **Restart services** | `docker compose restart` |
| **Update** | `git pull && docker compose build && docker compose up -d` |
| **Check status** | `docker compose ps` |

## Access Points

| Service | URL | Description |
|---------|-----|-------------|
| **Web UI** | http://\<rpi-ip\>:8501 | Streamlit interface - upload images, view results |
| **REST API** | http://\<rpi-ip\>:5000 | FastAPI endpoint - for programmatic access |
| **API Docs** | http://\<rpi-ip\>:5000/docs | Interactive API documentation |

Find your IP: `hostname -I`

## Required Files Checklist

Before running, ensure you have:

- [ ] `saved_models/Resnet50_Final.pth`
- [ ] `saved_models/glint360k_r100.onnx`
- [ ] `saved_models/s1_glint360k_r50_512d_gmdb__v1.1.0_bs64_size112_channels3_last_model.pth`
- [ ] `saved_models/s2_glint360k_r100_512d_gmdb__v1.1.0_bs128_size112_channels3_last_model.pth`
- [ ] `data/image_gene_and_syndrome_metadata_20082024.p`
- [ ] `data/gallery_encodings/GMDB_gallery_encodings_20082024_v1.1.0_service.pkl`
- [ ] `config.json` (with YOUR credentials, not defaults!)

**To obtain models**: Contact thsieh@uni-bonn.de or la60312@gmail.com

## Example API Usage

### Test connection
```bash
curl http://localhost:5000/status
```

### Predict from file
```bash
curl -X POST http://localhost:5000/predict_file \
  -u your_username:your_password \
  -F "file=@/path/to/image.jpg"
```

### Predict from URL (Google Drive)
```bash
curl -X POST http://localhost:5000/predict_url \
  -u your_username:your_password \
  -H "Content-Type: application/json" \
  -d '{"url": "https://drive.google.com/file/d/FILE_ID/view"}'
```

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| **Out of memory** | `docker compose restart` or increase swap (see README_RPI5.md) |
| **Port in use** | Change ports in `docker-compose.yml` |
| **Services won't start** | Check logs: `docker compose logs` |
| **Slow performance** | Check CPU temp: `vcgencmd measure_temp` (add cooling if >70°C) |
| **Can't access from network** | Check firewall: `sudo ufw status` |

## Performance Tips

- ✅ Use **ethernet** instead of WiFi
- ✅ Enable **active cooling** (fan or heatsink)
- ✅ Use **8GB RAM** model for better performance
- ✅ Close unnecessary services: `sudo systemctl disable bluetooth`
- ✅ Monitor resources: `htop`

## Security Checklist

- [ ] Changed default username/password in `config.json`
- [ ] Firewall enabled: `sudo ufw enable`
- [ ] Kept system updated: `sudo apt update && sudo apt upgrade`
- [ ] Using HTTPS (if exposed to internet)
- [ ] Regular backups: `tar -czf backup.tar.gz config.json data/`

## Need More Help?

📖 **Full documentation**: [README_RPI5.md](README_RPI5.md)  
📧 **Contact**: thsieh@uni-bonn.de or la60312@gmail.com  
🐛 **Issues**: https://github.com/xukrutdonut/GestaltMatcher-Arc/issues

---

**License**: CC BY-NC 4.0 - Non-commercial use only
