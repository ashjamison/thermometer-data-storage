TITLE Thermometer Data Storage    

; Description: This program corrects the termometer data storage, previously messed up by an intern. The program reads the temperature measurements.
; from a file (input by the user), and prints them out with their order corrected (reverse order of how they're stored in the array).
; This program implements and tests three macros for I/O, and implements and tests two procedures which use string primitive instructions.
; Conversion routines use the LODSB and STOSB operators for dealing with strings.

INCLUDE Irvine32.inc

; ------------------------------------------------------------------------
; Name: mGetString
; Description: Displays a prompt (prompt), then gets the user’s 
; keyboard input into a memory location (offset userInput). Also 
; provides a count (MAX_FILE_SIZE) for the length of input string you 
; can accommodate and provide a number of bytes read (bytesNum) by the
; macro.
; receives: prompt = array address, userInput = array address, 
;			byteNum = value of bytes read
; returns: prompt = generated sring address, userInput = address of 
;			 user-input txt file, bytesNum = generated count
; preconditions: txt file needs to be in same directory as project
;					MAX_FILE_SIZE defined 
; ------------------------------------------------------------------------

mGetString	    macro	prompt, userInput, bytesNum
  push	edx
  push	ecx
  push	eax

  mov	edx, offset prompt
  call	writestring
  mov	edx, offset userInput
  mov	ecx, MAX_FILE_SIZE 
  call	readstring
  mov	bytesNum, eax

  pop	eax
  pop	ecx
  pop	edx

endm

; ------------------------------------------------------------------------
; Name: mDisplayString
; Description: Print the string which is stored in a specified 
; memory location (offset strOffset).
; receives: strOffset = array address
; returns: strOffset - generated string address
; preconditions: none
; ------------------------------------------------------------------------

mDisplayString	macro	strOffset
  push	edx

  mov	edx, offset strOffset
  call	writestring 

  pop	edx
endm

; ------------------------------------------------------------------------
; Name: mDisplayChar
; Description: Print an ASCII-formatted character which is provided as
; an immediate or constant (char - provided as constant).
; receives: char = ASCII-formatted character
; returns: char = generated ASCII-formatted character constant
; preconditions: none
; ------------------------------------------------------------------------

mDisplayChar	macro	char
  push	eax

  mov	al, char
  call	writechar

  pop	eax

endm



TEMPS_PER_DAY = 24
DELIMITER EQU <",">
MAX_FILE_SIZE = 1000

.data


intro1		  byte		"Welcome to Thermometer Data Storage! An intern messed up this program, so I am going to attempt to fix it.",13,10,0
intro2		  byte		"I'll read a comma-delimited file (ASCII-formatted) containing a series of temperature values.",13,10,0
intro3		  byte		"Then I'll reverse the order of the temperature values and print the corrected order of the temperatures!",13,10,0 
promptUser	  byte		"Enter the name of the file to be read: ",0
correctTemp	  byte		"Corrected Temperature Order: ",13,10,0
fileName	  byte		MAX_FILE_SIZE DUP(?) ;TempsFile.txt
fileBuffer	  byte		MAX_FILE_SIZE DUP(?)
tempArray	  sdword	MAX_FILE_SIZE DUP(?)
bytesRead	  dword		?	
fileHandle	  dword		?
fileNameError byte		"File Name Error",0
fileReadError byte		"File Read Error",0

.code
main PROC


;introduce program and programmer 
  mDisplayString offset intro1
  mDisplayString offset intro2
  mDisplayString offset intro3

;prompt and get user input 
  mGetString promptUser, fileName, bytesRead

  call	crlf
  mov	edx, offset fileName
  call	openinputfile 
  mov	fileHandle, eax

; verify correct file
  cmp	eax, INVALID_HANDLE_VALUE
  jne	_validName

  mDisplayString offset fileNameError

  call	crlf
  jmp	_error

_validName:
  mov	eax, fileHandle
  mov	edx, offset fileBuffer
  mov	ecx, MAX_FILE_SIZE 
  call	readfromfile
  mov	bytesRead, eax

  jnc	_validRead

  mDisplayString offset fileReadError

  call	crlf
  jmp	_error

_validRead:
  mov	eax, fileHandle
  call	closefile

;---------------------------------------------------------------------------------

  push	offset tempArray
  push	offset fileBuffer
  call	ParseTempsFromString

  push	offset correctTemp
  push	offset tempArray
  call	WriteTempsReverse

_error:

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ------------------------------------------------------------------------
; name: ParseTempsFromString
; desription: parses the first line of temperature readings, convertss them
; from ASCII to numeric value, and stores the numeric values in an array. 
; receives: [ebp +12] = offset tempArray & [ebp +8] = offset fileBuffer
; returns: converted integers are stored in tempArray
; preconditions: user input txt file is within the same directory as project
; postcoditions:  changes esi, edi, eax, ecx, edx, ebx
; ------------------------------------------------------------------------
ParseTempsFromString PROC 
  push	ebp
  mov	ebp, esp
  push	esi
  push	edi
  push	eax
  push	ecx
  push	edx
  push	ebx

  ; [ebp +12] = offset tempArray
  ; [ebp +8] = offset fileBuffer
  ; [ebp + 4] = return address
  ; [ebp] = old ebp 

  cld
  mov	esi, [ebp +8]
  mov	edi, [ebp +12]

  mov	ecx, TEMPS_PER_DAY

_parseLoop:
  mov	eax, 0    
  mov	ebx, 0 
  mov	edx, 0 

  lodsb
  cmp	al, 45
  jne	_checkInt
  mov	dl, 1  
  lodsb                     

_checkInt:
  sub	al, 48
  movzx	ebx, al              

_convertInt:
  lodsb
  cmp	al, DELIMITER
  je	_signCheck
  cmp	al, 0
  je	_signCheck
  cmp	al, 48
  jb	_signCheck
  cmp	al, 57
  ja	_signCheck

  sub	al, 48
  push	eax
  mov	eax, ebx
  imul	eax, 10
  mov	ebx, eax
  pop	eax
  movzx	eax, al
  add	ebx, eax
  jmp	_convertInt

_signCheck:
  cmp	dl, 0
  je	_storeTemp
  neg	ebx

_storeTemp:
  mov	eax, ebx
  stosd
  loop	_parseLoop
  jmp	_parseEnd

_parseEnd:
  pop	ebx
  pop	edx
  pop	ecx
  pop	eax
  pop	edi
  pop	esi
  pop	ebp
  ret	8
ParseTempsFromString ENDP



; ------------------------------------------------------------------------
; Name: WriteTempsReverse
; Description: prints the temperature values in the reverse order that 
; they were stored in the file (print to the terminal window).
; receives: [ebp + 12] = offset correctTemp & [ebp + 8] = offset tempsArray
; returns: correctTemp as a title string and a string of integers coverted
; from ParseTempsFromString
; preconditions: correctTemp is BYTE, tempsArray is DWORD
; postcoditions: changes eax, ebx, ecx, esi
; ------------------------------------------------------------------------
WriteTempsReverse PROC
  push	ebp
  mov	ebp, esp
  push	eax
  push	ebx
  push	ecx
  push	esi

  ; [ebp + 12] = offset correctTemp
  ; [ebp + 8] = offset tempsArray
  ; [ebp + 4] = return address
  ; [ebp] = old ebp 

 ; mDisplayString offset correctTemp

  mov	ecx, TEMPS_PER_DAY
  mov	esi, [ebp + 8]

  mov	eax, TEMPS_PER_DAY
  dec	eax
  mov	ebx, 4
  mul	ebx
  add	esi, eax

_printTempsReverse:
  mov	eax, [esi]
  call	writeint

  dec	ecx
  jz	_printDone

  mDisplayChar DELIMITER

  sub	esi, 4
  jmp	_printTempsReverse

_printDone:
  call	crlf
  
  pop	esi 
  pop	ecx
  pop	ebx
  pop	eax
  pop	ebp
  ret	8

WriteTempsReverse ENDP

END main
