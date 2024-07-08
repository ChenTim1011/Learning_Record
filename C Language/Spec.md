https://hackmd.io/@sysprog/c-standards?type=view

**David Brailsford's Interview:**

- **Early Mainframe Era:**

  - Machines did not use byte addressing.
  - High-level programming languages and computer hardware could not directly correspond.

- **C Language:**

  - C language filled the need for system-level programming.
  - Its development was pivotal in the evolution of computer systems.

- **UNIX Operating System:**
  - The influence of UNIX further transformed the information world we live in today.

**Importance of Software Licensing:**

- **Legal Document:**

  - Manages the use and redistribution of software.
  - Essential for both developers and users to understand.

- **GitHub Example:**

  - Open source projects without a public license default to "All rights reserved."
  - Unauthorized modifications or redistributions can lead to copyright issues.

- **Open Source Initiative (OSI):**
  - Emphasizes that open-source projects must have corresponding licenses.
  - Prevents public confusion and legal ambiguities regarding software use.

**Why Understand Software Licensing?**

1. **Legal Issues:**

   - Necessary for commercializing open-source projects.
   - Avoiding copyright law violations.

2. **Financial Impact:**

   - Legal battles can be time-consuming and costly.
   - Important for individual developers and startups.

3. **Protecting Rights:**
   - Ensures your work is not misused.
   - Provides clarity on usage and modification rights.

**Differences Between Copyleft, Copycenter, and Copyright:**

- **Copyleft:**

  - Promotes free usage and modification.
  - Derivative works must use the same license (e.g., GNU GPL, LGPL).

- **Copycenter:**

  - Middle ground between copyleft and copyright.
  - Allows more flexible licensing for derivative works (e.g., BSD, MIT, Apache).

- **Copyright:**
  - Traditional intellectual property rights.
  - Restricts free use and modification.

**Examples of Licenses:**

- **GNU GPL:**

  - Strong copyleft license.
  - Derivative works must also use the GPL.

- **LGPL:**

  - Lesser General Public License.
  - More permissive than GPL regarding linking.

- **BSD License:**

  - Requires acknowledgment of original authors.
  - Allows proprietary use.

- **MIT License:**

  - Highly permissive.
  - Allows almost unrestricted use and modification.

- **Apache License:**
  - Requires documenting modifications.
  - Similar flexibility to MIT.

**The First C Language Compiler:**

- **Bootstrapping Process:**
  - Initial compiler written in assembly language for a subset of C (C0).
  - Successive compilers developed using progressively more complex subsets (C1, C2, ... CN).
  - Eventually leads to a full C language compiler.

Life Philosophy:

Everything should be categorized into work, learning, or life.
Dr. Bing-Zhe Yeh's Tweet:

Tracing ability is crucial to avoid being misled by seemingly innovative but actually repackaged or borrowed cross-disciplinary "new ideas."
Specification Document Search Results:

"Object" appears 735 times.
"Pointer" appears 637 times.
Observation: Many educational materials often focus on pointers rather than objects, despite their interconnectedness.
Objects vs. Object-Oriented:

Objects: Focus on data representation.
Object-Oriented: Concept that "everything is an object."
C11 Standard (ISO/IEC 9899:201x):

Importance of learning from primary sources.
Software developers should refer to language specifications to understand definitions and standards.
Address Operator (&):

Do not always read as "and."
In pointer operations, read as "address of."
C99 Standard References:

[6.5.3.2] Address and Indirection Operators: Discusses the '&' address-of operator.
[3.14] Object: Defines an object as a region of data storage in the execution environment, capable of representing values.
Lvalue vs. Rvalue:

Lvalue (Locator Value): Refers to an object that occupies some identifiable location in memory.
Rvalue (Read Value): Refers to data value that is stored at some address in memory.
