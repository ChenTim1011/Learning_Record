### 撰寫一個簡單的32位元x86作業系統核心：Hello World Bootloader

這篇系列文章將教你如何從頭開始撰寫一個簡單的32位元x86作業系統核心。我們將從顯示"Hello world!"開始，逐步增加程式的複雜度，最終使用C++。這裡是詳細的步驟和說明。

### 1. 安裝必要工具

### 在Linux或WSL上安裝NASM組譯器和QEMU虛擬機器

```bash

sudo apt-get install nasm qemu

```

### 什麼是NASM？

NASM（Netwide Assembler）是一個開源的x86組合語言組譯器，支援16位、32位和64位的x86架構。它被設計用來生成高效的機器碼，並且擁有靈活的語法和強大的宏系統。

### 什麼是QEMU？

QEMU是一個開源的虛擬機器模擬器，可以模擬多種CPU架構和硬體。它允許你在不同作業系統和硬體環境中運行和測試作業系統。QEMU非常適合用來開發和測試操作系統，因為它可以模擬虛擬機器，而不會影響到你的真實硬體。

### 在Windows 10上安裝X Server

在Windows 10上，你需要安裝一個X Server來允許QEMU從Linux子系統打開一個視窗。

### 2. 撰寫Hello World Bootloader

### 程式碼

```

bits 16 ; 告訴NASM這是16位元程式碼
org 0x7c00 ; 起始地址為0x7C00 告訴NASM從偏移量0x7c00開始輸出
boot: ;程式的起始標籤
    mov si, hello ; 指向hello標籤所在的記憶體位置
    mov ah, 0x0e ; 0x0e表示'Write Character in TTY mode'
.loop:
    lodsb
    or al, al ; al == 0 ?
    jz halt  ; 如果al == 0，跳轉到halt標籤
    int 0x10 ; 執行BIOS中斷0x10 - 視訊服務
    jmp .loop
halt:
    cli ; 清除中斷標誌
    hlt ; 停止執行
hello: db "Hello world!", 0

times 510 - ($ - $$) db 0 ; 填充剩下的510位元組為零
dw 0xaa55 ; 魔法引導載入器標記 - 標記這個512位元組扇區為可引導

```


### 3. 編譯和運行程式

### 將程式碼保存為 `hello.asm`

### 使用NASM編譯程式碼

```bash

nasm -f bin hello.asm -o hello.bin

```

解釋：這個指令使用NASM將組合語言程式碼編譯成二進位文件。

### 檢查生成的二進位文件

```bash

hexdump hello.bin

```

你應該會看到類似這樣的輸出：

```r

0000000 be 10 7c b4 0e ac 08 c0 74 04 cd 10 eb f7 fa f4
0000010 48 65 6c 6c 6f 20 77 6f 72 6c 64 21 00 00 00 00
0000020 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
*
00001f0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 aa
0000200

```

### 使用QEMU運行二進位文件

```bash

qemu-system-x86_64 -fda hello.bin

```

在Windows 10上，如果使用WSL，你可能需要在前面加上`DISPLAY=:0`來打開視窗：

```bash

DISPLAY=:0 qemu-system-x86_64 -fda boot1.bin

```

你應該會看到類似這樣的畫面：

```

Hello world!

```

這就是一個基本的引導載入器，它顯示"Hello world!"在螢幕上。

### 總結

1. 安裝NASM組譯器和QEMU虛擬機器。
2. 撰寫並保存組合語言程式碼到文件`hello.asm`。
3. 使用NASM編譯組合語言程式碼為二進位文件`hello.bin`。
4. 使用QEMU運行二進位文件，看到"Hello world!"顯示在螢幕上。