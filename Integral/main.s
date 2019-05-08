.bss
inputBuffer: .space 32
start: .lcomm 4
end: .lcomm 4

.data
integral: .float 0

inputTextFormat: .string "%s"
inputTextStart: .string "Podaj początek przedziału całkowania: "
inputTextEnd: .string "Podaj koniec przedziału całkowania: "

numberInputFormat: .string "%f"

rectangleCount = 20
inputBufferSize = 32

READ = 3
WRITE = 4
EXIT = 1

STDIN = 0
STDOUT = 1
EXIT_VALUE = 0

SYSTEM_CALL = 0x80

.text
.global main
main:
    pushl inputTextStart
    pushl inputTextFormat
    call printf
    addl $8, %esp
    pushl $start
    pushl numberInputFormat
    call scanf
    addl $8, %esp

    pushl inputTextEnd
    pushl inputTextFormat
    call printf
    addl $8, %esp
    pushl $end
    pushl numberInputFormat
    call scanf
    addl $8, %esp
    jmp exit

exit:
    movl $EXIT, %eax
    movl $EXIT_VALUE, %ebx
    int $SYSTEM_CALL

.global my_sin
.type my_sin, @function
my_sin:
    pushl %ebp              #Preserve previous frame pointer.
    movl %esp, %ebp         #Set new frame pointer for function.
    subl $4, %esp           #Make space on stack for local variable
    
    movl 8(%ebp), %eax      #Get function parameter into %eax.
    movl %eax, -4(%ebp)     #Move the value of parameter into local variable.
    flds -4(%ebp)           #Load floating point number stored at address %eax into ST(0).
    fsin                    #Compute sin(st(0)) and store it in st(0).
    fstps -4(%ebp)          #Store the floating point number in local variable and pop the FPU stack.
    movl -4(%ebp), %eax     #Contents of local variable are returned in %eax.
    movl %ebp, %esp         #Dealocate local variables.
    popl %ebp               #Restore previous frame pointer.