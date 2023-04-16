all: main

main : trolloprint_fast.o trolloprint_slow.o my_print.o
	gcc -no-pie my_print.o trolloprint_fast.o trolloprint_slow.o -o main

my_print.o : my_print.cpp
	gcc  -c my_print.cpp -o my_print.o
	
trolloprint_fast.o : trolloprint_fast.s 
	nasm -f elf64 -g trolloprint_fast.s -o trolloprint_fast.o

trolloprint_slow.o : trolloprint_slow.s 
	nasm -f elf64 -g trolloprint_slow.s -o trolloprint_slow.o

clear:
	rm -rf *.o main
