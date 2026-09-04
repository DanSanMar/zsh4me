#!/usr/bin/env bash

# ==============================================================================
# zsh4me - Entorno Interactivo Multi-Distro y Ajustes de Shell
# ==============================================================================

set -eo pipefail
shopt -s inherit_errexit 2>/dev/null || true

# --- CONFIGURACIÓN DE COLORES ---
RESET='\e[0m'
NEGRITA='\e[1m'
VERDE_BRILLANTE='\e[92m'
VERDE='\e[32m'
AMARILLO='\e[33m'
AZUL='\e[34m'
AZUL_BRILLANTE='\e[94m'
CIAN='\e[36m'
MAGENTA='\e[35m'
ROJO='\e[31m'
ROJO_BRILLANTE='\e[91m'
BLANCO='\e[97m'

NC='\033[0m'
ver="v.2.6"

info() { echo -e "${AZUL_BRILLANTE}[INFO]${RESET} $1"; }
success() { echo -e "${VERDE_BRILLANTE}[OK]${RESET} $1"; }
warn() { echo -e "${AMARILLO}[WARN]${RESET} $1"; }
error() { echo -e "${ROJO_BRILLANTE}[ERROR]${RESET} $1"; exit 1; }

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$REAL_HOME/.zsh4me_backups/backup_$TIMESTAMP"

fzf_menu_principal() {
    # Script inline que limpia el string seleccionado y evalúa el caso exacto
    local preview_cmd='
        line="{}"
        if [[ "$line" =~ "INSTALACIÓN" ]]; then
            echo -e "\033[1;36m=== ⚡ INSTALACIÓN INTEGRAL ===\033[0m\n\nDespliega el entorno completo en un solo paso:\n ➔ Instala dependencias y fuentes NerdFont\n ➔ Configura Oh My Zsh y sus plugins principales\n ➔ Aplica las configuraciones de Ghostty y Tmux\n ➔ Modifica .zshrc sin perder tus ajustes previos\n ➔ Establece Zsh como tu Shell por defecto"
        elif [[ "$line" =~ "PAQUETES" ]]; then
            echo -e "\033[1;36m=== 📦 GESTOR DE PAQUETES ('$PKG_MANAGER') ===\033[0m\n\nInstala las herramientas base para tu terminal:\n ➔ zsh, git, curl, tmux, starship, fzf, zoxide\n ➔ eza, bat, micro\n ➔ Adaptadores de portapapeles (xclip, xsel, wl-clipboard)\n ➔ Fuente JetBrainsMono Nerd Font"
        elif [[ "$line" =~ "OH MY ZSH" ]]; then
            echo -e "\033[1;36m=== 🐚 OH MY ZSH & PLUGINS ===\033[0m\n\nDescarga e integra el framework Zsh:\n ➔ Autosugerencias (zsh-autosuggestions)\n ➔ Resaltado de sintaxis (zsh-syntax-highlighting)\n ➔ Autocompletados avanzados (zsh-completions)"
        elif [[ "$line" =~ "OPCIONES SHELL" ]]; then
            echo -e "\033[1;36m=== ⚙️ OPTIMIZACIÓN INTERACTIVA DE SHELL ===\033[0m\n\nConsola visual para activar o desactivar parámetros '\''setopt'\'':\n ➔ autocd, autocorrect de comandos\n ➔ Control de duplicados en historial\n ➔ Historial compartido entre terminales en tiempo real"
        elif [[ "$line" =~ "GHOSTTY" ]]; then
            echo -e "\033[1;36m=== 👻 CONFIGURACIÓN DE GHOSTTY ===\033[0m\n\nGenera el archivo ~/.config/ghostty/config con:\n ➔ Tema Catppuccin Mocha y transparencia al 90%\n ➔ Tipografía JetBrainsMono Nerd Font\n ➔ Portapapeles bidireccional integrado con el SO"
        elif [[ "$line" =~ "TMUX" ]]; then
            echo -e "\033[1;36m=== 🖥️ MULTIPLEXOR TMUX ===\033[0m\n\nAplica un ~/.tmux.conf optimizado para desarrolladores:\n ➔ Navegación e integración completa de ratón\n ➔ Copiado automático al portapapeles del SO al seleccionar\n ➔ Atajos de división con Prefix Ctrl+A"
        elif [[ "$line" =~ "PORTAPAPELES" ]]; then
            echo -e "\033[1;36m=== 📋 PUENTE DE PORTAPAPELES UNIVERSAL ===\033[0m\n\nResuelve los problemas de copiar y pegar:\n ➔ Configura el portapapeles global para Wayland y X11\n ➔ Vincula la selección de Ghostty, Tmux y Micro con el SO"
        elif [[ "$line" =~ "ZSHRC" ]]; then
            echo -e "\033[1;36m=== 📝 INYECCIÓN DE .ZSHRC ===\033[0m\n\nActualiza la configuración de la Shell:\n ➔ Añade alias modernos (ls -> eza, cat -> bat)\n ➔ Integra Starship, FZF y Zoxide\n ➔ Preserva intactos tus scripts y configuraciones personalizadas"
        elif [[ "$line" =~ "CAMBIAR SHELL" ]]; then
            echo -e "\033[1;36m=== 🔄 SHELL PREDETERMINADA ===\033[0m\n\nCambia tu Shell predeterminada de usuario a Zsh de forma segura mediante '\''chsh'\''."
        elif [[ "$line" =~ "BACKUPS" ]]; then
            echo -e "\033[1;36m=== 🗂️ GESTOR DE RESPALDOS ===\033[0m\n\nAdministra tus puntos de restauración previos:\n ➔ Explora copias organizadas por fecha y hora\n ➔ Revisa diferencias y edita archivos con Micro\n ➔ Restaura configuraciones a su estado original"
        elif [[ "$line" =~ "HELP ATAJOS" ]]; then
            echo -e "\033[1;36m=== 💡 AYUDA Y ATAJOS DE TECLADO ===\033[0m\n\nMuestra un menú interactivo con todos los atajos instalados:\n ➔ Comandos y prefijos de Tmux\n ➔ Atajos de búsqueda con FZF\n ➔ Alias modernos de Zsh (ls, cat, t, etc.)\n ➔ Teclas rápidas del sistema y de la Shell"    
        elif [[ "$line" =~ "SALIR" ]]; then
            echo -e "\033[1;31m=== ❌ SALIR ===\033[0m\n\nCierra el panel de administración ZSH4ME de forma segura."
        else
            echo -e "Selecciona una opción del menú para ver la descripción detallada de sus acciones."
        fi
    '

    fzf --ansi \
        --height=60% \
        --layout=reverse \
        --border=rounded \
        --prompt=" Seleccione Opción ❯ " \
        --header="--- Z S H 4 M E  P A N E L ---" \
        --header-lines=1 \
        --color="border:#5fafd7,header:#af87ff,prompt:#5fb2ff,pointer:#afff00" \
        --preview-window="right:50%:border-rounded:wrap" \
        --preview="$preview_cmd"
}

