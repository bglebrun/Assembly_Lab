
ASM_OBJECTS = float_test.o

float_test: $(ASM_OBJECTS)
	gcc -g -o float_test $(ASM_OBJECTS)

.c.o:
	gcc -I. -g -c $<

.S.o:
	gcc -I. -g -c $< 

clean:
	rm -f *.o float_test *~ *.pgm

