I want to review some computer organization knowledge.



Ch1:Computer Abstractions and Technology


1.1 Introduction 
1.2 Eight Great Ideas in Computer Architecture 
1.3 Below Your Program 
1.4 Under the Covers 
1.5 Technologies for Building Processors and Memory 
1.6 Performance 
1.7 Th e Power Wall 
1.8 Th e Sea Change: Th e Switch from Uniprocessors 
Multiprocessors 
1.9 Real Stuff : Benchmarking the Intel Core i7 
1.10 Fallacies and Pitfalls 
1.11 Concluding Remarks 


1.1 Introduction 

Computers are important and we can see it every where in our daily life.



Hardware or software component How this component affects performance

1. Algorithm Determines both the number of source-level statements and the number of I/O operations executed


2. Programming language,compiler, and architecture

Determines the number of computer instructionsfor each source-level statement


3. Processor and memory system

Determines how fast instructions can be executed 

4. I/O system (hardware andoperating system)

Determines how fast I/O operations may be executed

不同的平行化來加快速度

■ In the category of data level parallelism, in Chapter 3 we use subword
parallelism via C intrinsics to increase performance by a factor of 3.8.

■ In the category of instruction level parallelism, in Chapter 4 we use loop
unrolling to exploit multiple instruction issue and out-of-order execution
hardware to increase performance by another factor of 2.3.

■ In the category of memory hierarchy optimization, in Chapter 5 we use
cache blocking to increase performance on large matrices by another factor
of 2.5.

■ In the category of thread level parallelism, in Chapter 6 we use parallel for
loops in OpenMP to exploit multicore hardware to increase performance by
another factor of 14.





1.2 Eight Great Ideas in Computer Architecture 

1:依照摩爾定律來設計-電晶體的數量在18-24個月會兩倍的理論
2:利用抽象化來簡化設計-已比較高階的視角省略底層細節的部分
3:加速程式大部分使用的部分
4:平行化程式設計來加快速度
5:管線的平行化，在硬體很常會利用到，之後的章節也會講到
6:記憶體的階層式，理想是希望記憶體可以又大又快又便宜，但實際上速度快容量小又很快，所以透過階層式的設計，加上快取，不同狀況使用不同  
7:如果猜測的成本低，而且又猜的正確率高，與其等待結果出來，不如先大膽假設去設計
8:利用冗餘的設計來增加容錯性，有備用的當出錯的時候可以代替。




1.3 Below Your Program 

從底層到高層分別是硬體、系統程式、應用程式
系統程式常見像是編譯器、組譯器、連結器、載入器、作業系統等
作業系統是軟體和硬體之間的橋樑，具有許多重要的功能



1.4 Under the Covers 

電腦架構有I/O、Memory、Process、Arithmetic 


1.5 Technologies for Building Processors and Memory 

從真空管、電晶體、積體電路、VLSI 超大型積體電路 慢慢演進

介紹了晶圓製作的過程
首先由普通矽砂拉製提煉，經過溶解、提純、蒸餾一系列措施製成單晶矽棒，單晶矽棒經過切片、拋光之後，就得到了單晶矽圓片，也即單晶矽晶圓。
silicon ingot ->(slice)-> blank Wafer -> (20~40 processes) -> pattern  Wafer -> dies -> Test dies (yield良率) 
-> (boding to) -> dies package -> (test)-> shopping to customer

IC（Integrated Circuit, 積體電路），又被稱為是「資訊產業之母」， 是資訊產品最基本、也是最重要 的元件
IC 是將電晶體、二極體、電阻器及電容器等電路元件， 聚集在矽晶片上，形成完整的邏輯電路， 以
達成控制、計算或記憶等功能，為人們處理各種事務。IC 種類複雜，但可粗分為記憶體 IC、微元件 IC、
邏輯 IC及類比 IC 四 大類。
IC的製作過程，由矽晶圓開始，經過一連串製程步驟，包括光學顯影、快速高溫製程、化學氣相沉積、離子
植入、蝕刻、化學機械研磨與製程監控等前段製程，以及封裝、測試等後段製程方始完成。
近來逐漸成為半導體製程技術主流的銅製程，其製作流程則與傳統鋁導線製程稍有不同。


1.6 Performance 
如何來測量程式的效率 出現了幾個公式

 performance = 1/execution time

 throughput vs response time 
 1: response time 下降 必然會 throughput 上升
 2: 即使增加很多的同樣的設備 response time 不會上升 但是 throughput會 

CPU time 
= Instruction count x CPI(clock cycle per instruction) x clock time  
= Instruction count x CPI(clock cycle per instruction) / clock rate

演算法、程式語言、編譯器 會影響 Instruction count 和 CPI  指令集架構 除了前面兩個 還會影響 clock rate.

有可能調整 Instruction count 導致 CPI 上升 彼此會互相影響
clock rate 事實上可能會因為節能或是需要比較到功能會隨狀況來改變，題目正常只是假設固定的clock rate 會比較好算





1.7 The Power Wall 




1.8 The Sea Change: The Switch from Uniprocessors to Multiprocessors 

1.9 Real Stuff : Benchmarking the Intel Core i7 

1.10 Fallacies and Pitfalls 

1.11 Concluding Remarks 