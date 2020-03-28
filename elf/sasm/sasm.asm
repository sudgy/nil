; SASM: The sudgy assembler.
; This version is so old that it can't even assemble itself.  It is not
; finished.  To make it easier to assemble itself, only the following commands
; should be used to start with:
;   syscall
;   mov (register), (immediate hex value)
;   mov (register), (register)
;   push (register)
;   pop (register)
;   jmp (label)
;   cmp (register)
;   je (label)
;   jne (label)
;   call (label)
;   ret
;   add (register, register)
    pop rcx
    mov rdi, 0x1 ; In case we exit
    cmp rcx, 0x3
    jne exit
    pop rdi ; Program name
    ; Open input file
    pop rdi ; Input file name
    mov rax, 0x2 ; Open file syscall
    mov rsi, 0x2 ; R_RDWR
    syscall
    mov rdi, 0x2 ; In case we exit
    cmp rax, 0x3 ; Input file will always be file 3
    jne exit
    ; Open output file
    pop rdi ; Output file name
    mov rax, 0x2
    mov rsi, 0x42 ; O_CREAT | R_RDWR
    mov rdx, 0x1FD ; 775 Permissions
    syscall
    mov rdi, 0x3 ; In case we exit
    cmp rax, 0x4 ; Output file will always be file 4
    jne exit
    ; Write headers
    mov rax, 0x1
    mov rdi, 0x4
    mov rsi, 0x08000000
    mov rdx, 0x78
    syscall
    ; Start the assembling
line:
    call skipspac
    call pushipos
    ; syscall
    mov rdx, 0x4 ; Can only cmp 32-bit values :(
    call readn
    cmp rax, 0x63737973 ; "sysc"
    je syscall_
    call popipos
    ; Nothing was found :(
err:
    mov rdi, 0x4
    jmp exit
syscall_:
    mov rdx, 0x3
    call readn
    cmp rax, 0x6C6C61 ; "all"
    jne err
    mov rax, 0x050F ; syscall opcode
    push rax
    mov rax, 1
    mov rdi, 4
    mov rsi, rsp
    mov rdx, 2
    syscall
    jmp skipcom
; Will store the byte in rax
readchar:
    mov rax, 0x0 ; sys_read
    mov rdi, 0x3
    push rax
    mov rsi, rsp
    mov rdx, 0x1
    syscall
    mov rdi, 0x0 ; In case we exit
    cmp rax, 0x0
    je exit
    ; Get value and check for special cases
    pop rax
    cmp rax, 0xA ; If newline
    je line ; Yes, there will eventually be a stack overflow, who cares
    cmp rax, 0x3B ; If comment
    je skipcom
    ret
; Skips to the end of the line
skipcom:
    call readchar
    jmp skipcom
; Skip until next space
skipspac:
    call readchar
    cmp rax, 0x20
    je skipspac
    ; Go back one spot in the file so that the next read starts at the right
    ; spot
    mov rax, 0x8 ; sys_lseek
    mov rdi, 0x3
    mov rsi, 0xFFFFFFFFFFFFFFFF ; -1 :/
    mov rdx, 0x1 ; SEEK_CUR
    syscall
    ret
; Push the current position of the input file on the stack
pushipos:
    mov rax, 0x8 ; sys_lseek
    mov rdi, 0x3
    mov rsi, 0x0 ; No offset, we're reading
    mov rdx, 0x1 ; SEEK_CUR
    syscall
    pop rbx
    push rax
    push rbx
    ret
; Pop the current position of the input file (as set by pushipos) from the stack
; and set the offset of the file to that value
popipos:
    mov rax, 0x8 ; sys_lseek
    mov rdi, 0x3
    pop rbx
    pop rsi ; The offset
    push rbx
    mov rdx, 0x0 ; SEEK_SET
    syscall
    ret
; Read n characters.  Set rdx to the number of characters to read.  Rdx must be
; less than or equal to 8.  The resulting bytes will be the value of rax.
readn:
    mov rax, 0x0
    mov rdi, 0x3
    push rax
    mov rsi, rsp
    syscall
    pop rax
    ret
exit:
    mov rax, 0x3C
    syscall
