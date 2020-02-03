; ---
;
; This file contains helpful subroutines for working with strings.
;
; ---

; Compares two NUL-terminated strings given by SI and DI.
; Returns 0 (equal), 1 (SI lexicographically bigger) or
; -1 (SI lexicographically smaller) in AX.
strcmp:
  ; Compare the characters currently pointed to by SI and DI
  ; if they are not equal (i.e. less-than or greater-than eachother)
  ; we know we can stop the loop and just return the respective value.
  mov al, [si]
  cmp al, [di]
  jg .gt
  jl .lt

  ; Here we know that [SI] and [DI] are equal, so we only need to
  ; check if either of them is the terminating NUL.
  ; If it is we can end the loop as well.
  cmp byte [si], 0
  je .end

  ; Otherwise if the NUL-terminator has not been reached
  ; move onto the next characters.
  inc si
  inc di
  jmp strcmp
.gt:
  mov ax, 1
  ret
.lt:
  mov ax, -1
  ret
.end:
  mov ax, 0
  ret
