.bss
#Buffers for two 16 byte numbers.
firstNumberBuffer: .space 16
secondNumberBuffer: .space 16

#Buffer for input string.
inputOutputLineBuffer: .space 64

.data
#Program constant values declaration.
INPUT_BUFFER_SIZE = 64
DOUBLE_WORD_COUNT = 4
ASCII_LINE_FEED = 10
ASCII_ZERO = 48
ASCII_ONE = 49
ASCII_NINE = 57
ASCII_CHAR_A = 65
ASCII_CHAR_F = 70
ASCII_CHAR_PLUS = 43
ASCII_CHAR_MINUS = 45
ASCII_CHAR_DISPLACEMENT = 55

carryFlagStatus: .byte 0

inputFirstString: .string "Podaj pierwszą liczbę: \n"
inputFirstStringLen = . - inputFirstString

inputSecondString: .string "Podaj drugą liczbę: \n"
inputSecondStringLen= . - inputSecondString

inputOperationString: .string "Wybierz operację na liczbach (+ lub -): \n"
inputOperationStringLen = . - inputOperationString

inputErrorString: .string "Wprowadzona liczba lub operand ma nieprawidłowy format!\n"
inputErrorStringLen = . - inputErrorString

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
    #Display input prompt for first number.
    pushl $inputFirstStringLen
    pushl $inputFirstString
    call writeString

    #Read the number into its buffer.
    pushl $firstNumberBuffer
    call readNumber

    #Display input prompt for second number.
    pushl $inputSecondStringLen
    pushl $inputSecondString
    call writeString

    #Read the number into its buffer.
    pushl $secondNumberBuffer
    call readNumber

    #Display input prompt for operation type.
    pushl $inputOperationStringLen
    pushl $inputOperationString
    call writeString

    #Read the operation type into buffer.
    call readString
    cmpb $ASCII_CHAR_PLUS, inputOutputLineBuffer
    je addition
    cmpb $ASCII_CHAR_MINUS, inputOutputLineBuffer
    je subtraction
    jmp wrongInput

    #Perform chosen operation and display the result.
    addition: call addNumbers
    call writeNumber
    jmp exit
    subtraction: call subtractNumbers
    call writeNumber
    jmp exit

readString:
    #Read characters to temporary buffer.
    movl $READ, %eax
    movl $STDIN, %ebx
    movl $inputOutputLineBuffer, %ecx
    movl $INPUT_BUFFER_SIZE, %edx
    int $SYSTEM_CALL
    ret

writeString:
    #Get stack arguments and display string.
    movl 4(%esp), %ecx
    movl 8(%esp), %edx
    movl $WRITE, %eax
    movl $STDOUT, %ebx
    int $SYSTEM_CALL
    ret $8

writeNumber:
    #Start number conversion.
    movl $15, %esi
    #Starting from the end of the result, we go through individual bytes
    #until one is not null. 
    call highestNonNullByte
    movl %esi, %edi
    xorl %esi, %esi
    xorl %ecx, %ecx
    #Convert given result to string.
    call convertToString
    xorl %esi, %esi
    xorl %edx, %edx
    movl %ecx, %eax
    movl $2, %ebx
    #Divide string char count by two to get the number of bytes.
    divl %ebx
    pushl %ecx
    #If the result of division is uneven, fix endianness.
    call fixLittleEndian
    #Clear the stack after function call.
    addl $4, %esp
    #Swap bytes to get the proper big endian output.
    call swapBytes

    cmpb $0, carryFlagStatus
    jne addCarryToResult
    je continueWrite

    addCarryToResult:
    #Add carry to front of output string.
    movl %ecx, %ebx
    incl %ecx
    call shiftString
    movb $ASCII_ONE, inputOutputLineBuffer
    movb $ASCII_LINE_FEED, inputOutputLineBuffer(%ecx)

    continueWrite:
    #If there will be a zero in front, write starting from second character.
    movl $inputOutputLineBuffer, %esi
    cmpb $ASCII_ZERO, inputOutputLineBuffer
    je writeFromSecondChar
    jne write
    writeFromSecondChar:
    incl %esi
    decl %ecx    
    write:
    #Write string to console.
    incl %ecx
    pushl %ecx
    pushl %esi
    call writeString 
    ret

readNumber:
    #Start string conversion.
    call readString
    decl %eax
    cmpl $32, %eax
    ja wrongInput
    cmpl $0, %eax
    je wrongInput
    pushl %eax
    xorl %esi, %esi
    xorl %edx, %edx
    movl $2, %ebx
    divl %ebx
    call fixLittleEndian
    addl $4, %esp
    call swapBytes
    #Get the number buffer address into ebx.
    movl 4(%esp), %ebx
    xorl %esi, %esi
    call convertFromAscii
    ret $4

fixLittleEndian:
    #Change the format of input string to little endian.
    cmpl $1, %edx
    jne return
    movl 4(%esp), %ebx
    #Shift the string right once and put zero in front to align it properly.
    call shiftString
    movb $ASCII_ZERO, inputOutputLineBuffer
    movb $ASCII_LINE_FEED, inputOutputLineBuffer(%esi)
    xorl %esi, %esi
    incl %eax
    ret

