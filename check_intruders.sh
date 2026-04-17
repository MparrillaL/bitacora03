#!/bin/bash

# =================================================================
# SCRIPT: check_intruders.sh
# OBJETIVO: Automatizar la vigilancia de intentos fallidos por SSH
# RUTA: scripts/check_intruders.sh
# =================================================================

# 1. Definición de variables de ruta
# El archivo de logs se encuentra en /var/log según el estándar FHS [1].
LOG_SOURCE="/var/log/auth.log"
REPORT_DEST="alertas.txt"

# 2. Generación del encabezado del informe
# Utilizamos 'date' [2, 3] para capturar el timestamp exacto.
# El símbolo '>' sobrescribe el archivo para generar un reporte limpio cada vez.
echo "==========================================================" > $REPORT_DEST
echo "INFORME DE VIGILANCIA ACTIVA - OPERACIÓN ESCUDO" >> $REPORT_DEST
echo "Generado el: $(date)" >> $REPORT_DEST
echo "==========================================================" >> $REPORT_DEST

# 3. Filtrado y conteo matemático
# 'grep' actúa como cirujano buscando el rastro de error literal [4, 5].
# 'wc -l' [6] cuenta el número total de líneas (intentos) detectados.
# Se filtra por la fecha actual (día y mes) para cumplir el criterio de horas recientes.
FECHA_ACTUAL=$(date "+%b %_d")
TOTAL_ERRORES=$(grep "$FECHA_ACTUAL" $LOG_SOURCE | grep "Failed password" | wc -l)

echo "RESULTADO GLOBAL:" >> $REPORT_DEST
echo "Número total de intentos fallidos hoy ($FECHA_ACTUAL): $TOTAL_ERRORES" >> $REPORT_DEST
echo "----------------------------------------------------------" >> $REPORT_DEST

# 4. Extracción de columnas y limpieza de datos
# Utilizamos una tubería (|) [7] para conectar comandos:
# - grep: Localiza las líneas de fallo.
# - awk: Extrae la columna de la IP (3 posiciones antes del final en auth.log).
# - sort y uniq -c: Agrupa y cuenta cuántas veces atacó cada IP.
echo "DETALLE DE IPs SOSPECHOSAS (Frecuencia | Dirección IP):" >> $REPORT_DEST
grep "$FECHA_ACTUAL" $LOG_SOURCE | grep "Failed password" | awk '{print $(NF-3)}' | sort | uniq -c >> $REPORT_DEST

# 5. Notificación en terminal
# Usamos 'echo' [8] para confirmar al SysAdmin que la tarea ha finalizado.
echo "[+] Análisis completado. El archivo $REPORT_DEST ha sido generado."