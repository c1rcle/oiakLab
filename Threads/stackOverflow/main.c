#include <string.h>
#include <stdio.h>

extern void function(unsigned char * bytes);

int main()
{
    unsigned char * bytes = "\x48\x65\x6C\x6C\x6F\x77\x6F\x72\x6C\x64\x21\x0A\x00\x00\x00\x00\x90\x90\xB8\x04\x00\x00\x00\xBB\x01\x00\x00\x00\xB9\xA8\xCE\xFF\xFF\xBA\x0C\x00\x00\x00\xCD\x80\xB8\x01\x00\x00\x00\xBB\x00\x00\x00\x00\xCD\x80\xB8\xCE\xFF\xFF";
    function(bytes);
    return(0);
}