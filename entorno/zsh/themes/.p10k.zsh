# ~/.p10k.zsh - Estilos
typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%F{213}┌─%f'
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{213}└▶%f '

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs context status command_execution_time)
# Sin Promp a la derecha:
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

typeset -g POWERLEVEL9K_MODE='nerdfont-complete'
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=213
typeset -g POWERLEVEL9K_DIR_FOREGROUND=218
typeset -g POWERLEVEL9K_DIR_BACKGROUND=235
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=82
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=214
typeset -g POWERLEVEL9K_TIME_FOREGROUND=180
typeset -g POWERLEVEL9K_TIME_BACKGROUND=235
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='💗'

typeset -g POWERLEVEL9K_PROMPT_CHAR_FOREGROUND=213
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIVIS_FOREGROUND=213
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_FOREGROUND=160
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='❯'
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''


# Estilo visible para usuario normal
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n'
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND=0      # negro
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND=186    # amarillo pastel



# === Contexto (usuario) bien visible ===
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_SHOW_ALWAYS=true

# Estilo de root
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=15        # blanco
typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=160       # rojo

# Estilo de usuario normal
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND=0      # negro
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND=186    # amarillo pastel



# === Segmentos del prompt ===
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  os_icon
  dir
  vcs
  context
  status
  command_execution_time
)

# === Mostrar siempre el usuario (sin hostname) ===
typeset -g POWERLEVEL9K_CONTEXT_SHOW_ALWAYS=true
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n'

# === Colores usuario normal ===
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND=0
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND=186

# === Colores root ===
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=15
typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=160

# === Emoji de advertencia si eres root ===
typeset -g POWERLEVEL9K_CONTEXT_ROOT_CONTENT_EXPANSION='⚠️  %n'


[[ ! -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] || 
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