# --- HELPER CENTRALIZADO DE RESPALDOS ---
crear_backup() {
    local archivo_origen="$1"

    if [ -e "$archivo_origen" ]; then
        mkdir -p "$BACKUP_DIR"
        local nombre_base=$(basename "$archivo_origen")
        local destino="$BACKUP_DIR/$nombre_base"

        cp -r "$archivo_origen" "$destino"
        chown -R "$REAL_USER:$REAL_USER" "$BACKUP_DIR"

        warn "Respaldo creado para $nombre_base -> $destino"
    fi
}

# ==============================================================================
# SUBMÓDULO: MENÚ INTERACTIVO DE AYUDA Y ATAJOS CON FZF
# ==============================================================================

mostrar_ayuda_atajos() {
    local atajos="CATEGORÍA  | ATAJO / COMANDO           | DESCRIPCIÓN
Tmux       | Ctrl + a                  | Tecla Prefix (remplaza Ctrl+b)
Tmux       | Prefix + |                | Dividir panel verticalmente
Tmux       | Prefix + -                | Dividir panel horizontalmente
Tmux       | Prefix + r                | Recargar archivo de configuración ~/.tmux.conf
Tmux       | Arrastrar Ratón           | Copia automáticamente al portapapeles global
Zsh/Alias  | t                         | Conecta a la sesión 'main' de Tmux o la crea
Zsh/Alias  | ta <nombre>               | Adjuntarse a una sesión de Tmux específica
Zsh/Alias  | tn <nombre>               | Crear nueva sesión de Tmux
Zsh/Alias  | tl                        | Listar todas las sesiones activas de Tmux
Zsh/Alias  | tk <nombre>               | Eliminar/Cerrar una sesión de Tmux
Zsh/Alias  | ls / ll / tree            | Muestra directorios con eza (con iconos y colores)
Zsh/Alias  | cat <archivo>             | Visualiza archivos con bat (resaltado de sintaxis)
Zsh/Alias  | reload                    | Recarga el archivo ~/.zshrc en la terminal actual
Zsh/Alias  | .. / ...                  | Sube 1 o 2 niveles de directorio
FZF        | Ctrl + r                  | Búsqueda interactiva en el historial de comandos
FZF        | Ctrl + t                  | Búsqueda interactiva de archivos en el directorio
Zoxide     | z <directorio>            | Salto rápido a carpetas frecuentadas
Editor     | micro <archivo>           | Editor de texto por defecto (usa portapapeles externo)"

    echo "$atajos" | fzf \
        --ansi \
        --height=70% \
        --layout=reverse \
        --border=rounded \
        --prompt=" 🔍 Buscar Atajo/Comando > " \
        --header="--- ATAJOS Y FUNCIONES INSTALADAS POR ZSH4ME ---" \
        --header-lines=1 \
        --color="border:#5fafd7,header:#af87ff,prompt:#5fb2ff,pointer:#afff00"
}

