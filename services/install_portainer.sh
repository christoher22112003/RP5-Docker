#!/bin/bash

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROR_DIR="$SCRIPT_DIR/../logs"
ERROR_LOG="$ERROR_DIR/install_portainer.log"

# Colores
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Crear carpeta de logs si no existe
mkdir -p "$ERROR_DIR"

# Verificar si Portainer ya está instalado
echo -e "${YELLOW}Verificando si Portainer ya está instalado...${RESET}"
if docker ps --format '{{.Names}}' | grep -q "^portainer$"; then
    echo -e "${GREEN}Portainer ya está instalado. Omitiendo instalación.${RESET}"
    exit 0
fi

# Crear volumen Docker para Portainer
echo -e "${YELLOW}Creando volumen Docker para Portainer...${RESET}"
docker volume create portainer_data >> "$ERROR_LOG" 2>&1

# Descargar e instalar el contenedor Portainer
echo -e "${YELLOW}Descargando e instalando el contenedor Portainer...${RESET}"
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce:latest >> "$ERROR_LOG" 2>&1

# Verificar instalación de Portainer
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Portainer se instaló correctamente.${RESET}"
else
    echo -e "${RED}Error al instalar Portainer. Revisa $ERROR_LOG para más detalles.${RESET}"
    exit 1
fi

# Información de acceso a Portainer
echo -e "${GREEN}Portainer se ha instalado correctamente.${RESET}"
echo "Accede a la interfaz web de Portainer en: https://192.168.110.149:9443"