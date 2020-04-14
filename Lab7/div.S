        .data
instr:  .asciz  "Input natrual num:"
        .align  2
outstr: .asciz  "%d is prime"
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
        cmp     r2,r0
        beq     end

        add     r0,r0,#1
        str     r0,[sp]
        bl      isprime

        cmp     r0,#1
        bleq    print_prime
        b       loop

print_prime:
        ldr     r0,=outstr
        ldr     r1,[sp]
        bl      printf
        bx      lr

end:
        add     sp,sp,#4
        bx      lr

@ isprime(x)
@ returns 0 if false, 1 if true
isprime:
        sub     sp,sp,#8
        mov     r1,#0
        str     r1,[sp]         @ current iteration
        str     r0,[sp,#4]       @ store x

        cmp     r0,#1
        beq     ret_isprime

        cmp     r0,#2
        beq     ret_isprime

        mov     r1,#2

prime_loop:
        str     r1,[sp]         @ start iteration=2    
        bl      divide          @ r0=q,r1=remainder

        cmp     r1,#0           @ compare remainder for clean divide
        beq     ret_notprime

        ldr     r1,[sp]         @ load iteration and increment
        add     r1,r1,#1
        str     r1,[sp]

        ldr     r0,[sp,#4]       @ compare iteration=x
        cmp     r0,r1
        beq     ret_isprime     @ if iteration==x, then prime

        b       prime_loop      @ o/w, keep testing

ret_notprime:
        add     sp,sp,#8
        mov     r0,#0
        bx      lr

ret_isprime:
        add     sp,sp,#8
        mov     r0,#1
        bx      lr

@ divide(x,y)
@ r0=x
@ r1=y
@ returns quotient and remainder
divide:
        mov     r3,#0
div_loop:
        sub     r0,r0,r1
        add     r3,r3,#1
        cmp     r0,r1
        bpl     div_loop

        mov     r1,r0           @ remainder
        mov     r0,r3           @ quotient

        bx      lr

.end