# --- DETECCIÓN DE DISTRIBUCIÓN Y GESTOR DE PAQUETES ---
PKG_MANAGER=""
DISTRO_NAME=""

detectar_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_NAME=$NAME
        case "$ID" in
            arch|manjaro|endeavouros|garuda) PKG_MANAGER="pacman" ;;
            ubuntu|debian|pop|mint|elementary) PKG_MANAGER="apt" ;;
            fedora|rhel|nobara|centos) PKG_MANAGER="dnf" ;;
            *)
                if [[ "$ID_LIKE" == *"arch"* ]]; then PKG_MANAGER="pacman";
                elif [[ "$ID_LIKE" == *"debian"* || "$ID_LIKE" == *"ubuntu"* ]]; then PKG_MANAGER="apt";
                elif [[ "$ID_LIKE" == *"fedora"* || "$ID_LIKE" == *"rhel"* ]]; then PKG_MANAGER="dnf";
                else error "Distribución no soportada automáticamente: $ID"; fi
                ;;
        esac
    else
        error "No se pudo determinar la distribución Linux."
    fi
}

detectar_distro

if [ "$EUID" -eq 0 ] && [ -z "$SUDO_USER" ]; then
    error "No ejecutes este script directamente como root. Úsalo como usuario normal: ./zsh4me.sh"
fi

trap salir SIGINT SIGTERM

salir() {
    echo -e "\e[?25h"
    echo ""
    echo -e "${VERDE}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${AZUL}  Saliendo de zsh4me...${RESET}"
    echo -e "${VERDE_BRILLANTE}  ¡Hasta pronto!${RESET}"
    echo -e "${VERDE}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    exit 0
}

