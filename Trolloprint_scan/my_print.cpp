#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//-----------------------------------------------------------------------------------------------

extern "C" void _printtrl (const char *str, ...);       // use our function

//-----------------------------------------------------------------------------------------------

int main()
{
    int max_count = 10000;

    int i = 0;

    do
    {
        i++;
        /* code */
    
    
    _printtrl ("My line1: %s, %s and %c, %d, %o, %b, %x\n", 
               "Hello world?", "TROLLLLL", '!', -100500, 456, 25, 300);

    _printtrl ("My line2: %s, %s and %c, %d, %o, %b, %x\n", 
               "Hello world?", "TROLLLLL", '!', -100500, 456, 25, 300);

    for(int i = 0; i < 10; i++)
    {
        _printtrl ("6%c%d\n", '6', 6);
    }

    _printtrl ("1");
    _printtrl ("2");
    _printtrl ("3");
    _printtrl ("4");
    _printtrl ("5\n");

    } while ( i != max_count );
    
    return 0;
}

//-----------------------------------------------------------------------------------------------