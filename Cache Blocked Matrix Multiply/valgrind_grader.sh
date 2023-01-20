#!/bin/bash

###
# valgrind_grader.sh
# JR Smith
# Georgia Institute of Technology
# (C) 2021
###

function run_valgrind_check () {
	program=$1
	count=$2
	test_name=$3

	valgrind --leak-check=full \
			 --error-exitcode=1 \
			 --tool=memcheck \
			 --track-origins=yes \
			 --errors-for-leak-kinds=definite \
			 --show-leak-kinds=definite \
			 $program \
			 > temp.txt 2>&1
	grep -q "ERROR SUMMARY: 0 errors" temp.txt

	ret=$?

	if [ $ret == 0 ]; then
		echo "${test_name}: 1"
		count="$(($count+1))"
	else
		echo "${test_name}: 0"
	fi

	return "$(($count))"
}

passing_count=0
total_count=0

# Run Exercise One
run_valgrind_check ./bin/valgrind1 passing_count "Exercise One"
passing_count=$?
total_count=$((total_count + 1))

# Run Exercise Two
run_valgrind_check ./bin/valgrind2 passing_count "Exercise Two"
passing_count=$?
total_count=$((total_count + 1))

# Run Exercise Three
run_valgrind_check ./bin/valgrind3 passing_count "Exercise Three"
passing_count=$?
total_count=$((total_count + 1))

# Run Exercise Four
run_valgrind_check ./bin/valgrind4 passing_count "Exercise Four"
passing_count=$?
total_count=$((total_count + 1))

# Run Exercise Five
run_valgrind_check ./bin/valgrind5 passing_count "Exercise Five"
passing_count=$?
total_count=$((total_count + 1))

# Run Exercise Six
run_valgrind_check ./bin/valgrind6 passing_count "Exercise Six"
passing_count=$?
total_count=$((total_count + 1))

echo "Total: ${passing_count} / ${total_count}"