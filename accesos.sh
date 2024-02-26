#!/bin/bash

# Authors: Javier Pereira and Pablo Seijo
# Date: 23/02/2024
# Subject: Operative Systems II

### -------- COMPROBAMOS ARGUMENTOS POSICIONALES -------- ###

#Verificamos los parámetros pasados al script
if [ "$#" -ne 2 ]; then
    echo "Error: El numero de parametros es incorrecto. Proporcione exactamente 2 parametros"
    echo "Uso: $0 [-c, GET/POST, -s] directorio_origen"
    exit 1
fi

# Comprobamos el directorio de origen
# las opciones -d y -r, comprueban si el argumento especificado entre comillas es un directorio y comprueba si tiene permisos de lectura respectivamente
if [ ! -f "$2" ] || [ ! -r "$2" ]; then 
    echo "Error: El directorio origen no existe o no tiene permisos de lectura."
    echo "Uso: $0 [-c, GET/POST, -s] directorio_origen"
    exit 1
fi

###-------- VARIABLES A UTILIZAR -------- ###


# Leer el archivo línea por línea
# while IFS= read -r linea; do
    # Utilizamos awk para extraer los campos deseados de la línea actual
#    ip=$(echo "$linea" | awk '{print $1}')
#    fecha=$(echo "$linea" | awk '{print $4}')
#    zona=$(echo "$linea" | awk '{print $5}')
#    get_post=$(echo "$linea" | awk '{print $6}')
#    respuesta=$(echo "$linea" | awk '{print $9}')
#    bytes=$(echo "$linea" | awk '{print $10}')
# done < "$2"


###-------- ESTRUCTURA DE CONTROL -------- ###

opcion="$1"

case $opcion in
  "-c")

    ### -------------------------- Opción C ------------------------------ 
    echo "Has seleccionado la opción -c."

    # Divide el archivo en doce partes, con un prefijo para los nombres de archivo, para poder procesarlos en paralelo
    split -n 12 "$2" archivo_parte_

    # Crear un archivo temporal para almacenar los resultados intermedios
    temp_file=$(mktemp)

    ### ----------- Procesamiento cada archivo en paralelo -------------- ###

    
    # Para esto se utiliza el comando xargs, que permite nos permite la ejecución de comandos en paralelo. A traves de la opción -P 12, se le 
    #indica que ejecute 12 comandos en paralelo, que es el numero de archivos que se generaron con el comando split. por otra parte {} bash 
    #-c, indica que se ejecute el comando bash -c, con el argumento {} que es el archivo que se le pasa a xargs.

    ls archivo_parte_* | xargs -P 12 -I {} bash -c 'while IFS= read -r linea; do
        
        respuesta=$(echo "$linea" | awk "{print \$9}")
        echo "$respuesta"

    done < "{}"' >> "$temp_file"

    # Filtra los resultados únicos y los guarda en 'resultados.txt', luego elimina el archivo temporal
    sort -u "$temp_file" > resultados.txt
    rm "$temp_file"

    # Limpieza: elimina los archivos temporales de las partes
    rm archivo_parte_*

    # Mostramos los resultados
    while IFS= read -r linea; do
        echo "$linea"
    done < "resultados.txt"


    # Limpieza: elimina el archivo temporal de resultados
    rm resultados.txt

    echo "Operación -c realizada con éxito."

    ;;
  "GET/POST")

    echo "Has seleccionado la opción 2."
    ;;
  "-s")
    echo "Has seleccionado la opción 3."
    ;;
  "-t")
    echo "Has seleccionado la opción 3."
=======

    ### -------------------------- Opción GET/POST ------------------------------ ###

    echo "Has seleccionado la opción GET/POST."

    >resultados.txt # Crea un archivo vacío llamado resultados.txt

    # Divide el archivo en doce partes, con un prefijo para los nombres de archivo, para poder procesarlos en paralelo. $2 es el archivo que se le pasa al script. archivo_parte_ es el 
    # prefijo que se le da a los archivos que se generan.
    split -n 12 "$2" archivo_parte_

    # Crear un archivo temporal para almacenar los resultados intermedios
    temp_file=$(mktemp)

    ### ----------- Procesamiento de cada archivo en paralelo -------------- ###
    
    # Para esto se utiliza el comando xargs, que nos permite la ejecución de comandos en paralelo. A traves de la opción -P 12, se le 
    # indica que ejecute 12 comandos en paralelo, que es el numero de archivos que se generaron con el comando split. por otra parte {} bash 
    # GET/POST, indica que se ejecute el comando bash GET/POST, con el argumento {} que es el archivo que se le pasa a xargs.
    ls archivo_parte_* | xargs -S 10000 -P 12 -I {} bash -c 'while IFS= read -r linea; do
        
        getPost=$(echo "$linea" | awk "{sub(/^\"/, \"\", \$6); print \$6}")
        respuesta=$(echo "$linea" | awk "{print \$9}")

        # Si el campo getPost es igual a GET o POST y el campo respuesta es igual a 200, se imprime en el archivo resultados.txt
        if [[ ("$getPost" == "GET" || "$getPost" == "POST") && "$respuesta" == "200" ]]; then
      echo "$getPost $respuesta" >> "resultados.txt"
    fi

    done < "{}"' >> "$temp_file"


    # Limpieza: elimina los archivos temporales de las partes
    rm archivo_parte_*

    contador=0;

    # Por cada linea incrementamos el contador en uno
    while IFS= read -r linea; do
        let contador++ 
    done < "resultados.txt"

    # Limpieza: elimina el archivo temporal de resultados
    # rm resultados.txt

    # Mostramos los resultados
    # date "+%b %d %T" muestra la fecha y hora actual en el formato especificado
    # $contador muestra el valor de la variable contador
    echo "$(date "+%b %d %T"). Registrados $contador accesos tipo GET/POST con respuesta 200."

    ;;
  "-s")
    echo "Has seleccionado la opción -s."
    ;;
  "-t")
    echo "Has seleccionado la opción -t."

    ;;  
  *)
    # Si no se reconoce la opción, se muestra un mensaje de error, con la opcion -e habilita la interpretación de las secuencias de escape por 
    # echo.
    echo "Opción no reconocida en el segundo parametro. Debe usar: -t, -s, GET/POST o -c"
    ;;
esac



