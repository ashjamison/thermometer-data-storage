#  Thermometer Data Storage (Assembly)


##  Project Overview
This x86 Assembly program reads temperature data from a user-provided file, **reverses the order of the readings**, and prints the corrected sequence to the console.  

It “fixes” a previously mismanaged thermometer file and showcases proficiency in low-level programming concepts, including:  

- Macros for input/output operations  
- Procedures with string manipulation (`LODSB` and `STOSB`)  
- File handling in Assembly  
- Numeric conversion and parsing  

---

## Features
- Reads comma-delimited ASCII temperature data from a file  
- Stores numeric values in an array  
- Prints temperatures in **reverse order** to correct the sequence  
- Handles file input errors gracefully  

---

## Files in this Repository
- `proj6_jamisoas.asm` — Main Assembly source file  
- `sample_input.txt` — Example input file  

---

## Usage
1. Compile the `.asm` file using MASM (requires **Irvine32.inc** library)  
2. Run the program in a **32-bit Windows environment**  
3. Enter the name of your CSV input file (e.g., `sample_input.txt`)  
4. See the corrected temperature order printed to the console  

### Example

**Input (`sample_input.txt`):**
72,68,70,75

**Console Output:**
Corrected Temperature Order: 75,70,68,72
