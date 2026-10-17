# theme.zsh — integra el selector de temas (~/.local/bin/theme) con zsh
# Lo sourcea load.zsh. El script genera los colores; aquí se cargan en la shell
# actual (fzf, icono del prompt, starship y fastfetch) sin tener que reabrirla.

_THEME_ENV="${XDG_STATE_HOME:-$HOME/.local/state}/theme/env.zsh"

# Carga el tema activo al arrancar (si nunca se eligió uno, queda Neon Fuchsia)
[[ -f "$_THEME_ENV" ]] && source "$_THEME_ENV"

# Wrapper: ejecuta el script y recarga las variables en esta misma shell
theme() {
  command theme "$@" || return
  [[ -f "$_THEME_ENV" ]] && source "$_THEME_ENV"
  return 0
}

# Autocompletado: subcomandos + nombres de tema
_theme_complete() {
  local -a subcmds names
  subcmds=(list current preview random reset set help)
  names=(${(f)"$(command theme names 2>/dev/null)"})
  if (( CURRENT == 2 )); then
    compadd -a names subcmds
  elif [[ ${words[2]} == (set|preview) ]]; then
    compadd -a names
  fi
}
(( $+functions[compdef] )) && compdef _theme_complete theme
