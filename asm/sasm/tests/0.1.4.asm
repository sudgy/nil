    mov rax, 0x616263
    cmp rax, "abc"
    je pass1
fail1:
    mov rax, "Yay"
    jmp end1
pass1:
    mov rax, "No"
end1:
    push rax
    mov rax, 0x1
    mov rdi, 0x1
    mov rdx, 0x4
    mov rsi, rsp
    syscall

    mov rax, 0x3C
    mov rdi, 0x0
    syscall
