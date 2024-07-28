
Instructions: Language of the Computer 60

2.1 Introduction 62

命令電腦硬體的語言是instruction
這一章介紹MIPS的組合語言，學習如何表示指令，學習電腦如何儲存程式設計概念，練習寫電腦的語言，看到程式語言和編譯器最佳化對於速度的影響


2.2 Operations of the Computer Hardware 63

每個電腦都要會運算，MIPS規定要一個operation和三個variables
add a, b, c
b和c相加後再和a相加
如果是a,b,c,d 相加
add a b c
add a a d

設計原則1: Simplicity favor s regularity 
有規律方便簡化規則


2.3 Operands of the Computer Hardware 66
運算指令的運算元擺放的位置有限制，必須放在特定的暫存器中。
MIPS 架構是32位元，32位元又稱為一個word

設計原則2: Smaller is faster
為什麼要限制32個位元是因為如果數量很大的暫存器會增加 clock cycle time ，因為電子訊息傳送會花比較久的時間，但是也不一定31個位元比32個位元更快，設計者必須平衡 craving of program for more registers 保持 clock cycle fast ， 另外是
32位元是2的倍數，可以符合指令格式
MIPS表達指令的格式
例如 $s0 系列表示像是C語言的變數
$t0 系列 暫時的暫存器需要被編譯到MIPS指令

Memory operands
程式語言的陣列或是 structure 儲存在記憶體中， 電腦要如何表示和存取？ 
只有少量的資料可以在暫存器計算，那該如何把資料從記憶體取出到暫存器中？
使用 data transfer instructions 
可以在暫存器在記憶體之間移動資料
1: load memory 》register 

words 一定要在4的倍數的位址 這個叫做 alignment restrictions 之後會提到這樣機制可以加快資料傳輸

 
2.4 Signed and Unsigned Numbers 73
如何表示二進位的數
sign and magnitude 不太好用

sign bit 最左邊的bit 0 + 1 -

1補數 0和1 互換
缺點是會有兩個零 正零 負零
x的補數=2^n-x-1
000000000 正零
111111111 負零


2補數 主要在用 0和1互換後加1
觀察 x + ~x = -1 得到 ~x+1=-x
為什麼叫二補數法
unsigned sum of n bit + negative n bit = 2^n  
負的部分  2^n - x


biased notation 
000000000 最負
111111111 最正
100000000 0
之後會介紹這個用法


2.5 Representing Instructions in the Computer 80

指令在電腦中是一連串高低的電子訊號，而且可以數字表示，這一章介紹暫存器號碼對應數字，用數字來表示，每個指令可以拆成多段獨立數字，再把這幾個數字拼起來變成完整指令
暫存器對應數字可以看小綠卡

指令的片段叫做field, field 用 binary 表示 可以叫 instruction format， binary 表示出來也剛好是32bits 所有MIPS指令是32  bits 長 ' 為了和組合語言分辨 這個數字版本的指令我們叫它 machine languages 一連串的這些指令就叫 machine code 
MIPS field
op rs rt rd shamt funct
655556
opcode 做什麼動作
先給一個pattern 後面function code 
shamt 為什麼主要5bit 最多shift 31 bits 就好了！ 



這是r rype 指令 後面會有 lw sw 需要兩個暫存器和常數 就沒辦法像上面一樣
所以接下來有設計原則3 好的設計需要好的妥協

i type 指令
op rs rt constant 
6 5 5 16

16 bit的位址表示 load word 指令
可表示到+-2^15 

好的設計要有好的妥協
所有MIPS指令長度相同，但是有不同的format
雖然很多format會讓設計變得複雜，但是我們可以讓彼此format相似，不同類型的format有不同的op code 所以硬體知道該如何實作。
如果暫存器每一個field用更多的vit去表示，會降低速度，因為smaller is faster大多設計在16和32 bits

現在電腦設計兩個原則
1:指令被表示成數字
2:程式儲存在記憶體可以被讀取或是寫入
這兩個原則變成stored program 的概念
記憶體可以包含多個程式的machine code
這些已經存在的指令，具有 binary compatibility 的特性，能夠讓電腦繼承 ready made  軟體

2.6 Logical Operations 87




2.7 Instructions for Making Decisions 90
2.8 Supporting Procedures in Computer Hardware 96

program counter 指令位置的暫存器
如果當今天引數超過四個，我們想要更多引數，就必須使用 stack, 還需要 stack pointer。 stack 增長由 higher address 到 lower address 所以當push進去會是減的。
為了避免我們儲存和恢復沒有使用的值
有可能出現在 temporary 的暫存器
所以 MIPS 分成兩類 t0-t9 不會被 callee保存 s0-s7 一定要保存在 procedure call  如果使用由 callee 保存和恢復 

leaf procedure 沒有呼叫其他的函式

procedure frame stack片段包含procedure 儲存的暫存器和區域變數

frame pointer 指出 procedure frame 裡面 第一個 word

frame pointer 好處是所有在stack參考一下到的變數在 procedure 中 有同樣的 offset 但是 不一定都有 frame pointer GNU MIPS C compiler 有使用fp 但是 C compiler from MIPS 並沒有fp 第30的暫存器被當成是s8




2.9 Communicating with People 106
如果暫存器要放32bit怎麼辦？
使用lui 先把左邊的16 bits 給放進去
右邊16bits是0 再用ori 把 右邊16bits 放進去 因為自己和0 or 還會是自己 記得要算一下左和右 binary 的 總和

2.10 MIPS Addressing for 32-Bit Immediates and Addresses 111

2.11 Parallelism and Instructions: Synchronization 121
2.12 Translating and Starting a Program 123
2.13 A C Sort Example to Put It All Together 132
2.14 Arrays versus Pointers 141

x Contents

2.15 Advanced Material: Compiling C and Interpreting Java 145
2.16 Real Stuff : ARMv7 (32-bit) Instructions 145
2.17 Real Stuff : x86 Instructions 149
2.18 Real Stuff : ARMv8 (64-bit) Instructions 158
2.19 Fallacies and Pitfalls 159
