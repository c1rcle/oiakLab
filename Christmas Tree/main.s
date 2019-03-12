.bss
#Buffers for input/output
levelNumber: .space 32
lineBuffer: .space 64

.data
#Constant output strings
outString: .string "Podaj ilość poziomów drzewka:\n"
outStringLen = . - outString

tooSmallString: .string "Podałeś zbyt małą ilość poziomów!\n"
tooSmallStringLen = . - tooSmallString

tooBigString: .string "Podałeś zbyt dużą ilośc poziomów!\n"
tooBigStringLen = . - tooBigString

#Constant values declaration
LEVEL_BUFFER_SIZE = 32
OUTPUT_BUFFER_SIZE = 64
ASCII_DISPLACEMENT = 48
ASCII_SPACE = 32
ASCII_STAR = 42
ASCII_LINE_FEED = 10

#System constant values declaration
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
    #Write first string to console
    movl $WRITE, %eax
    movl $STDOUT, %ebx
    movl $outString, %ecx
    movl $outStringLen, %edx
    int $SYSTEM_CALL

    #Read input into buffer
    movl $READ, %eax
    movl $STDIN, %ebx
    movl $levelNumber, %ecx
    movl $LEVEL_BUFFER_SIZE, %edx
    int $SYSTEM_CALL

    #Clear %esi and %edx registers
    decl %eax
    xorl %esi, %esi
    xorl %edx, %edx
    jmp computeNumber

computeNumber:
    #Get next input byte into %bl and convert it to a number
    xorl %ebx, %ebx
    movb levelNumber(%esi), %bl
    subl $ASCII_DISPLACEMENT, %ebx

    #Push text length to the stack and compute value for a single digit
    pushl %eax
    subl %esi, %eax
    decl %eax
    jmp powerOfTen

powerOfTen:
    #Compute 10^index times digit
    cmpl $0, %eax
    je addPosition
    imull $10, %ebx
    decl %eax
    jmp powerOfTen

addPosition:
    #Add computed value to the %edx register
    popl %eax
    addl %ebx, %edx
    incl %esi
    cmp %eax, %esi
    jl computeNumber
    jmp numberComputed 

numberComputed:
    #Check input (Computed number is stored in %edx)
    cmpl $2, %edx
    jl levelTooSmall

    #We can compute how many bytes are going to be needed
    #for the last line using this equation:
    #numberOfBytes = 2 * levels (includes '/n' byte)
    pushl %edx
    imull $2, %edx
    cmpl $OUTPUT_BUFFER_SIZE, %edx
    jg levelTooBig

    #Start of printing routine (%esi - buffer offset, %edx - number of lines left
    #%eax - space loop counter, %ecx - star loop counter,
    #%ebx - number of stars in next line)
    xorl %esi, %esi
    popl %edx
    movl %edx, %eax
    movl $1, %ecx
    movl %ecx, %ebx
    decl %eax
    jmp prepareLine   

levelTooSmall:
    #If number of levels selected is less than two, exit the program
    movl $WRITE, %eax
    movl $STDOUT, %ebx
    movl $tooSmallString, %ecx
    movl $tooSmallStringLen, %edx
    int $SYSTEM_CALL
    jmp exit

levelTooBig:
    #If number of levels requires more bytes than the buffer length, exit the application
    movl $WRITE, %eax
    movl $STDOUT, %ebx
    movl $tooBigString, %ecx
    movl $tooBigStringLen, %edx
    int $SYSTEM_CALL
    jmp exit

prepareLine:
    #Place computed number of spaces into the adress lineBuffer + %esi
    cmp $0, %eax
    je prepareStars
    movb $ASCII_SPACE, lineBuffer(%esi)
    incl %esi
    decl %eax
    jmp prepareLine

prepareStars:
    #Place computed number of stars into the adress lineBuffer + %esi
    cmp $0, %ecx
    je nextLine
    movb $ASCII_STAR, lineBuffer(%esi)
    incl %esi
    decl %ecx
    jmp prepareStars

nextLine:
    #Push critical registers to stack because their value
    #will be lost due to the output call
    pushl %ebx
    pushl %edx

    #Insert LF character at the end of line and increment %esi
    #to get the amount of output bytes
    movb $10, lineBuffer(%esi)
    incl %esi

    #Write line to console
    movl $WRITE, %eax
    movl $STDOUT, %ebx
    movl $lineBuffer, %ecx
    movl %esi, %edx
    int $SYSTEM_CALL

    #Retrieve values of registers and check whether there are no more lines 
    popl %edx
    popl %ebx
    decl %edx
    cmp $0, %edx
    je exit

    #Clear %esi register, set loop counters and prepare nextLine
    xorl %esi, %esi
    movl %edx, %eax
    decl %eax
    addl $2, %ebx
    movl %ebx, %ecx
    jmp prepareLine

exit:
    #Standard system exit call
    movl $EXIT, %eax
    movl $EXIT_VALUE, %ebx
    int $SYSTEM_CALL
    