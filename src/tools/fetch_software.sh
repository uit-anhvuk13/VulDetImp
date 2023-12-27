#!/bin/bash

set -e

help_n_exit () {
    cat << EOF
Usage: $0 [<software> <Version> APP|VUL|PAT <SoftwareDir>]

APP            : Download software into /code/DATA/RAW/APP/<SofwareDir>
VUL            : Download software into /code/DATA/RAW/VUL/<SoftwareDir>
PAT            : Download software into /code/DATA/RAW/PAT/<SoftwareDir>

Example: $0 openssl 1.0.0 APP OpenSSL \\
                             openssl 3.2.0 APP OpenSSL \\
                             openssl 1.0.1-beta2 PAT CVE-2012-1165 \\
                             openssl 0.9.8s VUL CVE-2012-1165
EOF
    exit 0
}

[ $# -lt 2 ] && help_n_exit

shift_args () {
    local ShiftStep=$(($1+1))
    while [ $((ShiftStep--)) -gt 0 ]; do
        shift
    done
    get_args $@
}

OutputDir=/code/DATA/RAW

download_file () {
    mkdir -p "$1" && cd "$1" > /dev/null
    wget "$2/$3"
    tar -xf "$3"
    rm "$3"
    cd - > /dev/null
}

get_args () {
    [ $# -eq 0 ] && return
    [ $# -lt 4 ] && help_n_exit
    [ "$3" != "APP" ] && [ "$3" != "VUL" ] && [ "$3" != "PAT" ] && help_n_exit
    local Dest="$OutputDir/$3/$4"
    case $1 in
        openssl)
            FetchUrl='https://ftp.openssl.org/source'
            Ver="$1-$2.tar.gz"
            if [ "$(curl "$FetchUrl/" 2> /dev/null | grep -o 'href="openssl.*\([0-9]*\.\)*[0-9].*\"' | sed 's/href=\|"//g' | grep $Ver)" != '' ]; then
                download_file $Dest $FetchUrl $Ver
            else
                FetchUrl="$FetchUrl/old"
                VerDir=$(case $2 in
                            0.*)
                                echo 0.9.x
                                ;;
                            3.*)
                                echo $2 | grep -o '[0-9]*\.[0-9]*' | head -n 1
                                ;;
                            *)
                                echo $2 | sed 's/[a-zA-Z\_\-]//'
                                ;;
                        esac)
                FetchUrl="$FetchUrl/$VerDir"
                if [ "$(curl "$FetchUrl/" 2> /dev/null | grep -o 'href="openssl.*\([0-9]*\.\)*[0-9].*\"' | sed 's/href=\|"//g' | grep $Ver)" != '' ]; then
                    download_file $Dest $FetchUrl $Ver
                else
                    echo $FetchUrl/$Ver not found
                fi
            fi
            shift_args 4 $@
            ;;
        *)
            help_n_exit
            ;;
    esac
}

get_args $@
