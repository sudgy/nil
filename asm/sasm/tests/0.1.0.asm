    mov rax, 0x10
    add rax, 0x30
    cmp rax, 0x40
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

    mov rax, 0x30
    sub rax, 0x20
    cmp rax, 0x10
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
