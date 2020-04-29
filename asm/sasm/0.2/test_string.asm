test_str:
    call t_str1
    call t_str2
    call t_str3
    call t_str4
    call t_str5
    call t_str6
    call t_str7
    call t_str8
    call t_str9
    call t_str10
    call t_str11
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
    ret

t_str8a:
    db "is_ident with "
t_str8b:
    db "ident_a"
    db 0x0
t_str8c:
    db "is_ident with "
t_str8d:
    db "_ident"
    db 0x0
t_str8e:
    db "is_ident with empty string"
t_str8f:
    db 0x0
t_str8g:
    db "is_ident with "
t_str8h:
    db "["
    db 0x0
t_str8i:
    db "is_ident with "
t_str8j:
    db "two words"
    db 0x0
t_str8k:
    db "is_ident with "
t_str8l:
    db "word_sym["
    db 0x0
t_str8m:
    db "is_ident with "
t_str8n:
    db "0ab"
    db 0x0
t_str8o:
    db "is_ident with "
t_str8p:
    db "ab0"
    db 0x0
t_str8:
    mov rsi, t_str8b
    call is_ident
    mov rsi, t_str8a
    jne testfail
    mov rsi, t_str8d
    call is_ident
    mov rsi, t_str8c
    jne testfail
    mov rsi, t_str8f
    call is_ident
    mov rsi, t_str8e
    je testfail
    mov rsi, t_str8h
    call is_ident
    mov rsi, t_str8g
    je testfail
    mov rsi, t_str8j
    call is_ident
    mov rsi, t_str8i
    je testfail
    mov rsi, t_str8l
    call is_ident
    mov rsi, t_str8k
    je testfail
    mov rsi, t_str8n
    call is_ident
    mov rsi, t_str8m
    je testfail
    mov rsi, t_str8p
    call is_ident
    mov rsi, t_str8o
    jne testfail
    ret

t_str9a:
    db "is_dec with "
t_str9b:
    db "527"
    db 0x0
t_str9c:
    db "is_dec with "
t_str9d:
    db "527a"
    db 0x0
t_str9e:
    db "is_dec with "
t_str9f:
    db "a527"
    db 0x0
t_str9g:
    db "is_dec with "
t_str9h:
    db "0x57"
    db 0x0
t_str9i:
    db "is_dec with empty string"
t_str9j:
    db 0x0
t_str9k:
    db "is_dec with "
t_str9l:
    db "057"
    db 0x0
t_str9:
    mov rsi, t_str9b
    call is_dec
    mov rsi, t_str9a
    jne testfail
    mov rsi, t_str9d
    call is_dec
    mov rsi, t_str9c
    je testfail
    mov rsi, t_str9f
    call is_dec
    mov rsi, t_str9e
    je testfail
    mov rsi, t_str9h
    call is_dec
    mov rsi, t_str9g
    je testfail
    mov rsi, t_str9j
    call is_dec
    mov rsi, t_str9i
    je testfail
    mov rsi, t_str9l
    call is_dec
    mov rsi, t_str9k
    je testfail
    ret

t_str10a:
    db "is_hex with "
t_str10b:
    db "0x50aF7"
    db 0x0
t_str10c:
    db "is_hex with "
t_str10d:
    db "0XF"
    db 0x0
t_str10e:
    db "is_hex with "
t_str10f:
    db "0x50aFg"
    db 0x0
t_str10g:
    db "is_hex with "
t_str10h:
    db "50aF"
    db 0x0
t_str10i:
    db "is_hex with "
t_str10j:
    db "50"
    db 0x0
t_str10k:
    db "is_dec with empty string"
t_str10l:
    db 0x0
t_str10m:
    db "is_hex with "
t_str10n:
    db "0x"
    db 0x0
t_str10:
    mov rsi, t_str10b
    call is_hex
    mov rsi, t_str10a
    jne testfail
    mov rsi, t_str10d
    call is_hex
    mov rsi, t_str10c
    jne testfail
    mov rsi, t_str10f
    call is_hex
    mov rsi, t_str10e
    je testfail
    mov rsi, t_str10h
    call is_hex
    mov rsi, t_str10g
    je testfail
    mov rsi, t_str10j
    call is_hex
    mov rsi, t_str10i
    je testfail
    mov rsi, t_str10l
    call is_hex
    mov rsi, t_str10k
    je testfail
    mov rsi, t_str10n
    call is_hex
    mov rsi, t_str10m
    je testfail
    ret

t_str11a:
    db "is_num with "
t_str11b:
    db "52"
    db 0x0
t_str11c:
    db "is_num with "
t_str11d:
    db "0x52F"
    db 0x0
t_str11e:
    db "is_num with "
t_str11f:
    db "52F"
    db 0x0
t_str11g:
    db "is_num with "
t_str11h:
    db "052"
    db 0x0
t_str11i:
    db "is_num with "
t_str11j:
    db "G"
    db 0x0
t_str11k:
    db "is_num with empty string"
t_str11l:
    db 0x0
t_str11:
    mov rsi, t_str11b
    call is_num
    mov rsi, t_str11a
    jne testfail
    mov rsi, t_str11d
    call is_num
    mov rsi, t_str11c
    jne testfail
    mov rsi, t_str11f
    call is_num
    mov rsi, t_str11e
    je testfail
    mov rsi, t_str11h
    call is_num
    mov rsi, t_str11g
    je testfail
    mov rsi, t_str11j
    call is_num
    mov rsi, t_str11i
    je testfail
    mov rsi, t_str11l
    call is_num
    mov rsi, t_str11k
    je testfail
    ret
