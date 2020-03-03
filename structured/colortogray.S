

/* color_to_gray will allocate a new grayimage structure and fill it
   with the grayscale equivalent of the given image.

   The C prototype is:

   grayimage *color_to_gray(rgbimage *image);

*/

	.global	color_to_gray
color_to_gray:
	stmfd	sp!,{r4,r5,lr}			@ push lr and r5 to stack; will use r5
	/* Fill in the code to allocate a new grayimage, then convert
	   each pixel from the given rgbimage from color to grayscale,
	   and store it in the grayimage. */
	
	@ int col(0),row(4)=0
	@ int max_col(8),max_row(12)=0
	@ *rgbimage(16) color
	@ *grayimage(20) bw
	sub		sp,sp,#24			@ clearing 5 words of data on the stack
	mov		r1,#0				@ load 0 into r1
	str		r1,[sp]				@ store 0 to col(0)
	str		r1,[sp,#4]			@ store 0 to row(4)
	str		r1,[sp,#8]			@ store 0 to max_col(8)
	str		r1,[sp,#12]			@ store 0 to max_row(12)
	str		r0,[sp,#16]			@ store address of color(16)

	@ Write width/height from color to r0 and r1 for allocate_grayimage
	ldr		r2,[sp,#16]			@ get color(16)
	
	ldr		r0,[r2,#4]			@ get width/col from color(16)
	str		r0,[sp,#8]			@ store max_col on the stack
	
	ldr		r1,[r2,#8]			@ get color height/row
	str		r1,[sp,#12]			@ store max_row on the stack
	@ *r0+4 and *r0+8 should have width/height information

	@ allocate gray-image
	bl		allocate_grayimage	@ branch to allocate greyimage
	@ r0 should now have greyimage
	
	@ move r0 address to grayimage(20)
	str		r0,[sp,#20]			@ grayimage(20) = r0

	@ get column pointer
row:
	@ int col(0),row(4)=0
	@ int max_col(8),max_row(12)=0
	@ *rgbimage(16) color
	@ *grayimage(20) bw


	@ check if we're on last row
	ldr		r1,[sp,#4]			@ load row(4)
	ldr		r2,[sp,#12]			@ load max_row(12)
	@ run a comparison
	cmp		r1,r2				@ row == max_row
	beq		end_row				@ if == then break to end_row

	@ reset col pointer
	mov 	r1,#0
	str		r1,[sp]				@ col(0) = r1

col:
	@ check if we're on last col
	ldr		r2,[sp]				@ r2 = col(0)
	ldr		r1,[sp,#8]			@ r1 = max_col(8)
	cmp 	r1,r2				@ r2 == r1
	beq 	end_col				@ if == then break to end_col

	@ otherwise get colors and convert
	ldr		r4,[sp,#16]			@ Load initial color image
	ldr		ip,[sp,#4]			@ load row index to scratch reg
	ldr		r4,[r4,#0]			@ load color array
	ldr		r4,[r4,ip, lsl #2]	@ load row pointer to *color
	ldr		ip,[sp]				@ load col index
	mov		r0,#3
	mul		ip,ip,r0			@ align to 3
	add		r4,r4,ip			@ go to column pointer
	ldrb	r0,[r4],#1
	ldrb	r1,[r4],#1
	ldrb	r2,[r4],#1
	bl		convert_color_bw	@ with loaded colors, convert to bw
	@ our grayscale value should be sitting in r0 now

	@ load grayscale
	ldr		r1,[sp,#20]			@ load grayscale
	ldr		ip,[sp,#4]			@ load row index to scratch reg
	ldr		r1,[r1]				@ load grayscale rows
	ldr		r1,[r1,ip, lsl #2]	@ load pointer to correct *grayscale_row
	ldr		ip,[sp]				@ load col index
	add		r1,r1,ip
	str		r0,[r1]				@ store gray value to *graypixel

	@ increment col pointer index
	ldr		r1,[sp]				@ load col(0)
	add		r1,r1,#1			@ col(0)++
	str		r1,[sp]				@ =col(0)
	b 		col					@ break to col

end_col:

	@ increment row pointer index and return to col
	ldr		r1,[sp,#4]			@ load row(4) ptr
	add 	r1,r1,#1			@ ptr++
	str		r1,[sp,#4]			@ store ptr
	b 		row					@ return to row

end_row:
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

	.end