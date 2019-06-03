#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern void initializeByRows(int ** array, int row_count, int column_count);

extern void initializeByColumns(int ** array, int row_count, int column_count);

void printArray(int ** array)
{
    for (int i = 0; i < 30; ++i)
    {
        for (int j = 0; j < 30; ++j)
            printf("%i ", array[i][j]);
        printf("\n");
    }
}

void setArray(int ** array)
{
    for (int i = 0; i < 30; ++i)
    {
        for (int j = 0; j < 30; ++j)
            array[i][j] = 1;
    }
}

int main()
{
    int ** array;
    array = malloc(30 * sizeof(int *));
    for (int i = 0; i < 30; ++i)
        array[i] = malloc(30 * sizeof(int));

    setArray(array);
    long start = clock();
    initializeByRows(array, 30, 30);
    printf("Czas wykonania: %f ms\n", ((double) clock() - start) / CLOCKS_PER_SEC);
    printArray(array);

    printf("\n");

    setArray(array);
    start = clock();
    initializeByColumns(array, 30, 30);
    printf("Czas wykonania: %f ms\n", ((double) clock() - start) / CLOCKS_PER_SEC);
    printArray(array);

    for (int i = 0; i < 4; ++i)
        free(array[i]);
    free(array);
    return 0;
}