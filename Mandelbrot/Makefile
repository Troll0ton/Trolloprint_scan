compile: main.cpp
	g++ -c -Ofast -mavx -mavx512dq main.cpp NIcePaint.cpp
	g++ main.o NIcePaint.o -o app -lsfml-graphics -lsfml-window -lsfml-system

run:
	./app