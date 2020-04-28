    mov rax, 0x1
    mov rdi, 0x1
    mov rsi, message
    mov rdx, end
    sub rdx, rsi
    syscall
