#!/bin/bash

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROR_DIR="$SCRIPT_DIR/../logs"
ERROR_LOG="$ERROR_DIR/install_pihole.log"

# Crear carpeta de logs si no existe
mkdir -p "$ERROR_DIR"

# Verificar si Pi-hole ya está instalado
echo "Verificando si Pi-hole ya está instalado..."
sleep 3
if docker ps --format '{{.Names}}' | grep -q "^pihole$"; then
    echo "Pi-hole ya está instalado. Omitiendo instalación."
    exit 0
fi

# Verifica si docker-compose está instalado
echo "Verificando si docker-compose está instalado..."
sleep 3
if ! command -v docker-compose &> /dev/null; then
  echo "docker-compose no está instalado. Por favor, instálalo antes de continuar."
  exit 1
fi

# Cambia al directorio donde está el archivo docker-compose.yml
echo "Cambiando al directorio del archivo docker-compose.yml..."
sleep 3
cd "$SCRIPT_DIR/../Pi-hole"

# Verifica si el archivo docker-compose.yml existe
echo "Verificando si el archivo docker-compose.yml existe..."
sleep 3
if [ ! -f "docker-compose.yml" ]; then
  echo "El archivo docker-compose.yml no se encuentra en el directorio actual."
  exit 1
fi

# Construye e inicia el contenedor de Pi-hole
echo "Iniciando la instalación del contenedor de Pi-hole..."
sleep 3
docker-compose up -d >> "$ERROR_LOG" 2>&1

# Verifica si el contenedor se inició correctamente
if [ $? -eq 0 ]; then
  echo "Pi-hole se instaló correctamente." | tee -a "$ERROR_LOG"
else
  echo "Error al instalar Pi-hole. Revisa $ERROR_LOG para más detalles." | tee -a "$ERROR_LOG"

  # Obtiene el nombre del contenedor de Pi-hole
  CONTAINER_NAME=$(docker ps -a --filter "name=pihole" --format "{{.Names}}")

  # Verifica si el contenedor existe
  if [ -n "$CONTAINER_NAME" ]; then
    echo "Recopilando logs del contenedor..." | tee -a "$ERROR_LOG"
    docker logs "$CONTAINER_NAME" >> "$ERROR_LOG" 2>&1
  else
    echo "El contenedor de Pi-hole no se creó correctamente." | tee -a "$ERROR_LOG"
  fi

  exit 1
fi
sleep 3