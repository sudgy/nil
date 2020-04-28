; source and destination in rsi and rdi
strcpy:
    mov rax, 0x0
  strcpylp:
    mov al, [rsi]
    mov [rdi], al
    cmp rax, 0x0
    je return
    add rsi, 0x1
    add rdi, 0x1
    jmp strcpylp
; source and destination in rsi and rdi, count in rcx
strncpy:
    mov rax, 0x0
  strncpyl:
    cmp rcx, 0x0
    je return
    mov al, [rsi]
    mov [rdi], al
    cmp rax, 0x0
    je return
    add rsi, 0x1
    add rdi, 0x1
    sub rcx, 0x1
    jmp strncpyl
; source and destination in rsi and rdi
strcat:
    mov rax, 0x0
  strcatlp:
    mov al, [rdi]
    cmp rax, 0x0
    je strcpylp
    add rdi, 0x1
    jmp strcatlp
; String in rsi
strlen:
    mov rax, 0x0
    mov rdx, 0x0
  strlenlp:
    mov dl, [rsi]
    cmp rdx, 0x0
    je return
    add rax, 0x1
    add rsi, 0x1
    jmp strlenlp
; This is not like C's strcmp!  Call this with strings in rsi and rdi, then you
; can use je or jne.
strcmp:
    mov al, [rsi]
    mov dl, [rdi]
    cmp al, dl
    jne return
    cmp al, 0x0
    je return
    add rsi, 0x1
    add rdi, 0x1
    jmp strcmp
; source and destination in rsi and rdi, count in rcx
memcpy:
    cmp rcx, 0x0
    je return
    mov al, [rsi]
    mov [rdi], al
    add rsi, 0x1
    add rdi, 0x1
    sub rcx, 0x1
    jmp memcpy
; Source byte in in dl, destination in rdi, count in rcx
memset:
    cmp rcx, 0x0
    je return
    mov [rdi], dl
    add rdi, 0x1
    sub rcx, 0x1
    jmp memset

is_toke:
is_iden:
is_num:
is_dec:
is_hex:
is_ntoke:
is_niden:
is_nnum:
is_ndec:
is_nhex:
