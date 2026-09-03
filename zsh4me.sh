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
ver="v.2.1"

info() { echo -e "${AZUL_BRILLANTE}[INFO]${RESET} $1"; }
success() { echo -e "${VERDE_BRILLANTE}[OK]${RESET} $1"; }
warn() { echo -e "${AMARILLO}[WARN]${RESET} $1"; }
error() { echo -e "${ROJO_BRILLANTE}[ERROR]${RESET} $1"; exit 1; }

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$REAL_HOME/.zsh4me_backups/backup_$TIMESTAMP"

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

fzf_menu_principal() {
    local host_name=$(hostname 2>/dev/null || cat /etc/hostname)
    local date_now=$(date +"%d/%m/%Y")

    fzf --ansi \
        --height=15 \
        --layout=reverse \
        --border=rounded \
        --prompt=" Seleccione Opción-❯ " \
        --header="--- Z S H 4 M E  P A N E L ---" \
        --header-lines=1 \
        --color="border:#5fafd7,header:#af87ff,prompt:#5fb2ff,pointer:#afff00" \
        --preview-window="up:25%:border-bottom" \
        --preview="echo -e '\033[1;36mENTORNO: $DISTRO_NAME\033[0m | \033[1;33mFecha:\033[0m $date_now | \033[1;33mHost:\033[0m $host_name | \033[1;33mUsuario:\033[0m $REAL_USER'"
}

# ==============================================================================
# SUBMÓDULO: CONFIGURACIÓN INTERACTIVA DE PARÁMETROS SHELL
# ==============================================================================

