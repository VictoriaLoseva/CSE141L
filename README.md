# CSE141L

Items 1-7 are completely parallelizable, so are 10 and 11-13, we can call out who's doing what in discord 

TODO: 

1. ALU unit test 

   a. See the synthesizable ALU.sv for an example
   
   b. ADD, AND, SETB, FLIP, SHL, BXOR - go in the first case(op) I believe

   c. XOR, GETBIT, RSET - in the second case(op) 

   d. modify testbench and definitions accordingly

2. Register file (not sure yet)

3. VLUT (values); ZERO, ONE, THIRTY, SIXTY

4. ALUT (addreses): TBD, probably changes with assembly & gotta load them in every time

5. Instruction memory / PC (not sure yet) 

6. Data Memory (lw / sw) (not sure yet)

7. Branches (not sure yet) 

8. Wiring: 

     a. Draw a picture of all the connections 
     
     b. implement in top_level.sv

9. Once unit tests on processor elements are good, go to debugging assembler (for example, simple branches and trying to calculate P4) 
10. Finish writing the assembly for programs 1-3 
    a. Fill in the blanks for P1
    b. Fill in the blanks for P2 
    c. Figure out branching logic in P2 
    d. Write P3
11. Debug P1 
12. Debug P2 
13. Debug P3 
14. Submit and celebrate! 
