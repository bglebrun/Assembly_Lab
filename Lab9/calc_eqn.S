            .data
prompt:     .asciz  "Calculates f(x) = (x^3-x^2-2x)/( (x-2)^4/11 + 3)\n"
            .align  2
low:        .asciz  "Enter lower bounds for x: "
            .align  2
upper:      .asciz  "Enter upper bounds for x: "
            .align  2
row_str:    .asciz  "Enter rows to calculate: "
            .align  2
in_str_f:   .asciz  "%f"    @ float buffer
            .align  2
in_str_d:   .asciz  "%d"    @ normal integer buffer
            .align  2
tab_str:    .asciz  "\t"
            .align  2
nwline:     .asciz  "\n"
            .align  2
in_buff:    .space   16     @ Input buff
            .align  2
            .text
            .globl main
main:
    stmfd   sp!,{r4,lr}
    @ double low, high;
    @ int rows, step;
    sub     sp,sp,#16

    @ Instructions
    ldr     r0,=prompt
    bl      printf

    @ prompt lower bounds
    ldr     r0,=low
    bl      printf

    @ scanf lower bound
    ldr     r0,=in_str_s
    ldr     r1,=in_buff
    bl      scanf
    @ buffer should now have the number

    @ convert to s(15,16) using helper
    ldr     r0,=in_buff
    mov     r1,#16
    bl      strtoSfixed
    @ returns int, save to stack
    str     r0,[sp]

    @ newline for pretty shit
    ldr     r0,=nwline
    bl      printf

    @ prompt upper bounds
    ldr     r0,=upper
    bl      printf

    @ scanf upper bound
    ldr     r0,=in_str_s
    ldr     r1,=in_buff
    bl      scanf

    @ convert to S(15,16)
    ldr     r0,=in_buff
    mov     r1,#16
    bl      strtoSfixed
    str     r0,[sp,#4]

    @ newline for pretty shit
    ldr     r0,=nwline
    bl      printf

    @ prompt for rows
    ldr     r0,=row_str
    bl      printf
    ldr     r0,=in_str_d
    ldr     r1,=in_buff
    bl      scanf
    ldr     r0,=in_buff
    ldr     r0,[r0]
    str     r0,[sp,#8]

    @ newline for pretty shit
    ldr     r0,=nwline
    bl      printf

    @ idiot check (me mostly)
    ldr     r0,[sp,#8]      @ load rows for comparison
    cmp     r0,#1
    blt     return
    beq     single

    @ calculate step size
    ldr     r0,[sp,#4]
    ldr     r1,[sp]
    sub     r0,r0,r1        @ calc range, store to r0
    ldr     r1,[sp,#8]      @ divide range by step
    bl      udiv32          @ step size should be in r0 now
    str     r0,[sp,#12]     @ sp+12 now has the step size

    ldr     r4,[sp]         @ r4 is our iterator, set r4=low
loop:
    ldr     r3,[sp,#4]      @ load high iterator
    cmp     r4,r3           @ compare i>high
    bge     return          @ exit if i>high

    mov     r0,r4           @ load i
    mov     r1,#16          @ S value
    bl      printS          @ print current i

    ldr     r0,=tab_str     @ separator
    bl      printf          @ print separator

    mov     r0,r4           @ load i
    bl      calc_eqn        @ calculate current x
    @ result should be in r0, r1 still 16
    mov     r1,#16
    bl      printS

    ldr     r0,=nwline      @ print new line for pretty shit
    bl      printf

    ldr     r0,[sp,#12]     @ load step size
    add     r4,r4,r0        @ add step to iterator
    b       loop            @ loop again

single:
    ldr     r0,[sp]
    bl      printf
    ldr     r0,=tab_str
    bl      printf
    bl      calc_eqn
    @ single row already in r0, just call printS
    mov     r1,#16
    bl      printS
    ldr     r0,=nwline
    bl      printf          @ print new line for pretty shit

return:
    @ clear stack, return 0
    add     sp,sp,#16
    mov     r0,#0
    ldmfd   sp!,{r4,lr}
    bx      lr

@ Expects x->r0
@ returns f(x)=x^3-x^2-2x/( (x-2)^4/11 + 3 ) -> r0
calc_eqn:
    @ gonna split up numerator/denominator so need this
    @ yes I spent 2 weeks stuck on this lab because
    @ my link register and sp was all over the place and
    @ I'm trying to be clever for some reason
    stmfd   sp!,{lr}
    sub     sp,sp,#12       @ store x
    str     r0,[sp]         @ then actually store x

    bl      calc_num        @ calculate numerator, result in r0
    str     r0,[sp,#4]      @ store result for now

    ldr     r0,[sp]         @ load x
    bl      calc_den        @ calculate denomenator, result in r0
    str     r0,[sp,#8]      @ store result for now

    @ check signs 
    mov     r3,#0
    ldr     r0,[sp,#4]      @ get numerator
    cmp     r0,#0
    mvnlt   r0,r0
    addlt   r3,r3,#1        @ set sign reg
    strlt   r0,[sp,#4]      @ store new result if it exists

    ldr     r0,[sp,#8]      @ get denominator
    cmp     r0,#0           @ check negative
    mvnlt   r0,r0
    sublt   r3,r3,#1        @ set sign reg
    strlt   r0,[sp,#8]      @ store denominator if changed

    @ store sign result for now
    str     r3,[sp]

    @ start division signed 64 bit
    mov     r0,#0
    ldr     r1,[sp,#4]
    ldr     r2,[sp,#8]
    mov     r3,#0
    bl      sdiv64

    @ repair numbers
    lsr     r0,#16
    lsl     r1,#16
    orr     r0,r0,r1
    mov     r3,#1
    lsl     r3,#31
    mvn     r3,r3
    and     r0,r0,r3

    @ check sign reg, if sg==0, then is positive, otherwise negative
    ldr     r3,[sp]
    cmp     r3,#0
    mvnne   r0,r0           @ if sg!=0, then negate answer

    add     sp,sp,#12
    ldmfd   sp!,{lr}
    bx      lr

@ expects r0(x)
@ returns g(x)=x^3-x^2-2x -> r0
calc_num:
    stmfd   sp!,{lr}
    sub     sp,sp,#16
    @ for each of our polynomials
    str     r0,[sp]
    str     r0,[sp,#4]
    str     r0,[sp,#8]

    @ x^3
    @ copy x into r1 for x*x
    mov     r1,r0
    bl      mul_s16
    ldr     r1,[sp]         @ once more for x^2*x=x^3
    bl      mul_s16
    str     r0,[sp]         @ store x^3 to sp

    ldr     r0,[sp,#4]
    mov     r1,r0           @ same for x^2
    bl      mul_s16
    str     r0,[sp,#4]      @ store x^2 to sp+4

    ldr     r0,[sp,#8]
    mov     r1,#2
    @ if a bug happens, it's here because I'm a dumbass and dont 
    @ know how to mult integers by fixed point
    lsr     r0,#16
    mul     r0,r0,r1
    lsl     r0,r0,#16
    str     r0,[sp,#8]

    @ start subtracting
    ldr     r0,[sp]
    ldr     r1,[sp,#4]
    sub     r0,r0,r1

    ldr     r1,[sp,#8]
    sub     r0,r0,r1

    @ numerator should now be in r0

    add     sp,sp,#16
    ldmfd   sp!,{lr}
    bx      lr

@ expects r0(x)
@ returns h(x)= ( (x-2)^4/11 ) + 3 -> r0
calc_den:
    stmfd   sp!,{r4,lr}

    mov     r1,#2
    lsl     r1,#16

    sub     r0,r0,r1        @ subtract 2

    mov     r4,r0         @ store x-2=y for now
    mov     r1,r0
    bl      mul_s16         @ y ^ 2
    mov     r1,r4
    bl      mul_s16         @ y ^ 3
    mov     r1,r4
    bl      mul_s16         @ y ^ 4
    @ store y^4 to sp for now
    mov     r4,r0

    @ prep for 64 bit division
    mov     r2,#11
    lsl     r2,#16
    mov     r3,#0
    mov     r0,#0
    mov     r1,r4
    @ divide
    bl      sdiv64
    @ repair number
    lsr     r0,#16      @ shift decimal
    lsl     r1,#16      @ shift integer
    orr     r0,r0,r1    @ || together

    @ add 3, then return
    mov     r1,#3
    lsl     r1,#16
    add     r0,r0,r1

    ldmfd   sp!,{r4,lr}
    bx      lr


@ expects x->r0, y->r1 in S(16,15)
@ returns x*y
mul_s16:
    smull   r0,r1,r0,r1
    lsr     r0,r0,#16
    orr     r0,r1,lsl#16
    bx      lr

    .end