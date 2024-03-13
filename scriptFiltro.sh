#!/bin/bash

# Authors: Javier Pereira and Pablo Seijo
# Date: 15/02/2024
# Subject: Operative Systems II

# Rutas del archivo origen y destino
ARCHIVO_ORIGEN="passwd_copia"
ARCHIVO_DESTINO="/tmp/passwd_original"

# Creamos un archivo nuevo en el directorio temporal '/tmp/' usando 'touch':
touch "$ARCHIVO_DESTINO"

# Verificar si el archivo de origen existe antes de continuar
if [ -f "$ARCHIVO_ORIGEN" ]; then

    # Ordenamos las líneas de 'passwd_copia', en el archivo nuevo y eliminamos duplicados
    sort -u "$ARCHIVO_ORIGEN" > "$ARCHIVO_DESTINO"

else
    echo "El archivo origen '$ARCHIVO_ORIGEN' no existe o no se puede acceder a él."
    exit 1
fi

# Comprobamos si el archivo creado es igual a '/etc/passwd':
if ( diff "$ARCHIVO_DESTINO" <(sort "/etc/passwd") ) > /dev/null; then
    
    #Si no hay diferencia, imprimimos éxito:
    echo "Archivo creado y ordenado correctamente. Su contenido es igual a '/etc/passwd."

else
    #Si hay diferencia, informamos error:
    echo "El archivo se ha creado y ordenado correctamente, pero no coincide con '/etc/passwd."
fi