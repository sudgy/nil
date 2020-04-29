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
; Source byte is in dl, destination in rdi, count in rcx
memset:
    cmp rcx, 0x0
    je return
    mov [rdi], dl
    add rdi, 0x1
    sub rcx, 0x1
    jmp memset

; In all of these, rsi is a null-terminated string.  They act like cmp, and if
; the string is what the function is looking for, it acts like "equal" and je
; will happen.
is_ident:
    mov rax, 0x0
    mov al, [rsi]
    call isalpha
    je is_idlop
    cmp rax, "_"
    jne return
  is_idlop:
    add rsi, 0x1
    mov al, [rsi]
    call isalnum
    je is_idlop
    cmp rax, "_"
    je is_idlop
    cmp rax, 0x0
    ret
is_dec:
    mov rax, 0x0
    mov al, [rsi]
    call isdigit
    jne return
    cmp rax, "0"
    je retfalse
  is_declp:
    add rsi, 0x1
    mov al, [rsi]
    cmp rax, 0x0
    je return
    call isdigit
    jne return
    jmp is_declp
is_hex:
    mov rax, 0x0
    mov al, [rsi]
    cmp rax, "0"
    jne return
    add rsi, 0x1
    mov al, [rsi]
    cmp rax, "x"
    je is_hexbg
    cmp rax, "X"
    jne return
  is_hexbg:
    add rsi, 0x1
    mov al, [rsi]
    call isxdigit
    jne return
  is_hexlp:
    add rsi, 0x1
    mov al, [rsi]
    cmp rax, 0x0
    je return
    call isxdigit
    jne return
    jmp is_hexlp
is_num:
    call is_dec
    je return
    jmp is_hex
