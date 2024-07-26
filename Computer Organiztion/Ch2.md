
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

2.4 Signed and Unsigned Numbers 73
2.5 Representing Instructions in the Computer 80
2.6 Logical Operations 87
2.7 Instructions for Making Decisions 90
2.8 Supporting Procedures in Computer Hardware 96
2.9 Communicating with People 106
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
