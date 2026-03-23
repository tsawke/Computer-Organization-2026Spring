# Demo1
.data
	str: .asciz "Hello,RISC-V"
.text
	li a7,4
	la a0,str
	ecall
	
	li a7,10
	ecall