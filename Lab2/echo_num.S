        .data
str1:   .asciz  "%d"                    @ Format string for reading an int with scanf
        .align  2
str2:   .asciz  "The sum is %d\n"      @ Format string for printf
        .align  2
n:      .word   0                       @ Place to store integer
m:      .word   0                       @ Place to store integer
        .text
        .globl  main

main:   
        stmfd   sp!, {lr}               @ Push lr onto stack

        @ scanf("%d\0",&n)
        ldr     r0, =str1               @ Load address of format string
        ldr     r1, =n                  @ Load address of int variable
        bl      scanf                   @ call scanf("%d",&n)

        @ scanf("%d\0",&m)
        ldr     r0, =str1               @ Load address of format string
        ldr     r1, =m                  @ Load address of int variable
        bl      scanf                   @ call scanf("%d",&m)

        @printf("You entered %d\n",n+m)
        ldr     r0, =str2               @ Load address of format string
        @ Load m into register 2
        ldr     r2, =m                  @ Load address of int variable m
        ldr     r2, [r2]                @ Load int variable m
        @ Load n into register 1
        ldr     r1, =n                  @ Load address of int variable n
        ldr     r1, [r1]                @ Load int variable n
        add     r1, r1, r2              @ n = n + m
        bl      printf                  @ Call printf("You entered %d\n",n)

        ldmfd   sp!, {lr}               @ Pop lr from stack
        mov     r0, #0                  @ Load return value
        mov     pc, lr                  @ Return from main
        .end
