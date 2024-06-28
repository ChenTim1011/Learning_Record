現在我們將更進一步，在32位元保護模式下顯示「Hello World！」。

### 進入32位元模式

在上一篇文章中，CPU依然處於實模式——這意味著你可以通過中斷調用BIOS功能，使用16位指令，並且可以訪問最多1MB的記憶體（除非你使用段地址）。要訪問超過1MB的記憶體，我們需要啟用A20線，這可以通過調用‘A20-Gate activate’功能來實現。為此，我們將創建一個新檔案 `hello2.asm` 並將以下內容放入其中：

```
bits 16
org 0x7c00

boot:
    mov ax, 0x2401
    int 0x15 ; enable A20 bit

```

**解釋：** 這段程式碼啟用A20線，使得我們可以訪問超過1MB的記憶體。

接著，我們也會將VGA文字模式設置為已知值，以確保BIOS沒有設置為其他模式：

```
mov ax, 0x3
int 0x10 ; set vga text mode 3

```

**解釋：** 設置VGA文字模式為模式3，這是一個標準的80x25文字模式。

接下來，我們將啟用32位指令並進入保護模式。為此，我們需要設置一個全域描述符表（GDT），該表將定義一個32位程式碼段。然後使用 `lgdt` 指令加載它，並進行一個長跳轉到該程式碼段。

```
lgdt [gdt_pointer] ; load the gdt table
mov eax, cr0
or eax, 0x1 ; set the protected mode bit on special CPU reg cr0
mov cr0, eax
jmp CODE_SEG:boot2 ; long jump to the code segment

```

**解釋：** 這些指令負責加載GDT並進入保護模式。

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/0a34284e-c260-45f9-8797-9b6c5be931aa/e0cb0669-9413-42a3-b204-f0a8e870a630/Untitled.png)

### 全域描述符表 (GDT)

我們設置的GDT包含三個部分：一個空段、一個程式碼段和一個資料段。每個GDT條目的結構如下：

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

**解釋：** 定義GDT表，包含一個空段、一個程式碼段和一個資料段。

我們還需要一個GDT指標結構，這是一個16位的字段，包含GDT的大小，後跟一個32位指向GDT本身的指針。我們還將定義CODE_SEG和DATA_SEG值，這些值是GDT中的偏移量，稍後會使用：

```
gdt_pointer:
    dw gdt_end - gdt_start
    dd gdt_start
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

```

**解釋：** 定義GDT指標和段選擇子。

### 進入32位元保護模式

讓我們告訴nasm現在輸出32位元代碼。我們還會將其餘的段指向資料段。

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

**解釋：** 設置段寄存器以使用資料段。

### 向VGA文字緩衝區寫入資料

最後，讓我們從保護模式下向螢幕寫入「Hello World！」。我們無法再調用BIOS，但可以直接寫入VGA文字緩衝區。這個緩衝區對應的記憶體地址是0xb8000。每個螢幕上的字符佔用兩個位元組，頂位元組定義字符的顏色，底位元組定義ASCII碼。

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/0a34284e-c260-45f9-8797-9b6c5be931aa/bc8b5bf2-a941-4be6-83af-f781952c45db/Untitled.png)

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

**解釋：** 這段程式碼將「Hello World！」寫入VGA文字緩衝區。每個字符的顏色設置為藍色。

### 完整程式碼

```
bits 16
org 0x7c00

boot:
    mov ax, 0x2401          ; 設置AX為0x2401，準備啟用A20線
    int 0x15                ; 調用BIOS中斷0x15，啟用A20線
    mov ax, 0x3             ; 設置AX為0x3，準備設置VGA文字模式
    int 0x10                ; 調用BIOS中斷0x10，設置VGA文字模式為模式3

    lgdt [gdt_pointer]      ; 加載全域描述符表（GDT）
    mov eax, cr0            ; 將CR0寄存器的值讀入EAX
    or eax, 0x1             ; 設置EAX的最低位，啟用保護模式
    mov cr0, eax            ; 將修改後的值寫回CR0，進入保護模式
    jmp CODE_SEG:boot2      ; 長跳轉到32位代碼段，進入32位保護模式

gdt_start:
    dq 0x0                  ; GDT空段，必須存在的第一個段
gdt_code:
    dw 0xFFFF               ; 設置代碼段限長（低16位）
    dw 0x0                  ; 設置代碼段基址（低16位）
    db 0x0                  ; 設置代碼段基址（中8位）
    db 10011010b            ; 設置代碼段屬性（Present, Ring 0, Code Segment, Executable, Readable）
    db 11001111b            ; 設置代碼段限長（高4位）和段粒度（4KB, 32位模式）
    db 0x0                  ; 設置代碼段基址（高8位）
gdt_data:
    dw 0xFFFF               ; 設置資料段限長（低16位）
    dw 0x0                  ; 設置資料段基址（低16位）
    db 0x0                  ; 設置資料段基址（中8位）
    db 10010010b            ; 設置資料段屬性（Present, Ring 0, Data Segment, Writable）
    db 11001111b            ; 設置資料段限長（高4位）和段粒度（4KB, 32位模式）
    db 0x0                  ; 設置資料段基址（高8位）
gdt_end:

gdt_pointer:
    dw gdt_end - gdt_start  ; 設置GDT大小（16位）
    dd gdt_start            ; 設置GDT基址（32位）
CODE_SEG equ gdt_code - gdt_start  ; 定義代碼段選擇子
DATA_SEG equ gdt_data - gdt_start  ; 定義資料段選擇子

bits 32
boot2:
    mov ax, DATA_SEG        ; 將資料段選擇子載入AX
    mov ds, ax              ; 將AX的值載入DS段寄存器
    mov es, ax              ; 將AX的值載入ES段寄存器
    mov fs, ax              ; 將AX的值載入FS段寄存器
    mov gs, ax              ; 將AX的值載入GS段寄存器
    mov ss, ax              ; 將AX的值載入SS段寄存器

    mov esi, hello          ; 將字符串的地址載入ESI
    mov ebx, 0xb8000        ; 設置EBX為VGA文字緩衝區的起始地址
.loop:
    lodsb                   ; 從ESI載入一個字節到AL
    or al, al               ; 測試AL是否為零
    jz halt                 ; 如果AL為零，則跳轉到halt標籤
    or eax, 0x0100          ; 將AL擴展為16位，並設置顏色為藍色
    mov word [ebx], ax      ; 將擴展後的值寫入VGA緩衝區
    add ebx, 2              ; 將EBX增加2，指向下一個字符位置
    jmp .loop               ; 迴圈回到.loop標籤
halt:
    cli                     ; 禁用中斷
    hlt                     ; 停止CPU
hello: db "Hello world!", 0  ; 定義要顯示的字符串並以0結束

```

### 如何運行程式

將以上程式碼儲存為 `hello2.asm`，然後使用以下指令編譯並運行：

```
nasm -f bin hello2.asm -o hello2.bin
qemu-system-x86_64 -drive format=raw,file=hello2.bin

```

```
qemu-system-x86_64 -fda boot.bin
```
WARNING: Image format was not specified for 'hello2.bin' and probing guessed raw.
         Automatically detecting the format is dangerous for raw images, write operations on block 0 will be restricted.
         Specify the 'raw' format explicitly to remove the restrictions.
