; ---
;
; This file contains various subroutines for printing text to the
; screen.
;
; The print subroutines are in this separate file so they can be loaded
; by the first stage of the bootloader without having to load everything else with it.
;
; ---

; Print a single character given by AL
; at the current position of the cursor
printc:
  pusha
  ; 0x0E is the function to print a character
  ; from AL
  mov ah, 0x0E
  ; Page 0
  mov bh, 0x00
  int 0x10
  popa
  ret

; Prints a NUL-terminated string given by the
; SI register to the screen.
print:
  lodsb
  ; Check if given byte is the terminating
  ; NUL character
  cmp al, 0x00
  jz .end
  call printc
  jmp print

.end:
  ret

; Like print but will add a linebreak after
; the given string.
println:
  call print

  ; Move to the next line
  mov al, `\n`
  call printc

  ; Move the cursor to the start of the line
  mov al, `\r`
  call printc

  ret

; Print an unsigned number from the BX register
; in base-16.
printhex:
  mov cx, 4 ; A 16-bit number has 4 hexadecimal digits
  ror bx, 12
.loop:
  cmp cx, 0
  je .end

  ; Isolate lowest 4 bits
  mov ax, bx
  and ax, 0x000F

  add ax, `0` ; Lift the numerical digits into the ASCII range for digits

  ; If the ASCII character is beyond '9' the value is >10 and has to be brought into the
  ; ASCII range for the character 'A'-'F'
  cmp ax, `9`
  jle .skip
  add ax, 7
.skip:
  call printc
  ror bx, 4
  dec cx
  jmp .loop
.end:
  ret
