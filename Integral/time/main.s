.bss
#Uninitialized 64bit memory locations.
.lcomm startClockStatus, 8
.lcomm endClockStatus, 8

.data
#Constant strings declaration.
testString: .string "Testowy ciąg znaków.\n"
resultString: .string "Ilość cykli procesora: "

#Printf format strings declaration.
printfStringFormat: .string "%s"
printfDoubleFormat: .string "%.0f\n"

#System constant values declaration.
EXIT = 1
EXIT_VALUE = 0

SYSTEM_CALL = 0x80

.text
.global main
main:
    #Push printf arguments onto the stack and initialize %esi to 0.
    movl $0, %esi
    pushl $testString
    pushl $printfStringFormat
    #Load the processor's time stamp into %edx:%eax.
    rdtsc
    #Save the 64-bit integer value into 'startClockStatus'.
    movl %edx, startClockStatus + 4
    movl %eax, startClockStatus
    #Call printf 10 times.
    outputLoop:
    call printf
    incl %esi
    cmpl $10, %esi
    jne outputLoop

    #Load the processor's time stamp into %edx:%eax
    #(after executing the foregoing loop).
    rdtsc
    addl $8, %esp
    #Subtract the 'start' time stamp from 'end'.
    subl startClockStatus, %eax
    sbbl startClockStatus + 4, %edx
    #Save the result into 'endClockStatus'.
    movl %edx, endClockStatus + 4
    movl %eax, endClockStatus
    #Load result onto the FPU stack.
    fildq endClockStatus

    #Output the result string.
    pushl $resultString
    pushl $printfStringFormat
    call printf
    addl $8, %esp

    #Output the result (double cast).
    subl $8, %esp
    fstpl (%esp)
    pushl $printfDoubleFormat
    call printf
    addl $12, %esp

    #Standard exit call.
    movl $EXIT, %eax
    movl $EXIT_VALUE, %ebx
    int $SYSTEM_CALL
