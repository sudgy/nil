    pop rcx
    cmp ecx, 1 ; Make sure there is a parameter
    jne begin
    mov eax, 60
    mov edi, 1
    syscall
begin:
    pop rdi ; Program name
    pop rdi ; File name
    mov eax, 2
    mov esi, 64 ; O_CREAT
    mov edx, 0x1B4 ; 664 Permissions
    syscall
    mov edi, eax
    mov eax, 3
    syscall
    mov eax, 60
    mov edi, 0
    syscall
