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
  ; 0x0E is the function to print a character
  ; from AL
  mov ah, 0x0E
  ; Page 0
  mov bh, 0x00
  int 0x10
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
