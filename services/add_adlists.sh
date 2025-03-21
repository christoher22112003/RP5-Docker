#!/bin/bash

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROR_DIR="$SCRIPT_DIR/../logs"
ERROR_LOG="$ERROR_DIR/add_adlists.log"
URLS_FILE="$SCRIPT_DIR/../Pi-hole/urls.txt"

# Crear carpeta de logs si no existe
mkdir -p "$ERROR_DIR"

# Verificar si el archivo urls.txt existe
if [ ! -f "$URLS_FILE" ]; then
    echo "Error: El archivo urls.txt no existe en $URLS_FILE." | tee -a "$ERROR_LOG"
    exit 1
fi

# Verificar si el contenedor de Pi-hole está corriendo
if ! docker ps --format '{{.Names}}' | grep -q "^pihole$"; then
    echo "Error: El contenedor de Pi-hole no está corriendo." | tee -a "$ERROR_LOG"
    exit 1
fi

# Instalar sqlite3 dentro del contenedor de Pi-hole si no está instalado
echo "Verificando si sqlite3 está instalado en el contenedor de Pi-hole..." | tee -a "$ERROR_LOG"
docker exec -it pihole which sqlite3 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Instalando sqlite3 en el contenedor de Pi-hole..." | tee -a "$ERROR_LOG"
    docker exec -it pihole apt-get update >> "$ERROR_LOG" 2>&1
    docker exec -it pihole apt-get install -y sqlite3 >> "$ERROR_LOG" 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: No se pudo instalar sqlite3 en el contenedor de Pi-hole." | tee -a "$ERROR_LOG"
        exit 1
    fi
fi

# Leer el archivo urls.txt y agregar cada URL a la base de datos
echo "Agregando listas de bloqueo a la base de datos de Pi-hole..." | tee -a "$ERROR_LOG"
while IFS= read -r url; do
    # Ignorar líneas vacías
    if [ -z "$url" ]; then
        continue
    fi

    echo "Agregando URL: $url" | tee -a "$ERROR_LOG"
    docker exec -it pihole sqlite3 /etc/pihole/gravity.db \
        "INSERT INTO adlist (address, enabled, date_added, date_updated, comment) VALUES ('$url', 1, strftime('%s','now'), strftime('%s','now'), 'Lista personalizada');" >> "$ERROR_LOG" 2>&1

    if [ $? -ne 0 ]; then
        echo "Error: No se pudo agregar la URL $url a la base de datos." | tee -a "$ERROR_LOG"

        # Crear un archivo de log específico para errores de URLs
        URL_ERROR_LOG="$ERROR_DIR/add_adlists_errors.log"
        echo "Error al agregar URL: $url" >> "$URL_ERROR_LOG"
        echo "Consulta SQL fallida: INSERT INTO adlist (address, enabled, date_added, date_updated, comment) VALUES ('$url', 1, strftime('%s','now'), strftime('%s','now'), 'Lista personalizada');" >> "$URL_ERROR_LOG"
        echo "----------------------------------------" >> "$URL_ERROR_LOG"
    fi
done < "$URLS_FILE"

# Actualizar las listas de Pi-hole
echo "Actualizando las listas de bloqueo en Pi-hole..." | tee -a "$ERROR_LOG"
docker exec -it pihole pihole -g >> "$ERROR_LOG" 2>&1
if [ $? -eq 0 ]; then
    echo "Las listas de bloqueo se actualizaron correctamente." | tee -a "$ERROR_LOG"
else
    echo "Error: No se pudo actualizar las listas de bloqueo." | tee -a "$ERROR_LOG"
    exit 1
fi

echo "Proceso completado." | tee -a "$ERROR_LOG"
