

/* color_to_gray will allocate a new grayimage structure and fill it
   with the grayscale equivalent of the given image.

   The C prototype is:

   grayimage *color_to_gray(rgbimage *image);

*/

    .global color_to_gray
color_to_gray:
    stmfd   sp!,{lr}

    sub     sp,sp,#24       @ allocate temp variables
    mov     r1,#0           @ init all to 0
    str     r1,[sp]         @ Col
    str     r1,[sp,#4]      @ Row
    str     r1,[sp,#8]      @ MaxCol
    str     r1,[sp,#12]     @ MaxRow
    str     r0,[sp,#16]     @ color image now sitting on sp+16

    @ move color to r2
    mov     r2,r0

    ldr     r0,[r2,#4]      @ get width
    str     r0,[sp,#8]      @ store width

    ldr     r1,[r2,#8]      @ get height
    str     r1,[sp,#12]     @ store height

    @ r0 has width, r1 has height, allocate grey image
    bl      allocate_grayimage
    @ r0 now has allocated grayimage

    str     r0,[sp,#20]     @ sp+20 now has grayimage pointer
    ldr     r0,[sp,#16]     @ r0 now has the color image

    @ This is where we use NEON to do processing

    vld3.8  {d0[0],d1[0],d2[0]},[r0]!
    vld3.8  {d0[1],d1[1],d2[1]},[r0]!
    vld3.8  {d0[2],d1[2],d2[2]},[r0]!
    vld3.8  {d0[3],d1[3],d2[3]},[r0]!
    vld3.8  {d0[4],d1[4],d2[4]},[r0]!
    vld3.8  {d0[5],d1[5],d2[5]},[r0]!
    vld3.8  {d0[6],d1[6],d2[6]},[r0]!
    vld3.8  {d0[7],d1[7],d2[7]},[r0]!

    @ End of program
	ldr		r0,[sp,#20]			@ make sure greyscale is in r0 before we exit
	add		sp,sp,#24			@ deallocate memory
	ldmfd	sp!,{r4,r5,lr}		@ pop lr, r4 and r5 from stack
	mov		pc,lr				@ return


@ expects r(r0) g(r1) b(r2)
@ returns gray(r0)
convert_color_bw:
	mov		r3,#54				@ r3 = 54
	mul		r0,r0,r3			@ r0 = r0 * r3
	mov		r3,#184				@ r3 = 184
	mul		r1,r1,r3			@ r1 = r1*r3
	mov		r3,#18				@ r3 = 18
	mul		r2,r2,r3			@ r2 = r2*r3
	add		r0,r0,r1			@ r0 = r0 + r1
	add		r0,r0,r2			@ r0 = r0 + r2
	asr 	r0,r0,#8			@ r0 = r0/256
	mov		pc,lr				@ return r0

mov 

@ 54 in d3, 184 in d5, 18 in d7
mov     r0,#54
mov     r1,#184
mov     r2,#18

vmov.i8 d3[0],r0
vmov.i8 d3[1],r0
vmov.i8 d3[2],r0
vmov.i8 d3[3],r0
vmov.i8 d3[4],r0
vmov.i8 d3[5],r0
vmov.i8 d3[6],r0
vmov.i8 d3[7],r0

vmov.i8 d5[0],r0
vmov.i8 d5[1],r0
vmov.i8 d5[2],r0
vmov.i8 d5[3],r0
vmov.i8 d5[4],r0
vmov.i8 d5[5],r0
vmov.i8 d5[6],r0
vmov.i8 d5[7],r0

vmov.i8 d7[0],r0
vmov.i8 d7[1],r0
vmov.i8 d7[2],r0
vmov.i8 d7[3],r0
vmov.i8 d7[4],r0
vmov.i8 d7[5],r0
vmov.i8 d7[6],r0
vmov.i8 d7[7],r0


vmla.i8 d0,d0,d3
vmla.i8 d1,d1,d5
vmla.i8 d2,d2,d7
vadd.i8 d0,d0,d1
vadd.i8 d0,d0,d2
vshr.u8 d0,d0,#8

	.end