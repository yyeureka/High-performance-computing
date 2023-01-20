#include <stdio.h>
#include <cstring>

/*
    PROMPT
    This exercise should:
    1. You may modify the string
    2. You may *not* modify the declaration of a.
    2. Pass Valgrind
*/

int main(){
	char a[10];
	strcpy(a, "blueberry"); 
	printf("%s\n", a);

	return 0;
}