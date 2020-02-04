        .data
msg:
        .ascii  "Hello world!\n"
len     = . - msg

        .text

.globl  main

main:
        stmfd   sp!, {lr}
        @ printf(msg)
        ldr     r0, =msg
        bl      printf
        @ return from main()
        mov     r0, #0
        ldmfd   sp!, {lr}
        mov     pc, lr