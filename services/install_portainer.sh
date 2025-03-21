#!/bin/bash

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROR_DIR="$SCRIPT_DIR/../logs"
ERROR_LOG="$ERROR_DIR/install_portainer.log"

# Crear carpeta de logs si no existe
mkdir -p "$ERROR_DIR"

# Verificar si Portainer ya está instalado
echo "Verificando si Portainer ya está instalado..."
sleep 3
if docker ps --format '{{.Names}}' | grep -q "^portainer$"; then
    echo "Portainer ya está instalado. Omitiendo instalación."
    exit 0
fi

# Crear volumen Docker para Portainer
echo "Creando volumen Docker para Portainer..."
sleep 3
docker volume create portainer_data >> "$ERROR_LOG" 2>&1

# Descargar e instalar el contenedor Portainer
echo "Descargando e instalando el contenedor Portainer..."
sleep 3
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce:latest >> "$ERROR_LOG" 2>&1

# Verificar instalación de Portainer
if [ $? -eq 0 ]; then
    echo "Portainer se instaló correctamente."
else
    echo "Error al instalar Portainer. Revisa $ERROR_LOG para más detalles."
    exit 1
fi

# Información de acceso a Portainer
echo "Portainer se ha instalado correctamente."
echo "Accede a la interfaz web de Portainer en: https://192.168.110.149:9443"
sleep 3