CHAPEL = chpl
CHPL_TERASORT_MAIN_MODULE= --main-module terasort
MPICC = mpicc
MPICFLAGS = -std=c99 -fopenmp
MPICOPTFLAGS = -Iutils -O0 -g -Wall
MPILDFLAGS =

all: teragen terasort teravalidate terametrics

teragen: utils/teragen_main.c utils/terarec.c
	$(MPICC) $(MPICFLAGS) $(MPICOPTFLAGS) -o $@ $^ $(MPILDFLAGS)

terasort: student/terasort.chpl utils/terasort_main.chpl utils/terarec.chpl utils/qsort.chpl
	$(CHAPEL) --fast --no-local --no-cache-remote -o $@ $^ 

teravalidate: utils/teravalidate_main.c utils/teravalidate.c utils/terarec.c
	$(MPICC) $(MPICFLAGS) $(MPICOPTFLAGS) -o $@ $^ $(MPILDFLAGS)
	
terametrics: student/terasort.chpl utils/terametrics.chpl utils/terarec.chpl utils/qsort.chpl
	$(CHAPEL) --fast --no-local --no-cache-remote -o $@ $^

.PHONY: clean

clean:
	rm -f *.o teragen terasort terasort_real teravalidate terametrics terametrics_real data.dat
