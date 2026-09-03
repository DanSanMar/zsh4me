#!/usr/bin/env bash

# ==============================================================================
# zsh4me - Creación de Entorno Interactivo con Zsh + Ghostty + Tmux 
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

info() { echo -e "${AZUL_BRILLANTE}[INFO]${RESET} $1"; }
success() { echo -e "${VERDE_BRILLANTE}[OK]${RESET} $1"; }
warn() { echo -e "${AMARILLO}[WARN]${RESET} $1"; }
error() { echo -e "${ROJO_BRILLANTE}[ERROR]${RESET} $1"; exit 1; }

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# --- VERIFICACIONES INICIALES ---
if [ "$EUID" -eq 0 ] && [ -z "$SUDO_USER" ]; then
    error "No ejecutes este script directamente como root. Úsalo como usuario normal: ./zsh4me"
fi

if [ ! -f /etc/arch-release ]; then
    error "Este script está diseñado para ejecutarse exclusivamente en Arch Linux."
fi

# Captura de señales para salida limpia
trap salir SIGINT SIGTERM

salir() {
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
    echo -e "${VERDE_BRILLANTE}  ZSH4ME - CONFIGURADOR DE ENTORNO DE TERMINAL${RESET}"
    echo -e "${CIAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${AMARILLO}➤ Usuario:${RESET} ${BLANCO}${REAL_USER}${RESET}"
    echo -e "${AMARILLO}➤ Home:${RESET}    ${BLANCO}${REAL_HOME}${RESET}"
    echo -e "${CIAN}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

# --- ESTILOS DE MENU FZF ---
fzf_estilo() {
    local prompt_text="$1"
    local header_text="$2"
    fzf --ansi \
        --height=15 \
        --reverse \
        --border=rounded \
        --prompt="➤ $prompt_text: " \
        --header="$header_text" \
        --color="border:#00ffff,pointer:#92ff92,header:#5fb2ff"
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
        --preview="echo -e '\033[1;36mENTORNO ARCH LINUX\033[0m | \033[1;33mFecha:\033[0m $date_now | \033[1;33mHost:\033[0m $host_name | \033[1;33mUsuario:\033[0m $REAL_USER'"
}

# ==============================================================================
# FUNCIONES DE INSTALACIÓN Y CONFIGURACIÓN (CÓDIGO ORIGINAL CONSERVADO)
# ==============================================================================

instalar_paquetes() {
    info "Configurando entorno de terminal para el usuario: $REAL_USER..."
    info "Instalando paquetes requeridos con pacman..."
    PACKAGES=(
        zsh
        git
        curl
        tmux
        starship
        fzf
        zoxide
        eza
        bat
        micro
        ttf-jetbrains-mono-nerd
    )

    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
    success "Paquetes instalados correctamente."
}

configurar_oh_my_zsh() {
    ZSH_DIR="$REAL_HOME/.oh-my-zsh"
    ZSH_CUSTOM="$ZSH_DIR/custom"

    if [ ! -d "$ZSH_DIR" ]; then
        info "Instalando Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        chown -R "$REAL_USER:$REAL_USER" "$ZSH_DIR"
        success "Oh My Zsh instalado."
    fi

    info "Instalando plugins de Zsh..."
    [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ] && git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    success "Plugins de Zsh listos."
}

configurar_ghostty() {
    GHOSTTY_CONF_DIR="$REAL_HOME/.config/ghostty"
    GHOSTTY_CONF_FILE="$GHOSTTY_CONF_DIR/config"

    info "Configurando Ghostty..."
    mkdir -p "$GHOSTTY_CONF_DIR"

    [ -f "$GHOSTTY_CONF_FILE" ] && cp "$GHOSTTY_CONF_FILE" "${GHOSTTY_CONF_FILE}.bak"

    cat << EOF > "$GHOSTTY_CONF_FILE"
# Tipografía y renderizado
font-family = JetBrainsMono Nerd Font
font-size = 11
adjust-cell-height = 10%

# Apariencia y Tema
theme = Catppuccin Mocha
background-opacity = 0.90
window-padding-x = 12
window-padding-y = 12
confirm-close-surface = false

# Forzar arranque en Zsh
command = /usr/bin/zsh
shell-integration = zsh
cursor-style = block
cursor-style-blink = false
EOF
    chown -R "$REAL_USER:$REAL_USER" "$GHOSTTY_CONF_DIR"
    success "Ghostty configurado."
}

configurar_tmux() {
    TMUX_CONF_FILE="$REAL_HOME/.tmux.conf"
    info "Configurando Tmux..."

    [ -f "$TMUX_CONF_FILE" ] && cp "$TMUX_CONF_FILE" "${TMUX_CONF_FILE}.bak"

    cat << 'EOF' > "$TMUX_CONF_FILE"
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
set -g mouse on

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
    success "Tmux configurado."
}

generar_zshrc() {
    ZSHRC_FILE="$REAL_HOME/.zshrc"
    info "Configurando .zshrc..."

    mkdir -p "$REAL_HOME/.local/bin" "$REAL_HOME/bin"

    if [ ! -f "$ZSHRC_FILE" ]; then
cat << 'EOF' > "$ZSHRC_FILE"
# ==============================================================================
# 1. ALIASES Y ATAJOS DE TECLADO (Al inicio del archivo)
# ==============================================================================

# --- Aliases para reemplazos modernos de comandos base ---
alias ls="eza --icons --group-directories-first"          # Lista archivos mostrando iconos y carpetas primero
alias ll="eza -la --icons --group-directories-first"       # Detalle completo de archivos y ocultos con iconos
alias tree="eza --tree --icons"                            # Muestra la estructura de directorios en árbol visual
alias cat="bat --paging=never"                             # Visualiza archivos con resaltado de sintaxis
alias grep="grep --color=auto"                             # Resalta resultados en las búsquedas con grep

# --- Aliases de administración de sistema (Arch Linux / Pacman) ---
alias pacin="sudo pacman -S"                               # Instalar paquetes
alias pacup="sudo pacman -Syu"                             # Actualizar el sistema completo
alias pacrm="sudo pacman -Rns"                             # Eliminar paquete y sus dependencias no usadas
alias pacq="pacman -Qe"                                    # Listar paquetes explícitamente instalados

# --- Aliases para gestión de productividad y Tmux ---
alias t="[ -z \"\$TMUX\" ] && (tmux attach -t main 2>/dev/null || tmux new -s main) || echo 'Ya estás dentro de Tmux'" # Conexión segura a Tmux
alias ta="tmux attach -t"                                  # Acoplarse a una sesión existente indicando nombre (Ej: ta dev)
alias tn="tmux new -s"                                     # Crear una nueva sesión nombrada (Ej: tn dev)
alias tl="tmux ls"                                         # Listar todas las sesiones de Tmux activas
alias tk="tmux kill-session -t"                            # Cerrar/destruir una sesión específica (Ej: tk main)

# --- Aliases de navegación y utilidad general ---
alias ..="cd .."                                           # Subir un nivel de directorio
alias ...="cd ../.."                                       # Subir dos niveles de directorio
alias reload="source ~/.zshrc"                             # Recargar la configuración de Zsh al instante

# ==============================================================================
# 2. CONFIGURACIÓN PRINCIPAL DE OH MY ZSH Y PLUGINS
# ==============================================================================

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

fpath=($ZSH/custom/plugins/zsh-completions/src $fpath)

plugins=(
    git
    sudo
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

source $ZSH/oh-my-zsh.sh

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086,bold"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ==============================================================================
# 3. HISTORIAL DE ZSH
# ==============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# ==============================================================================
# 4. INTEGRACIÓN DE HERRAMIENTAS CLI (Zoxide, FZF, Starship)
# ==============================================================================

eval "$(zoxide init zsh)"

[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

eval "$(starship init zsh)"
EOF
    fi

    if ! grep -q 'export PATH="$HOME/.local/bin:' "$ZSHRC_FILE"; then
        info "Añadiendo ~/.local/bin al PATH y configurando micro como editor en .zshrc..."
        cat << 'EOF' >> "$ZSHRC_FILE"

# --- Variables de entorno locales ---
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export EDITOR="micro"
export VISUAL="micro"
EOF
    fi

    chown -R "$REAL_USER:$REAL_USER" "$ZSHRC_FILE" "$REAL_HOME/.local/bin"
    success ".zshrc configurado correctamente."
}

cambiar_shell() {
    info "Estableciendo Zsh como shell predeterminada..."
    sudo chsh -s /usr/bin/zsh "$REAL_USER"
    success "Shell predeterminada cambiada a /usr/bin/zsh."
}

ejecutar_instalacion_completa() {
    clear
    mostrar_logo
    echo -e "${MAGENTA}=== INICIANDO INSTALACIÓN INTEGRAL ===${RESET}\n"
    
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
    echo -e "Pasos obligatorios para aplicar los cambios:"
    echo -e "1. Cierra Ghostty por completo (Ctrl+Shift+Q)."
    echo -e "2. Vuelve a abrir Ghostty. Entrarás directo a Zsh sin avisos de error."
    echo -e "3. Para iniciar Tmux escribe solo: ${AZUL_BRILLANTE}t${RESET}"
    echo -e "====================================================="
    read -p "Presione Enter para volver al menú..."
}

# ==============================================================================
# BUCLE DE MENÚ PRINCIPAL CON FZF
# ==============================================================================

menu() {
    # Comprobar dependencia fzf
    if ! command -v fzf &>/dev/null; then
        warn "FZF no está instalado en el sistema. Instalando dependencias iniciales..."
        sudo pacman -S --needed --noconfirm fzf
    fi

    while true; do
        clear
        mostrar_logo

        opciones="ICONO | OPCIÓN        | DESCRIPCIÓN
0. ⚡ | INSTALACIÓN   | Ejecutar instalación y configuración completa.
1. 📦 | PAQUETES      | Instalar únicamente los paquetes de Arch necesarios.
2. 🐚 | OH MY ZSH     | Instalar Oh My Zsh y sus plugins.
3. 👻 | GHOSTTY       | Configurar la terminal Ghostty.
4. 🖥️ | TMUX          | Configurar el multiplexor Tmux.
5. 📝 | ZSHRC         | Generar archivo .zshrc con aliases y herramientas.
6. 🔄 | CAMBIAR SHELL | Establecer /usr/bin/zsh como shell por defecto.
7. ❌ | SALIR         | Salir del script"

        seleccion=$(echo -e "$opciones" | fzf_menu_principal)

        if [ $? -ne 0 ] || [ -z "$seleccion" ]; then salir; fi

        case ${seleccion%%.*} in
            0) ejecutar_instalacion_completa ;;
            1) clear; mostrar_logo; instalar_paquetes; read -p "Presione Enter...";;
            2) clear; mostrar_logo; configurar_oh_my_zsh; read -p "Presione Enter...";;
            3) clear; mostrar_logo; configurar_ghostty; read -p "Presione Enter...";;
            4) clear; mostrar_logo; configurar_tmux; read -p "Presione Enter...";;
            5) clear; mostrar_logo; generar_zshrc; read -p "Presione Enter...";;
            6) clear; mostrar_logo; cambiar_shell; read -p "Presione Enter...";;
            7) salir ;;
        esac
    done
}

# Iniciar la aplicación
menu