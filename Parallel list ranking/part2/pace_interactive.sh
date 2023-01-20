#!/bin/sh
qsub -I -q coc-ice-gpu -l nodes=1:ppn=8:core24:gpus=1 -N lab1_gpu_interactive
exit 0
