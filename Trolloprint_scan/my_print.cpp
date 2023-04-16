#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

//-----------------------------------------------------------------------------------------------

#define PROLOGUE                           \
    clock_t time_o = 0;                    \
    clock_t time_c = 0;                    \
                                           \
    time_o = clock ();

#define EPILOGUE                                                 \
    time_c = clock ();                                           \
                                                                 \
    double time = ((double) (time_c - time_o)) / CLOCKS_PER_SEC; \

//-----------------------------------------------------------------------------------------------

extern "C" void _printtrl_fast (const char *str, ...);       // use our function

extern "C" void _printtrl_slow (const char *str, ...);       // use our function

//-----------------------------------------------------------------------------------------------

void draw_graph (void (*funct) (const char *str, ...), FILE *file, char *main_line);

//-----------------------------------------------------------------------------------------------

int main()
{
    char main_line[10002] = "";

    for(int i = 0; i < 10000; i++)
    {
        main_line[i] = '_';
    }

    FILE *graph = fopen ("graph.py", "w+");

    fprintf (graph, "import matplotlib as mpl\n"
                    "import matplotlib.pyplot as plt\n"
                    "import numpy as np\n\n"
                    "plt.axis ([0, 1010000, 0, 0.0226])\n\n");

    draw_graph (_printtrl_slow, graph, main_line);

    draw_graph (_printtrl_fast, graph, main_line);

    fclose (graph);

    //-----------------------------------------------------------------------------------------------

    /*
    _printtrl ("\n%s\n", "1: Hello world!");
    _printtrl ("2: %s, %s finish;\n", "Hello world!", "Bye world!");
    _printtrl ("2: %s, %s finish;\n", "Hello world!", "Bye world!");

    _printtrl ("My line1: %s, %s and %c %c, |%d and %d|, %o, %b, %x, %u\n", 
               "Hello world?", "TROLLLLL", '!', '!', 100500, -100500, 456, 25, 300, 123456789);

    char main_line1[] = "123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789";
    
    _printtrl ("%s\n", main_line1);

    _printtrl ("%b, %b, %b, %b, %b, %b, %b\n", 1, 10, 25, 8, 24, 500, 10000);
    _printtrl ("%o, %o, %o, %o, %o, %o, %o\n", 1, 10, 25, 8, 24, 500, 10000);
    _printtrl ("%x, %x, %x, %x, %x, %x, %x\n", 1, 10, 25, 8, 24, 500, 10000);
    _printtrl ("%d, %d, %d, %d, %d, %d, %d\n", -10044232, 0, 5, -66666666, 545, 500, 10000);
    _printtrl ("%u, %u, %u, %u, %u, %u, %u\n", 10044232, 0, 5, 66666666, 545, 500, 10000);
    */    

    return 0;
}

//-----------------------------------------------------------------------------------------------

void draw_graph (void (*funct) (const char *str, ...), FILE *file, char *main_line)
{
    fprintf (file, "plt.plot ([");

    for(int i = 100000; i < 1000000; i+=100000)
    {
        fprintf (file, "%d, ", i);
    }

    fprintf (file, "], [");

    for(int size = 10; size < 100; size+=10)
    {
        PROLOGUE;

        for(int i = 0; i < size; i++)
        {
            funct ("%s", main_line);
        }

        EPILOGUE;

        fprintf (file, "%lg, ", time);
    }

    fprintf (file, "])\n\n");
}

//-----------------------------------------------------------------------------------------------