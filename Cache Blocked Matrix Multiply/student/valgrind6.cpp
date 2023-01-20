#include <stdio.h>
#include <stdlib.h>
  
/*
    PROMPT
    This exercise should:
    1. Print 0-9 on a new line each
    2. Pass Valgrind
    3. Modify the buffer with pointer arithmetic (i.e. not [])
*/

void fubar(void* buffer, int count) { 
    int* local_buffer = (int*)buffer;

    for(int i = 0; i < count; i++){
        *local_buffer = i;
        printf("%d\n", *local_buffer);
        local_buffer++;
    }
} 
  
int main() {
    int count = 10;
    int* buffer = (int*)malloc(sizeof(int) * count);
    
    fubar((void*)buffer, count);
    free(buffer);

    return 0; 
}