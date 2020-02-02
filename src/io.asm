%define KEY_BACKSPACE 0x0E
%define KEY_ENTER 0x1C

; Stores the colors to be used when clearing the screen.
SCREEN_COLOR: db 0x07

; Sets the color to be used for any following clear
; operations. New color is to be given via BL.
set_color:
  mov byte [SCREEN_COLOR], bl
  ret

; Removes all content from the screen and sets every cells color to
; the color set through `set_color` (or light grey on black by default).
; Also moves the cursor to the top-left cell.
clear_screen:
  ; 0x06 is the scroll function (current screen gets scrolled out of view)
  mov ah, 0x06
  ; 0x00 tells it to completely scroll everything out of view
  mov al, 0x00
  ; Set background color to black and text color to light grey
  mov bh, [SCREEN_COLOR]
  ; Store the coordinates of the top-left cell and the bottom-right
  ; cells in CX and DX respectively.
  mov cx, 0x0000
  mov dx, 0x184F
  int 0x10

  ; Now just move the cursor back to the top-left cell.
  mov dx, 0x0000
  call move_cursor

  ret

; Moves the cursor to the specified coordinates
; in DX (DH=Row, DL=Column)
move_cursor:
  ; Move cursor function
  mov ah, 0x02
  ; Page 0
  mov bh, 0x00
  int 0x10
  ret

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

; Reads an entire line (terminated by the ENTER key) of input
; into the memory pointed to by DI. Does not attempt to read more
; than one byte less as specified by DL to terminate the input string
; with a NUL character.
readln:
  ; When pressing backspace you should not be able to
  ; delete infinite amounts of characters. So keep track of
  ; how many characters where to write into the buffer in the first place.
  mov dh, dl

.loop:
  ; Read key press
  mov ah, 0x00
  int 0x16

  cmp ah, KEY_BACKSPACE
  je .backspace

  cmp ah, KEY_ENTER
  je .end

  cmp dl, 1
  je .loop

  ; Write the character from AL into the memory pointed
  ; to by DI (stosb). But also print said character to the screen
  ; so the user knows what they're typing.
  stosb
  call printc

  sub dl, 1
  jmp .loop

.backspace:
  ; If the characters left to read is still the same
  ; as the max amount of characters allowed then backspace
  ; should not do anything.
  cmp dh, dl
  je .loop

  ; Otherwise go back one character, replace it with a space (empty)
  ; and then go back a character again (print a space will have moved us forwards).
  ; Afterwards also decrease the pointer in DI.
  ; Then we're ready to read new input again.
  mov al, `\b`
  call printc
  mov al, ' '
  call printc
  mov al, `\b`
  call printc
  add dl, 1
  sub di, 1
  jmp .loop

.end:
  mov al, 0
  stosb
  ret
