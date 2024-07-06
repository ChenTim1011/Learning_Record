#### Reference: https://hackmd.io/@sysprog/c-compiler-optimization

了解編譯器的限制，因為我們付出便利的時候，可能會付出一些代價。
https://briancallahan.net/blog/20210814.html

Sure, here are the main points in English:

### 1.1 What is a Compiler?

- **Role of a Compiler**: Translates a high-level programming language, suitable for human programmers, into low-level machine language required by computers.
- **Advantages of High-Level Languages**:
  - Closer to how humans think about problems, reducing development time.
  - Compilers can detect and report obvious programming errors.
  - Programs in high-level languages are generally shorter than equivalent machine language programs.
- **Portability**: The same high-level language program can be compiled into many different machine languages, making it runnable on various machines.

### 1.2 Phases of a Compiler

- **Lexical Analysis**: Divides the program text into tokens, each representing a symbol in the programming language, like variable names, keywords, or numbers.
- **Syntax Analysis**: Organizes tokens into a syntax tree that reflects the program's structure.
- **Type Checking**: Ensures the program meets certain consistency requirements, like using declared variables correctly.
- **Intermediate Code Generation**: Translates the program into a simple, machine-independent intermediate language.
- **Register Allocation**: Translates symbolic variable names in the intermediate code into register numbers in the target machine code.
- **Machine Code Generation**: Converts intermediate language into assembly language specific to a machine architecture.
- **Assembly and Linking**: Translates assembly language code into binary representation and determines addresses of variables and functions.

The first three phases (lexical analysis, syntax analysis, type checking) are called the **frontend**, while the last three phases (intermediate code generation, register allocation, machine code generation) are the **backend**. **Middle part** often includes optimizations and transformations on intermediate code.
