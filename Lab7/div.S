        .data
instr:  .asciz  "Input natrual num: "
        .align  2
outstr: .asciz  "%d is prime\n"
        .align  2
input:  .asciz  "%d"
        .align  2

n:      .word   0

        .text
        .globl  main
main:
        stmfd   sp!,{lr}

        sub     sp,sp,#4

        @printf
        ldr     r0,=instr
        bl      printf

        @scanf("%d\0",&m)
        ldr     r0,=input
        ldr     r1,=n
        bl      scanf

        mov     r0,#0
        str     r0,[sp]

loop:
        ldr     r0,[sp]
        ldr     r2,=n
        ldr     r2,[r2]
        cmp     r2,r0
        beq     end

        add     r0,r0,#1
        str     r0,[sp]
        bl      isprime

        cmp     r0,#0           @ if isprime is false, go back to loop
        beq     loop

        ldr     r0,=outstr      @ otherwise, print and loop again
        ldr     r1,[sp]
        bl      printf
        b       loop

@ return 0 (r0)
end:
        add     sp,sp,#4
        mov     r0,#0
        ldmfd   sp!,{lr}
        bx      lr

@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ isprime(x)
isprime:
        push    {lr}
        mov     r1,#0
        mov     r6,#0           @ iteration in r6
        mov     r5,r0           @ store x in r5

        cmp     r0,#1
        beq     ret_isprime

        cmp     r0,#2
        beq     ret_isprime

        mov     r6,#2           @ start iteration=2

prime_loop:
        mov     r0,r5           @ load x into r0
        mov     r1,r6           @ loat iterator into r1
        bl      divide          @ r0=q,r1=remainder

        cmp     r1,#0           @ compare remainder for no remainder
        beq     ret_notprime  

        add     r6,r6,#1        @ increment iteration

        cmp     r6,r5
        beq     ret_isprime     @ if iteration==x, then prime

        b       prime_loop      @ o/w, keep testing

@ returns 0 if false, 1 if true
ret_notprime:
        mov     r0,#0
        pop     {pc}
        bx      lr

ret_isprime:
        mov     r0,#1
        pop     {pc}
        bx      lr

@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ divide(x,y)
@ r0=x
@ r1=y
divide:
        mov     r3,#0
div_loop:
        sub     r0,r0,r1
        add     r3,r3,#1
        cmp     r0,r1
        bpl     div_loop

@ returns quotient (r0) and remainder(r1)
        mov     r1,r0           @ remainder
        mov     r0,r3           @ quotient

        bx      lr

.end