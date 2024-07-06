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

### Lexical Analysis

#### 2.1 Introduction

- **Definition**: Lexical pertains to words. In programming, words are objects like variable names, numbers, keywords, etc., called tokens.
- **Lexical Analyser (Lexer)**: A lexer takes a string of individual characters and divides it into tokens, filtering out white-space (spaces, newlines, etc.) and comments.
- **Purpose**: Lexical analysis simplifies the syntax analysis phase.
  - **Efficiency**: Lexers can process simpler parts faster than general parsers.
  - **Modularity**: Separates the syntax description of the language from lexical details.
  - **Tradition**: Many languages are designed with separate lexical and syntactical phases.

#### 2.2 Regular Expressions

- **Definition**: Regular expressions describe sets of strings using a compact, human-readable algebraic notation.
- **Alphabet**: The set of characters used in the strings.
- **Languages**: Sets of strings defined by regular expressions.

##### Basic Constructs of Regular Expressions

- **Single Letter**: Describes a language with the one-letter string as its only element.
- **Empty String (ε)**: Describes a language containing only the empty string.
- **Union (s|t)**: Describes the union of languages described by `s` and `t`.
- **Concatenation (st)**: Describes the concatenation of languages `L(s)` and `L(t)`.
- **Kleene Star (s\*)**: Describes the language consisting of the empty string plus any number of concatenations of strings from `L(s)`.

##### Precedence Rules

- **Binding Order**:
  - `*` binds tighter than concatenation.
  - Concatenation binds tighter than alternative `|`.
- **Example**: `a|ab*` is equivalent to `a|(a(b*))`.
- **Associative and Commutative Properties**:
  - `|` is associative and commutative (like set union).
  - Concatenation is associative but not commutative and distributes over `|`.

### 2.2.1 Shorthands

#### Introduction

While the constructions in Figure 2.1 suffice for describing number strings and variable names, using extra shorthands can simplify the expressions. For example, describing non-negative integer constants with regular expressions can be verbose.

#### Shorthands for Regular Expressions

- **Bracket Notation**:
  - Example: `[ab01]` is shorthand for `a|b|0|1`.
  - Interval Notation: `[0-9]` for digits from 0 to 9; `[a-zA-Z]` for all alphabetic letters.
- **Usage of Intervals**:
  - Use standard ASCII or ISO 8859-1 character sets for clear symbol ordering.
  - Avoid ambiguous intervals like `[0-z]`.

#### Examples of Shorthand Usage

- **Integer Constants**: `[0-9][0-9]*` becomes `[0-9]+`.
- **Optional Elements**: `s?` represents `s|ε`.

These shorthands make regular expressions more concise and manageable without altering the sets of languages they describe.

#### Algebraic Properties of Regular Expressions (Figure 2.2)

- Associative and commutative properties of `|`.
- Associative property of concatenation.
- Idempotent properties of `|` and `*`.
- Definitions of shorthands such as `s+` and `s?`.

### 2.2.2 Examples

#### Describing Programming Language Elements with Regular Expressions

- **Keywords**: Regular expression for `if` is simply `if`.
- **Variable Names**:
  - In C: `[a-zA-Z_][a-zA-Z_0-9]*`.
- **Integers**:
  - Non-empty sequence of digits, optionally preceded by a sign: `[+-]?[0-9]+`.
- **Floats**:
  - Complex format involving optional signs, digits, decimal points, and exponents.
  - Simplified version (if integers are also included): `[+-]?(([0-9]+(.[0-9]*)?|.[0-9]+)([eE][+-]?[0-9]+)?)`.
- **String Constants**:
  - Starts and ends with quotation marks, includes alphanumeric characters and escape sequences: `"([a-zA-Z0-9]|\\[a-zA-Z])*"`.

### 2.3 Nondeterministic Finite Automata (NFA)

#### Introduction

- **Purpose**: Transform regular expressions into efficient programs using nondeterministic finite automata (NFA). NFAs are then converted into deterministic finite automata (DFA) for efficient execution.
- **Definition**: A finite automaton is a machine with a finite number of states and transitions. Transitions can be labeled with input characters or ε (epsilon transitions).

#### Key Concepts

- **States and Transitions**:
  - **States**: Represent the condition or situation of the automaton at any given moment.
  - **Transitions**: Movements between states triggered by input characters or ε transitions.
- **Acceptance**: An input string is accepted if, after processing all characters, the automaton reaches an accepting state.

#### Nondeterministic Nature

- **Multiple Choices**: At each step, the automaton can:
  - Follow an epsilon transition.
  - Read a character and follow a corresponding transition.
- **Path to Acceptance**: A string is in the language if there exists at least one sequence of choices leading to an accepting state.

#### Formal Definition (Definition 2.1)

- **Components**:
  - **S**: Set of states.
  - **s0**: Starting state.
  - **F**: Subset of states that are accepting states.
  - **T**: Set of transitions labeled with symbols from the alphabet Σ or ε.
- **Transition Notation**: A transition from state s1 to s2 on symbol c is written as sc t.

#### Graphical Representation

