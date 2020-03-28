; Play around, get the ASCII for 'S' on the top of the stack
push rax
mov rax, 0x53
mov rdx, rsp
mov [rdx], rax
mov rbx, [rdx]
push rbx

; Output the 'S'
mov rax, 0x1
mov rdi, 0x1
mov rdx, 0x1
mov rsi, rsp
syscall

; Exit
mov rax, 0x3C
mov rdi, 0x0
syscall
