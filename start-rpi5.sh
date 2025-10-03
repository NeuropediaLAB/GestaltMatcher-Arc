#!/bin/bash
# Startup script for GestaltMatcher-Arc on Raspberry Pi 5

set -e

echo "==================================="
echo "GestaltMatcher-Arc for Raspberry Pi 5"
echo "==================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker first:"
    echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "  sudo sh get-docker.sh"
    exit 1
fi

# Check if Docker Compose is installed
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    echo "Please install Docker Compose:"
    echo "  sudo apt-get install docker-compose-plugin -y"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Check if required model files exist
MODELS_DIR="./saved_models"
DATA_DIR="./data"
GALLERY_DIR="./data/gallery_encodings"

echo "Checking for required files..."
MISSING_FILES=0

check_file() {
    if [ ! -f "$1" ]; then
        echo "❌ Missing: $1"
        MISSING_FILES=$((MISSING_FILES + 1))
    else
        echo "✅ Found: $1"
    fi
}

check_file "$MODELS_DIR/Resnet50_Final.pth"
check_file "$MODELS_DIR/glint360k_r100.onnx"
check_file "$MODELS_DIR/s1_glint360k_r50_512d_gmdb__v1.1.0_bs64_size112_channels3_last_model.pth"
check_file "$MODELS_DIR/s2_glint360k_r100_512d_gmdb__v1.1.0_bs128_size112_channels3_last_model.pth"
check_file "$DATA_DIR/image_gene_and_syndrome_metadata_20082024.p"
check_file "$GALLERY_DIR/GMDB_gallery_encodings_20082024_v1.1.0_service.pkl"
check_file "./config.json"

echo ""

if [ $MISSING_FILES -gt 0 ]; then
    echo "⚠️  WARNING: $MISSING_FILES required file(s) missing!"
    echo "Please obtain the model files as described in README_RPI5.md"
    echo "Contact: thsieh@uni-bonn.de or la60312@gmail.com"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if config.json has default credentials
if grep -q '"your_username"' config.json || grep -q '"your_password"' config.json; then
    echo "⚠️  WARNING: config.json still has default credentials!"
    echo "Please update config.json with secure credentials before deploying to production."
    echo ""
fi

# Create output directory
mkdir -p output

# Check for existing containers
if docker compose ps | grep -q "Up"; then
    echo "Services are already running."
    read -p "Restart services? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Restarting services..."
        docker compose restart
    fi
else
    # Build and start services
    echo "Building Docker images (this may take 15-30 minutes on first run)..."
    docker compose build

    echo ""
    echo "Starting services..."
    docker compose up -d

    echo ""
    echo "Waiting for services to be ready..."
    sleep 10
fi

echo ""
echo "==================================="
echo "Services Status:"
echo "==================================="
docker compose ps

echo ""
echo "==================================="
echo "Access Information:"
echo "==================================="

# Get IP addresses
IP_ADDR=$(hostname -I | awk '{print $1}')

echo "Web Interface (Streamlit):"
echo "  🌐 Local: http://localhost:8501"
echo "  🌐 Network: http://$IP_ADDR:8501"
echo ""
echo "REST API (FastAPI):"
echo "  🌐 Local: http://localhost:5000"
echo "  🌐 Network: http://$IP_ADDR:5000"
echo "  📚 API Docs: http://$IP_ADDR:5000/docs"
echo ""
echo "==================================="
echo "Useful Commands:"
echo "==================================="
echo "  View logs:          docker compose logs -f"
echo "  Stop services:      docker compose down"
echo "  Restart services:   docker compose restart"
echo "  View API logs:      docker compose logs -f gm-api"
echo "  View Web logs:      docker compose logs -f gm-web"
echo ""
echo "For troubleshooting, see README_RPI5.md"
echo "==================================="
