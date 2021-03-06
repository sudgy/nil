; SASM: The sudgy assembler.
; This version is so old that it can barely assemble itself.  It is not
; finished.  Only the following commands are implemented:
;
;   syscall
;   mov (register), (immediate hex value or string)
;   mov (register), (register)
;   mov (register), [register]
;   mov [register], (register)
;   mov (registor), (label)
;   push (register)
;   pop (register)
;   jmp (label)
;   cmp (register), (immediate hex value or string)
;   cmp (register), (register)
;   je (label)
;   jne (label)
;   jl (label)
;   call (label)
;   ret
;   add (register), (register)
;   add (register), (immediate hex value or string)
;   sub (register), (register)
;   sub (register), (immediate hex value or string)
;   shl (register), (immediate hex value or string)
;   shr (register), (immediate hex value or string)
;   mul (register)
;   div (register)
;   db (immediate hex value or string)
;
; Because indirect addressing with rsp and rbp is more complicated, it doesn't
; work yet, which is sad because they're the ones you want to do it with the
; most.  Move them into another register first!
    pop rcx
    mov rdi, 0x1 ; In case we exit
    cmp rcx, 0x3
    jl exit
    pop rdi ; Program name
    ; Open input file
    pop rdi ; Input file name
    push rcx
    mov rax, 0x2 ; Open file syscall
    mov rsi, 0x2 ; R_RDWR
    syscall
    mov rdi, 0x2 ; In case we exit
    cmp rax, 0x3 ; Input file will always be file 3
    jne exit
    ; Open output file
    pop rcx
    sub rcx, 0x3
    shl rcx, 0x3
    mov rbx, rsp
    add rbx, rcx
    push rbx ; Save this for later, it's after the last address of input files
    mov rdi, [rbx]
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
    ; Prepare the stack.  The label section has some stuff about how it uses the
    ; stack, but there are other things here.  The first two elements of the
    ; stack have to do with labels, the third element is what line number we are
    ; on, the fourth is the address of the next file to open, and the fifth is
    ; after the last address of the files to open.
    pop rdx ; This is from earlier, it will be the address after the input files
    mov rax, 0x0
    mov rbx, rsp
    push rax ; First label entry
    mov rbp, rsp
    push rax ; First jump entry
    push rax ; Line number
    push rbx ; Next file
    push rdx ; After next files
    ; Start the assembling
