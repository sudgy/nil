; SASM: The sudgy assembler.
; This version is so old that it can't even assemble itself.  It is not
; finished.  To make it easier to assemble itself, only the following commands
; should be used in this file to start with:
;
;   syscall
;   mov (register), (immediate hex value)
;   mov (register), (register)
;   mov (register), [register]
;   mov [register], (register)
;   push (register)
;   pop (register)
;   jmp (label)
;   cmp (register), (immediate hex value)
;   cmp (register), (register)
;   je (label)
;   jne (label)
;   jl (label)
;   call (label)
;   ret
;   add (register, register)
;   sub (register, register)
;
; Because indirect addressing with rsp and rbp is more complicated, it doesn't
; work yet, which is sad because they're the ones you want to do it with the
; most.  Move them into another register first!
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
    ; Prepare the label list (see the label section for more details)
    mov rax, 0x0
    push rax ; First label entry
    mov rbp, rsp
    push rax ; First jump entry
    ; Start the assembling
line:
    call skipspac
    call lablchck
    ; Four-character strings
    call pushipos
    mov rdx, 0x4 ; Can only cmp 32-bit values :(
    call readn
    ; syscall
    cmp rax, 0x63737973 ; "sysc"
    je syscall_
    ; push
    cmp rax, 0x68737570 ; "push"
    je push_
    ; call
    cmp rax, 0x6C6C6163 ; "call"
    je call_
    call popipos
    ; Three-character strings
    call pushipos
    mov rdx, 0x3
    call readn
    ; mov
    cmp rax, 0x766F6D ; "mov"
    je mov_
    ; pop
    cmp rax, 0x706F70 ; "pop"
    je pop_
    ; jmp
    cmp rax, 0x706D6A ; "jmp"
    je jmp_
    ; cmp
    cmp rax, 0x706D63 ; "cmp"
    je cmp_
    ; jne
    cmp rax, 0x656E6A ; "jne"
    je jne_
    ; ret
    cmp rax, 0x746572 ; "ret"
    je ret_
    ; add
    cmp rax, 0x646461 ; "add"
    je add_
    ; sub
    cmp rax, 0x627573 ; "sub"
    je sub_
    call popipos
    ; Two-character strings
    call pushipos
    mov rdx, 0x2
    call readn
    ; je
    cmp rax, 0x656A ; "je"
    je je_
    ; jl
    cmp rax, 0x6C6A ; "jl"
    je jl_
    call popipos
    ; Nothing was found :(
err:
    mov rdi, 0x4
    jmp exit

;;;;;;;;;;;;;;;;;;;;;;;;
; INPUT FILE UTILITIES ;
;;;;;;;;;;;;;;;;;;;;;;;;

; Will store the byte in rax
readchar:
    mov rax, 0x0 ; sys_read
    mov rdi, 0x3
    push rax
    mov rsi, rsp
    mov rdx, 0x1
    syscall
    cmp rax, 0x0
    je cleanup
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
; Skip until next non-space
skipspac:
    call readchar
    cmp rax, 0x20
    je skipspac
    call iback
    ret
; Get the current position of the input file into rax
getipos:
    mov rax, 0x8 ; sys_lseek
    mov rdi, 0x3 ; Input file
    mov rsi, 0x0 ; No offset, we're reading
    mov rdx, 0x1 ; SEEK_CUR
    syscall
    ret
; Push the current position of the input file on the stack
pushipos:
    call getipos
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
; Go back one character in the input file
iback:
    mov rax, 0x8 ; sys_lseek
    mov rdi, 0x3
    mov rdx, 0x1 ; SEEK_CUR
    mov rsi, 0x0
    sub rsi, rdx ; Set rsi to -1, rdx happens to be 1 already
    syscall
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;
; OUTPUT FILE UTILITIES ;
;;;;;;;;;;;;;;;;;;;;;;;;;

; Write to the output file.  It assumes that the data is on the top of the stack
; and that you have already set rdx.
write:
    pop rbx
    mov rax, 0x1 ; sys_write
    mov rdi, 0x4 ; output file
    mov rsi, rsp
    syscall
    push rbx
    ret
; Write one byte from rax.  This was common enough that I wanted a separate
; subroutine.
write1:
    push rax
    mov rdx, 0x1
    call write
    pop rax
    ret
; Write two bytes from rax.  This was common enough that I wanted a separate
; subroutine.
write2:
    push rax
    mov rdx, 0x2
    call write
    pop rax
    ret
; Get the current position of the output file into rax
getopos:
    mov rax, 0x8 ; sys_lseek
    mov rdi, 0x4 ; Output file
    mov rsi, 0x0 ; No offset, we're reading
    mov rdx, 0x1 ; SEEK_CUR
    syscall
    ret
; Go to the position in rsi in the output file
oseek:
    mov rax, 0x8 ; sys_lseek
    mov rdi, 0x4 ; Output file
    mov rdx, 0x0 ; SEEK_SET
    syscall
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;
; MISCELANEOUS UTILITIES ;
;;;;;;;;;;;;;;;;;;;;;;;;;;

exit:
    mov rax, 0x3C
    syscall
return:
    ret
unreturn:
    push rax
    push rdx
    call iback
    pop rdx
    pop rax
    ret

;;;;;;;;;;
; LABELS ;
;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Here is how the labels work.  First, rbp points to the following values:
;
; rbp -> Address of first label entry (8 bytes)
;        Address of first jump entry (8 bytes)
;
; A label entry consists of the following:
;
;               Address of label in output file (8 bytes)
;               Name of label (8 bytes, zero padded if needed)
; pointed to -> Address of next label entry (8 bytes)
;
; A jump entry consists of the following:
;
;               Address after jump address in output file (8 bytes)
;               Name of label (8 bytes, zero padded if needed)
; pointed to -> Address of next jump entry (8 bytes)
;
; These are implemented as a linked list across the stack, because that is the
; easiest to make at the moment.  This system should get improved in the future.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check a line for a label
lablchck:
    call pushipos
  lblcloop:
    mov rdx, 0x1
    call readn
    cmp rax, 0xA ; Newline
    je lblckend
    cmp rax, 0x3B ; Semicolon
    je lblckend
    cmp rax, 0x3A ; Colon
    je label
    jmp lblcloop
  lblckend:
    call popipos
    ret
  label:
    call getipos
    mov rdx, 0x1
    sub rax, rdx ; Get rid of the colon
    pop rbx ; The value from pushipos
    push rax
    push rbx
    call popipos
    call getipos
    pop rdx
    ; Now the range of the label is [rax, rdx)
    sub rdx, rax ; rdx is now the length, hope it's valid (<= 8)
    call readn
    push rax
    mov rbx, rbp
  findlabl:
    mov rdx, [rbx]
    cmp rdx, 0x0
    je addlabel
    mov rbx, rdx
    jmp findlabl
  addlabel:
    call getopos
    pop rcx ; The label name
    push rax
    push rcx
    mov rax, 0x0
    push rax
    mov [rbx], rsp
    jmp skipcom

; Add a label found in a jump instruction or something to the output file to be
; dealt with later.  The label name should be passed in rax.
addjump:
    push rax
    ; First write the blank label really quickly.  It can be anything, so we
    ; don't care.
    mov rdx, 0x4
    call write
    ; Add a new jmp address
    mov rbx, rbp
    mov rdx, 0x8
    sub rbx, rdx
  addjumpl:
    mov rax, [rbx]
    cmp rax, 0x0
    je addjumpe
    mov rbx, [rbx]
    jmp addjumpl
  addjumpe:
    call getopos
    pop rcx ; The label name
    push rax
    push rcx
    mov rax, 0x0
    push rax
    mov [rbx], rsp
    jmp skipcom

; Go through all jumps and set them correctly
cleanup:
    mov rbx, rbp
    mov rdx, 0x8 ; This will be used to increment and decrement pointers a lot
  cleanlop:
    sub rbx, rdx
    mov rdi, 0x0 ; In case we exit
    mov rax, [rbx]
    cmp rax, 0x0
    je exit
    mov rbx, [rbx]
    add rbx, rdx
    mov rsi, [rbx]
    mov rcx, rbp
  clnfndlb:
    mov rcx, [rcx]
    add rcx, rdx
    mov rdi, [rcx]
    cmp rsi, rdi
    je foundlbl
    sub rcx, rdx
    jmp clnfndlb
  foundlbl:
    add rbx, rdx
    add rcx, rdx
    mov rsi, [rbx]
    mov rdi, [rcx]
    sub rdi, rsi
    push rbx
    push rdi
    mov rax, 0x4 ; remember that the index saved in a jmp instruction is after
                 ; the instruction
    sub rsi, rax
    call oseek
    mov rdx, 0x4
    call write
    pop rdi
    pop rbx
    mov rdx, 0x8 ; This is also resetting it for the beginning
    sub rbx, rdx
    jmp cleanlop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INSTRUCTION READING HELPERS ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Read a register, storing it numerically in rax
readreg:
    mov rdx, 0x3
    call readn
    mov rdx, rax
    cmp rdx, 0x786172 ; "rax"
      mov rax, 0x0
      je return
    cmp rdx, 0x786372 ; "rcx"
      mov rax, 0x1
      je return
    cmp rdx, 0x786472 ; "rdx"
      mov rax, 0x2
      je return
    cmp rdx, 0x786272 ; "rbx"
      mov rax, 0x3
      je return
    cmp rdx, 0x707372 ; "rsp"
      mov rax, 0x4
      je return
    cmp rdx, 0x706272 ; "rbp"
      mov rax, 0x5
      je return
    cmp rdx, 0x697372 ; "rsi"
      mov rax, 0x6
      je return
    cmp rdx, 0x696472 ; "rdi"
      mov rax, 0x7
      je return
    call err
; Read a hex value into rdx.  Assumes that "0x" has already been parsed.
; Currently, if the digits are not ended by a newline, space, or semicolon, the
; behavior is undefined.
readhex:
    mov rdx, 0x0 ; Result
  rdhexbeg:
    push rdx
    mov rdx, 0x1
    call readn
    pop rdx
    cmp rax, 0xA ; newline
    je unreturn
    cmp rax, 0x20 ; space
    je unreturn
    cmp rax, 0x3B ; semicolon
    je unreturn
    mov rcx, 0x30 ; Convert ASCII digit to number
    sub rax, rcx
    cmp rax, 0xA ; Check if the digit is a letter
    jl rdhexdig
    mov rcx, 0x7 ; Convert ASCII Letter to number (already subtracted 0x30)
    sub rax, rcx
  rdhexdig:
    ; Multiply rdx by 0x10
    add rdx, rdx
    add rdx, rdx
    add rdx, rdx
    add rdx, rdx
    ; Combine values
    add rdx, rax
    jmp rdhexbeg

; This will read two paramaters, such as in "cmp rax, 0x10" or "mov [rbx], rsp".
; The destination register will be put into rdi, and the source register or
; value will be put into rsi.  rax will be set to the following values to
; specify what kinds of operands rdi and rsi are:
;
;   0: Both are direct registers.
;   1: Source is indirect register, destination is direct register.
;   2: Source is direct register, destination is indirect register.
;   3: Source is immediate value, destination is direct register.
;
; Keep in mind that all of the instructions that call this may not check for all
; of the values of rax, at least at the moment.
readtwo:
    call skipspac
    call readchar ; Check for '['
    cmp rax, 0x5B ; '['
    je readtwo2
    call iback
    call readreg
    push rax
    call readchar ; For the ',', hope it's there.
    call skipspac
    call readchar ; Determine if it's a register or an immediate value
    cmp rax, 0x30
    je readtwo3
    cmp rax, 0x5B ; '['
    je readtwo1
  readtwo0:
    call iback
    call readreg
    mov rsi, rax
    pop rdi
    mov rax, 0x0
    ret
  readtwo1:
    call readreg
    mov rsi, rax
    pop rdi
    mov rax, 0x1
    ret
  readtwo2:
    call readreg
    push rax
    call readchar ; For the '[', hope it's there.
    call readchar ; For the ',', hope it's there.
    call skipspac
    call readreg
    mov rsi, rax
    pop rdi
    mov rax, 0x2
    ret
  readtwo3:
    call readchar ; Hope that the next character is 'x'
    call readhex ; rdx now has the immediate value
    mov rsi, rdx
    pop rdi
    mov rax, 0x3
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;
; SPECIFIC INSTRUCTIONS ;
;;;;;;;;;;;;;;;;;;;;;;;;;

syscall_:
    mov rdx, 0x3
    call readn
    cmp rax, 0x6C6C61 ; "all"
    jne err
    mov rax, 0x050F ; syscall opcode
    call write2
    jmp skipcom
mov_:
    call readtwo
    cmp rax, 0x3
    je mov3
    cmp rax, 0x2
    je mov2
    cmp rax, 0x1
    je mov1
    ; Assume rax is 0
  mov0:
    push rdi
    push rsi
    mov rax, 0x8B48 ; REW.W + MOV opcode
    call write2
    ; Create ModRM Byte
    pop rsi ; ModRM.rm
    pop rdi ; ModRM.reg
    add rdi, rdi
    add rdi, rdi
    add rdi, rdi
    add rdi, rsi
    mov rax, 0xC0
    add rax, rdi
    call write1
    jmp skipcom
  mov1:
    push rdi
    push rsi
    mov rax, 0x8B48 ; REX.W + MOV opcode
    call write2
    ; Create ModRM Byte
    pop rax ; ModRM.rm
    pop rdi ; ModRM.reg
    add rdi, rdi
    add rdi, rdi
    add rdi, rdi
    add rax, rdi
    call write1
    jmp skipcom
  mov2:
    push rdi
    push rsi
    mov rax, 0x8948 ; REX.W + MOV opcode
    call write2
    pop rsi ; ModRM.reg
    pop rax ; ModRM.rm
    add rsi, rsi
    add rsi, rsi
    add rsi, rsi
    add rax, rsi
    call write1
    jmp skipcom
  mov3:
    push rsi
    mov rax, 0xB8 ; MOV opcode
    add rax, rdi
    call write1
    mov rdx, 0x4
    call write
    pop rsi
    jmp skipcom
pushpop:
    call skipspac
    call readreg
    add rax, rbx
    call write1
    jmp skipcom
push_:
    mov rbx, 0x50
    jmp pushpop
pop_:
    mov rbx, 0x58
    jmp pushpop
jmp_com:
    call skipspac
    call pushipos
  jmp_coml:
    mov rdx, 0x1
    call readn
    cmp rax, 0xA ; Newline
    je jmp_come
    cmp rax, 0x20 ; Space
    je jmp_come
    cmp rax, 0x3B ; Semicolon
    je jmp_come
    jmp jmp_coml
  jmp_come:
    call iback
    call getipos
    pop rbx
    push rax
    push rbx
    call popipos
    call getipos
    pop rdx
    sub rdx, rax
    call readn
    call addjump
jmp_:
    mov rax, 0xE9
    call write1
    jmp jmp_com
je_:
    mov rax, 0x840F
    call write2
    jmp jmp_com
jne_:
    mov rax, 0x850F
    call write2
    jmp jmp_com
jl_:
    mov rax, 0x8C0F
    call write2
    jmp jmp_com
call_:
    mov rax, 0xE8
    call write1
    jmp jmp_com
cmp_:
    call readtwo
    cmp rax, 0x3
    je cmp3
  cmp0:
    push rdi
    push rsi
    mov rax, 0x3B48 ; REX.W + CMP opcode
    call write2
    pop rsi
    pop rdi
    ; Make ModRM byte
    add rdi, rdi
    add rdi, rdi
    add rdi, rdi
    add rsi, rdi
    mov rax, 0xC0
    add rax, rsi
    call write1
    jmp skipcom
  cmp3:
    push rsi
    push rdi
    mov rax, 0x8148 ; REX.W + CMP opcode
    call write2
    mov rax, 0xF8 ; ModRM byte except for register
    pop rdi
    add rax, rdi
    call write1
    mov rdx, 0x4
    call write
    pop rsi
    jmp skipcom
ret_:
    mov rax, 0xC3
    call write1
    jmp skipcom
addsub:
    call readtwo ; Assumes rax == 0 for now
    add rdi, rdi
    add rdi, rdi
    add rdi, rdi
    mov rax, 0xC0
    add rax, rdi
    add rax, rsi
    call write1
    jmp skipcom
add_:
    mov rax, 0x0348 ; REX.W + ADD opcode
    call write2
    jmp addsub
sub_:
    mov rax, 0x2B48 ; REX.W + SUB opcode
    call write2
    jmp addsub
