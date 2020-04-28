test_str:
    call t_str1
    call t_str2
    call t_str3
    call t_str4
    call t_str5
    call t_str6
    call t_str7
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
t_stri4:
    db "Shot string 1"
    db 0x0
t_stri5:
    db "Test string 1Short"
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

t_str4a:
    db "strncpy normal"
    db 0x0
t_str4b:
    db "strncpy less"
    db 0x0
t_str4:
    push rax
    push rax
    mov rsi, t_stri1
    mov rdi, rsp
    mov rcx, 0x15
    call strncpy
    mov rsi, t_stri1
    mov rdi, rsp
    call strcmp
    mov rsi, t_str4a
    jne testfail

    mov rsi, t_stri2
    mov rdi, rsp
    mov rcx, 0x3
    call strncpy
    mov rsi, t_stri4
    mov rdi, rsp
    call strcmp
    mov rsi, t_str4b
    jne testfail

    pop rax
    pop rax
    ret

t_str5a:
    db "strcat"
    db 0x0
t_str5:
    push rax
    push rax
    push rax
    mov rdi, rsp
    mov rsi, t_stri1
    call strcpy
    mov rdi, rsp
    mov rsi, t_stri2
    call strcat
    mov rdi, rsp
    mov rsi, t_stri5
    call strcmp
    mov rsi, t_str5a
    jne testfail
    pop rax
    pop rax
    pop rax
    ret

t_str6a:
    db "memcpy"
    db 0x0
t_str6:
    push rax
    push rax
    mov rsi, t_stri1
    mov rdi, rsp
    call strcpy
    mov rsi, t_stri2
    mov rdi, rsp
    mov rcx, 0x3
    call memcpy
    mov rsi, t_stri4
    mov rdi, rsp
    call strcmp
    mov rsi, t_str6a
    jne testfail
    pop rax
    pop rax
    ret

t_str7a:
    db "memset"
    db 0x0
t_str7:
    mov rax, 0x0
    push rax
    mov rdx, 0x03
    mov rdi, rsp
    mov rcx, 0x3
    call memset
    pop rax
    cmp rax, 0x030303
    mov rsi, t_str7a
    jne testfail
    pop rax
    ret
