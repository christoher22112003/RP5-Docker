#!/bin/bash

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROR_DIR="$SCRIPT_DIR/../logs"
ERROR_LOG="$ERROR_DIR/install_docker.log"

# Crear carpeta de logs si no existe
mkdir -p "$ERROR_DIR"

# Instalar Docker
echo "Descargando e instalando Docker..." | tee -a "$ERROR_LOG"
sudo curl -fsSL https://get.docker.com/ -o get-docker.sh
sudo sh get-docker.sh >> "$ERROR_LOG" 2>&1

# Añadir el usuario actual al grupo Docker
echo "Añadiendo el usuario actual al grupo Docker..." | tee -a "$ERROR_LOG"
sudo usermod -aG docker ${USER} >> "$ERROR_LOG" 2>&1

# Verificar instalación de Docker
echo "Verificando instalación de Docker..." | tee -a "$ERROR_LOG"
if ! command -v docker &> /dev/null; then
  echo "Error: Docker no se instaló correctamente." | tee -a "$ERROR_LOG"
  exit 1
fi

echo "Docker se instaló correctamente." | tee -a "$ERROR_LOG"

# Verificar instalación de Docker Compose
echo "Verificando instalación de Docker Compose..."
if ! docker compose version &> /dev/null; then
  echo "Error: Docker Compose no se instaló correctamente." | tee -a "$ERROR_LOG"
  exit 1
fi