# --- DIBUJADO DE LOGO ---
mostrar_logo() {
    echo -e "${CIAN}  ███████╗███████╗██╗  ██╗██╗  ██╗███╗   ███╗███████╗${RESET}"
    echo -e "${AZUL_BRILLANTE}  ╚══███╔╝██╔════╝██║  ██║██║  ██║████╗ ████║██╔════╝${RESET}"
    echo -e "${AZUL}    ███╔╝ ███████╗███████║███████║██╔████╔██║█████╗  ${RESET}"
    echo -e "${AZUL}   ███╔╝  ╚════██║██╔══██║╚════██║██║╚██╔╝██║██╔══╝  ${RESET}"
    echo -e "${AZUL_BRILLANTE}  ███████╗███████║██║  ██║     ██║██║ ╚═╝ ██║███████╗${RESET}"
    echo -e "${VERDE_BRILLANTE}  ╚══════╝╚══════╝╚═╝  ╚═╝     ╚═╝╚═╝     ╚═╝╚══════╝${RESET}"
    echo -e "${VERDE_BRILLANTE}  ZSH4ME - CONFIGURADOR DE ENTORNO $ver${RESET}"
    echo -e "${CIAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${AMARILLO}➤ Sistema:${RESET}  ${BLANCO}${DISTRO_NAME} (${PKG_MANAGER})${RESET}"
    echo -e "${AMARILLO}➤ Usuario:${RESET}  ${BLANCO}${REAL_USER}${RESET}"
    echo -e "${AMARILLO}➤ Home:${RESET}     ${BLANCO}${REAL_HOME}${RESET}"
    echo -e "${CIAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

# ==============================================================================
# SUBMÓDULO: CONFIGURACIÓN INTERACTIVA DE PARÁMETROS SHELL
# ==============================================================================

configurar_opciones_shell_interactivas() {
    set +e

    local TARGET_RC="$REAL_HOME/.zshrc"
    local SHELL_NAME="Zsh"
    local MARKER_START="# === INICIO BLOQUE PERSONALIZADO SHELL4ME ==="
    local MARKER_END="# === FIN BLOQUE PERSONALIZADO SHELL4ME ==="

    local OPCIONES=(
        "autocd"         "Entra a directorios escribiendo solo su nombre" "on"
        "correct"        "Corrige automáticamente la ortografía de comandos" "on"
        "correctall"     "Corrige ortografía de argumentos y rutas" "on"
        "globdots"       "Incluye archivos ocultos con el comodín *" "off"
        "extendedglob"   "Habilita patrones de búsqueda avanzados" "off"
        "histignoredups" "Omite duplicados consecutivos en el historial" "on"
        "histfindnodups" "Omite duplicados al buscar con flechas" "on"
        "sharehistory"   "Comparte historial en tiempo real entre pestañas" "on"
        "bgnice"         "Ejecuta procesos en segundo plano con menor prioridad" "on"
        "nonomatch"      "Si un patrón falla, no lanza error (estilo Bash)" "on"
    )

    local num_opciones=$((${#OPCIONES[@]} / 3))
    local cursor=0
    local key=""

    while true; do
        clear
        echo -e "${CIAN}========================================================================${RESET}"
        echo -e "       ${NEGRITA}ZSH4ME - CONSOLA DE OPTIMIZACIÓN DE SHELL${RESET}"
        echo -e "${CIAN}========================================================================${RESET}"
        echo -e " Configurando: ${AMARILLO}$TARGET_RC${RESET}"
        echo -e " Controles: [${AMARILLO}W/S${RESET} o ${AMARILLO}Flechas${RESET}: Navegar] | [${AMARILLO}Espacio${RESET}: Alternar] | [${AMARILLO}Enter${RESET}: Guardar] | [${AMARILLO}Q${RESET}: Cancelar]"
        echo -e "${CIAN}------------------------------------------------------------------------${RESET}\n"

        local idx=0
        for ((i=0; i<${#OPCIONES[@]}; i+=3)); do
            local opt="${OPCIONES[i]}"
            local desc="${OPCIONES[i+1]}"
            local state="${OPCIONES[i+2]}"
            local check="[ ]"
            [ "$state" == "on" ] && check="[X]"

            if [ $idx -eq $cursor ]; then
                echo -e " ${VERDE_BRILLANTE}➔ $check $opt:${RESET} $desc"
            else
                echo -e "    $check $opt: $desc"
            fi
            ((idx++))
        done
        echo -e "\n${CIAN}------------------------------------------------------------------------${RESET}"

        read -rsn1 key

        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.05 key
            case "$key" in
                "[A") key="w" ;;
                "[B") key="s" ;;
            esac
        fi

        case "$key" in
            w|W)
                ((cursor--))
                [ $cursor -lt 0 ] && cursor=$((num_opciones - 1))
                ;;
            s|S)
                ((cursor++))
                [ $cursor -ge $num_opciones ] && cursor=0
                ;;
            " ")
                local elem_idx=$((cursor * 3 + 2))
                if [ "${OPCIONES[elem_idx]}" == "on" ]; then
                    OPCIONES[elem_idx]="off"
                else
                    OPCIONES[elem_idx]="on"
                fi
                ;;
            q|Q)
                warn "Operación cancelada. Sin cambios en $TARGET_RC."
                set -e
                return
                ;;
            "")
                break
                ;;
        esac
    done

    set -e

    crear_backup "$TARGET_RC"

    if grep -q "$MARKER_START" "$TARGET_RC" 2>/dev/null; then
        info "Limpiando bloque de optimizaciones previo..."
        awk "/$MARKER_START/{p=1;next} /$MARKER_END/{p=0;next} !p" "$TARGET_RC" > "${TARGET_RC}.tmp"
        mv "${TARGET_RC}.tmp" "$TARGET_RC"
    fi

    info "Escribiendo directivas en $TARGET_RC..."
    {
        echo "$MARKER_START"
        echo "# Configuración de $SHELL_NAME - Optimizada por ZSH4ME"
        for ((i=0; i<${#OPCIONES[@]}; i+=3)); do
            opt="${OPCIONES[i]}"
            desc="${OPCIONES[i+1]}"
            state="${OPCIONES[i+2]}"
            if [ "$state" == "on" ]; then
                echo "# [ACTIVO] $desc"
                echo "setopt $opt 2>/dev/null || true"
            else
                echo "# [INACTIVO] $desc"
                echo "unsetopt $opt 2>/dev/null || true"
            fi
        done
        echo "$MARKER_END"
    } >> "$TARGET_RC"

    success "Opciones de $SHELL_NAME aplicadas correctamente en $TARGET_RC"
}

# ==============================================================================
# FUNCIONES DE INSTALACIÓN ADAPTATIVAS
# ==============================================================================

instalar_paquetes() {
    info "Instalando paquetes en $DISTRO_NAME usando $PKG_MANAGER..."
    case "$PKG_MANAGER" in
        pacman) sudo pacman -S --needed --noconfirm zsh git curl tmux starship fzf zoxide eza bat micro xclip xsel wl-clipboard ttf-jetbrains-mono-nerd ;;
        apt)
            sudo apt update && sudo apt install -y zsh git curl tmux fzf zoxide bat micro xclip xsel wl-clipboard
            if ! command -v eza &>/dev/null; then sudo apt install -y eza 2>/dev/null || sudo apt install -y exa 2>/dev/null || true; fi
            if ! command -v starship &>/dev/null; then curl -sS https://starship.rs/install.sh | sh -s -- -y; fi
            ;;
        dnf) sudo dnf install -y zsh git curl tmux starship fzf zoxide eza bat micro xclip xsel wl-clipboard ;;
    esac
    
    # Configuración global para Micro Editor (Usar portapapeles del SO)
    mkdir -p "$REAL_HOME/.config/micro"
    echo '{"clipboard": "external"}' > "$REAL_HOME/.config/micro/settings.json"
    chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config/micro"

    success "Paquetes de sistema y adaptadores de portapapeles instalados."
}

