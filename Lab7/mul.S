        .data
instr:  .asciz  "Enter the number of pennies, nickels, dimes, and quarters for week %d: "
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
@ input buffers
c_buf:  .word   0
n_buf:  .word   0
d_buf:  .word   0
q_buf:  .word   0
@ coin sums
cent:   .word   0
nick:   .word   0
dime:   .word   0
quart:  .word   0

        .text
        .globl  main
main:
        stmfd   sp!,{r4-r9,lr}

        mov     r3,#0
        mov     r8,#4

in_loop:
        add     r3,r3,#1
        ldr     r0,=instr
        mov     r1,r3
        bl      printf

        @ scanf(input,c_buff,n_buff,d_buff,q_buff)
        ldr     r0,=input
        ldr     r1,=c_buf
        ldr     r2,=n_buf
        ldr     r3,=d_buf
        ldr     ip,=q_buf
        str     ip,[sp,#-4]!
        bl      scanf
        add     sp,sp,#4

        @ add input buffers to the sums
        ldr     r0,=c_buf
        ldr     r0,[r0]
        ldr     r1,=n_buf
        ldr     r1,[r1]
        ldr     r2,=d_buf
        ldr     r2,[r2]
        ldr     r3,=q_buf
        ldr     r3,[r3]

        ldr     r4,=cent
        ldr     r4,[r4]
        add     r4,r4,r0
        ldr     ip,=cent
        str     r4,[ip]

        ldr     r5,=nick
        ldr     r5,[r5]
        add     r5,r5,r1
        ldr     ip,=nick
        str     r5,[ip]

        ldr     r6,=dime
        ldr     r6,[r6]
        add     r6,r6,r2
        ldr     ip,=dime
        str     r6,[ip]

        ldr     r7,=quart
        ldr     r7,[r7]
        add     r7,r7,r3
        ldr     ip,=quart
        str     r7,[ip]

        @ if i != 4, keep looping
        cmp     r8,r3
        bne     in_loop

        @ output coin results
        ldr     r0,=outstr
        ldr     r1,=cent
        ldr     r2,=nick
        ldr     r3,=dime
        ldr     sp,=quart
        bl      printf

        @ calculate total
        ldr     r4,[sp]         @ quarters on r4
        ldr     r6,[r2]         @ nickles on r6
        ldr     r5,[r1]         @ cents on r5
        ldr     r7,[r3]         @ dimes on r7

        @ reminder that r0 is basically being butchered through this section
        
        @ quarters first        
        mov     r0,r4           @ calculate quarters first (r0)
        mov     r1,#25          @ 25 cents on r1
        bl      multiply
        @ store result
        mov     r4,r0
        @ * shouldn't * have to worry about r0 beacuse we calculated quarters first

        @ Don't need to do cents, already cent=cent

        @ nickles
        mov     r0,r6
        mov     r1,#5
        bl      multiply
        @ store result
        mov     r5,r0

        @ dimes
        mov     r0,r7
        mov     r1,#10
        bl      multiply
        @ store result
        mov     r7,r0

        @ add all coins together for total cents
        add     r0,r0,r4
        add     r0,r0,r5
        add     r0,r0,r6
        add     r0,r0,r7
        @ total should now be in r0

        @ do all calculations for total dollars here now
        @ cents is sitting in r0, need to convert because we're not using yen


        @ need to convert to total in $x.xx format
        @ divide by 100 then use quotient as dollars, cents as remainder

        @ save cents into constant register
        mov     r8,r0           @ cents should now be in r8 as a constant
        mov     r1,#100         @ 100 now in r1
        bl      divide          @ divide r0/100
        @ dollars(r0), cents(r1)
        @ should be able to just print r0->r1, r1->r2
        mov     r2,r1
        mov     r1,r0
        ldr     r0,=sumstr
        @ should have just printed sum string, done

        @ then weekly average, divide by 4
        mov     r0,r8
        mov     r1,#4
        bl      divide
        @ quotient should now be in r0, remainder in r1
        mov     r2,r1
        mov     r1,r0
        ldr     r0,=avstr
        @ weekly average done

        @ then yearly savings, multiply total by 13
        mov     r8,r0
        mov     r1,#13
        bl      multiply
        @ total now in r0, div by 100
        mov     r1,#100
        bl      divide

        mov     r2,r1
        mov     r1,r0
        ldr     r0,=savstr
        @ savestring should now be saved and printed, done, exit

        ldmfd   sp!,{r4-r9,lr}
        mov     r0,#0           @ return 0
        bx      lr

@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ multiply(x,y)
@ return x * y
@ r0=x
@ r1=y
multiply:
        mov     r3,#0
        cmp     r3,r0
        moveq   r0,#0
        bxeq    lr
        cmp     r3,r1
        moveq   r0,#0
        bxeq    lr

        mov     r3,#1
        cmp     r0,r3
        moveq   r0,r1
        bxeq    lr

mul_loop:
        cmp     r1,r3           @ check if r1 == 1 yet
        bxle    lr              @ if so, our result is now in r0, return

        add     r0,r0,r0
        sub     r1,r1,#1
        b       mul_loop


@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ divide(x,y)
@ return x/y
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