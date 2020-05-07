
C_OBJECTS = Lab8.c
ASM_OBJECTS = calc_eqn.o divide.o

calc_eqn: $(C_OBJECTS) $(ASM_OBJECTS)
	gcc -g -o calc_eqn $(C_OBJECTS) $(ASM_OBJECTS)

.c.o:
	gcc -I. -g -c $<

.S.o:
	gcc -I. -g -c $< 

clean:
	rm -f *.o calc_eqn *~ *.pgm

