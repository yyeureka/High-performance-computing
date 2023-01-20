#include <stdlib.h> 

/*
    PROMPT
    This exercise should:
    1. You may *not* delete or modify the malloc line.
    2. Pass Valgrind
*/

int main() { 
    int* ptr = (int*)malloc(sizeof(int));
    free(ptr);

    return 0;
} 