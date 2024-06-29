bits 16         ; Tell NASM this is 16-bit code
org 0x7c00      ; Set the starting address to 0x7C00, telling NASM to output starting at offset 0x7C00
boot:           ; The starting label of the program
    mov si, hello  ; Point SI register to the memory location of the 'hello' label
    mov ah, 0x0e   ; Set AH register to 0x0e, which indicates 'Write Character in TTY mode'
.loop:
    lodsb          ; Load byte at address in SI into AL and increment SI
    or al, al      ; Check if AL == 0 (null terminator)
    jz halt        ; If AL == 0, jump to the 'halt' label
    int 0x10       ; Execute BIOS interrupt 0x10 - Video services
    jmp .loop      ; Jump back to the start of the loop
halt:
    cli            ; Clear interrupt flag
    hlt            ; Halt the CPU
hello: db "Hello world!", 0  ; Define a null-terminated string "Hello world!"

times 510 - ($ - $$) db 0  ; Fill the remaining bytes to make the total size 510 bytes with zeros
dw 0xaa55         ; Bootloader signature - marks this 512-byte sector as bootable