configurar_oh_my_zsh() {
    ZSH_DIR="$REAL_HOME/.oh-my-zsh"
    ZSH_CUSTOM="$ZSH_DIR/custom"

    if [ ! -d "$ZSH_DIR" ]; then
        info "Instalando Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        chown -R "$REAL_USER:$REAL_USER" "$ZSH_DIR"
    fi

    info "Instalando plugins de Zsh..."
    [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ] && git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    
    chown -R "$REAL_USER:$REAL_USER" "$ZSH_CUSTOM"
    success "Plugins de Zsh listos."
}

configurar_ghostty() {
    GHOSTTY_CONF_DIR="$REAL_HOME/.config/ghostty"
    GHOSTTY_CONF_FILE="$GHOSTTY_CONF_DIR/config"

    mkdir -p "$GHOSTTY_CONF_DIR"
    crear_backup "$GHOSTTY_CONF_FILE"

    cat << EOF > "$GHOSTTY_CONF_FILE"
# Tipografía y Renderizado
font-family = JetBrainsMono Nerd Font
font-size = 11
adjust-cell-height = 10%

# Apariencia y Tema
theme = Catppuccin Mocha
background-opacity = 0.90
window-padding-x = 12
window-padding-y = 12
confirm-close-surface = false

# Integración y Comportamiento de Selección
command = /usr/bin/zsh
shell-integration = zsh
cursor-style = block
cursor-style-blink = false

# COPIAR/PEGAR AUTOMÁTICO AL PORTAPAPELES GLOBAL (VSCodium/Browser compatible)
copy-on-select = true
clipboard-write = allow
clipboard-read = allow
clipboard-trim-trailing-spaces = true
clipboard-paste-protection = false
EOF
    chown -R "$REAL_USER:$REAL_USER" "$GHOSTTY_CONF_DIR"
    success "Ghostty configurado con integración universal de portapapeles."
}

