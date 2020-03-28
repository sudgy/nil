    mov rax, 0x10
    cmp rax, 0x10
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

    mov rax, 0x10
    cmp rax, 0x9
    je fail2
pass2:
    mov rax, 0xA796159
    jmp end2
fail2:
    mov rax, 0xA206F4E
end2:
    push rax
    mov rax, 0x1
    mov rdi, 0x1
    mov rdx, 0x4
    mov rsi, rsp
    syscall

    mov rax, 0x10
    mov rbx, 0x10
    cmp rax, rbx
    je pass3
fail3:
    mov rax, 0xA206F4E
    jmp end3
pass3:
    mov rax, 0xA796159
end3:
    push rax
    mov rax, 0x1
    mov rdi, 0x1
    mov rdx, 0x4
    mov rsi, rsp
    syscall

    mov rax, 0x10
    mov rbx, 0x9
    cmp rax, rbx
    je fail4
pass4:
    mov rax, 0xA796159
    jmp end4
fail4:
    mov rax, 0xA206F4E
end4:
    push rax
    mov rax, 0x1
    mov rdi, 0x1
    mov rdx, 0x4
    mov rsi, rsp
    syscall

    mov rax, 0x3C
    mov rdi, 0x0
    syscall
