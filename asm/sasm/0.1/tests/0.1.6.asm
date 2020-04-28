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
    db "Hello, world!"
    db 0x0
end:
