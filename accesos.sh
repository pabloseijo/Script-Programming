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

# Estructura de control que permite seleccionar la opción deseada, lo que sería el equivalente a un switch en otros lenguajes de programación.

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

    
    ### -------------------------- Opción GET/POST ------------------------------ ###

    echo "Has seleccionado la opción GET/POST."

    >resultados.txt # Crea un archivo vacío llamado resultados.txt, o si ya existe, lo vacía.

    # Divide el archivo en doce partes, con un prefijo para los nombres de archivo, para poder procesarlos en paralelo. $2 es el archivo que se le pasa al script. archivo_parte_ es el 
    # prefijo que se le da a los archivos que se generan.
    split -n 12 "$2" archivo_parte_

    # Crear un archivo temporal para almacenar los resultados intermedios
    temp_file=$(mktemp)

    ### ----------- Procesamiento de cada archivo en paralelo -------------- ###
    
    # Para esto se utiliza el comando xargs, que nos permite la ejecución de comandos en paralelo. A traves de la opción -P 12, se le 
    # indica que ejecute 12 comandos en paralelo, que es el numero de archivos que se generaron con el comando split. por otra parte {} bash 
    # GET/POST, indica que se ejecute el comando bash GET/POST, con el argumento {} que es el archivo que se le pasa a xargs.
    ls archivo_parte_* | xargs -s 10000 -P 12 -I {} bash -c 'while IFS= read -r linea; do
        
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

    ### -------------------------- Opción -s ------------------------------ ###
    echo "Has seleccionado la opción -s."

    # Inicializamos los contadores, uno para los bytes y otro para las lineas
    contadorBytes=0;
    contadorLineas=0;

    # Divide el archivo en doce partes, con un prefijo para los nombres de archivo, para poder procesarlos en paralelo. $2 es el archivo que se le pasa al script. archivo_parte_ es el 
    # prefijo que se le da a los archivos que se generan.
    split -n 12 "$2" archivo_parte_

    # Crear un archivo temporal para almacenar los resultados intermedios
    temp_file=$(mktemp)

    ### ----------- Procesamiento de cada archivo en paralelo -------------- ###
    
    # Para esto se utiliza el comando xargs, que nos permite la ejecución de comandos en paralelo. A traves de la opción -P 12, se le dice que ejecute 12 comandos en paralelo, que es el numero de archivos que se generaron con el comando split.
    # A diferencia de los anteriores podemos ver que dentro de cada comando se ejecuta un bucle que recorre cada linea del archivo que se le paga con xargs, cogiendo las varbiables y sumando los bytes.
    # Una notable consideraciión es que se utiliza la comprobación =~ ^[0-9]+$. Esto significa que se comprueba si el valor de bytes es un número entero positivo, pues =~ es un operador de coincidencia de expresiones regulares, despues ^[0-9]+$ es una expresión regular que comprueba si el valor de bytes es un número entero positivo.
    # Una expresión regular es una secuencia de caracteres que forma un patrón de búsqueda. Cuando se busca datos en un texto, puede utilizar este patrón para describir lo que está buscando. Estas pueden transformarse en automatas finitos deterministas, que son una forma de representar un lenguaje regular.
    ls archivo_parte_* | xargs -P 12 -I {} bash -c '{
        localBytes=0
        localLines=0 # Inicializa el contador de líneas
        while IFS=" " read -r ip client user datetime1 datetime2 method url protocol status bytes
        do
            # Asegura que solo se sumen valores numéricos para los bytes
            if [[ "$bytes" =~ ^[0-9]+$ ]]; then
                ((localBytes+=bytes))
            fi
            ((localLines++)) # Incrementa el contador de líneas por cada línea procesada
        done < "{}"
        echo "$localBytes $localLines" # Imprime tanto los bytes como las líneas contadas
    }' >> "$temp_file"


    # Limpieza: elimina los archivos temporales de las partes
    rm archivo_parte_*

    # Leer el archivo temporal para sumar los bytes totales
    while IFS= read -r linea; do

        # Extraemos del temp file los bytes
        bytes=$(echo "$linea" | awk "{print \$1}")
        lineas=$(echo "$linea" | awk "{print \$2}")

        #Sumamos los bytes y contamos las lineas
        ((contadorBytes+=bytes))
        let contadorLineas+=$lineas;

    done < "$temp_file"

    # Eliminar el archivo temporal
    rm "$temp_file"

    # Convertir el total de bytes a KiB
    contadorBytesKiB=$((contadorBytes/1024))

    # Mostramos los resultados
    echo "$contadorBytes KiB enviados en $contadorLineas peticiones."



    ;;
  "-t")

    ### -------------------------- Opción -t ------------------------------ ###

    # TODO: Implementar la opción -t

    echo "Has seleccionado la opción -t."

    >resultados.txt # Crea un archivo vacío llamado resultados.txt, o si ya existe, lo vacía.

    # Divide el archivo en doce partes, con un prefijo para los nombres de archivo, para poder procesarlos en paralelo. $2 es el archivo que se le pasa al script. archivo_parte_ es el 
    # prefijo que se le da a los archivos que se generan.
    split -n 12 "$2" archivo_parte_

    # Crear un archivo temporal para almacenar los resultados intermedios
    temp_file=$(mktemp)

    ### ----------- Procesamiento de cada archivo en paralelo -------------- ###
    

    ls archivo_parte_* | xargs -P 12 -I {} bash -c '{
        while IFS=" " read -r ip client user datetime1 datetime2 method url protocol status bytes
        do
            # Asumiendo que queremos procesar `datetime1` que contiene la fecha y hora
            fecha_original=$datetime1
            # Eliminar el corchete y reemplazar el primer ':' por un espacio para separar la fecha de la hora
            fecha_ajustada=$(echo "$fecha_original" | sed -e "s/\[/ /" -e "s/:/ /")

            # Usar `date` con el formato ajustado
            fecha_formateada=$(date -d "$fecha_ajustada" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
            echo "$fecha_formateada" # Imprime la fecha formateada
        done < "{}"
    }' >> "$temp_file"

    sort -u "$temp_file" > resultados.txt


    # Limpieza: elimina los archivos temporales de las partes
    rm archivo_parte_*

    # Limpieza: elimina el archivo temporal de resultados
    rm "$temp_file"

    echo "Operación -t realizada con éxito."

    ;;  
  *)
    # Si no se reconoce la opción, se muestra un mensaje de error, con la opcion -e habilita la interpretación de las secuencias de escape por 
    # echo.
    echo "Opción no reconocida en el segundo parametro. Debe usar: -t, -s, GET/POST o -c"
    ;;
esac



