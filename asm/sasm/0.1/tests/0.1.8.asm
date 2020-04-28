    mov rax, 0x010203
    push rax
    mov rax, 0x0
    mov rbx, rsp
    add rbx, 0x1
    mov al, [rbx]
    add rax, 0x2
    mov [rbx], al
    pop rax
    cmp rax, 0x010403
    jne fail
pass:
    mov rax, "Pass"
    jmp end
fail:
    mov rax, "Fail"
end:
    push rax
    mov rax, 0x1
    mov rdi, 0x1
    mov rdx, 0x4
    mov rsi, rsp
    syscall

    mov rax, 0x3C
    mov rdi, 0x0
    syscall
