    call hello
    mov rax, 0x3C
    mov rdi, 0x0
    syscall
hello:
    mov rax, 0x0A6948
    push rax
    mov rax, 0x1
    mov rdi, 0x1
    mov rdx, 0x3
    mov rsi, rsp
    syscall
    pop rax
    ret
