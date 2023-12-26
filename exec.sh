#!/bin/bash

set -e

[ $# -eq 0 ] && {
    docker exec -it vuldetector bash
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
Usage: $0 [COMMAND]

COMMANDS:
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



################################################################################
################################################################################
################################################################################

case $1 in
    prepare|p)
        shift
        prepate_data $@
        ;;
    *)
        help_n_exit
        ;;
esac
