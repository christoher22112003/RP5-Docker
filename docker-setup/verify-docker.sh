#!/bin/bash

# Variables
ERROR_DIR="$(pwd)/errores"
ERROR_LOG="$ERROR_DIR/verify_docker.log"

# Crear carpeta de errores si no existe
mkdir -p "$ERROR_DIR"

# Verificar Docker ejecutando el contenedor hello-world
echo "Verificando Docker ejecutando el contenedor hello-world..." | tee -a "$ERROR_LOG"
if docker run hello-world >> "$ERROR_LOG" 2>&1; then
  echo "Docker está funcionando correctamente." | tee -a "$ERROR_LOG"
else
  echo "Error: Docker no está funcionando correctamente." | tee -a "$ERROR_LOG"
  exit 1
fi
