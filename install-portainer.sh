#!/bin/bash

# Crear volumen Docker para Portainer
echo "Creando volumen Docker para Portainer..."
docker volume create portainer_data

# Descargar e instalar el contenedor Portainer
echo "Descargando e instalando el contenedor Portainer..."
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce:latest

# Verificar los contenedores instalados
echo "Mostrando los contenedores en ejecución..."
docker ps

# Verificar instalación de Portainer
echo "Verificando instalación de Portainer..."
if ! docker ps | grep -q "portainer/portainer-ce"; then
  echo "Error: Portainer no se instaló correctamente." | tee "$HOME/Desktop/portainer_install_error.log"
  exit 1
fi

# Información de acceso a Portainer
echo "Portainer se ha instalado correctamente."
echo "Accede a la interfaz web de Portainer en: https://192.168.110.149:9443"
