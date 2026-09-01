#!/usr/bin/env bash

# ==============================================================================
# zsh4me - Instalador y configurador de Zsh + Ghostty + Tmux para Arch Linux
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

if [ "$EUID" -eq 0 ] && [ -z "$SUDO_USER" ]; then
    error "No ejecutes este script directamente como root. Úsalo como usuario normal: ./zsh4me"
fi

if [ ! -f /etc/arch-release ]; then
    error "Este script está diseñado para ejecutarse exclusivamente en Arch Linux."
fi

info "Configurando entorno de terminal para el usuario: $REAL_USER..."

# 1. Instalación de paquetes
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
    ttf-jetbrains-mono-nerd
)

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
success "Paquetes instalados correctamente."

# 2. Oh My Zsh y Plugins
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

# 3. Configuración de Ghostty (Sintaxis actualizada)
GHOSTTY_CONF_DIR="$REAL_HOME/.config/ghostty"
GHOSTTY_CONF_FILE="$GHOSTTY_CONF_DIR/config"

info "Configurando Ghostty..."
mkdir -p "$GHOSTTY_CONF_DIR"

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

# 4. Configuración de Tmux
TMUX_CONF_FILE="$REAL_HOME/.tmux.conf"
info "Configurando Tmux..."

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

# 5. Generación de .zshrc
ZSHRC_FILE="$REAL_HOME/.zshrc"
info "Generando .zshrc..."

cat << 'EOF' > "$ZSHRC_FILE"
# ==============================================================================
# 1. ALIASES Y ATAJOS DE TECLADO (Al inicio del archivo)
# ==============================================================================

# --- Aliases para reemplazos modernos de comandos base ---
alias ls="eza --icons --group-directories-first"         # Lista archivos mostrando iconos y carpetas primero
alias ll="eza -la --icons --group-directories-first"      # Detalle completo de archivos y ocultos con iconos
alias tree="eza --tree --icons"                           # Muestra la estructura de directorios en árbol visual
alias cat="bat --paging=never"                            # Visualiza archivos con resaltado de sintaxis
alias grep="grep --color=auto"                            # Resalta resultados en las búsquedas con grep

# --- Aliases de administración de sistema (Arch Linux / Pacman) ---
alias pacin="sudo pacman -S"                              # Instalar paquetes
alias pacup="sudo pacman -Syu"                            # Actualizar el sistema completo
alias pacrm="sudo pacman -Rns"                            # Eliminar paquete y sus dependencias no usadas
alias pacq="pacman -Qe"                                   # Listar paquetes explícitamente instalados

# --- Aliases para gestión de productividad y Tmux ---
alias t="[ -z \"\$TMUX\" ] && (tmux attach -t main 2>/dev/null || tmux new -s main) || echo 'Ya estás dentro de Tmux'" # Conexión segura a Tmux
alias ta="tmux attach -t"                                 # Acoplarse a una sesión existente indicando nombre (Ej: ta dev)
alias tn="tmux new -s"                                    # Crear una nueva sesión nombrada (Ej: tn dev)
alias tl="tmux ls"                                        # Listar todas las sesiones de Tmux activas
alias tk="tmux kill-session -t"                           # Cerrar/destruir una sesión específica (Ej: tk main)

# --- Aliases de navegación y utilidad general ---
alias ..="cd .."                                          # Subir un nivel de directorio
alias ...="cd ../.."                                      # Subir dos niveles de directorio
alias reload="source ~/.zshrc"                            # Recargar la configuración de Zsh al instante

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

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

eval "$(starship init zsh)"
EOF

chown -R "$REAL_USER:$REAL_USER" "$GHOSTTY_CONF_DIR" "$TMUX_CONF_FILE" "$ZSHRC_FILE"

# 6. Forzar cambio de shell del sistema
info "Estableciendo Zsh como shell predeterminada..."
sudo chsh -s /usr/bin/zsh "$REAL_USER"

echo ""
echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}  ¡PROCESO FINALIZADO SIN ERRORES!                  ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "Pasos obligatorios para aplicar los cambios:"
echo -e "1. Cierra Ghostty por completo (Ctrl+Shift+Q)."
echo -e "2. Vuelve a abrir Ghostty. Entrarás directo a Zsh sin avisos de error."
echo -e "3. Para iniciar Tmux escribe solo: ${BLUE}t${NC}"
echo -e "====================================================="
