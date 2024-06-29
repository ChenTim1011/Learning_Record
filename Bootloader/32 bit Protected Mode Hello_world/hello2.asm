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
