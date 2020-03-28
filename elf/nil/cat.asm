    pop rcx
    pop rdi ; Program name
begin:
    dec ecx
    cmp ecx, 0
    je end
    mov eax, 2 ; sys_open
    pop rdi ; File name
    mov esi, 2
    push rcx
    syscall
    mov r15, rax
    push rax ; Or anything, really
beginloop:
    mov eax, 0 ; sys_read
    mov rdi, r15
    mov rsi, rsp
    mov edx, 1
    syscall
    cmp eax, 1
    jne endloop
    mov eax, 1 ; sys_write
    mov edi, 1 ; stdout
    mov rsi, rsp
    mov edx, 1
    syscall
    jmp beginloop
endloop:
    pop rax
    pop rcx
    jmp begin
end:
    mov eax, 60
    mov edi, 0
    syscall
