# =========================
# Aliases builtin (cross-platform)
# =========================

# Disk / memory
if command -v df >/dev/null 2>&1; then
  alias diskspace='df -h'
fi

if command -v free >/dev/null 2>&1; then
  alias mem='free -h --si'
else
  alias mem='top -l 1 -s 0 | grep PhysMem'
fi

# Espacio usado por carpetas (función, no alias)
freespace() {
  du -sh -- * 2>/dev/null | sort -h
}

# CPU load (función robusta en zsh)
cpuload() {
  uptime | awk '{print "Carga:", $(NF-2), $(NF-1), $NF}'
}

# Files / search
alias findtxt='find . -type f -name "*.txt"'
alias grepip="grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'"
alias greppass="grep -i 'password'"

# Archives
alias untar='tar -xvf'
alias unzipdir='unzip -d ./extracted/'
alias wgetr='wget --continue'

# Safety
alias rm='rm -i'

