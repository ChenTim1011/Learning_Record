### Entering 32-bit Protected Mode to Display "Hello World!"

In the previous article, the CPU was still in real mode, meaning we could call BIOS functions using interrupts, use 16-bit instructions, and access up to 1MB of memory (unless using segment addresses). To access more than 1MB of memory, we need to enable the A20 line, which can be done by calling the 'A20-Gate activate' function. For this, we'll create a new file `hello2.asm` and add the following content:

```
bits 16
org 0x7c00

boot:
    mov ax, 0x2401
    int 0x15 ; enable A20 bit

```

**Explanation:** This code enables the A20 line, allowing us to access more than 1MB of memory.

Next, we'll set the VGA text mode to a known value to ensure the BIOS hasn't set it to something else:

```
mov ax, 0x3
int 0x10 ; set VGA text mode 3

```

**Explanation:** This sets the VGA text mode to mode 3, a standard 80x25 text mode.

Now, we'll enable 32-bit instructions and enter protected mode. For this, we need to set up a Global Descriptor Table (GDT) that defines a 32-bit code segment. Then, we'll use the `lgdt` instruction to load it and perform a long jump to this code segment.

```
lgdt [gdt_pointer] ; load the GDT
mov eax, cr0
or eax, 0x1 ; set the protected mode bit on special CPU register cr0
mov cr0, eax
jmp CODE_SEG:boot2 ; long jump to the code segment

```

**Explanation:** These instructions load the GDT and enter protected mode.

### Global Descriptor Table (GDT)

Our GDT consists of three parts: a null segment, a code segment, and a data segment. Each GDT entry is structured as follows:

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/0a34284e-c260-45f9-8797-9b6c5be931aa/1ae0e9b3-6a35-48af-9ff9-a6445df020e6/Untitled.png)

```
gdt_start:
    dq 0x0
gdt_code:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0
gdt_data:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
gdt_end:

```

**Explanation:** Defines the GDT table with a null segment, a code segment, and a data segment.

We also need a GDT pointer structure, which is a 16-bit field containing the size of the GDT followed by a 32-bit pointer to the GDT itself. We'll also define CODE_SEG and DATA_SEG values as the offsets within the GDT that we'll use later:

```
gdt_pointer:
    dw gdt_end - gdt_start
    dd gdt_start
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

```

**Explanation:** Defines the GDT pointer and segment selectors.

### Entering 32-bit Protected Mode

Let's tell NASM to output 32-bit code now. We'll also set the rest of the segments to point to the data segment.

```
bits 32
boot2:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

```

**Explanation:** Sets up the segment registers to use the data segment.

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/0a34284e-c260-45f9-8797-9b6c5be931aa/b827a42f-e52a-4cf1-807c-cb1c678b5795/Untitled.png)

### Writing Data to the VGA Text Buffer

Finally, let's write "Hello World!" to the screen from protected mode. We can no longer call BIOS, but we can write directly to the VGA text buffer at memory address 0xb8000. Each character on the screen occupies two bytes, with the high byte defining the character's color and the low byte defining the ASCII code.

```
mov esi, hello
mov ebx, 0xb8000
.loop:
    lodsb
    or al, al
    jz halt
    or eax, 0x0100
    mov word [ebx], ax
    add ebx, 2
    jmp .loop
halt:
    cli
    hlt
hello: db "Hello world!", 0

```

**Explanation:** This code writes "Hello World!" to the VGA text buffer. The color of each character is set to blue.

### Complete Code

```
bits 16
org 0x7c00

boot:
    mov ax, 0x2401          ; Set AX to 0x2401 to prepare for enabling the A20 line
    int 0x15                ; Call BIOS interrupt 0x15 to enable the A20 line
    mov ax, 0x3             ; Set AX to 0x3 to prepare for setting VGA text mode
    int 0x10                ; Call BIOS interrupt 0x10 to set VGA text mode to mode 3

    lgdt [gdt_pointer]      ; Load the Global Descriptor Table (GDT)
    mov eax, cr0            ; Read the value of CR0 into EAX
    or eax, 0x1             ; Set the lowest bit of EAX to enable protected mode
    mov cr0, eax            ; Write the modified value back to CR0, entering protected mode
    jmp CODE_SEG:boot2      ; Far jump to the 32-bit code segment, entering 32-bit protected mode

gdt_start:
    dq 0x0                  ; Null descriptor, required first entry in the GDT
gdt_code:
    dw 0xFFFF               ; Set segment limit (low 16 bits)
    dw 0x0                  ; Set base address (low 16 bits)
    db 0x0                  ; Set base address (middle 8 bits)
    db 10011010b            ; Set segment attributes (Present, Ring 0, Code Segment, Executable, Readable)
    db 11001111b            ; Set segment limit (high 4 bits) and granularity (4KB, 32-bit mode)
    db 0x0                  ; Set base address (high 8 bits)
gdt_data:
    dw 0xFFFF               ; Set segment limit (low 16 bits)
    dw 0x0                  ; Set base address (low 16 bits)
    db 0x0                  ; Set base address (middle 8 bits)
    db 10010010b            ; Set segment attributes (Present, Ring 0, Data Segment, Writable)
    db 11001111b            ; Set segment limit (high 4 bits) and granularity (4KB, 32-bit mode)
    db 0x0                  ; Set base address (high 8 bits)
gdt_end:

gdt_pointer:
    dw gdt_end - gdt_start  ; Set GDT size (16 bits)
    dd gdt_start            ; Set GDT base address (32 bits)
CODE_SEG equ gdt_code - gdt_start  ; Define code segment selector
DATA_SEG equ gdt_data - gdt_start  ; Define data segment selector

bits 32
boot2:
    mov ax, DATA_SEG        ; Load data segment selector into AX
    mov ds, ax              ; Load AX into DS segment register
    mov es, ax              ; Load AX into ES segment register
    mov fs, ax              ; Load AX into FS segment register
    mov gs, ax              ; Load AX into GS segment register
    mov ss, ax              ; Load AX into SS segment register

    mov esi, hello          ; Load the address of the string into ESI
    mov ebx, 0xb8000        ; Set EBX to the starting address of the VGA text buffer
.loop:
    lodsb                   ; Load a byte from ESI into AL
    or al, al               ; Test if AL is zero
    jz halt                 ; If AL is zero, jump to halt label
    or eax, 0x0100          ; Extend AL to 16 bits and set the color to blue
    mov word [ebx], ax      ; Write the extended value to the VGA buffer
    add ebx, 2              ; Increment EBX by 2 to point to the next character position
    jmp .loop               ; Loop back to .loop label
halt:
    cli                     ; Disable interrupts
    hlt                     ; Halt the CPU
hello: db "Hello world!", 0  ; Define the string to be displayed, ending with 0

```

### How to Run the Program

Save the above code as `hello2.asm`, then compile and run it with the following commands:

```bash
nasm -f bin hello2.asm -o hello2.bin
qemu-system-x86_64 -fda hello2.bin

```

Note: If you encounter the following warning:

```bash
WARNING: Image format was not specified for 'hello2.bin' and probing guessed raw.
         Automatically detecting the format is dangerous for raw images, write operations on block 0 will be restricted.
         Specify the 'raw' format explicitly to remove the restrictions.

```

You can use

```
qemu-system-x86_64 -drive format=raw,file=hello2.bin
```

Ensure to specify the format explicitly as shown above.

By following these steps, you will see "Hello world!" displayed on the screen in blue text. This example demonstrates how to set up protected mode

and output text directly to the VGA text buffer from a 32-bit x86 operating system kernel.