; ============================================================================
; 06_remove_numbers.asm - Elimina todos los dígitos de una cadena
; Plataforma: Linux x86-64 (NASM)
; ============================================================================
; Características:
; - Filtra todos los dígitos (0-9) de la cadena
; - Preserva todos los demás caracteres
; - Muestra la cadena original y la cadena filtrada
; - Soporta cadenas de hasta 200 caracteres
; ============================================================================

section .data
  msg_input       db "Ingrese una cadena: ", 0xA
  len_input       equ $ - msg_input
  msg_original    db "Cadena original: "
  len_original    equ $ - msg_original
  msg_result      db "Sin numeros: "
  len_result      equ $ - msg_result

  newline         db 0xA
  len_nl          equ 1

section .bss
  input_buffer    resb 200      ; buffer para entrada
  output_buffer   resb 200      ; buffer para cadena sin números
  input_len       resq 1        ; longitud de entrada
  output_len      resq 1        ; longitud de salida

section .text
  global _start

print_str:
  push rax
  push rdi
  mov rax, 1                    ; sys_write
  mov rdi, 1                    ; stdout
  syscall
  pop rdi
  pop rax
  ret

print_newline:
  push rsi
  push rdx
  mov rsi, newline
  mov rdx, len_nl
  call print_str
  pop rdx
  pop rsi
  ret

read_stdin:
  push rbx
  push rcx
  push rdi
  push rsi
  push rdx

  mov rax, 0                    ; sys_read
  mov rdi, 0                    ; stdin
  mov rsi, input_buffer
  mov rdx, 200
  syscall

  mov rcx, rax                  ; guardar longitud

  ; Verificar si el último carácter es newline
  cmp rcx, 0
  je .done

  dec rcx                       ; ajustar índice al último carácter
  cmp byte [input_buffer + rcx], 0xA
  jne .no_newline

  ; Reemplazar newline con null
  mov byte [input_buffer + rcx], 0
  mov rax, rcx                  ; retornar longitud sin newline
  jmp .done

.no_newline:
  inc rcx
  mov rax, rcx

.done:
  pop rdx
  pop rsi
  pop rdi
  pop rcx
  pop rbx
  ret

remove_digits:
  push rbx
  push rcx
  push rsi
  push rdi
  push r12

  xor r12, r12                  ; r12 = contador de caracteres copiados

  ; Si la cadena está vacía, terminar
  test rcx, rcx
  jz .done

.process_loop:
  movzx rbx, byte [rsi]         ; Obtener el carácter actual

  ; Verificar si es un dígito ('0' = 48, '9' = 57)
  cmp bl, '0'
  jl .not_digit
  cmp bl, '9'
  jg .not_digit

  jmp .skip_char

.not_digit:
  mov [rdi], bl
  inc rdi
  inc r12                       ; incrementar contador

.skip_char:
  inc rsi
  dec rcx
  jnz .process_loop

.done:
  mov rax, r12                  ; retornar longitud de la cadena resultante
  pop r12
  pop rdi
  pop rsi
  pop rcx
  pop rbx
  ret

_start:
  mov rsi, msg_input
  mov rdx, len_input
  call print_str

  call read_stdin
  mov [input_len], rax          ; guardar longitud

  call print_newline

  mov rsi, msg_original
  mov rdx, len_original
  call print_str

  mov rsi, input_buffer
  mov rdx, [input_len]
  call print_str

  call print_newline

  mov rsi, input_buffer
  mov rdi, output_buffer
  mov rcx, [input_len]
  call remove_digits
  mov [output_len], rax         ; guardar longitud resultante

  mov rsi, msg_result
  mov rdx, len_result
  call print_str

  mov rsi, output_buffer
  mov rdx, [output_len]
  call print_str

  call print_newline

  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall