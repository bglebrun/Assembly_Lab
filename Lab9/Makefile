
C_OBJECTS = makegray.o  netpbm.o
ASM_OBJECTS = colortogray.o

makegray: $(C_OBJECTS) $(ASM_OBJECTS)
	gcc -g -o makegray $(C_OBJECTS) $(ASM_OBJECTS)

.c.o:
	gcc -I. -g -c $<

.S.o:
	gcc -I. -g -c -mcpu=cortex-a7 -mfpu=neon-vfpv4 $< 

clean:
	rm -f *.o makegray *~ *.pgm

