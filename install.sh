#!/usr/bin/env bash

# Salir inmediatamente si un comando falla
set -e

echo "======================================================="
echo "  Instalador de Lenovo LOQ / Legion RGB para Linux"
echo "======================================================="

# 1. Instalar dependencias necesarias
echo "[1/4] Instalando dependencias del sistema (wget, unzip)..."
sudo apt-get update -qq
sudo apt-get install -y -qq wget unzip libusb-1.0-0

# 2. Descargar y ubicar el binario desde tu propio release
echo "[2/4] Descargando la aplicación RGB..."
TEMP_DIR=$(mktemp -d)
wget -q --show-progress -O "$TEMP_DIR/legion-kb-rgb.zip" "https://github.com/EduardoTapia23/lenovo-loq-rgb-installer/releases/download/v1.0.0/legion-kb-rgb-linux.zip"
unzip -qo "$TEMP_DIR/legion-kb-rgb.zip" -d "$TEMP_DIR"

echo "Moviendo el ejecutable a /usr/local/bin..."
sudo mv "$TEMP_DIR/legion-kb-rgb" /usr/local/bin/legion-kb-rgb
sudo chmod +x /usr/local/bin/legion-kb-rgb
rm -rf "$TEMP_DIR"

# 3. Configurar permisos USB (udev) para los chips ITE
echo "[3/4] Configurando reglas USB (udev) para evitar el uso de sudo..."
sudo tee /etc/udev/rules.d/99-lenovo-rgb.rules > /dev/null << 'EOF'
# Permite el acceso sin root a los controladores de teclado Lenovo ITE (Vendor ID 048d)
SUBSYSTEM=="usb", ATTR{idVendor}=="048d", MODE="0666"
EOF

# Aplicar las reglas inmediatamente
sudo udevadm control --reload-rules
sudo udevadm trigger

# 4. Crear el acceso directo en el sistema (.desktop)
echo "[4/4] Creando acceso directo en el menú de aplicaciones..."
sudo tee /usr/share/applications/lenovo-rgb.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Lenovo RGB Keyboard
Comment=Controlador de luces para teclados Lenovo LOQ y Legion
Exec=legion-kb-rgb --gui
Icon=preferences-desktop-keyboard
Terminal=false
Type=Application
Categories=Settings;HardwareSettings;
EOF

echo "======================================================="
echo " ¡Instalación completada con éxito!"
echo " Puedes abrir 'Lenovo RGB Keyboard' desde tu menú de aplicaciones."
echo "======================================================="
