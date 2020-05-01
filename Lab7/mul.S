        .data
instr:  .asciz  "Enter the number of pennies, nickels, dimes, and quarters for week %d:"
        .align  2
outstr: .asciz  "Over four weeks you have collected %d pennies, %d nickles, %d dimes, and %d quarters."
        .align  2
sumstr: .asciz  "This comes to $%d.%d"
        .align  2
avstr:  .asciz  "Your weekly average is $%d.%d"
        .align  2
savstr: .asciz  "Your estimated yearly savings is $%d.%d"
        .align  2
input:  .asciz  "%d %d %d %d"
        .align  2

        .text
        .globl  main
main:
        stmfd   sp!,{lr}

        ldmfd   sp!,{lr}
        bx      lr