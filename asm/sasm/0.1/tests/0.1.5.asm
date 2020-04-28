    mov rax, 0x1
    mov rdi, 0x1
    mov rsi, message
    mov rdx, end
    sub rdx, rsi
    syscall

    mov rax, 0x3C
    mov rdi, 0x0
    syscall

message: ; This message is actually "PQRSTUVW"
    push rax
    push rcx
    push rdx
    push rbx
    push rsp
    push rbp
    push rsi
    push rdi
end:
