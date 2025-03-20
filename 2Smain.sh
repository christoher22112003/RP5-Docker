#!/bin/bash

# Variables
ERROR_DIR="$(pwd)/errores"
ERROR_LOG="$ERROR_DIR/errores_instalacion.log"

# Crear carpeta de errores si no existe
mkdir -p "$ERROR_DIR"

# Limpiar archivo de errores previo
> "$ERROR_LOG"

# Función para ejecutar un script y manejar errores
ejecutar_script() {
    local script=$1
    echo "Ejecutando $script..."
    bash "$script" >> "$ERROR_LOG" 2>&1
    if [ $? -ne 0 ]; then
        echo "Error al ejecutar $script. Revisa $ERROR_LOG para más detalles."
        exit 1
    fi
}

# Verificar la instalación de Docker
ejecutar_script "/home/christopher-muzo/RP5-Docker/docker-setup/verify-docker.sh"

# Instalar Portainer
ejecutar_script "/home/christopher-muzo/RP5-Docker/install_portainer.sh"

# Instalar Pi-hole
ejecutar_script "/home/christopher-muzo/RP5-Docker/install_pihole.sh"

echo "Instalación completada con éxito."
