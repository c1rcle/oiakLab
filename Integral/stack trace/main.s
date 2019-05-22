.bss
#Uninitialized memory locations.
.lcomm backtraceAddresses, 64
.lcomm backtraceStrings, 64
.lcomm addressCount, 4
.lcomm stringArrayAddress, 4

.data
#Printf format string declaration.
outputStringFormat: .string "%s\n"

#Program constant values declaration.
backtraceAddressesSize = 8
ASCII_LINE_FEED = 0x10

#System constant values declaration.
EXIT = 1
EXIT_VALUE = 0
SYSTEM_CALL = 0x80

.text
.global main
main:
    #Call first function.
    call func1
    #Standard exit call.
    movl $EXIT, %eax
    movl $EXIT_VALUE, %ebx
    int $SYSTEM_CALL

func1:
    #Follow x86 calling convention.
    pushl %ebp
    movl %esp, %ebp
    #Call second function.
    call func2
    movl %ebp, %esp
    popl %ebp
    ret

func2:
    pushl %ebp
    movl %esp, %ebp
    #Call third function.
    call func3
    movl %ebp, %esp
    popl %ebp
    ret

func3:
    pushl %ebp
    movl %esp, %ebp
    #Call the last function that prints the stack trace.
    call printStackTrace
    movl %ebp, %esp
    popl %ebp
    ret

printStackTrace:
    pushl %ebp
    movl %esp, %ebp
    #Execute function 'backtrace(void ** buffer, int size)' from execinfo.h.
    pushl $backtraceAddressesSize
    pushl $backtraceAddresses
    call backtrace
    #Return value of backtrace is the actual number of entries that were obtained.
    movl %eax, addressCount
    addl $8, %esp

    #Execute function 'backtrace_symbols(void*const* buffer, int size)' from execinfo.h.
    #The return value is a pointer to array of strings which has 'size' entries.
    #Each value represents the corresponding element from buffer in string format.
    pushl %eax
    pushl $backtraceAddresses
    call backtrace_symbols
    movl %eax, stringArrayAddress
    addl $8, %esp

    #Display all of these strings.
    movl $0, %esi
    movl $0, %edi
    stringLoop:
    cmpl addressCount, %edi
    je finishedLoop
    movl stringArrayAddress, %eax
    #The return address is char**, so we can get to individual strings by indexed addressing.
    pushl (%eax, %esi, 4)
    pushl $outputStringFormat
    call printf
    addl $8, %esp
    incl %edi
    incl %esi
    jmp stringLoop

    finishedLoop:
    #Refer to 'backtrace_symbols()' documentation. 
    #(https://www.gnu.org/software/libc/manual/html_node/Backtraces.html)
    #The return value of this function is a pointer obtained via malloc.
    #We have to free that memory at the end.
    pushl stringArrayAddress
    call free
    addl $4, %esp
    movl %ebp, %esp
    popl %ebp
    ret