configurar_tmux() {
    TMUX_CONF_FILE="$REAL_HOME/.tmux.conf"
    crear_backup "$TMUX_CONF_FILE"

    cat << 'EOF' > "$TMUX_CONF_FILE"
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"

# Habilitar soporte de ratón y selección
set -g mouse on
setw -g mode-keys vi

# Sincronización universal de selección con ratón a Portapapeles Global (Wayland/X11)
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "wl-copy 2>/dev/null || xclip -selection clipboard -in 2>/dev/null || xsel --clipboard --input"
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "wl-copy 2>/dev/null || xclip -selection clipboard -in 2>/dev/null || xsel --clipboard --input"

set -g base-index 1
set -g pane-base-index 1
set-window-option -g pane-base-index 1
set-option -g renumber-windows on

unbind C-b
set -g prefix C-a
bind C-a send-prefix

bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

bind r source-file ~/.tmux.conf \; display "¡Configuración de Tmux recargada!"

set -g status-style bg=default,fg=colour12
set -g status-left-length 40
set -g status-right "#[fg=colour8]%Y-%m-%d %H:%M"
EOF
    chown "$REAL_USER:$REAL_USER" "$TMUX_CONF_FILE"
    success "Tmux configurado con puente multigestor (wl-copy / xclip / xsel)."
}

configurar_portapapeles_universal() {
    clear
    mostrar_logo
    info "Aplicando sincronización de portapapeles universal en $DISTRO_NAME..."
    
    instalar_paquetes
    configurar_ghostty
    configurar_tmux

    success "¡Portapapeles universal habilitado! Ahora la selección con el ratón se enviará al portapapeles global del sistema (VSCodium, navegadores, Micro, etc.)."
}

generar_zshrc() {
    ZSHRC_FILE="$REAL_HOME/.zshrc"
    mkdir -p "$REAL_HOME/.local/bin" "$REAL_HOME/bin"

    if [ -f "$ZSHRC_FILE" ]; then
        crear_backup "$ZSHRC_FILE"
    else
        touch "$ZSHRC_FILE"
        chown "$REAL_USER:$REAL_USER" "$ZSHRC_FILE"
    fi

    if ! grep -q "# === ZSH4ME CONFIG START ===" "$ZSHRC_FILE"; then
        cat << 'EOF' >> "$ZSHRC_FILE"

# === ZSH4ME CONFIG START ===
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
fpath=($ZSH/custom/plugins/zsh-completions/src $fpath)
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
[ -f $ZSH/oh-my-zsh.sh ] && source $ZSH/oh-my-zsh.sh

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086,bold"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
command -v starship &>/dev/null && eval "$(starship init zsh)"
# === ZSH4ME CONFIG END ===
EOF
    fi

    if ! grep -q "# === ZSH4ME ALIASES START ===" "$ZSHRC_FILE"; then
        cat << 'EOF' >> "$ZSHRC_FILE"

# === ZSH4ME ALIASES START ===
if command -v batcat &>/dev/null; then alias bat="batcat"; fi
if command -v exa &>/dev/null && ! command -v eza &>/dev/null; then alias eza="exa"; fi

if command -v eza &>/dev/null; then
    alias ls="eza --icons --group-directories-first" 2>/dev/null || true
    alias ll="eza -la --icons --group-directories-first" 2>/dev/null || true
    alias tree="eza --tree --icons" 2>/dev/null || true
fi

if command -v bat &>/dev/null || command -v batcat &>/dev/null; then
    alias cat="bat --paging=never" 2>/dev/null || true
fi

alias grep="grep --color=auto" 2>/dev/null || true
alias t="[ -z \"\$TMUX\" ] && (tmux attach -t main 2>/dev/null || tmux new -s main) || echo 'Ya estás dentro de Tmux'"
alias ta="tmux attach -t"
alias tn="tmux new -s"
alias tl="tmux ls"
alias tk="tmux kill-session -t"
alias ..="cd .."
alias ...="cd ../.."
alias reload="source ~/.zshrc"
# === ZSH4ME ALIASES END ===
EOF
    fi

    if ! grep -q 'export PATH="$HOME/.local/bin:' "$ZSHRC_FILE"; then
        cat << 'EOF' >> "$ZSHRC_FILE"

# === ZSH4ME PATHS ===
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export EDITOR="micro"
export VISUAL="micro"
EOF
    fi

    chown -R "$REAL_USER:$REAL_USER" "$ZSHRC_FILE" "$REAL_HOME/.local/bin"
    success ".zshrc inyectado respetando tus configuraciones anteriores."
}

