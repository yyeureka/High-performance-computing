#include <stdlib.h>
#include <stdio.h>

/*
    PROMPT
    This exercise should:
    1. Only modify the p variable using increments
    2. Not modify the a variable directly
    2. Pass Valgrind
*/
  
int main() { 
    int a = 10; 
    int* p = &a; 
  
    (*p)++;
    printf("Value: %d\n", a);

    // DO NOT MODIFY ANYTHING BELOW THIS COMMENT
    // YOU WILL LOSE POINTS IF YOU DO
    if(a != 11){
    	int* force_error = (int*)malloc(sizeof(int) * 10);
    }

    return 0;
}
