### Writing a Simple 32-bit x86 Operating System Kernel: From "Hello World!" to Complexity

We will start from scratch to write a simple 32-bit x86 operating system kernel. We'll begin by displaying "Hello World!" on the screen and gradually increase the complexity of the program, eventually using C++. Here are the detailed steps and explanations.

### 1. Installing Necessary Tools

### Install NASM Assembler and QEMU Emulator on Linux or WSL

```bash
sudo apt-get install nasm qemu

```

### What is NASM?

NASM (Netwide Assembler) is an open-source x86 assembler that supports 16-bit, 32-bit, and 64-bit x86 architectures. It is designed to generate efficient machine code and has flexible syntax and a powerful macro system.

### What is QEMU?

QEMU is an open-source virtual machine emulator that can emulate various CPU architectures and hardware. It allows you to run and test operating systems in different environments without affecting your real hardware. QEMU is ideal for developing and testing operating systems as it can simulate virtual machines safely.

### Installing X Server on Windows 10

On Windows 10, you need to install an X Server to allow QEMU to open a window from the Linux subsystem.

### 2. Writing the Hello World Bootloader

### Code

```
bits 16         ; Tell NASM this is 16-bit code
org 0x7c00      ; Set the starting address to 0x7C00
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

```

### Code Explanation

- `bits 16`: Specifies that the code is 16-bit, as the CPU starts in 16-bit real mode at boot.
- `org 0x7c00`: Sets the origin to 0x7C00, the memory address where the BIOS loads the bootloader.
- `boot:`: The starting point of the program.
- `mov si, hello`: Points the `si` register to the `hello` label, where the string "Hello world!" is stored.
- `mov ah, 0x0e`: Sets the `ah` register to 0x0e, a BIOS interrupt function for writing a character to the screen.
- `.loop:`: The main loop of the program.
- `lodsb`: Loads the byte at `ds:si` into the `al` register and increments `si`.
- `or al, al`: Checks if `al` is 0. If `al` is 0, it jumps to the `halt` label.
- `jz halt`: Jumps to the `halt` label if `al` is 0.
- `int 0x10`: Calls BIOS interrupt 0x10 to print the character in `al` to the screen.
- `jmp .loop`: Jumps back to the start of the loop to print the next character.
- `halt:`: The end of the program.
- `cli`: Clears the interrupt flag, disabling hardware interrupts.
- `hlt`: Halts the CPU, putting it to sleep and indicating the end of the program.
- `hello: db "Hello world!", 0`: Defines the string "Hello world!" followed by a null character (0).
- `times 510 - ($ - $$) db 0`: Fills the remaining space in the 512-byte sector with zeros. `$` represents the current address, and `$$` represents the start address. `db 0` fills the space with zeros.
- `dw 0xaa55`: Adds the boot signature (0xAA55) to the end of the 512-byte sector, marking it as bootable.

### 3. Compile and Run the Program

### Save the Code as `hello.asm`

### Compile the Code Using NASM

```bash
nasm -f bin hello.asm -o hello.bin

```

Explanation: This command uses NASM to compile the assembly code into a binary file.

### Verify the Generated Binary File

```bash
hexdump hello.bin

```

You should see output similar to this:

```r
0000000 be 10 7c b4 0e ac 08 c0 74 04 cd 10 eb f7 fa f4
0000010 48 65 6c 6c 6f 20 77 6f 72 6c 64 21 00 00 00 00
0000020 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
*
00001f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 aa
0000200

```

### Run the Binary File Using QEMU

```bash
qemu-system-x86_64 -fda hello.bin

```

On Windows 10, if using WSL, you might need to prefix with `DISPLAY=:0` to open the window:

```bash
DISPLAY=:0 qemu-system-x86_64 -fda hello.bin

```

You should see output similar to this:

```
Hello world!

```

This is a basic bootloader that displays "Hello world!" on the screen.

### Summary

1. Install NASM assembler and QEMU emulator.
2. Write and save assembly code to a file (`hello.asm`).
3. Compile the assembly code into a binary file (`hello.bin`) using NASM.
4. Run the binary file using QEMU to see "Hello world!" displayed on the screen.

### If You Encounter the Following Error

```
Temporary failure resolving 'archive.ubuntu.com'
E: Failed to fetch <http://archive.ubuntu.com/ubuntu/pool/universe/n/nasm/nasm_2.15.05-1_amd64.deb>  Temporary failure resolving 'archive.ubuntu.com'

```

- Ensure `dpkg` is installed. Most Unix systems come with this tool pre-installed. If not, install it using a package manager:
    
    ```bash
    sudo apt-get install dpkg
    
    ```
    
- Extract the `.deb` file using `dpkg-deb` command:
    
    ```bash
    dpkg-deb -x nasm_2.15.05-1_amd64.deb extraction_directory
    
    ```
    

### 1. Extract the `.deb` File

First, you have extracted the contents:

```bash
dpkg-deb -x nasm_2.15.05-1_amd64.deb extraction_directory

```

This extracts the contents of the `.deb` file into the `extraction_directory`.

### 2. View the Extracted Directory Structure

Navigate into the extracted directory and view the files and directory structure:

```bash
cd extraction_directory
ls -R

```

### 3. Manually Install the Application

Typically, executable files are located in `usr/bin` or `usr/local/bin`, and libraries in `usr/lib`. You can manually copy these files to the corresponding directories in your system.

For example, if the extracted `nasm` executable is in `usr/bin`, you can copy it to the system's `/usr/local/bin` directory:

```bash
sudo cp -r usr/bin/* /usr/local/bin/

```

### 4. Update Environment Variables (If Needed)

If the manually installed application is not in the default system path, update the environment variables. For example, add `/usr/local/bin` to the `PATH`:

```bash
export PATH=/usr/local/bin:$PATH

```

Add this line to your `~/.bashrc` or `~/.profile` file to set it automatically each time you start a terminal.

### 5. Verify the Installation

Finally, verify the application installation:

```bash
nasm -v

```

This should display the `nasm` version information, indicating it is successfully installed and ready to use.