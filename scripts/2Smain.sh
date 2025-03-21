#!/bin/bash

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROR_DIR="$SCRIPT_DIR/../logs"
ERROR_LOG="$ERROR_DIR/errores_instalacion.log"

# Colores
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Crear carpeta de logs si no existe
mkdir -p "$ERROR_DIR"

# Limpiar archivo de errores previo
> "$ERROR_LOG"

# Función para ejecutar un script y manejar errores
ejecutar_script() {
    local script=$1
    echo -e "${YELLOW}Ejecutando $script...${RESET}"
    sleep 3
    bash "$script" >> "$ERROR_LOG" 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error al ejecutar $script. Revisa $ERROR_LOG para más detalles.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}Finalizado: $script${RESET}"
    sleep 3
}

# Verificar la instalación de Docker
ejecutar_script "$SCRIPT_DIR/../docker-setup/verify-docker.sh"

# Instalar Portainer
ejecutar_script "$SCRIPT_DIR/../services/install_portainer.sh"

# Instalar Pi-hole
ejecutar_script "$SCRIPT_DIR/../services/install_pihole.sh"

# Agregar listas de bloqueo a Pi-hole
ejecutar_script "$SCRIPT_DIR/../services/add_adlists.sh"

echo -e "${GREEN}Instalación completada con éxito.${RESET}"
sleep 3