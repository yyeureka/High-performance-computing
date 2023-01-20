#include <stdlib.h>
#include <stdio.h>

/*
    PROMPT
    This exercise should:
    1. Print 100 10 times on a new line each
    2. Pass Valgrind
    3. You may *not* modify the contents of the for loop.
*/
 
int main() { 
	int size = 10;
    int* p = (int*)malloc(sizeof(int) * size); 
    
    for (int i = 0; i < size; i++) {
        p[i] = 100;
        printf("%d\n", p[i]);

        // DO NOT DELETE THIS IF STATEMENT
    	// POINTS WILL BE DEDUCTED IF YOU DO
    	if (p[i] != 100){
    		exit(1);
    	}
    }

    free(p);
}