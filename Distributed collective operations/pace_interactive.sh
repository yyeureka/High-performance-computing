#!/bin/sh
qsub -I -q coc-ice-multi -l nodes=1:ppn=2:core24+1:ppn=2:core24+1:ppn=2:core24+1:ppn=2:core24,walltime=00:15:00 -N lab2_mpi_interactive
exit 0
