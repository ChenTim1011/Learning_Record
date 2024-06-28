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
