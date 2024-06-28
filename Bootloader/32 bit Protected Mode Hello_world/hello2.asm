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