# Bell Labs — print the banner once per interactive shell.
# Source from ~/.bashrc or ~/.zshrc:  . /path/to/bell-labs/extras/motd.sh
if [[ $- == *i* && -z ${BELL_LABS_MOTD_SHOWN:-} ]]; then
  export BELL_LABS_MOTD_SHOWN=1
  printf '\e[1;34m'
  cat "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/motd.txt"
  printf '\e[0m\n'
fi
