#!/usr/bin/env bash

LOCATION=$(echo -e "Local\nRemote" | dmenu -i -p "Server type")

openlocal() {
    FINDCMD=$(find ~ -maxdepth 5 -type d -not -path "$HOME/.cache/*" |  grep -P '^\/\w+\/\w+\/(\.config|[^.]\w+)(?!.*\.git)')
    OPTION=$(printf "$FINDCMD" | dmenu -i -p "Path")

    neovide "$OPTION"
}

openremote() {
    HOSTS=$(grep -oP '(?<=Host\s)\w+(\W*\w+)?$' "$HOME/.ssh/config")
    HOST=$(printf "$HOSTS" | dmenu -i -p "Host")
    PORT=$(ssh "$HOST" -t ss -tulpn | grep -oP '(?<=\d:)\d{2,5}(?=.*nvim)')

    ssh -C -L "$PORT:127.0.0.1:$PORT" "$HOST" -N &

    PROC="$(ps ax | grep -oP "^\s\d+(?=.*ssh.*$HOST)" | head -1)"
    sleep 5
    neovide --server "127.0.0.1:$PORT" ; kill $(ps ax | grep -oP "^\s\d+(?=.*ssh.*$HOST)" | head -1)
}

case $LOCATION in
    "Local") openlocal;;
    "Remote") openremote;;
    *) exit 0 ;;
esac
