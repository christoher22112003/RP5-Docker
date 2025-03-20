#!/bin/bash

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROR_DIR="$SCRIPT_DIR/../logs"
ERROR_LOG="$ERROR_DIR/install_pihole.log"

# Colores
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Crear carpeta de logs si no existe
mkdir -p "$ERROR_DIR"

# Verificar si Pi-hole ya está instalado
echo -e "${YELLOW}Verificando si Pi-hole ya está instalado...${RESET}"
if docker ps --format '{{.Names}}' | grep -q "^pihole$"; then
    echo -e "${GREEN}Pi-hole ya está instalado. Omitiendo instalación.${RESET}"
    exit 0
fi

# Verifica si docker-compose está instalado
echo -e "${YELLOW}Verificando si docker-compose está instalado...${RESET}"
if ! command -v docker-compose &> /dev/null; then
  echo -e "${RED}docker-compose no está instalado. Por favor, instálalo antes de continuar.${RESET}"
  exit 1
fi

# Cambia al directorio donde está el archivo docker-compose.yml
echo -e "${YELLOW}Cambiando al directorio del archivo docker-compose.yml...${RESET}"
cd "$SCRIPT_DIR/../Pi-hole"

# Verifica si el archivo docker-compose.yml existe
echo -e "${YELLOW}Verificando si el archivo docker-compose.yml existe...${RESET}"
if [ ! -f "docker-compose.yml" ]; then
  echo -e "${RED}El archivo docker-compose.yml no se encuentra en el directorio actual.${RESET}"
  exit 1
fi

# Construye e inicia el contenedor de Pi-hole
echo -e "${YELLOW}Iniciando la instalación del contenedor de Pi-hole...${RESET}"
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