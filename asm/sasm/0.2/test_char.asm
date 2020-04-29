test_cha:
    call t_cha1
    call t_cha2
    call t_cha3
    call t_cha4
    call t_cha5
    call t_cha6
    call t_cha7
    ret

t_cha1a:
    db "islower with a"
    db 0x0
t_cha1b:
    db "islower with m"
    db 0x0
t_cha1c:
    db "islower with z"
    db 0x0
t_cha1d:
    db "islower with `"
    db 0x0
t_cha1e:
    db "islower with {"
    db 0x0
t_cha1f:
    db "islower with M"
    db 0x0
t_cha1:
    mov rax, "a"
    call islower
    mov rsi, t_cha1a
    jne testfail
    mov rax, "m"
    call islower
    mov rsi, t_cha1b
    jne testfail
    mov rax, "z"
    call islower
    mov rsi, t_cha1c
    jne testfail
    mov rax, "`"
    call islower
    mov rsi, t_cha1d
    je testfail
    mov rax, "{"
    call islower
    mov rsi, t_cha1e
    je testfail
    mov rax, "M"
    call islower
    mov rsi, t_cha1f
    je testfail
    ret

t_cha2a:
    db "isupper with A"
    db 0x0
t_cha2b:
    db "isupper with M"
    db 0x0
t_cha2c:
    db "isupper with Z"
    db 0x0
t_cha2d:
    db "isupper with @"
    db 0x0
t_cha2e:
    db "isupper with ["
    db 0x0
t_cha2f:
    db "isupper with m"
    db 0x0
t_cha2:
    mov rax, "A"
    call isupper
    mov rsi, t_cha2a
    jne testfail
    mov rax, "M"
    call isupper
    mov rsi, t_cha2b
    jne testfail
    mov rax, "Z"
    call isupper
    mov rsi, t_cha2c
    jne testfail
    mov rax, "@"
    call isupper
    mov rsi, t_cha2d
    je testfail
    mov rax, "["
    call isupper
    mov rsi, t_cha2e
    je testfail
    mov rax, "m"
    call isupper
    mov rsi, t_cha2f
    je testfail
    ret

t_cha3a:
    db "isalpha with E"
    db 0x0
t_cha3b:
    db "isalpha with 0"
    db 0x0
t_cha3c:
    db "isalpha with !"
    db 0x0
t_cha3d:
    db "isalpha with z"
    db 0x0
t_cha3:
    mov rax, "E"
    call isalpha
    mov rsi, t_cha3a
    jne testfail
    mov rax, "0"
    call isalpha
    mov rsi, t_cha3b
    je testfail
    mov rax, "!"
    call isalpha
    mov rsi, t_cha3c
    je testfail
    mov rax, "z"
    call isalpha
    mov rsi, t_cha3d
    jne testfail
    ret

t_cha4a:
    db "isdigit with /"
    db 0x0
t_cha4b:
    db "isdigit with 0"
    db 0x0
t_cha4c:
    db "isdigit with 9"
    db 0x0
t_cha4d:
    db "isdigit with "
    db 0x3A ; A colon
    db 0x0
t_cha4:
    mov rax, "/"
    call isdigit
    mov rsi, t_cha4a
    je testfail
    mov rax, "0"
    call isdigit
    mov rsi, t_cha4b
    jne testfail
    mov rax, "9"
    call isdigit
    mov rsi, t_cha4c
    jne testfail
    mov rax, 0x3A ; A colon
    call isdigit
    mov rsi, t_cha4d
    je testfail
    ret

t_cha5a:
    db "isxdigit with /"
    db 0x0
t_cha5b:
    db "isxdigit with 0"
    db 0x0
t_cha5c:
    db "isxdigit with 9"
    db 0x0
t_cha5d:
    db "isxdigit with "
    db 0x3A ; A colon
    db 0x0
t_cha5e:
    db "isxdigit with @"
    db 0x0
t_cha5f:
    db "isxdigit with A"
    db 0x0
