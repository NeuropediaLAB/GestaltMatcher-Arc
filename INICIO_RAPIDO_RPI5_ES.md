# 🍓 GestaltMatcher-Arc - Inicio Rápido para Raspberry Pi 5

## Instalación en Una Línea (después de obtener los modelos)

```bash
curl -fsSL https://get.docker.com | sh && \
sudo usermod -aG docker $USER && \
sudo apt-get install -y docker-compose-plugin && \
echo "⚠️ Por favor, cierra sesión y vuelve a iniciar sesión, luego ejecuta: ./start-rpi5.sh"
```

## Comandos Esenciales

| Acción | Comando |
|--------|---------|
| **Iniciar servicios** | `./start-rpi5.sh` o `docker compose up -d` |
| **Detener servicios** | `docker compose down` |
| **Ver registros** | `docker compose logs -f` |
| **Reiniciar servicios** | `docker compose restart` |
| **Actualizar** | `git pull && docker compose build && docker compose up -d` |
| **Verificar estado** | `docker compose ps` |

## Puntos de Acceso

| Servicio | URL | Descripción |
|---------|-----|-------------|
| **Interfaz Web** | http://\<ip-rpi\>:8501 | Interfaz Streamlit - subir imágenes, ver resultados |
| **API REST** | http://\<ip-rpi\>:5000 | Endpoint FastAPI - para acceso programático |
| **Documentación API** | http://\<ip-rpi\>:5000/docs | Documentación interactiva de la API |

Encuentra tu IP: `hostname -I`

## Lista de Verificación de Archivos Requeridos

Antes de ejecutar, asegúrate de tener:

- [ ] `saved_models/Resnet50_Final.pth`
- [ ] `saved_models/glint360k_r100.onnx`
- [ ] `saved_models/s1_glint360k_r50_512d_gmdb__v1.1.0_bs64_size112_channels3_last_model.pth`
- [ ] `saved_models/s2_glint360k_r100_512d_gmdb__v1.1.0_bs128_size112_channels3_last_model.pth`
- [ ] `data/image_gene_and_syndrome_metadata_20082024.p`
- [ ] `data/gallery_encodings/GMDB_gallery_encodings_20082024_v1.1.0_service.pkl`
- [ ] `config.json` (¡con TUS credenciales, no las predeterminadas!)

**Para obtener los modelos**: Contacta thsieh@uni-bonn.de o la60312@gmail.com

## Ejemplos de Uso de la API

### Probar conexión
```bash
curl http://localhost:5000/status
```

### Predicción desde archivo
```bash
curl -X POST http://localhost:5000/predict_file \
  -u tu_usuario:tu_contraseña \
  -F "file=@/ruta/a/imagen.jpg"
```

### Predicción desde URL (Google Drive)
```bash
curl -X POST http://localhost:5000/predict_url \
  -u tu_usuario:tu_contraseña \
  -H "Content-Type: application/json" \
  -d '{"url": "https://drive.google.com/file/d/ID_ARCHIVO/view"}'
```

## Soluciones Rápidas para Problemas

| Problema | Solución |
|---------|----------|
| **Sin memoria** | `docker compose restart` o aumentar swap (ver README_RPI5.md) |
| **Puerto en uso** | Cambiar puertos en `docker-compose.yml` |
| **Los servicios no inician** | Verificar registros: `docker compose logs` |
| **Rendimiento lento** | Verificar temperatura CPU: `vcgencmd measure_temp` (añadir enfriamiento si >70°C) |
| **No puedo acceder desde la red** | Verificar firewall: `sudo ufw status` |

## Consejos de Rendimiento

- ✅ Usa **ethernet** en lugar de WiFi
- ✅ Habilita **enfriamiento activo** (ventilador o disipador)
- ✅ Usa el modelo de **8GB de RAM** para mejor rendimiento
- ✅ Cierra servicios innecesarios: `sudo systemctl disable bluetooth`
- ✅ Monitorea recursos: `htop`

## Lista de Verificación de Seguridad

- [ ] Cambiado el usuario/contraseña predeterminados en `config.json`
- [ ] Firewall habilitado: `sudo ufw enable`
- [ ] Sistema actualizado: `sudo apt update && sudo apt upgrade`
- [ ] Usando HTTPS (si está expuesto a internet)
- [ ] Respaldos regulares: `tar -czf backup.tar.gz config.json data/`

## ¿Necesitas Más Ayuda?

📖 **Documentación completa**: [README_RPI5.md](README_RPI5.md) (en inglés)  
📧 **Contacto**: thsieh@uni-bonn.de o la60312@gmail.com  
🐛 **Problemas**: https://github.com/xukrutdonut/GestaltMatcher-Arc/issues

