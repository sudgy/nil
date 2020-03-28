mov rax, 0x10
mov rbx, 0x30
add rax, rbx
push rax
mov rax, 0x1
mov rdi, 0x1
mov rdx, 0x1
mov rsi, rsp
syscall
pop rax

mov rax, 0x10
mov rbx, 0x6
sub rax, rbx
push rax
mov rax, 0x1
mov rdi, 0x1
mov rdx, 0x1
mov rsi, rsp
syscall
pop rax

mov rax, 0x3C
mov rdi, 0x0
syscall
