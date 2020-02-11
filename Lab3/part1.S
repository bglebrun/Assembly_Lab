        .data
chksm:  .asciz  "\nThe checksum is %08X\n"
prtst:  .asciz  "Enter text (ctrl-D to end): "
ans:    .asciz  "This checksum is wrong because we're performing check-ception on global vars"
rptst:  .asciz  "%s\n"
        .align  2

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
loop:
        @ buffer[i]=getchar();
        bl      getchar
        ldr     r1,=i
        ldr     r1,[r1]
        ldr     r2,=buffer
        str     r0,[r2,r1]

        @ while(buffer[i]!=-1)
        cmp     r0,#-1
        beq     endloop

        @ while(++i < 4095)
        ldr     r3,=i
        ldr     r3,[r4]
        add     r4,r4,#1
        str     r4,[r3]
        ldr     r3,[r3]
        ldr     r2,#4095
        cmp     r3,r2
        bgt     endloop
        @ while
        b       loop
endloop:
        @ buffer[i] = 0
        ldr     r0,=buffer
        ldr     r1,#0
        str     r1,[r0,r3]

        @ printf
        ldr     r0,=rptst
        ldr     r1,=buffer
        bl      printf

        @ i = 0
        ldr     r0,#0
        ldr     r1,=i
        str     r0,[r1]
checksum:
        @ buffer[i] != 0
        ldr     r1,=buffer
        ldr     r2,=i
        ldr     r2,[r2]
        ldr     r1,[r1,r2]
        cmp     r1,#0
        beq     checksum

        @  sum += buffer[i++]
        ldr     r0,=sum
        ldr     r0,[r0]
        
        ldr     r1,=buffer
        ldr     r2,=i
        ldr     r2,[r2]
        ldr     r1,[r1,r2]


        @ return 0
        ldmfd   sp!,{lr}
        mov     r0,#0
        mov     pc,lr
        .end