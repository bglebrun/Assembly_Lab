@_ZN5queue5enqueEi
@_ZN5queue5dequeERi

.globl  _ZN5queue5enqueEi
.globl  _ZN5queue5dequeERi

@ 52,53,54

_ZN5queue5enqueEi:

        stmfd   sp!,{r4-r8,lr}
        mov     r5,r1                   @ r5 now has object to insert
        mov     r6,r0                   @ r6 now has reference to *this
        bl      _ZN5queue6isfullEv      @ call isfull()
        mov     r2,#1                   @ load 1 for comparison
        cmp     r2,r0                   @ if 1, then full, return 0
        beq     return_0

        ldr     r7,[r6,#212]            @ r7 has endindex
        ldr     r8,[r6,#216]            @ r8 has nitems

        mov     ip,#4

        mul     r3,r7,ip

        str     r5,[r6,r3]              @ array[endindex] = item

        add     r7,r7,#1                @ ++endindex
        mov     r2,#52                  @ MAX_QUEUE_SIZE
        cmp     r7,r2                   @ endindex >= MAX_QUEUE_SIZE
        movge   r7,#0                   @ if greater than or equal, =0

        add     r8,r8,#1                @ nitems++

        str     r7,[r6,#212]            @ r7 has endindex
        str     r8,[r6,#216]            @ r8 has nitems

        @ return 1;
        mov     r0,#1
        ldmfd   sp!,{r4-r8,lr}
        bx      lr

return_0:
        mov     r0,#0
        ldmfd   sp!,{r4-r8,lr}
        bx      lr

_ZN5queue5dequeERi:
        stmfd   sp!,{r4-r8,lr}
        mov     r5,r0                   @ r5 now has reference to *this

        bl      _ZN5queue7isemptyEv     @ check if queue is empty
        mov     r2,#1                   @ load 1 for comparison
        cmp     r2,r0                   @ if 1, then empty, return 0
        beq     return_0

        ldr     r6,[r5,#208]            @ r6 has frontindex
        ldr     r7,[r5,#216]            @ r7 has nitems

        mov     ip,#4

        mul     r3,r6,ip

        ldr     r0,[r5,r3]              @ item = array[frontindex]

        add     r6,r6,#1                @ ++frontindex
        mov     r2,#52                  @ MAX_QUEUE_SIZE
        cmp     r6,r2                   @ frontindex >= MAX_QUEUE_SIZE
        movge   r6,#0                   @ if greater than or equal, =0

        sub     r7,r7,#1                @ nitems--

        str     r6,[r5,#208]            @ r6 has frontindex
        str     r7,[r5,#216]            @ r7 has nitems

        @ return item;
        ldmfd   sp!,{r4-r8,lr}
        bx      lr

        .end