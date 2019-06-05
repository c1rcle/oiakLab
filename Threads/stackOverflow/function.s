.global function
.type function, @function
function:
    pushl %ebp
    movl %esp, %ebp
    subl $48, %esp

    movl 8(%ebp), %eax
    pushl $56
    pushl %eax
    lea -48(%ebp), %eax
    pushl %eax
    call memcpy
    addl $12, %esp

    movl %ebp, %esp
    popl %ebp
    ret
