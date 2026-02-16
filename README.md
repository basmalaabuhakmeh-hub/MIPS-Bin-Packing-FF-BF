# Bin Packing Solver — MIPS Assembly

MIPS assembly implementation of the bin packing problem using First Fit (FF) and Best Fit (BF) heuristics. Reads item sizes from a file, runs the chosen heuristic, and writes the solution to an output file.

## Overview

Given a list of item sizes (floats in the range 0 to 1), the program packs them into the **minimum number of bins** of unit capacity (1.0) using:

1. **First Fit (FF)** — For each item, place it in the first bin that has enough remaining space.
2. **Best Fit (BF)** — For each item, place it in the bin that will have the **smallest remaining space** after placement (fullest bin that still fits the item).

The program provides a **menu-driven interface**: prompt for input file path, run FF or BF, write results to `output.txt`, and loop until the user quits with `q` or `Q`. Input validation is performed for file existence, read errors, and invalid item sizes (non-numeric or out-of-range values).

---

## Project structure

```
.
├── README.md
├── ENCS4370_Project+1_+Spring_2024_2025.pdf   # Project specification and grading
├── main.asm                                   # MIPS assembly source (menu, FF, BF, I/O)
├── input.txt                                  # Sample input (item sizes, space/newline separated)
└── output.txt                                 # Sample output (bins and items per bin)
```

---

## Requirements

- **MIPS simulator** — e.g. **MARS** (MIPS Assembler and Runtime Simulator) or **SPIM**. The code uses standard MIPS syscalls (file open/read/write/close, print string/int/float, read string/char).
- **Input file format:** Text file containing item sizes as decimal numbers between 0 and 1, separated by spaces or newlines. Invalid tokens or values outside [0, 1] trigger error messages.
- **Output:** Written to `output.txt` in the same directory as the program (path may depend on the simulator’s working directory).

---

## Usage

1. Open **main.asm** in MARS (or your MIPS environment).
2. Assemble and run the program.
3. In the menu:
   - **1** — Enter the input file name or full path (e.g. `input.txt` or `C:\...\input.txt`). The program reads and parses item sizes, validates them, and prints the number of items.
   - **2** — Run **First Fit**; results are displayed on the console and stored for writing to file.
   - **3** — Run **Best Fit**; same as above.
   - **4** — Write the last run’s results (FF or BF) to **output.txt**. If neither 2 nor 3 was run yet, an error message is shown.
   - **q** or **Q** — Exit the program.

**Notes:** Option 1 must be used before 2 or 3 (load items first). Option 4 requires that either FF or BF has been run. The menu repeats until the user quits.

---

## Input / output example

**input.txt** (example):

```
0.4 0.5 0.5 0.6 0.1 0.2 0.3 0.4
```

**output.txt** (First Fit solution for the above):

```
------ First Fit Solution ------

Number of bins: 4
  Bin 0:
    - 0.4
    - 0.5
    - 0.1
  Bin 1:
    - 0.5
    - 0.2
  Bin 2:
    - 0.6
    - 0.3
  Bin 3:
    - 0.4
```

---

## Algorithm summary

| Heuristic   | Rule |
|------------|------|
| **First Fit** | For each item, assign it to the first bin (lowest index) with remaining capacity ≥ item size; if none, open a new bin. |
| **Best Fit**  | For each item, among bins that can fit it, choose the one that minimizes remaining capacity after placement; if none, open a new bin. |

Bins have capacity 1.0. Item sizes must be in [0, 1]. The program supports up to 100 items and 100 bins (limits defined in **main.asm**).

---

## Report / specification

Full project description, requirements, and grading criteria:  
**`ENCS4370_Project+1_+Spring_2024_2025.pdf`**
