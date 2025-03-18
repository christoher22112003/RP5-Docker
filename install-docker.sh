#!/bin/bash

# Instalar Docker
echo "Descargando e instalando Docker..."
sudo curl -fsSL https://get.docker.com/ -o get-docker.sh
sudo sh get-docker.sh

# Añadir el usuario actual al grupo Docker
echo "Añadiendo el usuario actual al grupo Docker..."
sudo usermod -aG docker ${USER}

# Verificar instalación de Docker
echo "Verificando instalación de Docker..."
if ! command -v docker &> /dev/null; then
  echo "Error: Docker no se instaló correctamente." | tee "$HOME/Desktop/docker_install_error.log"
  exit 1
fi

# Verificar instalación de Docker Compose
echo "Verificando instalación de Docker Compose..."
if ! docker compose version &> /dev/null; then
  echo "Error: Docker Compose no se instaló correctamente." | tee -a "$HOME/Desktop/docker_install_error.log"
  exit 1
fi

echo "Docker y Docker Compose se instalaron correctamente."

# Crear un archivo de servicio de systemd para ejecutar el contenedor de prueba después del reinicio
echo "Creando archivo de servicio para ejecutar el contenedor de prueba después del reinicio..."
cat <<EOF | sudo tee /etc/systemd/system/docker-test.service
[Unit]
Description=Ejecutar contenedor de prueba Docker
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/usr/bin/docker run hello-world
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

# Habilitar el servicio para que se ejecute después del reinicio
sudo systemctl enable docker-test.service

# Reiniciar el sistema
echo "Reiniciando el sistema para aplicar los cambios..."
sudo reboot
