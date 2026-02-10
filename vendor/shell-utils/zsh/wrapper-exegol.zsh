# Ejecuta comandos en Exegol (imagen free) y filtra solo el banner de Exegol
ex() {
  exegol exec -v free -- "$@" 2>&1 | sed -E '
    /Exegol Community is currently in version/d
    /More about Exegol at:/d
    /Executing command on Exegol/d
    /Command received:/d
    /End of the command/d
  '
}

# Modo debug (sin filtrar)
exv() {
  exegol exec -v free -- "$@"
}
