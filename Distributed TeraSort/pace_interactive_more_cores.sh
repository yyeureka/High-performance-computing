#!/bin/sh
qsub -I -q coc-ice-multi -l nodes=1:ppn=4:core24+1:ppn=4:core24,walltime=30:00 -N lab3_chapel_interactive
exit 0
