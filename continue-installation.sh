#!/bin/bash

# Variables
ERROR_LOG="$HOME/Escritorio/errores_instalacion.log"

# Verificar si Docker ya se instaló
if [ -f /tmp/docker_installed.flag ]; then
    echo "Continuando con la instalación después de reiniciar..." >> "$ERROR_LOG"
    rm /tmp/docker_installed.flag

    # Continuar con la instalación de Portainer y Pi-hole
    bash "/home/christopher-muzo/RP5-Docker/install_portainer.sh" >> "$ERROR_LOG" 2>&1
    if [ $? -ne 0 ]; then
        echo "Error al instalar Portainer. Revisa $ERROR_LOG para más detalles."
        exit 1
    fi

    bash "/home/christopher-muzo/RP5-Docker/install_pihole.sh" >> "$ERROR_LOG" 2>&1
    if [ $? -ne 0 ]; then
        echo "Error al instalar Pi-hole. Revisa $ERROR_LOG para más detalles."
        exit 1
    fi

    echo "Instalación completada con éxito." >> "$ERROR_LOG"
fi
