        .data
prompt: .asciz  "Enter float: "
        .align  2
res:    .asciz  "\nResult: "
        .align  2
scan_f: .asciz  "%f"
        .align  2
endl:   .asciz  "\n"
        .align  2
f_buff: .space  8
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
        vldr            d5,[r1]

        ldr             r0,=endl
        bl              printf

        ldr             r0,=prompt
        ldr             r1,=f_buff
        bl              scanf

        ldr             r1,=f_buff
        vldr            d0,[r1]

        vadd.f64        d1,d5,d0

        ldr             r0,=res
        bl              printf

        tst             sp,#4           @ check to see if stack is aligned
        vmovne          r1,r2,d1        @ move to r1,r2 if not aligned
        vmoveq          r2,r3,d1        @ move to r2,r3 if aligned
        ldr             r0,=scan_f      @ format string
        bl              printf

        ldmfd           sp!,{lr}
        bx              lr