cambiar_shell() {
    info "Estableciendo Zsh como shell predeterminada..."
    ZSH_PATH=$(which zsh || echo "/usr/bin/zsh")
    sudo chsh -s "$ZSH_PATH" "$REAL_USER"
    success "Shell predeterminada cambiada a $ZSH_PATH."
}

ejecutar_instalacion_completa() {
    clear
    mostrar_logo
    echo -e "${MAGENTA}=== INICIANDO INSTALACIÓN INTEGRAL EN $DISTRO_NAME ===${RESET}\n"
    
    instalar_paquetes
    configurar_oh_my_zsh
    configurar_ghostty
    configurar_tmux
    generar_zshrc
    cambiar_shell

    echo ""
    echo -e "${VERDE_BRILLANTE}=====================================================${RESET}"
    echo -e "${VERDE_BRILLANTE}   ¡PROCESO FINALIZADO SIN ERRORES!                  ${RESET}"
    echo -e "${VERDE_BRILLANTE}=====================================================${RESET}"
    [ -d "$BACKUP_DIR" ] && echo -e "${AMARILLO} Archivos respaldados en:${RESET} ${BLANCO}$BACKUP_DIR${RESET}"
    read -p "Presione Enter para volver al menú..."
}

# ==============================================================================
# SUBMÓDULO: GESTOR INTERACTIVO DE BACKUPS (MICRO + FZF)
# ==============================================================================

gestionar_backups() {
    local BASE_BACKUP_DIR="$REAL_HOME/.zsh4me_backups"

    if [ ! -d "$BASE_BACKUP_DIR" ] || [ -z "$(ls -A "$BASE_BACKUP_DIR" 2>/dev/null)" ]; then
        warn "No se encontraron respaldos en $BASE_BACKUP_DIR"
        read -p "Presione Enter para continuar..."
        return
    fi

    local BAT_CMD="cat"
    if command -v bat &>/dev/null; then
        BAT_CMD="bat --theme=ansi --style=plain --color=always"
    elif command -v batcat &>/dev/null; then
        BAT_CMD="batcat --theme=ansi --style=plain --color=always"
    fi

    while true; do
        # 1. Seleccionar la carpeta del Respaldo (Backup por Fecha/Timestamp)
        local backup_folder
        backup_folder=$(find "$BASE_BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -r | sed "s|^$BASE_BACKUP_DIR/||" | fzf \
            --ansi \
            --height=50% \
            --layout=reverse \
            --border=rounded \
            --header="--- 📦 GESTOR DE BACKUPS ZSH4ME (Esc: Volver) ---" \
            --prompt="Seleccione Fecha/Sesión > " \
            --preview="ls -la '$BASE_BACKUP_DIR/{}'")

        [ -z "$backup_folder" ] && break

        local target_folder="$BASE_BACKUP_DIR/$backup_folder"

        # 2. Seleccionar el archivo dentro de esa carpeta de backup
        local selected_file
        selected_file=$(find "$target_folder" -type f 2>/dev/null | sed "s|^$target_folder/||" | fzf \
            --ansi \
            --height=60% \
            --layout=reverse \
            --border=rounded \
            --header="--- Archivos en: $backup_folder ---" \
            --prompt="Seleccione Archivo > " \
            --preview="$BAT_CMD '$target_folder/{}' 2>/dev/null || head -n 30 '$target_folder/{}'")

        [ -z "$selected_file" ] && continue

        local full_file_path="$target_folder/$selected_file"

        # 3. Menú de Acción para el archivo seleccionado
        local accion
        accion=$(printf "📝 Editar / Ver con Micro\n🔄 Restaurar Backup a su ubicación original\n❌ Cancelar" | fzf \
            --height=35% \
            --layout=reverse \
            --border=rounded \
            --header="--- Acción para: $selected_file ---" \
            --prompt="Elija acción > ")

        case "$accion" in
            "📝 Editar / Ver con Micro")
                micro "$full_file_path"
                ;;
            "🔄 Restaurar Backup a su ubicación original")
                local original_dest="$REAL_HOME/$selected_file"
                read -rp "¿Confirmas sobrescribir '$original_dest' con este backup? (s/N): " confirm
                if [[ "$confirm" =~ ^[Ss]$ ]]; then
                    crear_backup "$original_dest" # Backup preventivo antes de sobrescribir
                    cp -rf "$full_file_path" "$original_dest"
                    chown -R "$REAL_USER:$REAL_USER" "$original_dest" 2>/dev/null || true
                    success "Backup restaurado exitosamente en: $original_dest"
                    sleep 2
                fi
                ;;
            *)
                continue
                ;;
        esac
    done
}

