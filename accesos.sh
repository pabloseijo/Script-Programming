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
    if ["$opcion" == "GET"]; then
        # Si la opcion es GET, utilizamos awk para seleccionar las lineas que contienen GET y 200, y las contamos.
        contador=$(awk '$6 == "\"GET\"" && $(NF-1) == 200' log/access.log | wc -l)
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

    # Definir los días de cada mes (asumiendo que todos los años son no bisiestos)
    dias_por_mes=(0 31 28 31 30 31 30 31 31 30 31 30 31)

    # Calcular la cantidad de días transcurridos desde el 1 de enero de 1
    dias_desde_inicio_ano() {
        local dia=$1
        local mes=$2
        local ano=$3
        local dias=$((ano * 365 + dia))
        for ((m = 1; m < mes; m++)); do
            dias=$((dias + dias_por_mes[m]))
        done
        echo $dias
    }

    # Calcular la cantidad de días transcurridos desde el 1 de enero de 1 hasta la fecha
    dias_fecha1=$(dias_desde_inicio_ano ${fecha1[@]})
    dias_fecha2=$(dias_desde_inicio_ano ${fecha2[@]})

    echo "Días desde el 1 de enero de 1 hasta la fecha 1: $dias_fecha1"

    # Calcular la diferencia en días entre las dos fechas
    diferencia_dias=$((dias_fecha2 - dias_fecha1))

    echo "Días totales: $diasTotales"

    # Contar los días únicos con accesos
    diasConAcceso=$(awk '{print $4}' log/access.log | sed 's/\[//' | cut -d: -f1 | sort -u | wc -l)

    # Calcular los días sin acceso
    diasSinAcceso=$((diasTotales - diasConAcceso))


    echo "Días sin acceso: $diasSinAcceso"

    ;;  
  *)
    # Si no se reconoce la opción, se muestra un mensaje de error, con la opcion -e habilita la interpretación de las secuencias de escape por 
    # echo.
    echo "Opción no reconocida en el segundo parametro. Debe usar: -t, -s, GET/POST o -c"
    ;;
esac



