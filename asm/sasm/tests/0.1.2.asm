    mov rax, 0x3
    mov rbx, 0x2
    mul rbx
    cmp rax, 0x6
    je pass1
fail1:
    mov rax, 0xA206F4E
    jmp end1
pass1:
    mov rax, 0xA796159
end1:
    push rax
    mov rax, 0x1
    mov rdi, 0x1
    mov rdx, 0x4
    mov rsi, rsp
    syscall

    mov rax, 0x11
    mov rbx, 0x2
    mov rdx, 0x0
    div rbx
    cmp rax, 0x8
    je pass2
fail2:
    mov rax, 0xA206F4E
    jmp end2
pass2:
    mov rax, 0xA796159
end2:
    push rax
    mov rax, 0x1
    mov rdi, 0x1
    mov rdx, 0x4
    mov rsi, rsp
    syscall

    mov rax, 0x3C
    mov rdi, 0x0
    syscall
