#!/bin/bash
nasm -f elf64 ch12.asm -o ch12.o
ld -s ch12.o -o ch12.exe
objcopy -O binary -j .text ch12.exe shellcode.bin
a=$(cat shellcode.bin | xxd -i)
b="${a//, /\\}"
c="${b//,/\\}"
d="${c// /}"
echo "$d"| tr -d '\n' > out.txt