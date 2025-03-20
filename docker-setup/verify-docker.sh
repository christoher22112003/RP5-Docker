#!/bin/bash

# Variables
ERROR_DIR="$(pwd)/errores"
ERROR_LOG="$ERROR_DIR/verify_docker.log"

# Colores
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# Crear carpeta de errores si no existe
mkdir -p "$ERROR_DIR"

# Verificar Docker ejecutando el contenedor hello-world
echo -e "${GREEN}Verificando Docker ejecutando el contenedor hello-world...${RESET}"
if docker run hello-world >> "$ERROR_LOG" 2>&1; then
    echo -e "${GREEN}Docker está funcionando correctamente.${RESET}"
else
    echo -e "${RED}Error: Docker no está funcionando correctamente.${RESET}"
    exit 1
fi
