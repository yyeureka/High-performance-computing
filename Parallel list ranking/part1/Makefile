CC = gcc
CFLAGS = -Iutils -O0 -g -fopenmp -std=gnu99
LDFLAGS = -lm

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

ifeq ($(strip $(IMPL)), )
 IMPL=wyllie
endif

correctness: utils/correctness.o student/listrank_$(IMPL).o utils/listutils.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

metrics: utils/metrics.o student/listrank_$(IMPL).o utils/listutils.o utils/timer.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f *~ core correctness metrics *.o student/*.o utils/*.o
