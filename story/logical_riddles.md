# Logical Riddles and Puzzles from *Theoretical Computer Science: Logic & Puzzles*
**Source:** Prof. Dr. Karl Stroetmann, *Theoretical Computer Science: Logic & Puzzles (TypeScript Edition)*

This document compiles all logical riddles, deduction puzzles, and classic combinatorial logic problems featured in the textbook, organized by chapter and section.

---

## Table of Contents

- [Chapter 4: Propositional Calculus](#chapter-4-propositional-calculus)
  - [1. The Jewelry Store Burglary (The Three Suspects)](#1-the-jewelry-store-burglary-the-three-suspects)
  - [2. The Family Murder Mystery](#2-the-family-murder-mystery)
  - [3. The 8-Queens Problem](#3-the-8-queens-problem)
  - [4. The Four Gentlemen and Their Wives (Logelei von Zweistein)](#4-the-four-gentlemen-and-their-wives-logelei-von-zweistein)
  - [5. The Zebra Puzzle (Einstein's Riddle)](#5-the-zebra-puzzle-einsteins-riddle)
  - [6. The Trial of the Nine Portals](#6-the-trial-of-the-nine-portals)
  - [7. Arto Inkala's "Hardest" Sudoku](#7-arto-inkalas-hardest-sudoku)
- [Chapter 5: First-Order Logic & Constraint Programming](#chapter-5-first-order-logic--constraint-programming)
  - [8. Map Colouring Problem (Australia)](#8-map-colouring-problem-australia)
  - [9. Cryptarithmetic: SEND + MORE = MONEY](#9-cryptarithmetic-send--more--money)
  - [10. The Missionaries and Cannibals River Crossing](#10-the-missionaries-and-cannibals-river-crossing)
  - [11. The Wolf, Goat, and Cabbage River Crossing](#11-the-wolf-goat-and-cabbage-river-crossing)
  - [12. Sibling Count Text Problem](#12-sibling-count-text-problem)
  - [13. Japanese Deli: The Parrot and the Penguin](#13-japanese-deli-the-parrot-and-the-penguin)
  - [14. Train Speed Problem](#14-train-speed-problem)
  - [15. Alice and Bob's Ages Riddle](#15-alice-and-bobs-ages-riddle)
  - [16. The Knight's Tour](#16-the-knights-tour)
  - [17. "Zeit Online" Super Hard Sudoku](#17-zeit-online-super-hard-sudoku)
  - [18. Japanese River Crossing IQ Test](#18-japanese-river-crossing-iq-test)
  - [19. The Bridge and Torch Problem](#19-the-bridge-and-torch-problem)
- [Chapter 6: Automatic Theorem Proving](#chapter-6-automatic-theorem-proving)
  - [20. The Barber Paradox Deductive Riddle](#20-the-barber-paradox-deductive-riddle)
  - [21. Who Killed Aunt Agatha? (The Dreadbury Mansion Mystery)](#21-who-killed-aunt-agatha-the-dreadbury-mansion-mystery)

---

# Chapter 4: Propositional Calculus

### 1. The Jewelry Store Burglary (The Three Suspects)
* **Section:** 4.3.4 (pp. 45–47)
* **Story:**
  Inspector Watson is called to investigate a burglary at a jewelry store. Three suspects have been detained in the vicinity of the jewelry store: **Aaron**, **Bernard**, and **Caine**. Evaluation of the case files reveals the following facts:
* **Clues:**
  1. At least one of these suspects must have been involved in the crime:
     $$f_1 := a \lor b \lor c$$
  2. If Aaron is guilty, then he has exactly one accomplice:
     $$f_2 := a \rightarrow b \lor c$$
     $$f_3 := a \rightarrow \neg(b \land c)$$
  3. If Bernard is innocent, then Caine is innocent too:
     $$f_4 := \neg b \rightarrow \neg c$$
  4. If exactly two of the suspects are guilty, then Caine is one of them:
     $$f_5 := \neg(\neg c \land a \land b)$$
  5. If Caine is innocent, then Aaron is guilty:
     $$f_6 := \neg c \rightarrow a$$
* **Question:** Which suspects are guilty, and who is innocent?
* **Solution in Text:** There is only one satisfying assignment: Bernard and Caine are guilty, Aaron is innocent ($I = \{b, c\}$).

---

### 2. The Family Murder Mystery
* **Section:** Exercise 10 (p. 47)
* **Attribution:** George J. Summers, *Logical Deduction Puzzles*, 2006.
* **Story:**
  We all know Alice and Bob from Cryptography. However, little did we know about their difficult family relations, which might be the reason for their secrecy.
  
  Unfortunately, things have escalated recently: Murder occurred one evening in the home of their father and mother. Alice and Bob are the only children of their parents. One member of the family murdered another member, the third member witnessed the crime, and the fourth member was an accessory after the fact.
* **Clues:**
  1. The accessory and the witness were of opposite sex.
  2. The oldest member and the witness were of opposite sex.
  3. The youngest member and the victim were of opposite sex.
  4. The accessory was older than the victim.
  5. The father was the oldest member.
  6. The murderer was not the youngest member.
* **Question:** Which of the four — the father, the mother, Alice, or Bob — was the murderer?

---

### 3. The 8-Queens Problem
* **Section:** 4.8.1 (pp. 87–94) & 5.4.3 (pp. 129–132)
* **Description:** Place 8 chess queens on a standard $8 \times 8$ chessboard such that no queen can attack another queen.
* **Rules:**
  * In chess, a queen attacks any piece in the same row, column, or diagonal.
  * Exactly 8 queens must be placed without conflicts.

---

### 4. The Four Gentlemen and Their Wives (Logelei von Zweistein)
* **Section:** Exercise 12 (p. 95)
* **Attribution:** Thomas von Randow, *99 Logeleien von Zweistein*, Christian Wegner Verlag, 1968.
* **Story:**
  The gentlemen **Amann**, **Bemann**, **Cemann**, and **Demann** are called — not necessarily in the same order — by their first names **Erich**, **Fritz**, **Gustav**, and **Heiner**. They are all married to exactly one woman (**Inge**, **Josefa**, **Klara**, and **Luise**).
* **Clues:**
  1. Either Amann’s first name is Heiner, or Bemann’s wife is Inge.
  2. If Cemann is married to Josefa, then — and only in this case — Klara’s husband is not called Fritz.
  3. If Josefa’s husband is not called Erich, then Inge is married to Fritz.
  4. If Luise’s husband is called Fritz, then Klara’s husband’s first name is not Gustav.
  5. If the wife of Fritz is called Inge, then Erich is not married to Josefa.
  6. If Fritz is not married to Luise, then Gustav’s wife’s name is Klara.
  7. Either Demann is married to Luise, or Cemann is called Gustav.
* **Question:** What are the full names of these gentlemen, and what are their wives’ first names?

---

### 5. The Zebra Puzzle (Einstein's Riddle)
* **Section:** 4.8.2 (pp. 95–101) & 5.4.3 (p. 137)
* **Attribution:** *Life International*, December 17th, 1962.
* **Setup:**
  There are five houses in a row, each painted a different colour (**Red, Green, Ivory, Yellow, Blue**). Their inhabitants are of five different nationalities (**Englishman, Spaniard, Ukrainian, Norwegian, Japanese**), own five different pets (**Dog, Snails, Horse, Fox, Zebra**), drink five different beverages (**Coffee, Tea, Milk, Orange Juice, Water**), and smoke five different brands of cigarettes (**Old Gold, Kools, Chesterfields, Lucky Strike, Parliaments**).
* **Clues:**
  1. The Englishman lives in the red house.
  2. The Spaniard owns the dog.
  3. Coffee is drunk in the green house.
  4. The Ukrainian drinks tea.
  5. The green house is immediately to the right of the ivory house.
  6. The Old Gold smoker owns snails.
  7. Kools are smoked in the yellow house.
  8. Milk is drunk in the middle house.
  9. The Norwegian lives in the first house.
  10. The man who smokes Chesterfields lives in the house next to the man with the fox.
  11. Kools are smoked in the house next to the house where the horse is kept.
  12. The Lucky Strike smoker drinks orange juice.
  13. The Japanese smokes Parliaments.
  14. The Norwegian lives next to the blue house.
* **Questions:**
  1. Who drinks water? *(Answer: The Norwegian)*
  2. Who owns the zebra? *(Answer: The Japanese)*

---

### 6. The Trial of the Nine Portals
* **Section:** Exercise 13 (pp. 101–102)
* **Attribution:** Inspired by Raymond M. Smullyan, *The Lady or the Tiger? And Other Logic Puzzles*, 1982.
* **Story:**
  A King tests suitors for his daughter's hand. The Prince is brought to a corridor with nine identical doors, behind each of which lies one of three fates:
  * **The Princess:** The ultimate prize.
  * **A Ravenous Tiger:** Immediate death.
  * **Void & Dust:** An empty room.
* **The Royal Logic Protocol:**
  1. **Path of Teeth:** If a room contains a Tiger, the inscription on that door is a bold-faced lie (false).
  2. **Path of Matrimony:** If the room contains the Princess, the inscription is absolute truth (true).
  3. **Path of the Void:** If the room is empty, either *all* signs on empty rooms are true, or *all* of them are false.
* **Inscriptions:**
  * **Room 1:** The princess is in a room with an odd number and there is no tiger in the rooms with an even number.
  * **Room 2:** This room is empty.
  * **Room 3:** The inscription on Room No. 5 is true, the inscription on Room No. 7 is false, and there is a tiger in Room No. 3.
  * **Room 4:** The inscription on Room No. 1 is false, there is no tiger in Room No. 8, and the inscription on Room No. 9 is true.
  * **Room 5:** If the inscription on Room No. 2 or on Room No. 4 is true, then there is no tiger in Room No. 1.
  * **Room 6:** The inscription on Room No. 3 is false, the princess is in Room No. 2, and there is no tiger in Room No. 2.
  * **Room 7:** The princess is in Room No. 1 and the inscription on Room No. 5 is true.
  * **Room 8:** There is no tiger in this room and Room No. 9 is empty.
  * **Room 9:** Neither in this room nor in Room No. 1 is there a tiger, and moreover, the inscription on Room No. 6 is true.
* **Question:** Behind which door is the Princess?

---

### 7. Arto Inkala's "Hardest" Sudoku
* **Section:** 4.9 & 4.10 (pp. 102–111)
* **Description:** Created by Finnish mathematician Arto Inkala, who claimed this to be the hardest solvable instance of a Sudoku puzzle.
* **Grid:**
  ```text
  8 . . | . . . | . . .
  . . 3 | 6 . . | . . .
  . 7 . | . 9 . | 2 . .
  ------+-------+------
  . 5 . | . . 7 | . . .
  . . . | . 4 5 | 7 . .
  . . . | 1 . . | . 3 .
  ------+-------+------
  . . 1 | . . . | . 6 8
  . . 8 | 5 . . | . 1 .
  . 9 . | . . . | 4 . .
  ```
* **Goal:** Complete the $9 \times 9$ grid so that every row, column, and $3 \times 3$ block contains digits 1–9.

---

# Chapter 5: First-Order Logic & Constraint Programming

### 8. Map Colouring Problem (Australia)
* **Section:** 5.4.2 (pp. 127–129)
* **Description:** Given the seven states and territories of Australia:
  * Western Australia (WA)
  * Northern Territory (NT)
  * South Australia (SA)
  * Queensland (Q)
  * New South Wales (NSW)
  * Victoria (V)
  * Tasmania (T)
* **Goal:** Color each region using only three colors (**red**, **green**, **blue**) such that no two regions sharing a border have the same color.

---

### 9. Cryptarithmetic: SEND + MORE = MONEY
* **Section:** Exercise 18 (pp. 137–138)
* **Description:**
  Assign each letter $S, E, N, D, M, O, R, Y$ a distinct decimal digit from $\{0, 1, \dots, 9\}$ such that leading letters $S$ and $M$ are non-zero, and the addition holds:
  $$\begin{array}{r@{\quad}l}
    \text{S E N D} \\
  + \text{M O R E} \\
  \hline
  \text{M O N E Y}
  \end{array}$$

---

### 10. The Missionaries and Cannibals River Crossing
* **Section:** 5.5 (pp. 138–141) & 5.6.3 (pp. 151–155)
* **Story:**
  Three missionaries and three cannibals (referred to as "infidels" in the text) must cross a river to reach a church.
* **Constraints:**
  1. A small boat is available that holds at most 2 people.
  2. The boat cannot cross by itself (needs at least 1 person).
  3. If at any moment on either shore cannibals outnumber missionaries, the missionaries will be eaten.
* **Goal:** Find a sequence of river crossings that brings everyone across safely.

---

### 11. The Wolf, Goat, and Cabbage River Crossing
* **Section:** Exercise 19 (pp. 140–142)
* **Story:**
  An agricultural economist needs to transport a wolf, a goat, and a cabbage across a river.
* **Constraints:**
  1. The boat accommodates only the farmer and one other passenger/item (wolf, goat, or cabbage).
  2. If left alone together, the wolf eats the goat.
  3. If left alone together, the goat eats the cabbage.
* **Goal:** Cross the river safely without anything being eaten.

---

### 12. Sibling Count Text Problem
* **Section:** 5.6.1 (pp. 142–144)
* **Riddle:**
  * *"I have as many brothers as I have sisters."*
  * *"My sister has twice as many brothers as she has sisters."*
  * *Assumptions:* No illegitimate children; all children identify as male or female.
* **Question:** How many children does the father have?
* **Solution in Text:** 7 children (4 boys, 3 girls; the narrator is a boy: $b - 1 = g$ and $2(g - 1) = b \implies b=4, g=3$).

---

### 13. Japanese Deli: The Parrot and the Penguin
* **Section:** Exercise 20 (p. 145)
* **Riddle:**
  1. A Japanese deli offers both penguins and parrots.
  2. A parrot and a penguin together cost 666 bucks.
  3. The penguin costs 600 bucks more than the parrot.
* **Question:** What is the price of the parrot? (Assume integer prices.)
* **Solution:** $x + (x + 600) = 666 \implies 2x = 66 \implies x = 33$ bucks.

---

### 14. Train Speed Problem
* **Section:** Exercise 21 (p. 145)
* **Problem:**
  1. A train travels at uniform speed for 360 miles.
  2. The train would have taken 48 minutes less to travel the same distance if it had been 5 miles per hour faster.
* **Question:** Find the speed of the train.

---

### 15. Alice and Bob's Ages Riddle
* **Section:** Exercise 22 (p. 145)
* **Riddle:**
  > *"Alice is twice as old as Bob was when Alice was as old as Bob is now. When Bob is as old as Alice is now, the sum of their ages will be 90."*
* **Question:** How old are Alice and Bob now?

---

### 16. The Knight's Tour
* **Section:** 5.6.2 (pp. 145–150)
* **Description:**
  A knight starts at the top-left square $(0, 0)$ of an $8 \times 8$ chessboard.
* **Goal:** Visit all 64 squares of the board in 63 moves without visiting any square more than once, using only valid chess knight moves ($\pm 2$ horizontal and $\pm 1$ vertical, or $\pm 1$ horizontal and $\pm 2$ vertical).

---

### 17. "Zeit Online" Super Hard Sudoku
* **Section:** Exercise 23 (p. 151)
* **Grid:**
  ```text
  . 3 9 | . . . | . 7 .
  . . . | 7 . . | 4 9 2
  . . . | . 6 5 | . 8 3
  ------+-------+------
  . . . | 6 . 3 | 2 . 7
  . . . | . 4 . | . 8 .
  5 . 6 | . . . | . . .
  ------+-------+------
  . . 5 | 2 . 9 | . . 1
  . 2 1 | . . . | 4 . .
  7 . . | . . 5 | . . .
  ```
* **Goal:** Solve using Z3 constraint satisfaction with `Z3.Distinct`.

---

### 18. Japanese River Crossing IQ Test
* **Section:** Exercise 24 (p. 155)
* **Characters:**
  * Policeman
  * Convict
  * Father and two sons: Anton and Bruno
  * Mother and two daughters: Cindy and Doris
* **Constraints:**
  1. The boat carries at most 2 passengers.
  2. Only the father, mother, and policeman are able to steer the boat.
  3. The father is not allowed to be on a shore with one of the daughters if the mother is on the other shore.
  4. The mother is not allowed to be on a shore with one of the sons if the father is on the other shore.
  5. If the convict is not alone, the policeman must watch him.
  6. The convict can be alone on a shore (his shackles prevent escape).
* **Goal:** Transport everyone from one shore to the other.

---

### 19. The Bridge and Torch Problem
* **Section:** Exercise 25 (pp. 155–156)
* **Story:**
  Four individuals (**Ariela**, **Brian**, **Charly**, **Dumpy**) must cross a slender bridge in darkness using a single torch.
* **Constraints:**
  1. The bridge accommodates at most 2 people simultaneously.
  2. Any crossing requires the torch (it must be carried back and forth).
  3. When two people cross together, they walk at the pace of the slower individual.
  4. Crossing times:
     * Ariela: 1 minute
     * Brian: 2 minutes
     * Charly: 5 minutes
     * Dumpy: 8 minutes
  5. The torch only lasts for 15 minutes.
* **Question:** Can all four people cross within 15 minutes?

---

# Chapter 6: Automatic Theorem Proving

### 20. The Barber Paradox Deductive Riddle
* **Section:** Exercise 28 (p. 175)
* **Axioms:**
  1. Every barber shaves all persons who do not shave themselves:
     $$\forall b, x : (\text{barber}(b) \land \neg\text{shaves}(x, x) \rightarrow \text{shaves}(b, x))$$
  2. No barber shaves anyone who shaves themselves:
     $$\forall b, x : (\text{barber}(b) \land \text{shaves}(x, x) \rightarrow \neg\text{shaves}(b, x))$$
* **Task:** Using resolution calculus, deduce the contradiction resulting from a barber attempting to shave himself (framed humorously in the text).

---

### 21. Who Killed Aunt Agatha? (The Dreadbury Mansion Mystery)
* **Section:** 6.5.2 (pp. 177–179)
* **Story:**
  > Someone who lives in Dreadbury Mansion killed Aunt Agatha. Agatha, the butler, and Charles live in Dreadbury Mansion, and are the only people who live therein.
* **Clues:**
  1. A killer always hates his victim, and is never richer than his victim.
  2. Charles hates no one that Aunt Agatha hates.
  3. Agatha hates everyone except the butler.
  4. The butler hates everyone not richer than Aunt Agatha.
  5. The butler hates everyone Aunt Agatha hates.
  6. No one hates everyone.
  7. Agatha is not the butler.
* **Question:** Who killed Aunt Agatha?
* **Solution in Text:**
  * If Charles killed Agatha, Charles hates Agatha. But Charles hates no one Agatha hates, which implies Agatha did not hate herself. Yet Agatha hates everyone except the butler, so she must hate herself—contradiction.
  * If the butler killed Agatha, the butler is not richer than Agatha. Thus, the butler hates himself. The butler also hates everyone Agatha hates (everyone except himself), meaning the butler hates everyone—contradicting "no one hates everyone".
  * **Conclusion:** **Agatha killed herself.**
