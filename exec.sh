#!/bin/bash

set -e

[ $# -eq 0 ] && {
    if [ "$(hostname)" != vuldetector ]; then
        cd "$(dirname "$(realpath "$0")")" > /dev/null
        cp -r src/DataPrepare VulDetector/
        docker exec -it vuldetector bash
        cd - > /dev/null
    else
        echo Command ./exec.sh without args is only able to be executed outside the container vuldetector
    fi
    exit 0
}

[ "$(hostname)" != vuldetector ] && {
    cat << EOF
Please run your commands in vuldetector or execute the script below line by line:
$0
$0 $@
EOF
    exit 0
}

help_n_exit () {
    cat << EOF
Usage: $0 COMMAND

COMMANDS:
  cve|e        : Download CVEs' affected app listed in DATA/CVE_App.txt
  prepare|p    : Extract function codes and CFGs from a program.
  locate|l     : Locate the sensitive lines.
  wfg|w        : Generate WFGs from CFGs.
  compare|c    : Compute the similarity of two WFGs.

Example: $0 prepare help
EOF
    exit 0
}

################################################################################
################################################################################
################################################################################

prepare_data () {
    help_n_exit () {
        cat << EOF
Usage: $0 prepare [OPTION] [APP|VUL|PAT all|<Project>]

OPTIONS:
  --fun|-f     : Extract raw code for each function from sourcecode.
  --desc|-d    : Generate raw CFG description <ProjectDir>/tmp.log for a project.
  --cfg|-c     : Extract CFG description for each function from <ProjectDir>/tmp.log.
  --affected|-a: Only extract the affected functions listed from /code/DATA/CVE_Fun.txt.
                 Applied only when extracting APP/*.
                 VUL/* & PAT/* are always extracted the functions that related to their CVE

APP            : Extract data from a Software (/code/DATA/RAW/APP).
VUL            : Extract data from Vulnerable code (/code/DATA/RAW/VUL).
PAT            : Extract data from Patched code (/code/DATA/RAW/PAT).
all            : Process all projects in /code/DATA/RAW/{APP|VUL|PAT}.
<Project>      : Define a specific Software or Project (e.g., OpenSSL, CVE-2012-1165).

Example: $0 prepare -c -d -f APP OpenSSL \\
                                    VUL CVE-2012-1165 \\
                                    PAT all
EOF
        exit 0
    }

    local ExtractDesc=0
    local ExtractCfg=0
    local ExtractFun=0
    local AffectedOnly=0
    local Input=

    shift_args () {
        ShiftStep=$(($1+1))
        while [ $((ShiftStep--)) -gt 0 ]; do
            shift
        done
        get_args $@
    }

    get_args () {
        [ $# -eq 0 ] && return
        case $1 in
            --fun|-f)
                ExtractFun=1
                shift_args 1 $@
                ;;
            --desc|-d)
                ExtractDesc=1
                shift_args 1 $@
                ;;
            --cfg|-c)
                ExtractCfg=1
                shift_args 1 $@
                ;;
            --affected|-a)
                AffectedOnly=1
                shift_args 1 $@
                ;;
            APP|VUL|PAT)
                [ $# -lt 2 ] && help_n_exit
                local Dir=/code/DATA/RAW/$1
                if [ "$2" == all ]; then
                    local SubDir
                    for SubDir in $(ls -d $Dir/*); do
                        Input="$Input $SubDir"
                    done
                else
                    Input="$Input $Dir/$2"
                fi
                shift_args 2 $@
                ;;
            *)
                help_n_exit
                ;;
        esac
    }

    get_args $@
    [ $(($ExtractDesc|$ExtractCfg|$ExtractFun)) -eq 0 ] && help_n_exit
    [ "$Input" == "" ] && help_n_exit
    python /code/VulDetector/DataPrepare/batch_process.py $ExtractDesc $ExtractCfg $ExtractFun $AffectedOnly $Input
}

################################################################################
################################################################################
################################################################################

download_cve () {
    local BaseDir='/code/DATA/RAW'
    local Line
    while IFS= read -r Line; do
        [[ "$Line" == '#'* ]] && continue
        local Software=$(echo $Line | cut -d\  -f1)
        local Ver=$(echo $Line | cut -d\  -f2)
        local Type=$(echo $Line | cut -d\  -f3)
        local Dir=$(echo $Line | cut -d\  -f4)
        local Dest="$BaseDir/$Type/$Dir/$Software-$Ver"
        if [ -d "$Dest" ] && [ -z "$(find "$Dest" -maxdepth 0 -empty)" ]; then
            echo Already Existed: $BaseDir/$Type/$Dir/$Software-$Ver
        else
            /code/src/tools/fetch_software.sh $Line
        fi
    done < /code/DATA/CVE_App.txt
}

################################################################################
################################################################################
################################################################################

case $1 in
    cve|e)
        shift
        download_cve
        ;;
    prepare|p)
        shift
        prepare_data $@
        ;;
    *)
        help_n_exit
        ;;
esac
