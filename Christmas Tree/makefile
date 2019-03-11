all: main.s
	as --32 main.s -o main.o
	ld main.o -m elf_i386 -o main
clean:
	rm -f *.o main
