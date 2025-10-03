# GestaltMatcher-Arc: Guía de Instalación para Raspberry Pi 5

Esta guía explica cómo instalar y ejecutar GestaltMatcher-Arc en una Raspberry Pi 5 usando Docker, con acceso tanto a la API REST como a la interfaz web.

## Requisitos Previos

### Requisitos de Hardware
- **Raspberry Pi 5** (se recomienda 4GB u 8GB de RAM)
- **Tarjeta MicroSD**: 32GB mínimo, 64GB+ recomendado
- **Refrigeración**: Se recomienda refrigeración activa (el servicio puede ser intensivo en CPU)
- **Red**: Conexión Ethernet o WiFi

### Requisitos de Software
- **Raspberry Pi OS**: 64-bit (Bookworm o más reciente)
- **Docker**: Versión 20.10 o más reciente
- **Docker Compose**: Versión 2.0 o más reciente

## Pasos de Instalación

### 1. Instalar Docker en Raspberry Pi 5

```bash
# Actualizar paquetes del sistema
sudo apt-get update
sudo apt-get upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Añadir tu usuario al grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo apt-get install docker-compose-plugin -y

# Reiniciar para aplicar cambios de grupo
sudo reboot
```

Después del reinicio, verifica la instalación de Docker:
```bash
docker --version
docker compose version
```

### 2. Clonar el Repositorio

```bash
cd ~
git clone https://github.com/xukrutdonut/GestaltMatcher-Arc.git
cd GestaltMatcher-Arc
```

### 3. Obtener los Archivos de Modelo Requeridos

**IMPORTANTE**: Por razones éticas, los modelos pre-entrenados no están disponibles públicamente. Necesitas obtenerlos primero. Contacta a los autores (ver README.md principal) para obtener acceso a:

**Modelos pre-entrenados** (guardar en `./saved_models/`):
1. `Resnet50_Final.pth` (para alineación facial)
2. `s1_glint360k_r50_512d_gmdb__v1.1.0_bs64_size112_channels3_last_model.pth` (modelo 1 para codificación)
3. `s2_glint360k_r100_512d_gmdb__v1.1.0_bs128_size112_channels3_last_model.pth` (modelo 2 para codificación)
4. `glint360k_r100.onnx` (modelo 3 para codificación)

**Metadatos** (guardar en `./data/`):
1. `image_gene_and_syndrome_metadata_20082024.p` (metadatos de imágenes)

**Codificaciones** (guardar en `./data/gallery_encodings/`):
1. `GMDB_gallery_encodings_20082024_v1.1.0_service.pkl` (codificaciones de imágenes)

### 4. Configurar Autenticación

Edita `config.json` para establecer tus credenciales:
```bash
nano config.json
```

Cambia el usuario y contraseña predeterminados:
```json
{
    "username": "tu_usuario_seguro",
    "password": "tu_contraseña_segura"
}
```

### 5. Construir y Ejecutar con Docker Compose

```bash
# Construir las imágenes Docker (puede tomar 15-30 minutos en Raspberry Pi 5)
docker compose build

# Iniciar los servicios
docker compose up -d

# Verificar si los servicios están ejecutándose
docker compose ps
```

## Acceder a los Servicios

### Interfaz Web (Streamlit)
- **URL**: `http://<ip-raspberry-pi>:8501`
- **Puerto predeterminado**: 8501
- **Uso**: Interfaz web amigable para subir imágenes y ver resultados

Para encontrar la dirección IP de tu Raspberry Pi:
```bash
hostname -I
```

### API REST (FastAPI)
- **URL**: `http://<ip-raspberry-pi>:5000`
- **Puerto predeterminado**: 5000
- **Documentación**: `http://<ip-raspberry-pi>:5000/docs` (documentación auto-generada de FastAPI)
- **Autenticación**: HTTP Basic Auth (usa las credenciales de config.json)

#### Endpoints de la API

1. **Verificación de Estado** (no requiere autenticación)
   ```bash
   curl http://<ip-raspberry-pi>:5000/status
   ```

2. **Predicción desde Imagen Base64**
   ```bash
   curl -X POST http://<ip-raspberry-pi>:5000/predict \
     -u usuario:contraseña \
     -H "Content-Type: application/json" \
     -d '{"img": "<imagen-codificada-en-base64>"}'
   ```

3. **Predicción desde Carga de Archivo**
   ```bash
   curl -X POST http://<ip-raspberry-pi>:5000/predict_file \
     -u usuario:contraseña \
     -F "file=@/ruta/a/imagen.jpg"
   ```

