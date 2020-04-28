call test_uti
call test_str
mov rsi, test_end
call println
mov rdi, 0x0
jmp exit

testfail:
    push rsi
    mov rsi, testfstr
    call print
    pop rsi
    call println
    mov rdi, 0x1
    jmp exit
testfstr:
    db "Test failed - "
    db 0x0

test_end:
    db "All tests successful."
    db 0x0

