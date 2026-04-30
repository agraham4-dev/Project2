.section .data
intro_double: .asciz "The double is:"
.section .bss
my_number: .skip 20
my_char: .skip 1
	.section .text
	.global _start
_start:
	mov $0, %rax #0 for rax signifies a read operation
	mov $0, %rdi #0 file descriptor for 
	lea my_number(%rip), %rsi #stores the inputted number in buffer
	mov $20, %rdx #store 20 bytes in the buffer
	syscall #performs the operation

	mov $0, %rbx #add 0 to rbx which is where we will store the number
.ascii_to_int_start:
	movb (%rsi), %al #moves only a byte of input to rax
	cmpb $10, %al #stdin ends with linefeed character
	je .ascii_to_int_end # compare to

	movzx %al, %rax #moves the al to rax
	#convert digit to number
	imul $10, %rbx #multiply rbx by 10
	add %rax, %rbx #adds the new digit to rax
	sub $0x30, %rbx #subtract the 0 ascii

	incq %rsi #move to next char 
	jmp .ascii_to_int_start #return to loop start
.ascii_to_int_end:
	mov %rbx, %rax #mov rbx to rax since its open
	imul $2, %rax #multiply rax by 2
	push $0 #push to the stack, use as a sentinal
.int_to_ascii_start:
	cmp $0, %rax #loop ends when rax is 0
	je .int_to_ascii_end # compare to

	#divide by 10 to decrement and add remainder
	xor %rdx, %rdx #clear the rdx register prior to division
	mov $10, %rcx #make sure operand is same number of bytes
	div %rcx #divides rax by 10
	add $0x30, %rdx #adds the remainder byte to the remainder
	push %rdx #push the rdx register to the stack

	jmp .int_to_ascii_start #return to loop start
.int_to_ascii_end:
	mov $1, %rax #system call for sys_write
	mov $1, %rdi #file desctiptor for stdout
	lea intro_double(%rip), %rsi #loads the memory address
	mov $15, %rdx #15 bytes is the length of the string
	syscall

	mov $1, %rdx #the length of the char will just be 1
	lea my_char(%rip), %rsi #loads the memory address
.print_number_start:
	pop %rax #pop the char from the stack
	cmp $0, %rax #compare the char to the 0 I previously added
	je .print_number_end #end the loop

	mov %al, (%rsi) #loads al into the value of my_char

	mov $1, %rax #system call for sys_write
	mov $1, %rdi #file desctiptor for stdout
	syscall

	jmp .print_number_start
.print_number_end:

	#print a linefeed to it doesn't look weird on gl
	movb $10, (%rsi) #move linefeed to rsi
	mov $1, %rax #system call for sys_write
	mov $1, %rdi #file desctiptor for stdout
	syscall

	mov $60, %rax #syscall for exit
	xor %rdi, %rdi #clears the rdi register giving exit status 0
	syscall #exits the program