---

**Licencia**: CC BY-NC 4.0 - Solo uso no comercial

## Características Principales

### 🌐 Acceso Web con Streamlit
La interfaz web Streamlit proporciona:
- Subida de imágenes mediante arrastrar y soltar
- Visualización de resultados en tiempo real
- Interfaz amigable sin necesidad de programación
- Acceso desde cualquier navegador en tu red

### 🔌 API REST con FastAPI
La API REST permite:
- Integración con otras aplicaciones
- Procesamiento por lotes
- Automatización de predicciones
- Acceso programático desde Python, Node.js, etc.

### 🍓 Optimizado para Raspberry Pi 5
- Imágenes Docker optimizadas para ARM64
- Límites de recursos configurados apropiadamente
- Un solo worker para conservar memoria
- Construcción multi-etapa para reducir tamaño de imagen

## Arquitectura del Sistema

```
┌─────────────────────────────────────────┐
│         Raspberry Pi 5                  │
│                                         │
│  ┌───────────────┐   ┌──────────────┐  │
│  │  gm-web       │   │   gm-api     │  │
│  │  (Streamlit)  │   │  (FastAPI)   │  │
│  │  Puerto: 8501 │   │ Puerto: 5000 │  │
│  └───────────────┘   └──────────────┘  │
│          │                   │          │
│          └─────────┬─────────┘          │
│                    │                    │
│         ┌──────────▼────────┐          │
│         │   Modelos & Data  │          │
│         └───────────────────┘          │
└─────────────────────────────────────────┘
```

## Solución de Problemas Detallada

### Error: "Cannot connect to Docker daemon"
```bash
# Verificar que Docker esté ejecutándose
sudo systemctl status docker

# Iniciar Docker si está detenido
sudo systemctl start docker

# Verificar que tu usuario esté en el grupo docker
groups | grep docker

# Si no está, añádelo y reinicia sesión
sudo usermod -aG docker $USER
```

### Error: "Port already in use"
```bash
# Ver qué está usando el puerto
sudo lsof -i :5000
sudo lsof -i :8501

# Detener el proceso o cambiar el puerto en docker-compose.yml
```

### Error: "Out of memory"
```bash
# Aumentar archivo de swap
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Cambiar CONF_SWAPSIZE=2048
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# O reducir límites de memoria en docker-compose.yml
# mem_limit: 1g
```

### Rendimiento Lento
```bash
# Verificar temperatura
vcgencmd measure_temp

# Si está alta (>70°C), mejorar enfriamiento
# O reducir carga:
# - Usar solo API sin interfaz web
# - Procesar imágenes de menor tamaño
# - Aumentar tiempo entre peticiones
```

## Consejos Avanzados

### Acceso Remoto Seguro con Nginx
```bash
# Instalar Nginx
sudo apt-get install nginx

# Configurar proxy reverso
sudo nano /etc/nginx/sites-available/gestaltmatcher
```

Añade esta configuración:
```nginx
server {
    listen 80;
    server_name tu-dominio.com;

    location / {
        proxy_pass http://localhost:8501;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }

    location /api {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Monitoreo Continuo
```bash
# Instalar herramientas de monitoreo
sudo apt-get install htop iotop

# Ver uso de CPU y memoria
htop

# Ver uso de disco
iotop

# Monitorear logs en tiempo real
docker compose logs -f --tail=100
```

### Respaldo Automático
Crea un script de respaldo:
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf /home/$USER/backups/gm_backup_$DATE.tar.gz \
    config.json data/ output/
# Mantener solo los últimos 7 días
find /home/$USER/backups -name "gm_backup_*" -mtime +7 -delete
```

Programa con cron:
```bash
crontab -e
# Añade: 0 2 * * * /home/tu_usuario/backup.sh
```

## Preguntas Frecuentes

**P: ¿Cuánta RAM necesito?**
R: Mínimo 4GB, recomendado 8GB para mejor rendimiento.

**P: ¿Puedo usar WiFi?**
R: Sí, pero ethernet es más estable y rápido.

**P: ¿Cuánto tarda en procesar una imagen?**
R: Depende de la imagen, pero generalmente 10-30 segundos en Raspberry Pi 5.

**P: ¿Puedo ejecutar esto 24/7?**
R: Sí, con enfriamiento adecuado y configuración de reinicio automático.

**P: ¿Funciona en Raspberry Pi 4?**
R: Debería funcionar, pero puede ser más lento. Ajusta los límites de recursos.

---

**¡Listo para usar! Disfruta de GestaltMatcher-Arc en tu Raspberry Pi 5! 🍓🚀**