t_cha5g:
    db "isxdigit with F"
    db 0x0
t_cha5h:
    db "isxdigit with G"
    db 0x0
t_cha5i:
    db "isxdigit with `"
    db 0x0
t_cha5j:
    db "isxdigit with a"
    db 0x0
t_cha5k:
    db "isxdigit with f"
    db 0x0
t_cha5l:
    db "isxdigit with g"
    db 0x0
t_cha5:
    mov rax, "/"
    call isxdigit
    mov rsi, t_cha5a
    je testfail
    mov rax, "0"
    call isxdigit
    mov rsi, t_cha5b
    jne testfail
    mov rax, "9"
    call isxdigit
    mov rsi, t_cha5c
    jne testfail
    mov rax, 0x3A ; A colon
    call isxdigit
    mov rsi, t_cha5d
    je testfail
    mov rax, "@"
    call isxdigit
    mov rsi, t_cha5a
    je testfail
    mov rax, "A"
    call isxdigit
    mov rsi, t_cha5b
    jne testfail
    mov rax, "F"
    call isxdigit
    mov rsi, t_cha5c
    jne testfail
    mov rax, "G"
    call isxdigit
    mov rsi, t_cha5d
    je testfail
    mov rax, "`"
    call isxdigit
    mov rsi, t_cha5a
    je testfail
    mov rax, "a"
    call isxdigit
    mov rsi, t_cha5b
    jne testfail
    mov rax, "f"
    call isxdigit
    mov rsi, t_cha5c
    jne testfail
    mov rax, "g"
    call isxdigit
    mov rsi, t_cha5d
    je testfail
    ret

t_cha6a:
    db "isalnum with e"
    db 0x0
t_cha6a:
    db "isalnum with E"
    db 0x0
t_cha6a:
    db "isalnum with 5"
    db 0x0
t_cha6a:
    db "isalnum with {"
    db 0x0
t_cha6a:
    db "isalnum with ~"
    db 0x0
t_cha6:
    mov rax, "e"
    call isalnum
    mov rsi, t_cha6a
    jne testfail
    mov rax, "E"
    call isalnum
    mov rsi, t_cha6a
    jne testfail
    mov rax, "5"
    call isalnum
    mov rsi, t_cha6a
    jne testfail
    mov rax, "{"
    call isalnum
    mov rsi, t_cha6a
    je testfail
    mov rax, "~"
    call isalnum
    mov rsi, t_cha6a
    je testfail
    ret

t_cha7a:
    db "isspace with space"
    db 0x0
t_cha7b:
    db "isspace with form feed"
    db 0x0
t_cha7c:
    db "isspace with line feed"
    db 0x0
t_cha7d:
    db "isspace with carriage return"
    db 0x0
t_cha7e:
    db "isspace with horizontal tab"
    db 0x0
t_cha7f:
    db "isspace with vertical tab"
    db 0x0
t_cha7g:
    db "isspace with A"
    db 0x0
t_cha7h:
    db "isspace with 5"
    db 0x0
t_cha7i:
    db "isspace with !"
    db 0x0
t_cha7:
    mov rax, " "
    call isspace
    mov rsi, t_cha7a
    jne testfail
    mov rax, 0x0C
    call isspace
    mov rsi, t_cha7b
    jne testfail
    mov rax, 0xA
    call isspace
    mov rsi, t_cha7c
    jne testfail
    mov rax, 0xD
    call isspace
    mov rsi, t_cha7d
    jne testfail
    mov rax, 0x9
    call isspace
    mov rsi, t_cha7e
    jne testfail
    mov rax, 0xB
    call isspace
    mov rsi, t_cha7f
    jne testfail
    mov rax, "A"
    call isspace
    mov rsi, t_cha7g
    je testfail
    mov rax, "5"
    call isspace
    mov rsi, t_cha7h
    je testfail
    mov rax, "!"
    call isspace
    mov rsi, t_cha7i
    je testfail
