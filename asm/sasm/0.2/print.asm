; Put string in rsi
print:
    push rsi
    call strlen
    pop rsi
    mov rdx, rax
    mov rax, 0x1
    mov rdi, 0x1
    syscall
    ret
; Put string in rsi
println:
    call print
    mov rax, 0xA
    push rax
    mov rsi, rsp
    call print
    pop rax
    ret