shiftString:
    #Shift string by one character right.
    movb inputOutputLineBuffer(%esi), %dl
    incl %esi
    shiftStringNext:
    movb inputOutputLineBuffer(%esi), %dh
    movb %dl, inputOutputLineBuffer(%esi)
    movb %dh, %dl
    incl %esi
    decl %ebx
    cmpl $0, %ebx
    jne shiftStringNext
    ret

swapBytes:
    #Swap bytes so that they are in little endian format.
    cmpl %esi, %eax
    jbe return
    decl %eax
    movw inputOutputLineBuffer(,%eax,2), %bx
    movw inputOutputLineBuffer(,%esi,2), %dx
    movw %bx, inputOutputLineBuffer(,%esi,2)
    movw %dx, inputOutputLineBuffer(,%eax,2)
    incl %esi
    jmp swapBytes
    #Return label.
    return: ret

convertFromAscii:
    #Get first char from input buffer and convert it to a value.
    movb inputOutputLineBuffer(%esi), %al
    cmpb $ASCII_LINE_FEED, %al
    je return
    call checkCharacterType
    #Its position means that it has to be multiplied by 16.
    movb $16, %dl
    mulb %dl
    #Store the number in number buffer.
    movb %al, (%ebx)

    #Get second char from input buffer and convert it to a value.
    incl %esi
    movb inputOutputLineBuffer(%esi), %al
    cmpb $ASCII_LINE_FEED, %al
    je return
    call checkCharacterType
    #Its position means that it should be just added to make a byte.
    addb %al, (%ebx)
    #We move that newly created byte into a number buffer which is a function argument.
    incl %esi 
    incl %ebx
    jmp convertFromAscii

checkCharacterType:
    #Check if typed character could be a number.
    cmpb $ASCII_CHAR_A, %al
    jb convertDigit
    jmp convertChar
    
convertDigit:
    #Filter out unwanted input.
    cmpb $ASCII_NINE, %al
    ja wrongInput
    cmpb $ASCII_ZERO, %al
    jb wrongInput
    subb $ASCII_ZERO, %al
    ret

convertChar:
    #Filter out unwanted input.
    cmpb $ASCII_CHAR_F, %al
    ja wrongInput
    subb $ASCII_CHAR_DISPLACEMENT, %al
    ret

highestNonNullByte:
    #If the operation set CF return higest buffer index.
    cmpb $1, carryFlagStatus
    je return
    nextByte:
    #Find highest non null byte.
    cmpb $0, firstNumberBuffer(%esi)
    jne return
    cmpl $0, %esi
    je return
    decl %esi
    jmp nextByte

convertToString:
    #Convert a byte number represantation to string.
    cmpl %esi, %edi
    jb return
    xorw %ax, %ax
    movb firstNumberBuffer(%esi), %al
    movb $16, %dl
    divb %dl
    movb %al, inputOutputLineBuffer(%ecx)
    call checkByteType
    incl %ecx
    movb %ah, inputOutputLineBuffer(%ecx)
    call checkByteType
    incl %ecx
    incl %esi
    jmp convertToString

checkByteType:
    #Check whether a value byte represents a digit or letter.
    cmpb $0x0a, inputOutputLineBuffer(%ecx)
    jb convertToDigit
    jmp convertToChar

convertToDigit:
    #Convert a digit to its ASCII representation.
    addb $ASCII_ZERO, inputOutputLineBuffer(%ecx)
    ret

convertToChar:
    #Convert a letter to its ASCII implementation.
    addb $ASCII_CHAR_DISPLACEMENT, inputOutputLineBuffer(%ecx)
    ret

wrongInput:
    #Display error string and end the program.
    pushl $inputErrorStringLen
    pushl $inputErrorString
    call writeString
    jmp exit

addNumbers:
    #Starting from the low-order byte add numbers together.
    xorl %esi, %esi
    movl secondNumberBuffer(,%esi,4), %eax
    addl %eax, firstNumberBuffer(,%esi,4)
    incl %esi
    jmp addSecondDoubleWord
    addNextDoubleWord:
    popfl
    addSecondDoubleWord:
    movl secondNumberBuffer(,%esi,4), %eax
    #Add carry to the result of addition.
    adcl %eax, firstNumberBuffer(,%esi,4)
    incl %esi
    pushfl
    cmpl $DOUBLE_WORD_COUNT, %esi
    jb addNextDoubleWord
    popfl
    setc carryFlagStatus
    ret

subtractNumbers:
    #Starting from the low-order byte subtract numbers.
    xorl %esi, %esi
    movl secondNumberBuffer(,%esi,4), %eax
    subl %eax, firstNumberBuffer(,%esi,4)
    incl %esi
    jmp subSecondDoubleWord
    subNextDoubleWord:
    popfl
    subSecondDoubleWord:
    movl secondNumberBuffer(,%esi,4), %eax
    #Subtract carry from the result of previous subtraction.
    sbbl %eax, firstNumberBuffer(,%esi,4)
    incl %esi
    pushfl
    cmpl $DOUBLE_WORD_COUNT, %esi
    jb subNextDoubleWord
    popfl
    setc carryFlagStatus
    ret

exit:
    #Standard exit call.
    movl $EXIT, %eax
    movl $EXIT_VALUE, %ebx
    int $SYSTEM_CALL
    