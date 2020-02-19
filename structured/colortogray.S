.data
col:		.word	0
row:		.word	0
max_col:	.word	0
max_row:	.word	0

.text

/* color_to_gray will allocate a new grayimage structure and fill it
   with the grayscale equivalent of the given image.

   The C prototype is:

   grayimage *color_to_gray(rgbimage *image);

*/

	.global	color_to_gray
color_to_gray:
	/* Fill in the code to allocate a new grayimage, then convert
	   each pixel from the given rgbimage from color to grayscale,
	   and store it in the grayimage. */
	
	@ int col(0),row(4)=0
	@ int max_col(8),max_row(12)=0
	/*
	@ stack pointer
	sub		sp,sp,#16
	mov		r1,#0
	str		r1,[sp]
	str		r1,[sp,#4]
	str		r1,[sp,#8]
	str		r1,[sp,#12]
	*/

	@ allocate gray-image
	mov		r0,r3				@ move color copy to r3
	ldr		r0,[r3,#4]			@ width/row from color
	ldr		r1,[r3,#8]			@ height/column	from color
	bl		allocate_grayimage	@ branch to allocate greyimage
	@ r0 should now have greyimage

	@ Write width/height from color to bw
	ldr		r1,[r3,#4]			@ get color width/row
	ldr		r1,[r1]				@ dereference width/row from color
	str 	r1,[r0,#4]			@ store grey width/row to bw
	@ stack pointer
	// str	r1,[sp,#12]			@ store max_row on the stack
	@ global
	ldr		r2,=max_row			@ load address to max_row
	str		r1,[r2]				@ store color row to address of max_row

	
	ldr		r1,[r3,#8]			@ get color height/column
	ldr		r1,[r1]				@ dereferencer height/column from color
	str		r1,[r0,#8]			@ store grey height/column to bw
	@ stack pointer
	// str	r1,[sp,#8]			@ store max_col on the stack
	@ global
	ldr		r2,=max_col			@ load address to max_col
	str		r1,[r2]				@ store color col to address of max_col
	@ r0+4 and r0+8 should have width/height information

	@ get column pointer
col:
	@ r0, grayscale
	@ int col(sp),row(sp+4)=0
	@ int max_col(sp+8),max_row(sp+12)=0
	@ r3, color


	@ reset row pointer
	mov 	r1,#0
	/*
	@ stack ptr
	str		r1,[sp,#4]			@ r1 = row(sp+4)
	*/
	@ globals
	ldr		r2,=row				@ load r2 with address of row
	str		r1,[r2]				@ store 0 in address of r2

	@ check if we're on last column
	/*
	@ stack pointer
	ldr		r1,[sp]				@ load col(sp)
	ldr		r2,[sp,#8]
	*/
	@ globals
	ldr		r1,=col				@ Load column global
	ldr		r1,[r1]				@ dereference column

	@ run a comparison
	cmp		r1,r2
	beq		noloop
	@ else dereference row pointer
	@ get row pointer
row:
	@ check if we're on last row
	@ stack pointer
	/*
	@ stack pointer
	ldr		r2,[sp,#4]
	ldr		r1,[sp,#12]
	cmp 	r1,r2
	beq 	col
	*/
	@ globals
	ldr		r2,=max_row
	ldr		r1,=row
	cmp		r1,r2
	beq		col

	@ otherwise get colors and convert

	@increment row pointer index
	@ stack pointer
	/*
	ldr		r1,[sp,#4]
	add		r1,r1,#1
	str		r1,[sp,#4]
	b 		col
	*/
	@globals
	ldr		r1,=row
	ldr		r2,[r1]
	add		r2,r2,#1
	str		r2,[r1]

	@ increment column pointer index
	/*
	@ stack pointer
	ldr		r1,[sp]
	add 	r1,r1,#1
	str		r1,[sp]
	b 		col
	*/
	@ globals
	ldr		r1,=col
	ldr		r2,[r1]
	add		r2,r2,#1
	str		r2,[r1]

noloop:
	mov	pc,lr		@ return
