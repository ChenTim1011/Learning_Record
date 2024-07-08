#### Reference: https://hackmd.io/@sysprog/c-pointer?type=view

Sure! Here is the translation of your text into coherent English:

---

[Unknown Aspects of C Language: Pointers - HackMD](https://hackmd.io/@sysprog/c-pointer?type=view)

### Why Pointers Are Designed

What kind of products from this company would use pointers, and in what scenarios would they be applicable?

In an interview, the ability to react reflects the skills required by the company.

```c
int main() {
    typedef void (*funcptr)();
    (* (funcptr) (void *) 0)();
}
```

- Defines a function pointer type `funcptr` that points to a function returning `void` and taking no parameters.
- Uses the function pointer to cast the address `0x0` to the `funcptr` type and calls the function at that address.

### x86 64 gcc Assembly Explanation

```assembly
main:
        push    rbp           ; Save rbp
        mov     rbp, rsp      ; Set the new stack base pointer
        mov     eax, 0        ; Set eax to 0
        mov     edx, 0        ; Set edx to 0 (preparing for the call)
        call    rdx           ; Call the function pointed to by edx (here edx = 0)
        mov     eax, 0        ; Set return value to 0
        pop     rbp           ; Restore rbp
        ret                   ; Return to caller
```

### Detailed Explanation

1. `push rbp`: Saves the current base pointer (rbp), to restore the stack state at the end of the function.
2. `mov rbp, rsp`: Copies the stack pointer (rsp) to the base pointer (rbp), setting up the new stack frame.
3. `mov eax, 0`: Sets eax to 0. Here, eax is typically used for setting the system call number or preparing function arguments.
4. `mov edx, 0`: Sets edx to 0. This step sets edx to point to the memory address 0x0.
5. `call rdx`: Calls the function pointed to by edx, which is the memory address 0x0. Since 0x0 is usually an invalid memory address, this typically causes a segmentation fault.
6. `mov eax, 0`: Sets eax to 0 as the return value.
7. `pop rbp`: Restores the previously saved base pointer.
8. `ret`: Returns to the caller.

### Why Learn Assembly Language

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/0a34284e-c260-45f9-8797-9b6c5be931aa/b390a4a4-1673-4761-87c2-840d74476fdb/Untitled.png)

User-level programs cannot arbitrarily access the address 0x0.

Pointers are somewhat similar to the needle of a sewing machine.

### Technology Company Interview Question:

```c
void **(*d) (int &, char **(*)(char *, char **));
```

Interpretation of the above declaration:

d is a pointer to a function that takes two parameters:

1. a reference to an int
2. a pointer to a function that takes two parameters:
   - a pointer to a char
   - a pointer to a pointer to a char
     and returns a pointer to a pointer to a char

and returns a pointer to a pointer to void

### Reference:

`void ( *signal(int sig, void (*handler)(int)) ) (int);`

### Why C Language Was Designed

C language was designed to develop the Unix operating system in 1969, utilizing both assembly language and interpreters.

C language was influenced by its predecessors:

- Fortran
- B language (precursor to C language)
- CPL → BCPL → B language → C language
  The emphasis lies in how the design of a programming language is influenced by its predecessors.

### Unix Operating System Development (1972-1974)

1. Most of the Unix operating system was developed using the C language.
2. It allowed direct hardware manipulation.
3. C language is not just a programming language but a culture, often referred to as the Unix culture.

### Go Language

After retiring from Bell Labs, Ken Thompson became a pilot. Gaining inspiration from flying, he joined Google in 2006. The following year, he, along with his former Bell Labs colleagues Rob Pike and Robert Griesemer, proposed the new Go programming language within Google. Go can be used in numerous fields, including cloud computing.

The good aspects of pointers in C language were carried over to Go language, along with the beautiful struct.

### The Need for Go Language

Prior programming languages before Go could not achieve:

- Adding new libraries is not the correct direction.
- The entire architecture needs to be rethought to develop a new programming language.
- In practical terms, pointers and structs often go hand-in-hand (explained below).

[C language: Easy-to-Understand Pointers, Beginners Welcome - Kopuchat](https://kopu.chat/c語言-超好懂的指標，初學者請進～/)

---
