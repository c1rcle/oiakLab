.bss
#Buffers for two 16 byte numbers.
firstNumberBuffer: .space 128
secondNumberBuffer: .space 128

#Buffer for input string.
inputLineBuffer: .space 64

#Buffer for the output string.
outputLineBuffer: .space 64

.data
#Program constant values declaration.
INPUT_BUFFER_SIZE = 64
DOUBLE_WORD_COUNT = 4
ASCII_LINE_FEED = 10

#System constant values declaration.
READ = 3
WRITE = 4
EXIT = 1

STDIN = 0
STDOUT = 1
EXIT_VALUE = 0

SYSTEM_CALL = 0x80

.text
.global _start
_start:
    

readString:
    movl $READ, %eax
    movl $STDIN, %ebx
    movl $inputLineBuffer, %ecx
    movl $INPUT_BUFFER_SIZE, %edx
    int $SYSTEM_CALL
    ret

readNumber:
    subl $1, %eax
    movl 
    call swapNumberBytes
    ret

swapNumberBytes:
    ret

addNumbers:
    xorl %esi, %esi
    addl secondNumberBuffer(,%esi,4), firstNumberBuffer(,%esi,4)
    incl %esi
    addNextDoubleWord:
    adcl secondNumberBuffer(,%esi,4), firstNumberBuffer(,%esi,4)
    incl %esi
    cmpl $DOUBLE_WORD_COUNT, %esi
    jb addNextDoubleWord
    ret

subtractNumbers:
    xorl %esi
    subl secondNumberBuffer(,%esi,4), firstNumberBuffer(,%esi,4)
    incl %esi
    subNextDoubleWord:
    sbbl secondNumberBuffer(,%esi,4), firstNumberBuffer(,%esi,4)
    incl %esi
    cmpl $DOUBLE_WORD_COUNT, %esi
    jb subNextDoubleWord
    ret
    