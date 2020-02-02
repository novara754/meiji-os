; ---
;
; This is the entry file of the operating system, which contains the
; first and second stage of the bootloader and will be execute on system start.
;
; ---

[bits 16]
[org 0x7C00]

%define INPUT_BUFFER_LEN 128

reset_floppy:
  ; Reset the floppy drive (0x00)...
  mov dl, 0x00
  ; ...with the reset function (0x00)
  mov ah, 0x00
  int 0x13
  ; If everything worked (carry flag not set) move on
  ; to read the second stage from the floppy
  jnc read_snd_stage
  ; Otherwise print an error and try again
  mov si, RESET_FLOPPY_ERROR
  call println
  jmp reset_floppy

read_snd_stage:
  ; Store second stage at 0x00:0x7E00 (ES:BX), i.e.
  ; after the current stage (0x7E00 = 0x7C00 + 512).
  mov bx, 0x7E00
  mov cx, 0x0002 ; Read from cylinder 0 (CH) starting at sector 2 (CL)
  mov dx, 0x0000 ; Head 0 (DH) and floppy drive number 0 (DL)
  mov ax, 0x0201 ; AH=0x02 is the read function, read one sector in total (AL)
  int 0x13
  jnc execute_snd_stage ; Carry flag is signifies error

read_snd_stage_err:
  mov si, READ_SND_STAGE_ERROR
  call println
  jmp read_snd_stage

execute_snd_stage:
  cmp al, 0x01 ; Make sure one sector was really read
  jne read_snd_stage_err
  call main

; -- Includes --
%include "print.asm"

; -- Strings --
RESET_FLOPPY_ERROR: db "Failed to reset the floppy drive. Trying again...", 0
READ_SND_STAGE_ERROR: db "Failed to read the second stage from the floppy drive. Trying again...", 0

; -- Magic Number Signature --
; The BIOS expects to find the magic number
; 0xAA55 at the end of the first 512-byte sector
; identify the boot sector. We fill the rest of the bytes
; with 0s.
times 510-($-$$) db 0x00
dw 0xAA55

[org 0x]

%include "io.asm"

main:
  call clear_screen

  mov si, WELCOME_MSG
  call println

.input_loop:
  mov si, PROMPT
  call print

  mov di, INPUT_BUFFER
  mov dl, INPUT_BUFFER_LEN
  call readln

  mov si, EMPTY
  call println

  mov si, INPUT_BUFFER
  call println

  jmp .input_loop

; -- Strings --
WELCOME_MSG: db "Welcome to the Meiji operating system.", 0
PROMPT: db "> ", 0
INPUT_BUFFER: times INPUT_BUFFER_LEN db 0x00
EMPTY: db 0
