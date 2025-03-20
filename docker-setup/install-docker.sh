#!/bin/bash

# Variables
ERROR_DIR="$(pwd)/errores"
ERROR_LOG="$ERROR_DIR/install_docker.log"

# Crear carpeta de errores si no existe
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
