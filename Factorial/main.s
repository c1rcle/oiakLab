.data
firstStr: .string "Program obliczający n!. Podaj n: \n"
resultStr: .string "Wynik to: %i\n"

errDataStr: .string "Wprowadziłeś niepoprawne dane!\n"
errformatStr: .string "Niepoprawny format wejściowy!\n"

inFormat: .string "%i"
inN: .space 4

exitCode = 0

.text
.global main
main:
    pushl $firstStr     #Call printf with start string parameter
    call printf
    pushl $inN          #Input a number using scanf
    pushl $inFormat
    call scanf

    cmpl $0, %eax       #Check for succesful read
    je wrongFormat

    movl inN, %eax      #Check if n is less/equal/greater than 0
    cmpl $0, %eax
    je equalsZero
    jl lessThanZero
    movl $1, %ecx
    movl $1, %edx
    jg moreThanZero

wrongFormat:
    pushl $errformatStr
    call printf
    jmp endProg

lessThanZero:
    pushl $errDataStr
    call printf
    jmp endProg

equalsZero:
    pushl $1
    pushl $resultStr
    call printf
    jmp endProg

moreThanZero:
    cmpl %eax, %ecx
    ja done
    imull %ecx, %edx
    incl %ecx
    jmp moreThanZero

done:
    pushl %edx
    pushl $resultStr
    call printf
    jmp endProg

endProg:
    pushl $exitCode
    call exit
