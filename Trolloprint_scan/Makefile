all: project

project : trolloprint.o my_print.o
	gcc -no-pie my_print.o trolloprint.o -o main

my_print.o : my_print.cpp
	gcc  -c my_print.cpp -o my_print.o
	
trolloprint.o : trolloprint.s 
	nasm -f elf64 -g trolloprint.s -o trolloprint.o

clear:
	rm -rf *.o main
