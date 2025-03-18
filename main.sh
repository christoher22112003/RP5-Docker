#!/bin/bash

# Variables
ERROR_LOG="$HOME/Escritorio/errores_instalacion.log"

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

# Ejecutar scripts en orden
ejecutar_script "/home/christopher-muzo/RP5-Docker/install_docker.sh"
ejecutar_script "/home/christopher-muzo/RP5-Docker/install_portainer.sh"
ejecutar_script "/home/christopher-muzo/RP5-Docker/install_pihole.sh"

echo "Instalación completada con éxito."
