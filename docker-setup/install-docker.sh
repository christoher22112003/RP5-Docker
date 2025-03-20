#!/bin/bash

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROR_DIR="$SCRIPT_DIR/../logs"
ERROR_LOG="$ERROR_DIR/install_docker.log"

# Colores
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Crear carpeta de logs si no existe
mkdir -p "$ERROR_DIR"

# Instalar Docker
echo -e "${YELLOW}Descargando e instalando Docker...${RESET}" | tee -a "$ERROR_LOG"
sudo curl -fsSL https://get.docker.com/ -o get-docker.sh
sudo sh get-docker.sh >> "$ERROR_LOG" 2>&1

# Añadir el usuario actual al grupo Docker
echo -e "${YELLOW}Añadiendo el usuario actual al grupo Docker...${RESET}" | tee -a "$ERROR_LOG"
sudo usermod -aG docker ${USER} >> "$ERROR_LOG" 2>&1

# Verificar instalación de Docker
echo -e "${YELLOW}Verificando instalación de Docker...${RESET}" | tee -a "$ERROR_LOG"
if ! command -v docker &> /dev/null; then
  echo -e "${RED}Error: Docker no se instaló correctamente.${RESET}" | tee -a "$ERROR_LOG"
  exit 1
fi

echo -e "${GREEN}Docker se instaló correctamente.${RESET}" | tee -a "$ERROR_LOG"

# Instalar Docker Compose si no está instalado
echo -e "${YELLOW}Verificando instalación de Docker Compose...${RESET}" | tee -a "$ERROR_LOG"
if ! command -v docker-compose &> /dev/null; then
  echo -e "${YELLOW}Docker Compose no está instalado. Instalándolo ahora...${RESET}" | tee -a "$ERROR_LOG"
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >> "$ERROR_LOG" 2>&1
  sudo chmod +x /usr/local/bin/docker-compose >> "$ERROR_LOG" 2>&1

  # Verificar si Docker Compose se instaló correctamente
  if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: Docker Compose no se instaló correctamente.${RESET}" | tee -a "$ERROR_LOG"
    exit 1
  fi
fi

echo -e "${GREEN}Docker Compose se instaló correctamente.${RESET}" | tee -a "$ERROR_LOG"
