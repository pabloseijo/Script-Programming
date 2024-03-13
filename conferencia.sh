#!/bin/bash

# Script para organizar vídeos de conferencias
# Autor: Pablo Seijo y Javier Pereira
# Fecha: 2023-2024

### Verificación de argumentos ###
if [ "$#" -ne 2 ]; then
    echo "Error: El número de parámetros es incorrecto. Proporcione exactamente 2 parámetros."
    echo "Uso: $0 origen destino"
    exit 1
fi

### Verificación de directorio de origen ###
if [ ! -d "$1" ] || [ ! -r "$1" ]; then
    echo "Error: El directorio de origen no existe o no tiene permisos de lectura."
    echo "Uso: $0 origen destino"
    exit 1
fi

### Creación del directorio de destino si no existe ###
mkdir -p "$2"

### Verificación de permisos de escritura en el directorio de destino ###
if [ ! -w "$2" ]; then
    echo "Error: El directorio de destino no tiene permisos de escritura."
    exit 1
fi

### Creación de directorios de salida ###
# Crea directorios de sala, aunque estén vacíos
for i in $(seq 20 50); do
    mkdir -p "$2/s$i"
done

### Organización y copia de archivos ###
for archivo in "$1"/*; do
    # Verificación de que el archivo es un archivo regular
    if [ -f "$archivo" ]; then
        # Extracción de información del nombre del archivo
        nombre_archivo=$(basename "$archivo")
        # Extracción de información
        sala=$(echo "$nombre_archivo" | awk -F '_' '{print $2}')
        fecha=$(echo "$nombre_archivo" | awk -F '@' '{print $2}' | awk -F '.' '{print $1}')
        hora=$(echo "$nombre_archivo" | awk -F '@' '{print $2}' | awk -F '.' '{print $2}' | awk -F '.' '{print $1}')
        res=$(echo "$nombre_archivo" | awk -F '.' '{print $2}')
        
        # Creación de directorios de salida
        dir_destino="$2/s$sala/$fecha/$res"
        mkdir -p "$dir_destino"
        
        # Copia de archivos 
        nombre_nuevo="charla_at_${hora}.${res}"
        cp "$archivo" "$dir_destino/$nombre_nuevo"
    fi
done

# 
echo "Organización de vídeos completada."
