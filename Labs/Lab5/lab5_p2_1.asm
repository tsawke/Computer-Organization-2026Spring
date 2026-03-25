# 请补全代码, 不可修改已有部分
# Please complete the code below, without modifying the existing part
.macro print_string(%str)
	.data 
		pstr:   .asciz   %str
	.text
		la a0,pstr
		li a7,4
		ecall
.end_macro

.macro end
	li a7,10
	ecall
.end_macro

.text
	li a7,5
	ecall
	mv t1,a0
	ecall
	mv t2,a0		
	sub t0, t1, t2		# t0 = t1 - t2 
	mv a0, t0		# print the sum
	li a7, 1
	ecall	

    #在此处补全代码 complete the code here

    # (a ^ b) & (a ^ res)
    # sign digit is 1 <=> value < 0
    xor t3, t1, t2
    xor t4, t0, t1
    and t5, t3, t4
    bltz t5, overflow

    #在此处补全代码 complete the code here
	
	print_string("\nNo overflow occured.")
	jal exit	
overflow:
	print_string("\nOverflow occured.")
exit:	
	end

