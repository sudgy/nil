; Put the exit reason into rdi first
exit:
    mov rax, 0x3C
    syscall
; This is used to have a conditional return, like "je return"
return:
    ret
; This is like "return true"
rettrue:
    cmp rax, rax
    ret
; This is like "return false" (it's actually kind of inefficient, but oh well)
retfalse:
    cmp rax, 0xFE
    jne return
    cmp rax, 0x0
    ret
; Have your inputs in rdi and rsi, output will be in rax
min:
    cmp rdi, rsi
    jl min1
    mov rax, rsi
    ret
  min1:
    mov rax, rdi
    ret
max:
    cmp rdi, rsi
    jl max2
    mov rax, rdi
    ret
  max2:
    mov rax, rsi
    ret
