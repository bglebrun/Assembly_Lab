        .data
instr:  .asciz  "Enter the number of pennies, nickels, dimes, and quarters for week %d: "
        .align  2
outstr: .asciz  "Over four weeks you have collected %d pennies, %d nickles, %d dimes, and %d quarters. \n"
        .align  2
sumstr: .asciz  "This comes to $%d.%d \n"
        .align  2
avstr:  .asciz  "Your weekly average is $%d.%d \n"
        .align  2
savstr: .asciz  "Your estimated yearly savings is $%d.%d \n"
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

        mov     r9,#0
        mov     r8,#4

in_loop:
        add     r9,r9,#1
        ldr     r0,=instr
        mov     r1,r9
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
        cmp     r8,r9
        bne     in_loop

        @ output coin results
        ldr     r0,=outstr
        ldr     r1,=cent
        ldr     r1,[r1]
        ldr     r2,=nick
        ldr     r2,[r2]
        ldr     r3,=dime
        ldr     r3,[r3]
        ldr     ip,=quart
        ldr     ip,[ip]
        str     ip,[sp,#-4]!
        bl      printf
        add     sp,sp,#4

        @ reminder that r0 is basically being butchered through this section

        @ Don't need to do cents, already cent=cent
        ldr     r4,=cent
        ldr     r4,[r4]
        
        @ nickles to cents then store->r5
        ldr     r5,=nick
        @ load nickels amount to r5 and r0, then shift, add
        ldr     r0,[r5]
        mov     r5,r0
        @ shift add 4*r5
        add     r0,r0,r5, lsl #2
        mov     r5,r0           @ nickels cent total now in r5


        @ dimes to cents then store->r6
        ldr     r6,=dime
        ldr     r0,[r6]
        mov     r6,r0
        add     r0,r0,r6, lsl #2
        lsl     r0, #1
        mov     r6,r0
        @ dimes total now in r6        

        @ quarters to cents then store->r7
        ldr     r0,=quart
        ldr     r0,[r0]
        mov     r7,r0
        add     r0,r0,r7, lsl #2
        mov     r7,r0
        mov     r0,#0
        add     r0,r0,r7
        add     r0,r0,r7, lsl #2
        mov     r7,r0
        @ quarters total now in r7

        @ cent=cent, start with cent
        mov     r0,r4

        @ add all coins together for total cents
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
        bl      printf
        @ should have just printed sum string, done

        @ then weekly average, divide by 4
        mov     r0,r8
        lsr     r0,#2          @ divide by 4
        @ remainder is throwaway precision
        @ divide current quotient by 100
        mov     r1,#100
        bl      divide
        @ quotient should now be in r0, remainder in r1
        mov     r2,r1
        mov     r1,r0
        ldr     r0,=avstr
        bl      printf
        @ weekly average done

        @ then yearly savings, multiply total by 13
        mov     r0,r8
        add     r0,r0,r8, lsl #2
        add     r0,r0,r8, lsl #1
        mov     r1,#100
        bl      divide

        mov     r2,r1
        mov     r1,r0
        ldr     r0,=savstr
        bl      printf
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
        cmp     r0,r1
        subpl   r0,r0,r1
        addpl   r3,r3,#1
        bpl     div_loop

@ returns quotient (r0) and remainder(r1)
        mov     r1,r0           @ remainder
        mov     r0,r3           @ quotient

        bx      lr

        .end