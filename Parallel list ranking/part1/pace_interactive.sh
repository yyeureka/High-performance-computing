#!/bin/sh
qsub -I -q coc-ice -l nodes=1:ppn=16:core24 -N lab1_openmp_interactive
exit 0
