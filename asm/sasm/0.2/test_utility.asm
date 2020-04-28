test_uti:
    call t_uti1
    call t_uti2
    ret

t_uti1a:
    db "min rdi"
    db 0x0
t_uti1b:
    db "min rsi"
    db 0x0
t_uti1:
    mov rdi, 0x3
    mov rsi, 0x5
    call min
    mov rsi, t_uti1a
    cmp rax, 0x3
    jne testfail

    mov rdi, 0x5
    mov rsi, 0x3
    call min
    mov rsi, t_uti1b
    cmp rax, 0x3
    jne testfail

    ret

t_uti2a:
    db "max rsi"
    db 0x0
t_uti2b:
    db "max rdi"
    db 0x0
t_uti2:
    mov rdi, 0x3
    mov rsi, 0x5
    call max
    mov rsi, t_uti2a
    cmp rax, 0x5
    jne testfail

    mov rdi, 0x5
    mov rsi, 0x3
    call max
    mov rsi, t_uti2b
    cmp rax, 0x5
    jne testfail

    ret
