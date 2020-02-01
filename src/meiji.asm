[bits 16]
[org 0x7C00]

start:
  call clear_screen

  mov si, WELCOME_MSG
  call println

  ; Disable interrupts and then
  ; halt until an interrupt, effectively
  ; halting the system forever.
  cli
  hlt

; -- Strings --
WELCOME_MSG: db "Welcome to the Meiji operating system.", 0

; -- Includes --
%include "io.asm"

; -- Magic Number Signature --
; The BIOS expects to find the magic number
; 0xAA55 at the end of the first 512-byte sector
; identify the boot sector. We fill the rest of the bytes
; with 0s.
times 510-($-$$) db 0x00
dw 0xAA55
