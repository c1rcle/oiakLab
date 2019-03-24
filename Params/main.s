.bss
#Buffer for output
outputBuffer: .space 2048

.data
#Constant values declaration
ASCII_LINE_FEED = 10
ASCII_NULL_BYTE = 0

#System constant values declaration
WRITE = 4
EXIT = 1

STDOUT = 1
EXIT_ARG = 0

SYSTEM_CALL = 0x80

.text
.global _start
_start:
    #Move 0 to %ebx register and jump to parseArgs label.
    movl $0, %ebx
    jmp parseArgs

parseArgs:
    #%esp points to argc, so we can access argv and its contents by indexed adressing.
    #First we need to increment %ebx (our indexing register) to get %esp + %ebx(which will be 1) * 4
    #which points to argv[0].
    incl %ebx
    xorl %esi, %esi
    movl (%esp,%ebx,4), %edi
    #argv is a null terminated array. After its last element there are 4 null bytes.
    cmpl $ASCII_NULL_BYTE, %edi
    #If we load a null double word into %edi we know that we read all of argv contents.
    je parseEnvironment
    #Prepare and print string using standard output.
    call prepareLine
    call printLine
    jmp parseArgs

parseEnvironment:
    #Now we parse the contents of evnp environment variable array.
    incl %ebx
    xorl %esi, %esi
    movl (%esp,%ebx,4), %edi
    #envp is also a null terminated array. After its last element there are 4 null bytes.
    cmpl $ASCII_NULL_BYTE, %edi
    je exit
    #Prepare and print string using standard output.
    call prepareLine
    call printLine
    jmp parseEnvironment

prepareLine:
    #%edi points to a single character of a given string. We move that byte to %dl.
    movb (%edi), %dl
    #If we encounter a null byte, we know that the string has ended.
    cmpb $ASCII_NULL_BYTE, %dl
    je endProc
    #We move that singe character to our output buffer (%esi is the offset).
    movb %dl, outputBuffer(%esi)
    #Then we move to the next byte of a given string.
    incl %edi
    incl %esi
    jmp prepareLine
    endProc: ret

printLine:
    #Add a line feed character at the end of a string.
    movb $ASCII_LINE_FEED, outputBuffer(%esi)
    incl %esi
    #Push %ebx to the top of stack because its content will be lost due to the output call.
    pushl %ebx
    
    #Print string using standard output.
    movl $WRITE, %eax
    movl $STDOUT, %ebx
    movl $outputBuffer, %ecx
    movl %esi, %edx
    int $SYSTEM_CALL

    #Retrieve the value of %ebx.
    popl %ebx
    ret

exit:
    #Standard system exit call.
    movl $EXIT, %eax
    movl $EXIT_ARG, %ebx
    int $SYSTEM_CALL

