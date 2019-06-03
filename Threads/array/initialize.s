.global initializeByRows
.type initializeByRows, @function
initializeByRows:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp
    pushl %ebx
    pushl %esi

    movl 8(%ebp), %eax
    movl 12(%ebp), %ebx
    movl 16(%ebp), %ecx

    movl %ebx, -4(%ebp)
    movl %ecx, -8(%ebp)

    movl $0, %ecx
    movl $0, %esi
    traverseArrayRow:
    cmpl %ecx, -4(%ebp)
    je completed
    traverseArrayColumn:
    cmpl %esi, -8(%ebp)
    je rowTraversed
    movl (%eax, %ecx, 4), %ebx
    movl $0, (%ebx, %esi, 4)
    incl %esi
    jmp traverseArrayColumn
    rowTraversed:
    incl %ecx
    xorl %esi, %esi
    jmp traverseArrayRow

    completed:
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

.global initializeByColumns
.type initializeByColumns, @function
initializeByColumns:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp
    pushl %ebx
    pushl %esi

    movl 8(%ebp), %eax
    movl 12(%ebp), %ebx
    movl 16(%ebp), %ecx

    movl %ebx, -4(%ebp)
    movl %ecx, -8(%ebp)

    movl $0, %ecx
    movl $0, %esi
    traverseArray2Column:
    cmpl %ecx, -8(%ebp)
    je completed
    traverseArray2Row:
    cmpl %esi, -4(%ebp)
    je row2Traversed
    movl (%eax, %esi, 4), %ebx
    movl $0, (%ebx, %ecx, 4)
    incl %esi
    jmp traverseArray2Row
    row2Traversed:
    incl %ecx
    xorl %esi, %esi
    jmp traverseArray2Column

    completed2:
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
