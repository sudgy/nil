    pop rcx
    add ecx, 2607
    push rcx
    mov eax, 1
    mov edi, 1
    mov esi, esp
    mov edx, 8
    syscall
    pop rcx
    sub ecx, 2607
    pop rsi
begin:
    pop rsi
    dec ecx
    cmp ecx, 0
    je end
    mov rdx, rsi
beginloop:
    cmp [rdx], byte 0
    je endloop
    inc rdx
    jmp beginloop
endloop:
    sub rdx, rsi
    mov eax, 1
    mov edi, 1
    push rcx
    syscall
    push 10
    mov eax, 1
    mov edi, 1
    mov rsi, rsp
    mov edx, 1
    syscall
    pop rcx
    pop rcx
    jmp begin
end:
    mov eax, 60
    mov edi, 0
    syscall
