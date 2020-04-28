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
strcat:
strncat:
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
strncmp:
memcpy:

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