- **States**: Represented by circles (double circles for accepting states).
- **Initial State**: Marked by an arrow pointing to it from outside the automaton.
- **Transitions**: Represented by arrows between states, labeled with symbols or ε.

#### Example NFA (Figure 2.3)

- **Structure**:
  - States: 1 (starting), 2, 3 (accepting).
  - Transitions: ε from 1 to 2, 'a' from 2 to 1 and 3, 'b' from 1 to 3.
- **Language**: Recognizes the language described by the regular expression `a*(a|b)`.
- **Example String**: The string "aab" is accepted by the sequence of transitions:
  1. 1 to 2 (ε)
  2. 2 to 1 (a)
  3. 1 to 2 (ε)
  4. 2 to 1 (a)
  5. 1 to 3 (b)

#### Challenges of NFA

- **Multiple Transitions**: NFAs may have multiple transitions for the same input character from a state, requiring backtracking or simultaneous path exploration.
- **Efficiency**: NFAs are not efficient for recognition due to the need to explore multiple paths. They serve as an intermediate step before converting to DFAs.

### 2.4 Converting a Regular Expression to an NFA

#### Approach

- Construct an NFA compositionally from a regular expression.
- Build NFA fragments from subexpressions and combine them to form the full NFA.
- An NFA fragment includes states, transitions, an incoming half-transition, and an outgoing half-transition.

#### Construction of NFA Fragments

- **Incoming half-transition**: Not labeled by a symbol.
- **Outgoing half-transition**: Labeled by either ε or an alphabet symbol.
- **Combination**: Fragments are combined using the half-transitions to form larger fragments and eventually the complete NFA.

#### NFA Fragments for Basic Regular Expressions (Figure 2.4)

- **Single Character `a`**:
  ```
  a ✲✚✙✛✘a
  ```
- **Empty String `ε`**:
  ```
  ε ✲✚✙✛✘ε
  ```
- **Concatenation `st`**:
  ```
  s t ✲ s ✲ t
  ```
- **Union `s|t`**:
  ```
  ✲✚✙✛✘✲ ε
  ε ✲
  s
  t
  ✚✙❫✛✘
  ✣
  ε
  ```
- **Kleene Star `s*`**:
  ```
  s ✲✚✙✛✘ε
  ✲
  ε
  ✠
  s
  ```

#### Complete NFA Example

- Regular Expression: `(a|b)*ac`
- **NFA**: (Figure 2.5)
  ```
  ✲✖✕✗✔1
  ε ✲
  ✲
  ε
  ✖✕✗✔2
  a✲✖✕✗✔3
  c✲✖✕✗✔✒✑✓✏4
  ✖✕✗✔5
  ε ✲
  ε ✲
  ✖✕✗✔6
  ❘
  a
  ✖✕✗✔7
  ✒
  b
  ✖✕✗✔8
  ✰
  ε
  ```

#### Optimizations (Figure 2.6)

- **Shorthands for Regular Expressions**:

  - `ε`
  - `[0-9]`
    ```
    ✲✚✙✛✘❘
    0
    ✒
    9
    ...
    ✚✙✛✘ε
    ```
  - `s+`
    ```
    ✲✚✙✛✘
    ✲
    ε
    ✚✙✛ ε ✛✘ε
    ☛
    s
    ```

- **Optimized NFA Example**:
  - Regular Expression: `[0-9]+`
  - **NFA**: (Figure 2.7)
    ```
    ✲✚✙ε✛✘
    ✚✙✛ ε ✛✘ε
    ✲✚✙✛✘
    ✒✑✠✓✏
    ✲✚✙✛✘❘
    0
    ✒
    9
    ...
    ✚✙✛✘
    ε
    ```

### 2.5 Deterministic Finite Automata (DFA)

#### Introduction

- **Purpose**: DFAs are NFAs with additional restrictions to make them closer to actual machine operations.
- **Restrictions**:
  - No epsilon transitions.
  - No multiple transitions with the same symbol from a state.

#### Characteristics

- **Deterministic**: The state and the next input symbol uniquely determine the transition.
- **Implementation**: Easy to implement using a two-dimensional table for state transitions and a one-dimensional table for accepting states.

#### Example DFA

- Equivalent to the NFA in Figure 2.3:
  ```
  ✲✚✙✛✘1
  b✲
  ✻a
  ✚✙✛✘
  ✒✑✓✏3
  ✚✙✛✘2
  ✸
  a
  ❄
  b
  ```

### 2.6 Converting an NFA to a DFA

#### Approach

- Simulate all possible paths in an NFA at once by operating with sets of NFA states.
- **Sets of NFA States**: A set of NFA states becomes a single DFA state.

#### Handling Epsilon Transitions

- **Epsilon-closure**: Extend the set of NFA states with those reachable by epsilon transitions.
- **Definition (2.2)**:
  ```
  ε-closure(M) = M ∪ {t | s ∈ ε-closure(M) and sε t ∈ T}
  ```

#### Conversion Process

- For each possible input symbol, form new sets of NFA states by following transitions labeled by the symbol.
- The DFA transitions become deterministic by moving between sets of NFA states based on input symbols.
