#!/bin/bash

# Variables
ERROR_DIR="$(pwd)/logs"
ERROR_LOG="$ERROR_DIR/install_pihole.log"

# Colores
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# Crear carpeta de logs si no existe
mkdir -p "$ERROR_DIR"

# Verifica si docker-compose está instalado
if ! command -v docker-compose &> /dev/null; then
  echo "docker-compose no está instalado. Por favor, instálalo antes de continuar."
  exit 1
fi

# Cambia al directorio donde está el archivo docker-compose.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../Pi-hole"

# Verifica si el archivo docker-compose.yml existe
if [ ! -f "docker-compose.yml" ]; then
  echo "El archivo docker-compose.yml no se encuentra en el directorio actual."
  exit 1
fi

# Construye e inicia el contenedor de Pi-hole
echo -e "${GREEN}Iniciando la instalación del contenedor de Pi-hole...${RESET}"
docker-compose up -d >> "$ERROR_LOG" 2>&1

# Verifica si el contenedor se inició correctamente
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Pi-hole se instaló correctamente.${RESET}"
else
  echo -e "${RED}Error al instalar Pi-hole. Revisa $ERROR_LOG para más detalles.${RESET}"

  # Obtiene el nombre del contenedor de Pi-hole
  CONTAINER_NAME=$(docker ps -a --filter "name=pihole" --format "{{.Names}}")

  # Verifica si el contenedor existe
  if [ -n "$CONTAINER_NAME" ]; then
    echo "Recopilando logs del contenedor..."
    # Obtiene los logs del contenedor
    LOGS=$(docker logs "$CONTAINER_NAME" 2>&1)
  else
    LOGS="El contenedor de Pi-hole no se creó correctamente."
  fi

  # Define la ruta al escritorio del usuario
  DESKTOP_DIR="$HOME/Escritorio"
  if [ ! -d "$DESKTOP_DIR" ]; then
    DESKTOP_DIR="$HOME/Desktop" # Para sistemas en inglés
  fi

  # Crea el archivo de texto con los errores
  ERROR_FILE="$DESKTOP_DIR/pihole_error_logs.txt"
  echo "$LOGS" > "$ERROR_FILE"

  echo "Los errores se han guardado en: $ERROR_FILE"
  exit 1
fi