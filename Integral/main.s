.bss
inputBuffer: .space 32

#Uninitialized number data.
.lcomm start, 4
.lcomm end, 4
.lcomm stepLength, 4
.lcomm integral, 4

.data
#Initialized variables for integration. 
currentIndex: .long 0
rectangleCount: .long 400

#Constant strings declaration.
inputTextStart: .string "Podaj początek przedziału całkowania: "
inputTextEnd: .string "Podaj koniec przedziału całkowania: "
outputTextSin: .string "Wynik całki dla funkcji sin(x): "
outputTextLog: .string "Wynik całki dla funkcji log(x): "

#Printf and scanf format strings declaration.
outputTextFormat: .string "%s"
floatFormat: .string "%f"
floatOutputFormat: .string "%f\n"

#Program constant values declaration.
inputBufferSize = 32

#System constant values declaration.
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
    #Display input prompt for the start of integration interval.
    pushl $inputTextStart
    pushl $outputTextFormat
    call printf
    #Clear the pushed function arguments.
    addl $8, %esp
    #Read the 'start of integration interval' number into 'start' variable.
    pushl $start
    pushl $floatFormat
    call scanf
    addl $8, %esp

    #Display input prompt for the end of integration interval.
    pushl $inputTextEnd
    pushl $outputTextFormat
    call printf
    addl $8, %esp
    #Read the 'end of integration interval' number info 'end' variable.
    pushl $end
    pushl $floatFormat
    call scanf

    #Display the sin result preceding string.
    addl $8, %esp
    pushl $outputTextSin
    pushl $outputTextFormat
    call printf
    addl $8, %esp

    #Calculate integral for function sin(x) over the interval [start, end].
    movl $0, integral
    call calculateSinIntegral
    #Make room on stack for a double variable (printf expects double cast).
    subl $8, %esp
    flds integral
    #Cast float result to double format and store in on the stack.
    fstpl (%esp)
    pushl $floatOutputFormat
    call printf
    #Clear the stack after function call.
    addl $12, %esp 

    #Display the log result preceding string.
    addl $8, %esp
    pushl $outputTextLog
    pushl $outputTextFormat
    call printf
    addl $8, %esp

    #Calculate integral for function log(x) over the interval [start, end].
    movl $0, integral
    call calculateLogIntegral
    subl $8, %esp
    flds integral
    fstpl (%esp)
    pushl $floatOutputFormat
    call printf
    addl $12, %esp
    #Exit the program.
    jmp exit

calculateSinIntegral:
    #Calculate step length for rectangle method.
    flds end
    fsub start
    fidiv rectangleCount
    fstps stepLength
    xorl %ecx, %ecx

    rectangleSinLoop:
    #Check if we have gone through all rectangles.
    movl rectangleCount, %eax
    cmpl %eax, %ecx
    je loopFinished
    movl %ecx, currentIndex
    #The formula is as follows: sin(start + i * stepLength) * stepLength.
    fild currentIndex
    fmul stepLength
    fadd start
    fsin
    fmul stepLength
    fadd integral
    #Save partial product into 'integral' variable.
    fstps integral
    incl %ecx
    jmp rectangleSinLoop

loopFinished:
    ret

calculateLogIntegral:
    flds end
    fsub start
    fidiv rectangleCount
    fstps stepLength
    xorl %ecx, %ecx

    rectangleLogLoop:
    movl rectangleCount, %eax
    cmpl %eax, %ecx
    je loopFinished
    movl %ecx, currentIndex
    #Load log2(e) onto the stack.
    fldl2e
    #There is no FPU instruction for log(x) calculation, so we have to improvise.
    #Change of base formula: log(x) = log2(x) / log2(e).
    #This instruction loads +1.0 onto the FPU stack.
    fld1
    fild currentIndex
    fmul stepLength
    fadd start
    #fyl2x calculates st(1) * log2(st(0)).
    fyl2x
    #Divide st(1) by st(0) and pop the FPU stack.
    fdivp %st, %st(1)
    fmul stepLength
    fadd integral
    fstps integral
    incl %ecx
    jmp rectangleLogLoop

exit:
    #Standard exit call.
    movl $EXIT, %eax
    movl $EXIT_VALUE, %ebx
    int $SYSTEM_CALL
