#include <stdio.h>

extern float my_sin(float arg);

int main()
{
    float arg = my_sin(0.42f);
    printf("%f\n", (double)arg);
    return 0;
}