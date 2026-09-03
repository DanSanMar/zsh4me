# 🐚 zsh4me

> **Sencillo optimizador de terminal Linux.**  
> *Una solución prácicta para desplegar Zsh, Oh My Zsh, Ghostty, Tmux y herramientas CLI en cuestión de segundos.*

---

[![GitHub release](https://img.shields.io/badge/release-v2.5-brightgreen.svg?style=for-the-badge&logo=git&logoColor=white)](https://github.com/DanSanMar/zsh4me)
[![Linux Multi-Distro](https://img.shields.io/badge/Linux-Arch%20%7C%20Debian%20%7C%20Ubuntu%20%7C%20Fedora-blue?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/DanSanMar/zsh4me)
[![Shell Script](https://img.shields.io/badge/Shell-Bash%20%2F%20Zsh-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://github.com/DanSanMar/zsh4me)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

## ✨ Highlights

* 🚀 **Instalación Integral en 1-Clic:** Todo tu entorno listo (Zsh, Oh My Zsh, Starship, Ghostty, Tmux, FZF, Zoxide, Eza, Bat, Micro).
* 🎛️ **Menú Interactivo con `fzf`:** Interfaz visual fluida en la terminal para elegir exactamente qué módulo instalar o configurar.
* 🐧 **Soporte Multi-Distribución:** Detección automática del gestor de paquetes (`pacman`, `apt`, `dnf`).
* 📋 **Puente de Portapapeles Universal:** Sincronización perfecta entre Ghostty, Tmux, Micro y el portapapeles global de tu SO (X11 / Wayland).
* ⚙️ **Optimizador de Shell:** Panel TUI para activar/desactivar opciones de Zsh (`autocd`, `correct`, `sharehistory`, etc.).
* 🗂️ **Gestor de Backups Integrado:** Copias de seguridad automáticas con timestamp antes de modificar nada, con opción de previsualizar, editar con `micro` y restaurar.

---

## 📦 Herramientas e Integraciones

| Herramienta | Función |
| :--- | :--- |
| **Oh My Zsh** | Framework base con plugins (*autosuggestions*, *syntax-highlighting*, *completions*). |
| **Starship** | Prompt minimalista, hiperrápido y personalizable. |
| **Ghostty** | Tema *Catppuccin Mocha*, opacidad al 90% y JetBrainsMono Nerd Font. |
| **Tmux** | Navegación por ratón habilitada, atajos intuitivos (`Ctrl+a`) y soporte RGB. |
| **CLI Tools** | Sustitutos modernos: `eza` (*ls*), `bat` (*cat*), `zoxide` (*cd*) y `micro` (*editor*). |

---

## ⚡ Instalación Rápida

Solo necesitas clonar el repositorio y ejecutar el script en tu terminal favorita:

```bash
# 1. Clona el repositorio
git clone [https://github.com/DanSanMar/zsh4me.git](https://github.com/DanSanMar/zsh4me.git)

# 2. Entra al directorio
cd zsh4me

# 3. Dar permisos de ejecución e iniciar
chmod +x zsh4me.sh
./zsh4me.sh

> ⚠️ **Nota:** No ejecutes el script con `sudo ./zsh4me.sh`. El script solicitará permisos de superusuario cuando sea necesario para instalar paquetes.

## 🛠️ Opciones del Menú

```text
 0. ⚡ INSTALACIÓN COMPLETA   ➔ Despliega el entorno completo en un solo paso.
 1. 📦 PAQUETES DE SISTEMA    ➔ Instala CLI tools y la fuente JetBrainsMono Nerd Font.
 2. 🐚 OH MY ZSH              ➔ Instala OMZ y sus plugins más populares.
 3. ⚙️ OPCIONES SHELL         ➔ Consola de personalización gráfica para setopt/unsetopt.
 4. 👻 GHOSTTY                ➔ Genera la configuración gráfica optimizada para Ghostty.
 5. 🖥️ TMUX                   ➔ Configura .tmux.conf con soporte para ratón y portapapeles.
 6. 📋 PORTAPAPELES           ➔ Conecta Ghostty + Tmux + Micro con el portapapeles del SO.
 7. 📝 CONFIGURACIÓN .ZSHRC   ➔ Aplica alias modernos e integraciones preservando tus datos.
 8. 🔄 CAMBIAR SHELL          ➔ Cambia tu Shell por defecto a Zsh de forma segura.
 9. 🗂️ GESTOR DE BACKUPS      ➔ Revisa, edita o restaura respaldos anteriores.
