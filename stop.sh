#!/bin/sh

set -e

cd "$(dirname "$(realpath "$0")")"
docker-compose down
