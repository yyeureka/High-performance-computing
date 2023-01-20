###
# Makefile
# JR Smith
# Georgia Institute of Technology
# (C) 2021
###


# ======================================================================
#                       GLOBAL
# ======================================================================

SHELL=/bin/bash
CC=gcc
CFLAGS=-Iutils -g -O0 -std=gnu99
LDFLAGS=-lm

CPP=g++
CPPFLAGS=-std=c++11 -ggdb3

default: all

clean:
	rm -f *~ core mm *.o student/*.o utils/*.o bin/valgrind* bin/core*

all: mm valgrind valgrind_answers

# ======================================================================
#                       MATRIX MULTIPLY
# ======================================================================

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

mm: student/mm.o utils/mm_utils.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# ======================================================================
#                       VALGRIND EXERCISES
# ======================================================================

valgrind: \
	valgrind_prep_work \
	valgrind1 \
	valgrind2 \
	valgrind3 \
	valgrind4 \
	valgrind5 \
	valgrind6

valgrind_prep_work:
	mkdir -p bin

valgrind1:
	$(CPP) $(CPPFLAGS) -o bin/valgrind1 student/valgrind1.cpp

valgrind2:
	$(CPP) $(CPPFLAGS) -o bin/valgrind2 student/valgrind2.cpp

valgrind3:
	$(CPP) $(CPPFLAGS) -o bin/valgrind3 student/valgrind3.cpp

valgrind4:
	$(CPP) $(CPPFLAGS) -o bin/valgrind4 student/valgrind4.cpp

valgrind5:
	$(CPP) $(CPPFLAGS) -o bin/valgrind5 student/valgrind5.cpp

valgrind6:
	$(CPP) $(CPPFLAGS) -o bin/valgrind6 student/valgrind6.cpp

valgrind_answers: \
	valgrind_answer1 \
	valgrind_answer2 \
	valgrind_answer3 \
	valgrind_answer4 \
	valgrind_answer5 \
	valgrind_answer6

valgrind_answer1:
	if [ -d "./solution" ]; then \
		$(CPP) $(CPPFLAGS) -o bin/valgrind_answer1 solution/valgrind/answers1.cpp; \
	fi;

valgrind_answer2:
	if [ -d "./solution" ]; then \
		$(CPP) $(CPPFLAGS) -o bin/valgrind_answer2 solution/valgrind/answers2.cpp; \
	fi;

valgrind_answer3:
	if [ -d "./solution" ]; then \
		$(CPP) $(CPPFLAGS) -o bin/valgrind_answer3 solution/valgrind/answers3.cpp; \
	fi;

valgrind_answer4:
	if [ -d "./solution" ]; then \
		$(CPP) $(CPPFLAGS) -o bin/valgrind_answer4 solution/valgrind/answers4.cpp; \
	fi;

valgrind_answer5:
	if [ -d "./solution" ]; then \
		$(CPP) $(CPPFLAGS) -o bin/valgrind_answer5 solution/valgrind/answers5.cpp; \
	fi;

valgrind_answer6:
	if [ -d "./solution" ]; then \
		$(CPP) $(CPPFLAGS) -o bin/valgrind_answer6 solution/valgrind/answers6.cpp; \
	fi;

