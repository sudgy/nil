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

; Get a token from a string.  Pass in your string in rsi.  It will skip any
; whitespace characters, then will read "a token" (more on the definition in a
; moment) from rsi, leaving rsi pointing at the first character right after the
; token (so this string can be passed to strgettk right away again).  The token
; that it finds will be copied into the string in rdi, so make sure you pass in
; a valid, large enough buffer for any token to go in.  If no token is found,
; rdi is set to zero.  This will not clobber rsi or rdi, but can change them.
;
; A token is one of the following:
;  - A sequence of alphanumeric characters and underscores
;  - Any single character of punctuation.  Note that for the moment "==" will be
;    parsed the same as "= =".  Same with "<<" or "+=" and such.
; A token will never contain whitespace of any kind.
strgettk:
    mov rax, 0x0
    mov al, [rsi]
    cmp rax, 0x0
    je strgette
    call isspace
    je strgetts
    call isalnum
    je strgettt
    cmp rax, "_"
    je strgettt
  strgettp: ; Punctuation
    mov rcx, 0x1
    push rsi
    push rdi
    call strncpy
    mov rax, 0x0
    mov [rdi], al ; We are sneaky and know what strncpy leaves rdi as
    pop rdi
    pop rsi
    add rsi, 0x1
    ret
  strgettt: ; Get a sequence of alphanumeric characters and underscores
    mov rcx, rsi
   strgettl:
    add rcx, 0x1
    mov al, [rcx]
    call isalnum
    je strgettl
    cmp rax, "_"
    je strgettl
    push rcx
    sub rcx, rsi
    push rdi
    call strncpy
    mov rax, 0x0
    mov [rdi], al ; We are sneaky and know what strncpy leaves rdi as
    pop rdi
    pop rsi
    ret
  strgetts: ; A space was found
    add rsi, 0x1
    jmp strgettk
  strgette: ; The end was found
    mov rdi, 0x0
    ret