# ==============================================================================
# BUCLE DE MENÚ PRINCIPAL
# ==============================================================================

menu() {
    if ! command -v fzf &>/dev/null; then
        warn "Instalando dependencias del panel (FZF)..."
        case "$PKG_MANAGER" in
            pacman) sudo pacman -S --needed --noconfirm fzf ;;
            apt) sudo apt update && sudo apt install -y fzf ;;
            dnf) sudo dnf install -y fzf ;;
        esac
    fi

    while true; do
        clear
        mostrar_logo

        opciones="ICONO | OPCIÓN        | DESCRIPCIÓN
0. ⚡ | INSTALACIÓN   | Desplegar entorno completo y optimizado.
1. 📦 | PAQUETES      | Instalación de paquetes y fuentes base.
2. 🐚 | OH MY ZSH     | Framework Zsh, plugins y completados.
3. ⚙️ | OPCIONES SHELL| Ajustar parámetros de la shell de forma visual.
4. 👻 | GHOSTTY       | Configurar terminal Ghostty y estilo gráfico.
5. 🖥️ | TMUX          | Configurar multiplexor de terminal Tmux.
6. 📋 | PORTAPAPELES  | Habilitar sincronización universal de portapapeles.
7. 📝 | ZSHRC         | Actualizar .zshrc con alias y herramientas modernas.
8. 🔄 | CAMBIAR SHELL | Establecer Zsh como la shell predeterminada.
9. 🗂️ | BACKUPS       | Explorar, editar o restaurar copias de seguridad.
10. 💡| HELP ATAJOS   | Ver atajos de teclado, alias y funciones integradas.
11. ❌| SALIR        | Salir del administrador zsh4me"

        seleccion=$(echo -e "$opciones" | fzf_menu_principal)

        if [ $? -ne 0 ] || [ -z "$seleccion" ]; then salir; fi

        case ${seleccion%%.*} in
            0) ejecutar_instalacion_completa ;;
            1) clear; mostrar_logo; instalar_paquetes; read -p "Presione Enter...";;
            2) clear; mostrar_logo; configurar_oh_my_zsh; read -p "Presione Enter...";;
            3) configurar_opciones_shell_interactivas; read -p "Presione Enter...";;
            4) clear; mostrar_logo; configurar_ghostty; read -p "Presione Enter...";;
            5) clear; mostrar_logo; configurar_tmux; read -p "Presione Enter...";;
            6) configurar_portapapeles_universal; read -p "Presione Enter...";;
            7) clear; mostrar_logo; generar_zshrc; read -p "Presione Enter...";;
            8) clear; mostrar_logo; cambiar_shell; read -p "Presione Enter...";;
            9) gestionar_backups ;;
            10) mostrar_ayuda_atajos ;;
            11) salir ;;
        esac
    done
}

menu