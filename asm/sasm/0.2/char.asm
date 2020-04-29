; pass in rax, it will not change it.  true = je, false = jne.
islower:
    cmp rax, "a"
    jl return
    cmp rax, "{"
    jl rettrue
    jmp retfalse
isupper:
    cmp rax, "A"
    jl return
    cmp rax, "["
    jl rettrue
    jmp retfalse
isalpha:
    call isupper
    je return
    jmp islower
isdigit:
    cmp rax, "0"
    jl return
    cmp rax, 0x3A ; Colon
    jl rettrue
    jmp retfalse
isxdigit:
    call isdigit
    je return
    cmp rax, "A"
    jl return
    cmp rax, "G"
    jl rettrue
    cmp rax, "a"
    jl return
    cmp rax, "g"
    jl rettrue
    jmp retfalse
isalnum:
    call isalpha
    je return
    jmp isdigit
isspace:
    cmp rax, " "
    je return
    cmp rax, 0x9
    jl return
    cmp rax, 0xE
    jl rettrue
    jmp retfalse
