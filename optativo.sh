#!/bin/bash

# Authors: Javier Pereira and Pablo Seijo
# Date: 7/03/2024
# Subject: Operative Systems II

# Primero vamos a declarar una variable con la ruta a las simulaciones (que se encuentra en el directorio actual)
SIMULATION_PATH="simulaciones_MC"

# Imprimimos en el txt las cabeceras
echo "ID Simulación | Tiempo de Vuelo [fs] | Corriente [A]" > datos_filtrados.txt

# Inicializamos una variable para almacenar la suma de las corrientes
sumaCorrientes=0
# Inicializamos un contador para el número de simulaciones
contador=0

# Usamos un bucle para procesar cada archivo de resultados
for file in ${SIMULATION_PATH}/*; do
    # Extraemos el ID de la simulación del nombre del archivo
    id=$(basename "$file" .txt)

    # Buscamos la línea con el tiempo de vuelo deseado y extraemos la corriente
    corriente=$(awk -v time="1.355000e+03" '$1==time {print $12}' "$file")

    # Mostramos por pantalla la corriente asociada a la simulación
    echo "> La corriente para un tiempo del vuelo de 1.355000e+03 fs en la simulación ${id} es: ${corriente} A"

    # Añadimos la línea al archivo de datos filtrados
    echo "${id} | 1.355000e+03 | ${corriente}" >> datos_filtrados.txt

    # Acumulamos la corriente y aumentamos el contador
    sumaCorrientes=$(echo "$sumaCorrientes + $corriente" | bc)
    ((contador++))
done

# Calculamos la corriente media
if [ $count -gt 0 ]; then
    avg_current=$(echo "scale=9; $sum_current / $contador" | bc)
    # Imprimimos por pantalla la corriente media
    echo "> El valor medio de la corriente, una vez evaluadas $contador simulaciones es: ${avg_current} A"
else
    echo "No se encontraron archivos de simulación para procesar."
fi
