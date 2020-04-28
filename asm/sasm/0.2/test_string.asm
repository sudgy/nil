test_str:
    call t_str1
    call t_str2
    call t_str3
    ret

t_stri1:
    db "Test string 1"
    db 0x0
t_stri2:
    db "Short"
    db 0x0
t_stri3:
    db "Test string 3"
    db 0x0

t_str1a:
    db "strlen"
    db 0x0
t_str1:
    mov rsi, t_stri1
    call strlen
    mov rsi, t_str1a
    cmp rax, 0xD
    jne testfail
    ret

t_str2a:
    db "strcmp equal"
    db 0x0
t_str2b:
    db "strcmp not equal"
    db 0x0
t_str2c:
    db "strcmp not equal same length"
    db 0x0
t_str2:
    mov rdi, t_stri1
    mov rsi, t_stri1
    call strcmp
    mov rsi, t_str2a
    jne testfail

    mov rdi, t_stri1
    mov rsi, t_stri2
    call strcmp
    mov rsi, t_str2b
    je testfail

    mov rdi, t_stri1
    mov rsi, t_stri3
    call strcmp
    mov rsi, t_str2c
    je testfail

    ret

t_str3a:
    db "strcpy basic"
    db 0x0
t_str3b:
    db "strcpy less"
    db 0x0
t_str3:
    push rax
    push rax
    mov rsi, t_stri1
    mov rdi, rsp
    call strcpy
    mov rsi, t_stri1
    mov rdi, rsp
    call strcmp
    mov rsi, t_str3a
    jne testfail

    mov rsi, t_stri2
    mov rdi, rsp
    call strcpy
    mov rsi, t_stri2
    mov rdi, rsp
    call strcmp
    mov rsi, t_str3b
    jne testfail

    pop rax
    pop rax
    ret