4. **Predicción desde URL** (ej. Google Drive)
   ```bash
   curl -X POST http://<ip-raspberry-pi>:5000/predict_url \
     -u usuario:contraseña \
     -H "Content-Type: application/json" \
     -d '{"url": "https://drive.google.com/file/d/TU_ID_ARCHIVO/view"}'
   ```

## Gestión de los Servicios

### Ver Registros
```bash
# Todos los servicios
docker compose logs -f

# Solo API
docker compose logs -f gm-api

# Solo interfaz web
docker compose logs -f gm-web
```

### Detener Servicios
```bash
docker compose down
```

### Reiniciar Servicios
```bash
docker compose restart
```

### Actualizar a la Última Versión
```bash
git pull
docker compose build
docker compose up -d
```

## Optimización de Rendimiento para Raspberry Pi 5

### Gestión de Memoria
El docker-compose.yml está configurado con límites de memoria de 2GB por servicio. Si tienes el modelo de 4GB y experimentas problemas:

```yaml
# En docker-compose.yml, ajusta mem_limit:
mem_limit: 1g  # Reduce a 1GB si es necesario
```

### Asignación de CPU
Los servicios están limitados a 2 núcleos de CPU por defecto. Para la Raspberry Pi 5 de 4 núcleos:

```yaml
# En docker-compose.yml
cpus: 1.5  # Ajusta según sea necesario
```

### Reducir Workers
La API está configurada con 1 worker para Raspberry Pi. Esto ya está optimizado, pero puedes ajustar en `Dockerfile.rpi5`:

```dockerfile
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000", "--workers", "1"]
```

## Solución de Problemas

### El Servicio No Inicia
1. Verificar registros: `docker compose logs`
2. Verificar que los archivos de modelo estén en las ubicaciones correctas
3. Asegurar espacio en disco adecuado: `df -h`
4. Verificar uso de memoria: `free -h`

### Problemas de Memoria Insuficiente
```bash
# Aumentar tamaño del archivo de swap
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Establecer CONF_SWAPSIZE=2048 (2GB)
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

### Rendimiento Lento
- Asegurar refrigeración adecuada (verificar temperatura: `vcgencmd measure_temp`)
- Cerrar servicios innecesarios
- Usar ethernet en lugar de WiFi
- Considerar usar solo el servicio API sin la interfaz web

### Puerto Ya en Uso
```bash
# Verificar qué está usando los puertos
sudo lsof -i :5000
sudo lsof -i :8501

# Cambiar puertos en docker-compose.yml si es necesario
```

## Acceso de Red

### Acceso desde Otros Dispositivos
Ambos servicios son accesibles desde cualquier dispositivo en tu red usando la dirección IP de la Raspberry Pi.

### Acceso Externo (Avanzado)
Para acceder desde fuera de tu red:

1. **Redirección de Puertos**: Configura tu router para redirigir los puertos 5000 y 8501
2. **DNS Dinámico**: Usa un servicio como DuckDNS para un nombre de host estable
3. **Proxy Inverso**: Usa Nginx o Caddy para soporte HTTPS

Ejemplo de configuración de Nginx:
```nginx
server {
    listen 80;
    server_name tu-dominio.com;

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

## Recomendaciones de Seguridad

1. **Cambiar credenciales predeterminadas** en config.json
2. **Usar contraseñas fuertes** para autenticación
3. **Habilitar firewall**:
   ```bash
   sudo apt-get install ufw
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 5000/tcp  # API
   sudo ufw allow 8501/tcp  # Web
   sudo ufw enable
   ```
4. **Mantener el sistema actualizado**:
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   ```
5. **Usar HTTPS** en producción (con proxy inverso)

## Respaldo y Mantenimiento

### Respaldar Configuración
```bash
tar -czf gestaltmatcher-backup.tar.gz config.json data/
```

### Monitorear Espacio en Disco
```bash
# Verificar uso de disco
df -h

# Limpiar imágenes Docker antiguas
docker system prune -a
```

### Monitorear Recursos del Sistema
```bash
# Instalar herramientas de monitoreo
sudo apt-get install htop

# Ejecutar htop para monitorear CPU/RAM
htop
```

## Soporte

Para problemas específicos de la implementación en Raspberry Pi 5, por favor consulta:
1. Este archivo README_RPI5_ES.md
2. README.md principal para documentación general
3. Problemas de GitHub: https://github.com/xukrutdonut/GestaltMatcher-Arc/issues

Para acceso a modelos y preguntas generales:
- Email: thsieh@uni-bonn.de o la60312@gmail.com

## Licencia
[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-nc/4.0/)