line:
    ; Increment line number
    mov rax, rbp
    sub rax, 0x10
    mov rdx, [rax]
    add rdx, 0x1
    mov [rax], rdx

    call skipspac
    call lablchck
    ; Four-character strings
    call pushipos
    mov rdx, 0x4 ; Can only cmp 32-bit values :(
    call readn
    ; syscall
    cmp rax, "sysc"
    je syscall_
    ; push
    cmp rax, "push"
    je push_
    ; call
    cmp rax, "call"
    je call_
    call popipos
    ; Three-character strings
    call pushipos
    mov rdx, 0x3
    call readn
    ; mov
    cmp rax, "mov"
    je mov_
    ; pop
    cmp rax, "pop"
    je pop_
    ; jmp
    cmp rax, "jmp"
    je jmp_
    ; cmp
    cmp rax, "cmp"
    je cmp_
    ; jne
    cmp rax, "jne"
    je jne_
    ; ret
    cmp rax, "ret"
    je ret_
    ; add
    cmp rax, "add"
    je add_
    ; sub
    cmp rax, "sub"
    je sub_
    ; shl
    cmp rax, "shl"
    je shl_
    ; shr
    cmp rax, "shr"
    je shr_
    ; mul
    cmp rax, "mul"
    je mul_
    ; div
    cmp rax, "div"
    je div_
    call popipos
    ; Two-character strings
    call pushipos
    mov rdx, 0x2
    call readn
    ; je
    cmp rax, "je"
    je je_
    ; jl
    cmp rax, "jl"
    je jl_
    ; db
    cmp rax, "db"
    je db_
    call popipos
    ; Nothing was found :(
err:
    ; Output line number
    mov rax, rbp
    sub rax, 0x10
    mov rax, [rax]
    call numtostr
    push rdi
    mov rdx, 0x8
    call printerr
    mov rax, 0xA
    push rax
    mov rdx, 0x1
    call printerr

    mov rdi, 0x4
    jmp exit

;;;;;;;;;;;;;;;;;;;;;;;;
; INPUT FILE UTILITIES ;
;;;;;;;;;;;;;;;;;;;;;;;;

; Called when one input file is finished
endinp:
    pop rax ; Cleanup from readchar
    mov rbx, rbp
    sub rbx, 0x18
    mov rax, [rbx]
    sub rbx, 0x8
    mov rdx, [rbx]
    cmp rax, rdx
    je cleanup
    add rbx, 0x8
    push rbx
    push rax
    ; Close the old input file
    mov rax, 0x3
    mov rdi, 0x3
    syscall
    ; Open new input file
    pop rax
    pop rbx
    mov rdi, [rax]
    add rax, 0x8
    mov [rbx], rax
    mov rax, 0x2 ; sys_open
    mov rsi, 0x2 ; R_RDWR
    syscall
    mov rdi, 0x2 ; In case we exit
    cmp rax, 0x3
    jne exit
    ; fallthrough
; Will store the byte in rax
readchar:
    mov rax, 0x0 ; sys_read
    mov rdi, 0x3
    push rax
    mov rsi, rsp
    mov rdx, 0x1
    syscall
    cmp rax, 0x0
    je endinp
    ; Get value and check for special cases
    pop rax
    cmp rax, 0xA ; If newline
    je line ; Yes, there will eventually be a stack overflow, who cares
    cmp rax, ";"
    je skipcom
    ret
; Skips to the end of the line
skipcom:
    call readchar
    jmp skipcom
; Skip until next non-space
skipspac:
    call readchar
    cmp rax, " "
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
    sub rsi, 0x1 ; Set rsi to -1
    syscall
    ret
; Read a single token into rax.  All tokens should be less than or equal to
; eight characters.
readtok:
    call skipspac ; In case you just wanted the next token
    call pushipos
  readtokl:
    mov rdx, 0x1
    call readn
    cmp rax, "0"
    jl readtoke
    cmp rax, 0x3A ; Right after '9'
    jl readtokl
    cmp rax, "A"
    jl readtoke
    cmp rax, "[" ; Right after 'Z'
    jl readtokl
    cmp rax, "_"
    je readtokl
    cmp rax, "a"
    jl readtoke
    cmp rax, "{" ; Right after 'z'
    jl readtokl
  ; Fallthrough
  readtoke:
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

; Converts the number in rax to a decimal string stored into rdi.  Hope that the
; string is small enough, because I have no idea what might happen if it isn't.
numtostr:
    mov rdi, 0x0 ; Result
    mov rbx, 0xA ; Constant 10
    mov rcx, 0x1 ; Keeps track of what digit we're on, gets multiplied by each
                 ; digit
  ntostrlp:
    mov rdx, 0x0
    div rbx
    add rdx, "0"
    push rax
    mov rax, rdx
    mul rcx
    add rdi, rax
    pop rax
    cmp rax, 0x0
    je return
    shl rcx, 0x8
    jmp ntostrlp

; This is the same as write but for stderr
printerr:
    pop rbx
    mov rax, 0x1 ; sys_write
    mov rdi, 0x2 ; stderr
    mov rsi, rsp
    syscall
    push rbx
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
;               Bool, zero=relative, nonzero=absolute (8 bytes, 7 of padding)
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
    cmp rax, ";"
    je lblckend
    cmp rax, 0x3A ; Colon
    je label
    jmp lblcloop
  lblckend:
    call popipos
    ret
  label:
    call getipos
    sub rax, 0x1 ; Get rid of the colon
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
; dealt with later.  The label name should be passed in rax, and the boolean
; describing if it is relative (zero) or absolute (nonzero) should be passed in
; rbx.
addjump:
    push rbx ; This is actually this value's final resting place, so we don't
             ; need it anymore
    push rax
    ; First write the blank label really quickly.  It can be anything, so we
    ; don't care.
    mov rdx, 0x4
    call write
    ; Add a new jmp address
    mov rbx, rbp
    sub rbx, 0x8
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
  cleanlop:
    sub rbx, 0x8
    mov rdi, 0x0 ; In case we exit
    mov rax, [rbx]
    cmp rax, 0x0
    je exit
    mov rbx, [rbx]
    add rbx, 0x8
    mov rsi, [rbx]
    mov rcx, rbp
  clnfndlb:
    mov rcx, [rcx]
    add rcx, 0x8
    mov rdi, [rcx]
    cmp rsi, rdi
    je foundlbl
    sub rcx, 0x8
    jmp clnfndlb
  foundlbl:
    add rcx, 0x8
    mov rdi, [rcx]
    add rbx, 0x10
    mov rsi, [rbx]
    sub rbx, 0x8
    cmp rsi, 0x0
    mov rsi, [rbx]
    je lblrel
    add rdi, 0x08000000
    jmp lblend
  lblrel:
    mov rsi, [rbx]
    sub rdi, rsi
  lblend:
    push rbx
    push rdi
    sub rsi, 0x4 ; remember that the index saved in a jmp instruction is after
                 ; the instruction
    call oseek
    mov rdx, 0x4
    call write
    pop rdi
    pop rbx
    sub rbx, 0x8
    jmp cleanlop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INSTRUCTION READING HELPERS ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Read a register, storing it numerically in rax.  rcx will contain the size of
; the register, in bytes (currently only 1 or 8).  If there is no register, rax
; will contain the token that was there instead.
readreg:
    call readtok
    mov rdx, rax
    mov rcx, 0x8
    cmp rdx, "rax"
      mov rax, 0x0
      je return
    cmp rdx, "rcx"
      mov rax, 0x1
      je return
    cmp rdx, "rdx"
      mov rax, 0x2
      je return
    cmp rdx, "rbx"
      mov rax, 0x3
      je return
    cmp rdx, "rsp"
      mov rax, 0x4
      je return
    cmp rdx, "rbp"
      mov rax, 0x5
      je return
    cmp rdx, "rsi"
      mov rax, 0x6
      je return
    cmp rdx, "rdi"
      mov rax, 0x7
      je return
    mov rcx, 0x1
    cmp rdx, "al"
      mov rax, 0x0
      je return
    cmp rdx, "cl"
      mov rax, 0x1
      je return
    cmp rdx, "dl"
      mov rax, 0x2
      je return
    cmp rdx, "bl"
      mov rax, 0x3
      je return
    cmp rdx, "sl"
      mov rax, 0x4
      je return
    cmp rdx, "bl"
      mov rax, 0x5
      je return
    cmp rdx, "sl"
      mov rax, 0x6
      je return
    cmp rdx, "dl"
      mov rax, 0x7
      je return
    mov rax, rdx
    ret
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
    cmp rax, " "
    je unreturn
    cmp rax, ";"
    je unreturn
    sub rax, "0" ; Convert ASCII digit to number
    cmp rax, 0xA ; Check if the digit is a letter
    jl rdhexdig
    sub rax, 0x7 ; Convert ASCII Letter to number (already subtracted 0x30)
  rdhexdig:
    ; Multiply rdx by 0x10
    shl rdx, 0x4
    ; Combine values
    add rdx, rax
    jmp rdhexbeg

; Read a string value into rdx.  Assumes that the first quote has already been
; parsed.  Currently, if the string is not ended by a newline, space, or
; semicolon, the behavior is undefined.  These strings can only be 8 bytes long.
readstr:
    call pushipos
  rdstrbeg:
    mov rdx, 0x1
    call readn
    cmp rax, 0x22 ; "
    jne rdstrbeg
    ; End of loop
    call getipos
    sub rax, 0x1 ; Get rid of the final quote
    pop rbx
    push rax
    push rbx
    call popipos
    call getipos
    pop rdx
    ; Now the range of the string is [rax, rdx)
    sub rdx, rax ; rdx is now the length, hope it's valid (<= 8)
    call readn
    mov rdx, rax
    ret

; This will read two paramaters, such as in "cmp rax, 0x10" or "mov [rbx], rsp".
; The destination register will be put into rdi, and the source register or
; value will be put into rsi.  rax will be set to the following values to
; specify what kinds of operands rdi and rsi are:
;
;   0: Both are direct registers.
;   1: Source is indirect register, destination is direct register.
;   2: Source is direct register, destination is indirect register.
;   3: Source is immediate value, destination is direct register.
;   4: Source is a label, destination is direct register.
;
; Keep in mind that all of the instructions that call this may not check for all
; of the values of rax, at least at the moment.
;
; The size of the registers stored in rsi and rdi will be put into rcx and rdx,
; respectively.
readtwo:
    call skipspac
    call readchar ; Check for '['
    cmp rax, "["
    je readtwo2
    call iback
    call readreg
    push rax
    push rcx
    call readchar ; For the ',', hope it's there.
    call skipspac
    call readchar ; Determine if it's a register or an immediate value
    cmp rax, "0"
    je readtwo3
    cmp rax, "["
    je readtwo1
    cmp rax, 0x22 ; '"'
    je readtw32
    call iback
    call readreg
    cmp rax, 0x8
    jl readtwo0
    jmp readtwo4
  readtwo0:
    mov rsi, rax
    pop rdx
    pop rdi
    mov rax, 0x0
    ret
  readtwo1:
    call readreg
    mov rsi, rax
    pop rdx
    pop rdi
    mov rax, 0x1
    ret
  readtwo2:
    call readreg
    push rax
    push rcx
    call readchar ; For the ']', hope it's there.
    call readchar ; For the ',', hope it's there.
    call skipspac
    call readreg
    mov rsi, rax
    pop rdx
    pop rdi
    mov rax, 0x2
    ret
  readtwo3:
    call readchar ; Hope that the next character is 'x'
    call readhex ; rdx now has the immediate value
    mov rsi, rdx
    pop rdx
    pop rdi
    mov rax, 0x3
    ret
  readtw32: ; This should really be something like readtwo3-string
    call readstr
    mov rsi, rdx
    pop rdx
    pop rdi
    mov rax, 0x3
    ret
  readtwo4:
    mov rsi, rax
    pop rdx
    pop rdi
    mov rax, 0x4
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;
; SPECIFIC INSTRUCTIONS ;
;;;;;;;;;;;;;;;;;;;;;;;;;

syscall_:
    mov rdx, 0x3
    call readn
    cmp rax, "all"
    jne err
    mov rax, 0x050F ; syscall opcode
    call write2
    jmp skipcom
mov_:
    call readtwo
    cmp rax, 0x4
    je mov4
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
    shl rdi, 0x3
    add rdi, rsi
    mov rax, 0xC0
    add rax, rdi
    call write1
    jmp skipcom
  mov1:
    push rdi
    push rsi
    cmp rdx, 0x1
    je mov1byte
  mov1quad:
    mov rax, 0x8B48 ; REX.W + MOV opcode
    call write2
    jmp mov1_end
  mov1byte:
    mov rax, 0x8A
    call write1
  mov1_end:
    ; Create ModRM Byte
    pop rax ; ModRM.rm
    pop rdi ; ModRM.reg
    shl rdi, 0x3
    add rax, rdi
    call write1
    jmp skipcom
  mov2:
    push rdi
    push rsi
    cmp rcx, 0x1
    je mov2byte
  mov2quad:
    mov rax, 0x8948 ; REX.W + MOV opcode
    call write2
    jmp mov2_end
  mov2byte:
    mov rax, 0x88
    call write1
  mov2_end:
    pop rsi ; ModRM.reg
    pop rax ; ModRM.rm
    shl rsi, 0x3
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
  mov4:
    push rsi
    mov rax, 0xB8 ; MOV opcode
    add rax, rdi
    call write1
    pop rax
    mov rbx, 0x1
    call addjump
    jmp skipcom
pushpop:
    push rbx
    call skipspac
    call readreg
    pop rbx
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
    call readtok
    mov rbx, 0x0
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
    shl rdi, 0x3
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
addsub0:
    pop rdi
    pop rsi
    shl rdi, 0x3
    mov rax, 0xC0
    add rax, rdi
    add rax, rsi
    call write1
    jmp skipcom
addsub3:
    pop rdi
    shl rax, 0x3
    add rax, 0xC0
    add rax, rdi
    call write1
    mov rdx, 0x4
    call write
    pop rsi
    jmp skipcom
add_:
    call readtwo
    push rsi
    push rdi
    cmp rax, 0x0
    jne add3 ; Assume rax == 3
  add0:
    mov rax, 0x0348 ; REX.W + ADD opcode
    call write2
    jmp addsub0
  add3:
    mov rax, 0x8148 ; REX.W + ADD opcode
    call write2
    mov rax, 0x0
    jmp addsub3
sub_:
    call readtwo
    push rsi
    push rdi
    cmp rax, 0x0
    jne sub3 ; Assume rax == 3
  sub0:
    mov rax, 0x2B48 ; REX.W + ADD opcode
    call write2
    jmp addsub0
  sub3:
    mov rax, 0x8148 ; REW.W + SUB opcode
    call write2
    mov rax, 0x5
    jmp addsub3
shift:
    push rax
    mov rax, 0xC148 ; REX.W + SHL or SHR opcode
    call write2
    call readtwo ; Assume rax == 3
    pop rax
    push rsi
    shl rax, 0x3
    add rax, 0xC0
    add rax, rdi
    call write1
    mov rdx, 0x1
    call write
    pop rsi
    jmp skipcom
shl_:
    mov rax, 0x4
    jmp shift
shr_:
    mov rax, 0x5
    jmp shift
muldiv:
    push rax
    mov rax, 0xF748 ; REX.W + MUL or DIV opcode
    call write2
    call skipspac
    call readreg
    pop rbx
    shl rbx, 0x3
    add rax, rbx
    add rax, 0xC0
    call write1
    jmp skipcom
mul_:
    mov rax, 0x4
    jmp muldiv
div_:
    mov rax, 0x6
    jmp muldiv
db_:
    call skipspac
    call readchar
    cmp rax, 0x22 ; "
    je dbloop
    call readchar ; Hope it's x
    call readhex
    mov rax, rdx
    call write1 ; db should only dump one byte when it's a numerical value
    jmp skipcom
  dbloop:
    call readchar
    cmp rax, 0x22 ; "
    je skipcom
    call write1
    jmp dbloop
