#!/bin/sh

set -e

cd "$(dirname "$(realpath "$0")")"
docker build --rm -t vuldetector .
