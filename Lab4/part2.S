        .data
chksm:  .asciz  "\nThe checksum is %08X\n"
	.align	2
prtst:  .asciz  "Enter text (ctrl-D to end): "
	.align	2
ans:    .asciz  "This checksum is correct because we're passing variables to functions\n"
	.align 	2
rptst:  .asciz  "%s\n"
        .align  2

buffer: .space  4096

        .text
        .global main
main:
        stmfd   sp!,{lr}

        @ int i(sp)=0;
        subs    sp,sp,#8        @ malloc
        mov     r0,#0
        str     r0,[sp]         @ i = 0
        @ this snippet makes sp+4 = 4095 and will remain constant inshallah
        mov     r0,#4096	@ ip = 4096
        sub     r0,r0,#1	@ ip = ip - 1
        str     r0,[sp,#4]      @ max = 4095

        @ printf
        ldr     r0,=prtst
        bl      printf

        @ do
while:
        bl      getchar         @ getchar
        ldr     r1,=buffer      @ get buffer
        ldr     r3,[sp]         @ move i(sp) into r3
        str     r0,[r1,r3]      @ store r0 into buffer(sp)

        cmp     r0,#-1          @ r0 == -1
        beq     end_loop        @ if equal, go to end_loop

        add     r3,r3,#1        @ i++
        str     r3,[sp]         @ store i
        ldr     ip,[sp,#4]
        cmp     r3,ip           @ i == 4095
        ble     while           @ if less than or equal, go to while

end_loop:
        mov     r2,#0           @ r2 = 0
        ldr     r3,[sp]
        str     r2,[r1,r3]      @ buffer[i] = r2

        @ print back message
        ldr     r0,=rptst
        ldr     r1,=buffer
        bl      printf

        
        @ printf("\nThe checksum is %08X\n",checksum(buffer));
        ldr     r0,=buffer
        bl      checksum
        mov     r1,r0
        ldr     r0,=chksm
        bl      printf
        @ printf("\nThe checksum is %08X\n",checksum(buffer));
        ldr     r0,=buffer
        bl      checksum
        mov     r1,r0
        ldr     r0,=chksm
        bl      printf

        ldr     r0,=ans
        bl      printf

        @ return 0;
        add     sp,sp,#8        @ free
        ldmfd	sp!,{lr}
        mov	    r0,#0
        mov	    pc,lr

@ expects buffer in r0
@ returns sum in r0
checksum:
        @ int i(sp) = 0;int sum(sp+4) = 0;
        subs    sp,sp,#8
        mov     r1,#0
        str     r1,[sp]         @ i(sp) = 0
        str     r1,[sp,#4]      @ sum(sp+4) = 0
sum_loop:
        ldr     r3,[sp]         @ r3 = i(sp)
        ldrb    r1,[r0,r3]      @ r1 = buff[i]
        cmp     r1,#0           @ r1 == 0
        beq     end_checksum    @ if: end_checksum

        ldr     r2,[sp,#4]      @ r2 = sum(sp+4)

        add     r3,r3,#1        @ i = i + 1
        str     r3,[sp]         @ store i

        add     r2,r2,r1        @ sum += buff[i]
        str     r2,[sp,#4]      @ store sum
        b       sum_loop

end_checksum:
        ldr     r0,[sp,#4]
        add     sp,sp,#8
        mov     pc,lr

        .end