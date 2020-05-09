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
in_buff:    .space  32     @ Input buff, overkill yes but I'm programming assembly in 2020 where I could make this 4 gb if I wanted, pray I do not alter it further
            .align  2
            .text
            .globl main
main:
    stmfd   sp!,{lr}
    @ double low, high;
    @ double rows, step, i;
    sub     sp,sp,#16
    vpush   {d8-d12}

    @ Instructions
    ldr     r0,=prompt
    bl      printf

    @ prompt lower bounds
    ldr     r0,=low
    bl      printf

    @ scanf lower bound
    ldr     r0,=in_str_f
    ldr     r1,=in_buff
    bl      scanf
    @ buffer should now have the number

    @ convert from s0.f32 to d8.f64
    ldr     r0,=in_buff
    vldr            s0,[r0]
    vcvt.f64.f32    d8,s0

    @ newline for pretty shit
    ldr     r0,=nwline
    bl      printf
    @ prompt upper bounds
    ldr     r0,=upper
    bl      printf

    @ scanf upper bound
    ldr     r0,=in_str_f
    ldr     r1,=in_buff
    bl      scanf
    @ convert from s0.f32 to d9.f64
    ldr     r0,=in_buff
    vldr            s0,[r0]
    vcvt.f64.f32    d9,s0

    @ newline for pretty shit
    ldr     r0,=nwline
    bl      printf

    @ prompt for rows
    ldr     r0,=row_str
    bl      printf
    ldr     r0,=in_str_f
    ldr     r1,=in_buff
    bl      scanf
    @ convert from s0.f32 to d9.f64
    ldr     r0,=in_buff
    vldr            s0,[r0]
    vcvt.f64.f32    d10,s0  @ d10 now has number of rows
    @ newline for pretty shit
    ldr     r0,=nwline
    bl      printf

    @ idiot check (me mostly)
    ldr     r0,=in_buff
    ldr     r0,[r0]
    cmp     r0,#0x3f800000  @ check if 1 in floating point because that's our life now
    blt     return
    beq     single

    @ calculate step size
    vsub.f64        d11,d9,d8   @ d11 now has range
    vdiv.f64        d11,d11,d10 @ divide range by rows for step size

    vmov.f64        d12,d8      @ d12 is our iterator, set d12=low
loop:
    vcmp.f64        d12,d9           @ compare i>high
    vmrs            APSR_nzcv, FPSCR        @ get status, wonder if I can do this without consequence, probably not
    bge     return          @ exit if i>high

    @ print current i
    vmov.f64        d0,d12  @ load i to d0 for printing
    tst     sp,#4           @ check to see if we're aligned
    vmovne  r1,r2,d0        @ move to r1, r2 if not aligned
    vmoveq  r2,r3,d0        @ move to d2,d3 if aligned
    ldr     r0,=in_str_f    @ format string
    bl      printf

    ldr     r0,=tab_str     @ separator
    bl      printf          @ print separator

    vmov.f64        d0,d12  @ load iterator into d0 for calculating

    bl      calc_eqn        @ calculate current x
    @ result should be in d0

    @ print current result
    tst     sp,#4
    vmovne  r1,r2,d0
    vmoveq  r2,r3,d0
    ldr     r0,=in_str_f
    bl      printf

    ldr     r0,=nwline      @ print new line for pretty shit
    bl      printf

    vadd.f64        d12,d12,d11        @ add step to iterator
    b       loop            @ loop again

single:
    vmov.f64    d0,d8
    bl      calc_eqn
    @ single row already in d0, just call printf

    tst     sp,#4
    vmovne  r1,r2,d0
    vmoveq  r2,r3,d0
    ldr     r0,=in_str_f
    bl      printf

    ldr     r0,=nwline
    bl      printf          @ print new line for pretty shit

return:
    @ clear stack, return 0
    add     sp,sp,#16
    vpop    {d8-d12}
    mov     r0,#0
    ldmfd   sp!,{lr}
    bx      lr

@ Expects x->d0
@ returns f(x)=x^3-x^2-2x/( (x-2)^4/11 + 3 ) -> d0
calc_eqn:
    stmfd   sp!,{lr}
    vpush   {d8-d10}

    vmov.f64        d8,d0       @ save x in d8

    bl      calc_num            @ calculate numerator, result in d0
    vmov.f64        d9,d0       @ d9 now has numerator

    vmov.f64        d0,d8       @ move x into d0 again
    bl      calc_den            @ calculate denomenator, result in d0
    vmov.f64        d10,d0      @ d10 now has denomenator

    vdiv.f64        d0,d9,d10   @ numerator/denomenator, store to d0

    @ return
    vpop    {d8-d10}
    ldmfd   sp!,{lr}
    bx      lr

@ expects d0(x)
@ returns g(x)=x^3-x^2-2x -> d0
calc_num:
    stmfd   sp!,{lr}

    @ copy to even numbered registers
    vmov.f64        d2,d0
    vmov.f64        d6,d0
    
    @ x^3
    @ copy x into d1 for x*x
    vmov.f64        d1,d0
    vmul.f64        d0,d0,d1        @ x*x=x^2, copy to d4
    vmov.f64        d4,d0

    vmul.f64        d0,d0,d1        @ x^3
    
    mov     r0,#2
    vmov            s7,r0
    vcvt.f64.s32    d3,s7
    @ mult d6 by d3 for 2x
    vmul.f64        d6,d6,d3

    @ x^3-x^2
    vsub.f64        d0,d0,d4
    @ (x^3-x^2)-2x
    vsub.f64        d0,d0,d6

    @ numerator should now be in d0

    ldmfd   sp!,{lr}
    bx      lr

@ expects d0(x)
@ returns h(x)= ( (x-2)^4/11 ) + 3 -> d0
calc_den:
    stmfd   sp!,{lr}

    mov             r1,#2
    vmov            s2,r1
    vcvt.f64.s32    d1,s2           @ 2 should now be sitting in d1

    vsub.f64        d0,d0,d1        @ x-2=y
    vmov.f64        d1,d0           @ copy d0 into d1 for mult

    vmul.f64        d0,d0,d1        @ y^2
    vmul.f64        d0,d0,d1        @ y^3
    vmul.f64        d0,d0,d1        @ y^4

    mov             r1,#11
    vmov            s2,r1
    vcvt.f64.s32    d1,s2           @ 11 should now be sitting in d1

    mov             r1,#3
    vmov            s4,r1
    vcvt.f64.s32    d2,s4           @ 3 should now be sitting in d2

    vdiv.f64        d0,d0,d1        @ y/11=z
    vadd.f64        d0,d0,d2        @ z+3, answer in d0 now

    ldmfd   sp!,{lr}
    bx      lr

    .end