configurar_opciones_shell_interactivas() {
    local TARGET_RC="$REAL_HOME/.zshrc"
    local SHELL_NAME="Zsh"
    local MARKER_START="# === INICIO BLOQUE PERSONALIZADO SHELL4ME ==="
    local MARKER_END="# === FIN BLOQUE PERSONALIZADO SHELL4ME ==="

    local OPCIONES=(
        "autocd"         "Entra a directorios directamente escribiendo solo su nombre" "on"
        "correct"        "Corrige automáticamente la ortografía de los comandos mal escritos" "on"
        "correctall"     "Corrige la ortografía de los argumentos y rutas de archivos" "on"
        "globdots"       "Incluye archivos ocultos (con punto) al usar el comodín *" "off"
        "extendedglob"   "Habilita patrones de búsqueda ultra avanzados en la terminal" "off"
        "histignoredups" "No guarda un comando en el historial si es igual al anterior" "on"
        "histfindnodups" "Al buscar en el historial con flechas, omite duplicados" "on"
        "sharehistory"   "Comparte el historial de comandos en tiempo real entre pestañas" "on"
        "bgnice"         "Ejecuta los procesos en segundo plano con menor prioridad" "on"
        "nonomatch"      "Si un patrón de búsqueda falla, no lances error (estilo Bash)" "on"
    )

    local num_opciones=$((${#OPCIONES[@]} / 3))
    local cursor=0

    echo -ne "\e[H\e[2J\e[?25l"

    while true; do
        local menu=""
        menu+="\e[H"
        menu+="${CIAN}\n"
        menu+="     ZSH4ME - CONSOLA DE OPTIMIZACIÓN DE SHELL\n"
        menu+="${AZUL_BRILLANTE}--========================================================================${RESET}\n"
        menu+=" Configurando: ${AMARILLO}$TARGET_RC${RESET} | Salir: ${MAGENTA}[Q]${RESET}\n"
        menu+=" Navegar: ${AMARILLO}(↑ ↓)${RESET} | Alternar: ${AMARILLO}[Espacio]${RESET} | Guardar: ${AMARILLO}[Enter]${RESET}\n"
        menu+="${AZUL_BRILLANTE}--========================================================================${RESET}\n\n"

        local idx=0
        for ((i=0; i<${#OPCIONES[@]}; i+=3)); do
            local opt="${OPCIONES[i]}"
            local desc="${OPCIONES[i+1]}"
            local state="${OPCIONES[i+2]}"
            local check="[ ]"
            if [ "$state" == "on" ]; then check="[X]"; fi

            if [ $idx -eq $cursor ]; then
                menu+=" ${VERDE_BRILLANTE}➔ $check $opt:${RESET} $desc\n"
            else
                menu+="    $check $opt: $desc\n"
            fi
            ((idx++))
        done
        menu+="\n${CIAN}------------------------------------------------------------------------${RESET}\e[K"

        printf "$menu"

        IFS= read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            case "$key" in
                "[A") ((cursor--)); [ $cursor -lt 0 ] && cursor=$((num_opciones - 1)) ;;
                "[B") ((cursor++)); [ $cursor -ge $num_opciones ] && cursor=0 ;;
            esac
        elif [[ $key == "" ]]; then
            break
        elif [[ $key == " " ]]; then
            local elem_idx=$((cursor * 3 + 2))
            if [ "${OPCIONES[elem_idx]}" == "on" ]; then OPCIONES[elem_idx]="off"; else OPCIONES[elem_idx]="on"; fi
        elif [[ $key == "q" || $key == "Q" ]]; then
            echo -ne "\e[H\e[2J\e[?25h"
            warn "Operación cancelada. Sin cambios en las opciones de shell."
            return
        fi
    done

    # Guardado seguro garantizando la ruta exacta
    crear_backup "$TARGET_RC"

    if grep -q "$MARKER_START" "$TARGET_RC"; then
        info "Limpiando bloque de optimizaciones previo..."
        awk "/$MARKER_START/{p=1;next} /$MARKER_END/{p=0;next} !p" "$TARGET_RC" > "${TARGET_RC}.tmp"
        mv "${TARGET_RC}.tmp" "$TARGET_RC"
    fi

    info "Escribiendo directivas directamente en $TARGET_RC..."
    {
        echo "$MARKER_START"
        echo "# Configuración de $SHELL_NAME - Optimizada por ZSH4ME"
        for ((i=0; i<${#OPCIONES[@]}; i+=3)); do
            opt="${OPCIONES[i]}"
            desc="${OPCIONES[i+1]}"
            state="${OPCIONES[i+2]}"
            if [ "$state" == "on" ]; then
                echo -e "\n# [ACTIVO] $desc"
                echo "setopt $opt 2>/dev/null || true"
            else
                echo -e "\n# [INACTIVO] $desc"
                echo "unsetopt $opt 2>/dev/null || true"
            fi
        done
        echo -e "\n$MARKER_END"
    } >> "$TARGET_RC"

    echo -ne "\e[?25h"
    success "Opciones de $SHELL_NAME aplicadas correctamente en $TARGET_RC"
}

# ==============================================================================
# FUNCIONES DE INSTALACIÓN ADAPTATIVAS
# ==============================================================================

instalar_paquetes() {
    info "Instalando paquetes en $DISTRO_NAME usando $PKG_MANAGER..."
    case "$PKG_MANAGER" in
        pacman) sudo pacman -S --needed --noconfirm zsh git curl tmux starship fzf zoxide eza bat micro xclip ttf-jetbrains-mono-nerd ;;
        apt)
            sudo apt update && sudo apt install -y zsh git curl tmux fzf zoxide bat micro xclip
            if ! command -v eza &>/dev/null; then sudo apt install -y eza 2>/dev/null || sudo apt install -y exa 2>/dev/null || true; fi
            if ! command -v starship &>/dev/null; then curl -sS https://starship.rs/install.sh | sh -s -- -y; fi
            ;;
        dnf) sudo dnf install -y zsh git curl tmux starship fzf zoxide eza bat micro xclip ;;
    esac
    success "Paquetes de sistema instalados correctamente."
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

# COPIAR Y PEGAR AUTOMÁTICO
copy-on-select = true
clipboard-write = allow
clipboard-read = allow
EOF
    chown -R "$REAL_USER:$REAL_USER" "$GHOSTTY_CONF_DIR"
    success "Ghostty configurado (incluyendo copiar al seleccionar)."
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

# Copiar al portapapeles del sistema al seleccionar con el ratón
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"

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
    success "Tmux configurado con integración de portapapeles del sistema."
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
0. ⚡ | INSTALACIÓN   | Ejecutar instalación y configuración completa.
1. 📦 | PAQUETES      | Instalar paquetes de la distribución ($PKG_MANAGER).
2. 🐚 | OH MY ZSH     | Instalar Oh My Zsh y plugins.
3. ⚙️ | OPCIONES SHELL| Configurar setopt interactivamente.
4. 👻 | GHOSTTY       | Configurar Ghostty (Copy/Paste en selección incl.).
5. 🖥️ | TMUX          | Configurar Tmux (Integración xclip e historial).
6. 📝 | ZSHRC         | Inyectar archivo .zshrc sin borrar contenido.
7. 🔄 | CAMBIAR SHELL | Establecer Zsh como shell predeterminada.
8. ❌ | SALIR         | Salir del script"

        seleccion=$(echo -e "$opciones" | fzf_menu_principal)

        if [ $? -ne 0 ] || [ -z "$seleccion" ]; then salir; fi

        case ${seleccion%%.*} in
            0) ejecutar_instalacion_completa ;;
            1) clear; mostrar_logo; instalar_paquetes; read -p "Presione Enter...";;
            2) clear; mostrar_logo; configurar_oh_my_zsh; read -p "Presione Enter...";;
            3) configurar_opciones_shell_interactivas; read -p "Presione Enter...";;
            4) clear; mostrar_logo; configurar_ghostty; read -p "Presione Enter...";;
            5) clear; mostrar_logo; configurar_tmux; read -p "Presione Enter...";;
            6) clear; mostrar_logo; generar_zshrc; read -p "Presione Enter...";;
            7) clear; mostrar_logo; cambiar_shell; read -p "Presione Enter...";;
            8) salir ;;
        esac
    done
}

menu