        .data
chksm:  .asciz  "\nThe checksum is %08X\n"
	.align	2
prtst:  .asciz  "Enter text (ctrl-D to end): "
	.align	2
ans:    .asciz  "This checksum is wrong because we're performing check-ception on global vars"
	.align 	2
rptst:  .asciz  "%s\n"
        .align  2
@ maybe want to read this: https://azeria-labs.com/memory-instructions-load-and-store-part-4/
buffer: .space  4096
i:      .word   0
sum:    .word   0

        .text
        .global main
main:
        stmfd   sp!,{lr}

        @ printf
        ldr     r0,=prtst
        bl      printf

        @ do
	@ this snippet makes r5 = 4095 and will remain constant inshallah
	mov	r5,#4096	@ r5 = 4096
	sub	r5,r5,#1	@ r5 = r5 - 1

loop:
        @ buffer[i]=getchar();
        bl      getchar		@ call getchar
        ldr     r1,=i		@ load address of i into r1
        ldr     r1,[r1]		@ load value of r1 into i
        ldr     r2,=buffer	@ load address of buffer into r2
        str     r0,[r2,r1]	@ store contents of r0 into buffer+i

        @ while(buffer[i]!=-1)
        cmp     r0,#-1		@ compare contents of r0 to ctrl+D command
        beq     endloop		@ if r0=-1, end our loop

        @ while(++i < 4095)
        ldr     r3,=i		@ load address of i into *r3
        ldr     r4,[r3]		@ load contents of *r3 into r4
        add     r4,r4,#1	@ r4 = r4 + 1
	strb	r4,[r3]		@ store r4 into &r3
        cmp     r4,r5		@ compare r4=r5
        bgt     endloop		@ if r4>r5, break loop
        @ while
        b       loop		@ if we didn't break out of the loop, return to loop
endloop:
        @ buffer[i] = 0
        ldr     r0,=buffer	@ load buffer address to *r0
        mov     r1,#0		@ load r1 with 0
        str     r1,[r0,r4]	@ store 0 at the current location of buffer[i]

        @ printf
        ldr     r0,=rptst	@ load readback string
        ldr     r1,=buffer	@ load buffer
        bl      printf		@ printf("%s\n",buffer)

	@ printf("\nThe checksum is %08X\n",checksum(buffer));
        ldr     r0,=buffer
        bl      checksum
        ldr     r1,=sum
        ldr     r0,=chksm
        bl      printf
	@ printf("\nThe checksum is %08X\n",checksum(buffer));
        ldr     r0,=buffer
        bl      checksum
        ldr     r1,=sum
        ldr     r0,=chksm
        bl      printf

	@ return 0;
	ldmfd	sp!,{lr}
	mov	r0,#0
	mov	pc,lr

@ checksum expects buffer in r0, returns sum in r0
checksum:
	@ int checksum(char buffer[])
        @ i = 0
        mov     r1,#0		@ load 0 into r1
        ldr     r2,=i		@ load address of i into *r2
        str     r1,[r2]		@ store to location of *r2 the val of r1
chkloop:
        @ buffer[i] != 0	# buffer address should be in r0
        ldr     r2,=i		@ load i address to r2
        ldr     r2,[r2]		@ r2 = &r2
        add     r5,r0,r2        @ get address for buff[r2]
        ldrb    r1,[r5]   	@ r1 = buff[r2]
        cmp     r1,#0		@ r1 == 0
        beq     loopend		@ if(^) end loop

        @  sum += buffer[i++]
        ldr     r3,=sum         @ r3 = &sum
        ldr     r4,[r3]         @ r4 = *r3
        add     r4,r4,r1        @ sum = sum+buff[r2]
        str     r4,[r3]         @ store result of r4 to sum
        add     r2,r2,#1
        ldr     r1,=i
        str     r2,[r1]
        b       chkloop
loopend:

	@ return
	bx lr

	.end