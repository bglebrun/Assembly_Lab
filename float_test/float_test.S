        .data
prompt: .asciz  "Enter float: "
        .align  2
res:    .asciz  "\nResult: "
        .align  2
scan_f: .asciz  "%f"
        .align  2
endl:   .asciz  "\n"
        .align  2
f_buff: .space  32
        .align  2
        .global main

main:
        stmfd           sp!,{lr}

        ldr             r0,=prompt
        bl              printf
        ldr             r0,=scan_f
        ldr             r1,=f_buff
        bl              scanf  

        ldr             r1,=f_buff
        vldr            s0,[r1]

        vcvt.f64.f32    d0,s0

        ldr             r0,=endl
        bl              printf

        ldr             r0,=prompt
        bl              printf
        ldr             r0,=scan_f
        ldr             r1,=f_buff
        bl              scanf  

        ldr             r1,=f_buff
        vldr            s2,[r1]

        vcvt.f64.f32    d1,s2

        vmul.f64        d0,d0,d1

        ldr             r0,=res
        bl              printf

        tst             sp,#4           @ check to see if stack is aligned
        vmovne          r1,r2,d0        @ move to r1,r2 if not aligned
        vmoveq          r2,r3,d0        @ move to r2,r3 if aligned
        ldr             r0,=scan_f      @ format string
        bl              printf

        ldr             r0,=endl
        bl              printf

        ldmfd           sp!,{lr}
        bx              lr