.data
#System call identifiers.
SYS_WRITE = 4
SYS_MMAP2 = 192
SYS_CLONE = 120
SYS_EXIT  = 1
SYS_EXIT_VALUE = 0

#System call flags - clone().
CLONE_VM      = 0x00000100      #Set the new thread to run in the same virtual memory space.
CLONE_FS      = 0x00000200      #Share filesystem information.
CLONE_FILES   = 0x00000400      #Share filesystem information.
CLONE_SIGHAND = 0x00000800      #Share signal handlers with child thread.
CLONE_PARENT  = 0x00008000      #Share parent with callee.
CLONE_THREAD  = 0x00010000      #Child thread will be put in the same thread group.
CLONE_IO      = 0x80000000      #Share filesystem information.

#System call flags - mmap2().
MAP_GROWSDOWN = 0x0100          #Mapping extends downward in memory.
MAP_ANONYMOUS = 0x0020          #Mapping not backed by any file.
MAP_PRIVATE   = 0x0002          #Private copy-on-write mapping.

#Memory mapping protection.
PROT_READ  = 0x1                #Pages may be read.
PROT_WRITE = 0x2                #Pages may be written.

#Program constants declaraion.
THREAD_FLAGS = CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | CLONE_PARENT | CLONE_THREAD | CLONE_IO
STACK_SIZE   = 4096 * 1024
MAX_INC      = 100 
SYSTEM_CALL  = 0x80

#Variables declaration.
count: .long 0                  #Locking will be performed using this memory location.
printfFormat: .string "%i\n"

.text
.global main
main:
    #Create two threads using pointer to function threadFunction().
    movl $threadFunction, %ebx
    call createThread
    movl $threadFunction, %ebx
    call createThread

    #Main thread loop.
    workLoop:
    call checkOverflow
    jmp workLoop

threadFunction:
    #Thread function loop.
    call checkOverflow
    jmp threadFunction

checkOverflow:
    #If 'count' was incremented more than 100 times, exit thread.
    cmpl $MAX_INC, count
    ja exit
    movl $1, %eax
    #'count' incrementation thread locking.
    lock xadd %eax, count
    ret

createThread:
    #Save %ebx because it would get lost due to the system call.
    pushl %ebx
    #Create stack for a thread.
    call createStack
    #Second clone() argument is a pointer to the high address of stack.
    lea (STACK_SIZE - 8)(%eax), %ecx
    popl (%ecx)
    #Load clone() arguments into registers.
    movl $SYS_CLONE, %eax
    movl $THREAD_FLAGS, %ebx
    int $SYSTEM_CALL
    ret

createStack:
    #Load mmap2() arguments into registers.
    movl $SYS_MMAP2, %eax
    movl $0, %ebx
    movl $STACK_SIZE, %ecx
    movl $(PROT_WRITE | PROT_READ), %edx
    movl $(MAP_ANONYMOUS | MAP_PRIVATE | MAP_GROWSDOWN), %esi
    int $SYSTEM_CALL
    ret

exit:
    #Standard exit call.
    movl $SYS_EXIT, %eax
    movl $SYS_EXIT_VALUE, %ebx
    int $SYSTEM_CALL
