

/* color_to_gray will allocate a new grayimage structure and fill it
   with the grayscale equivalent of the given image.

   The C prototype is:

   grayimage *color_to_gray(rgbimage *image);

*/

	.global	color_to_gray
color_to_gray:
	stmfd	sp!,{r5,lr}			@ push lr and r5 to stack; will use r5
	/* Fill in the code to allocate a new grayimage, then convert
	   each pixel from the given rgbimage from color to grayscale,
	   and store it in the grayimage. */
	
	@ int col(0),row(4)=0
	@ int max_col(8),max_row(12)=0
	@ *rgbimage(16) color
	sub		sp,sp,#20			@ clearing 5 words of data on the stack
	mov		r1,#0				@ load 0 into r1
	str		r1,[sp]				@ store 0 to col(0)
	str		r1,[sp,#4]			@ store 0 to row(4)
	str		r1,[sp,#8]			@ store 0 to max_col(8)
	str		r1,[sp,#12]			@ store 0 to max_row(12)
	str		r0,[sp,#16]			@ store address of color(16)

	@ allocate gray-image
	bl		allocate_grayimage	@ branch to allocate greyimage
	@ r0 should now have greyimage

	@ Write width/height from color to bw
	ldr		r1,[sp,#16]			@ get color(16)
	ldr		r1,[r1,#4]			@ get width/row from color(16)
	ldr		r1,[r1]				@ dereference width/row from color(16)
	str 	r1,[r0,#4]			@ store grey width/row to bw

	str		r1,[sp,#12]			@ store max_row on the stack
	
	ldr		r1,[sp,#16]			@ get color(16)
	ldr		r1,[r1,#8]			@ get color height/column
	ldr		r1,[r1]				@ dereferencer height/column from color
	str		r1,[r0,#8]			@ store grey height/column to bw

	str		r1,[sp,#8]			@ store max_col on the stack
	@ *r0+4 and *r0+8 should have width/height information

	@ get column pointer
col:
	@ r0, grayscale
	@ int col(0),row(4)=0
	@ int max_col(8),max_row(12)=0
	@ *rgbimage(16) color

	@ reset row pointer
	mov 	r1,#0
	str		r1,[sp,#4]			@ row(sp+4) = r1

	@ check if we're on last column
	ldr		r1,[sp]				@ load col(sp)
	ldr		r2,[sp,#8]			@ load max_col(8)

	@ run a comparison
	cmp		r1,r2
	beq		noloop
	@ else dereference row pointer
	@ get row pointer
row:
	@ check if we're on last row
	@ stack pointer
	ldr		r2,[sp,#4]			@ r2 = row(4)
	ldr		r1,[sp,#12]			@ r1 = max_row(12)
	cmp 	r1,r2				@ r2 == r1
	beq 	col					@ if == then break to col

	@ otherwise get colors and convert

	@ increment row pointer index
	@ stack pointer
	ldr		r1,[sp,#4]
	add		r1,r1,#1
	str		r1,[sp,#4]
	b 		row

@ end row

	@ increment column pointer index
	@ stack pointer
	ldr		r1,[sp]
	add 	r1,r1,#1
	str		r1,[sp]
	b 		col

@ end col

noloop:
	@ make sure greyscale is in r0!
	add		sp,sp,#20			@ deallocate memory
	ldmfd	sp!,{r5,lr}			@ pop lr and r5 from stack
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

	.end