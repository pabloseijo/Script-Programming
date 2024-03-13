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

    ### -------------------------- Opción -c ------------------------------ 

    echo "Has seleccionado la opción -c."

    >resultados.txt # Crea un archivo vacío llamado resultados.txt, o si ya existe, lo vacía.

    # Utilizamos awk para coger el penultimo numero de la linea, que es el codigo de respuesta, y lo imprimimos por pantalla.
    awk '{print $(NF-1)}' log/access.log | sort -u

    echo "Operación -c realizada con éxito."

    ;;
  "GET" | "POST")

    
    ### -------------------------- Opción GET/POST ------------------------------ ###

    echo "Has seleccionado la opción GET/POST."

    # Miramos el codigo de la opcion para seleccionar GET o POST
    if [ "$opcion" == "GET" ]; then
        # Si la opcion es GET, utilizamos awk para seleccionar las lineas que contienen GET y 200, y las contamos.
        contador=$(awk '$6 == "\"GET" && $(NF-1) == 200' log/access.log | wc -l)
    else
        # Si la opcion es POST, utilizamos awk para seleccionar las lineas que contienen POST y 200, y las contamos.
        contador=$(awk '$6 == "\"POST" && $(NF-1) == 200' log/access.log | wc -l)
    fi

    echo "$(date "+%b %d %T"). Registrados $contador accesos tipo $opcion con respuesta 200."


    ;;
  "-s")

    ### -------------------------- Opción -s ------------------------------ ###
    echo "Has seleccionado la opción -s."

    # Inicializamos los contadores, uno para los bytes y otro para las lineas
    contadorBytes=0
    contadorLineas=0
    
    # Utilizamos awk para sumar los bytes de todas las lineas del archivo, y lo almacenamos en la variable contadorBytes. Basicamente suma el ultimo 
    # campo de cada linea y cuando termina imprime el resultado en la variable contadorBytes.
    contadorBytes=$(awk '{contadorBytes+=$NF} END {print contadorBytes}' log/access.log)

    # Convertimos los bytes a KiB
    contadorBytes=$((contadorBytes/1024))

    # Utilizamos wc -l para contar las lineas del archivo, y lo almacenamos en la variable contadorLineas.
    contadorLineas=$(wc -l < log/access.log)

    # Mostramos los resultados
    echo "$contadorBytes KiB enviados en $contadorLineas peticiones."

    ;;
  "-t")

    ### -------------------------- Opción -t ------------------------------ ###

    #TODO: Implementar la opción -t 

    echo "Has seleccionado la opción -t."

    # Extraer las fechas de primer y último acceso del archivo access.log, utilizamos sed para elimnar el corchete y cut para quedarnos con la fecha, con las opciones -d y -f indicamos el delimitador y el campo que queremos.
    primerAcceso=$(awk 'NR==1 {print $4}' log/access.log | sed 's/\[//' | cut -d: -f1)
    ultimoAcceso=$(awk 'END {print $4}' log/access.log | sed 's/\[//' | cut -d: -f1)

    echo "Primer acceso: $primerAcceso"
    echo "Último acceso: $ultimoAcceso"

    # Convertir una abreviatura de mes en inglés a su número correspondiente
    convertirMesANumero() {
        case $1 in
            Jan) mes="01" ;;
            Feb) mes="02" ;;
            Mar) mes="03" ;;
            Apr) mes="04" ;;
            May) mes="05" ;;
            Jun) mes="06" ;;
            Jul) mes="07" ;;
            Aug) mes="08" ;;
            Sep) mes="09" ;;
            Oct) mes="10" ;;
            Nov) mes="11" ;;
            Dec) mes="12" ;;
            *) echo "Mes desconocido: $1" >&2; exit 1 ;;
        esac
        echo "$mes"
    }

    # Función para reformatear fecha de "DD/Mmm/YYYY" a "YYYY-MM-DD"
    reformatearFecha() {
        dia=$(echo $1 | cut -d'/' -f1)
        mesTexto=$(echo $1 | cut -d'/' -f2)
        ano=$(echo $1 | cut -d'/' -f3)
        mes=$(convertirMesANumero $mesTexto)
        echo "${ano}-${mes}-${dia}"
    }

    primerAccesoReformateado=$(reformatearFecha $primerAcceso)
    ultimoAccesoReformateado=$(reformatearFecha $ultimoAcceso)

    # Convertir las fechas de acceso a segundos desde la época (Epoch)
    primerAccesoDate=$(date -d "$primerAccesoReformateado" +%s)
    ultimoAccesoDate=$(date -d "$ultimoAccesoReformateado" +%s)

    # Calcular la diferencia en segundos y luego convertir a días
    dias=$(( (ultimoAccesoDate - primerAccesoDate) / 86400 + 1 ))

    diasConAcceso=$(awk '{print $4}' log/access.log | sed 's/\[//' | cut -d: -f1 | sort -u | wc -l)

    # Calcular los días sin acceso
    diasSinAcceso=$((dias - diasConAcceso))

    echo "Días sin acceso: $diasSinAcceso"
    ;;  
  *)
    # Si no se reconoce la opción, se muestra un mensaje de error, con la opcion -e habilita la interpretación de las secuencias de escape por 
    # echo.
    echo "Opción no reconocida en el segundo parametro. Debe usar: -t, -s, GET/POST o -c"
    ;;
esac



