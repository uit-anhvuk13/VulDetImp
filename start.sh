#!/bin/sh

set -e

Dir="$(dirname "$(realpath "$0")")"
cd "$Dir"
StrDir="$(echo "$Dir" | sed 's/\//\\\//g')"
sed -i "s/-\s*[a-zA-Z_\/]*:\/code/- ${StrDir}:\/code/" docker-compose.yml
docker-compose up -d $@
