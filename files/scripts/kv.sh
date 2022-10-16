#!/usr/bin/env bash
STORE="$HOME/.kv.enc.yml"
NAME=$(basename ${0:-kv})
SUBCOMMAND=${1:-help}
shift
case $SUBCOMMAND in
  edit|e)
    sops "$STORE"
    ;;

  list|ls)
    grep -ohE '^\S+:' "$STORE" | grep -vE '^sops:' | cut -d":" -f1 | sort
    ;;

  get|g)
    if (( $# < 1 )); then
      echo "usage: ${NAME} get [key]"
    else
      sops --decrypt --extract "[\"$1\"]" "$STORE"
    fi
    ;;

  put|set|p|s)
    if (( $# < 2 )); then
      echo "usage: ${NAME} put [key] [value]"
    elif [ "$1" = "sops" ]; then
      echo "sops is a reserved key"
    else
      sops --set "[\"$1\"] \"$2\"" "$STORE"
    fi
    ;;

  *)
    echo "usage: ${NAME} (edit|list|get|put)"
esac
