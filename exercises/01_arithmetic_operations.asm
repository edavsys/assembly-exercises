; ============================================================================
; 01_arithmetic_operations.asm - Realiza operaciones aritméticas básicas entre dos operandos
; Plataforma: Linux x86-64 (NASM)
; ============================================================================
; Características:
; - Soporta enteros de 16 bits con signo (cargados como 64 bits)
; - Maneja resultados negativos correctamente
; - Detecta y reporta división por cero
; - Usa multiplicación y división con signo (imul, idiv)
; ============================================================================

section .data
  operando1     dw 1
  operando2     dw 10

  msg_add       db "Suma = "
  len_add       equ $ - msg_add
  msg_sub       db "Resta = "
  len_sub       equ $ - msg_sub
  msg_mul       db "Multiplicacion = "
  len_mul       equ $ - msg_mul
  msg_div       db "Division = "
  len_div       equ $ - msg_div

  msg_div_zero  db "Error: Division por cero", 0xA
  len_div_zero  equ $ - msg_div_zero

  newline       db 0xA
  len_nl        equ 1

section .bss
  buffer resb 20

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

number_to_string:
  push rbx
  push rcx
  push rdi

  mov rbx, buffer + 19
  mov byte [rbx], 0             ; terminador nulo 
  dec rbx

  test rax, rax
  jnz .not_zero
  mov byte [rbx], '0'
  dec rbx
  jmp .done

.not_zero:
  cmp rax, 0
  jge .positive
  neg rax                       ; convertir a positivo
  mov rcx, 1                    ; bandera: es negativo
  jmp .convert

.positive:
  mov rcx, 0                    ; bandera: positivo

.convert:
  mov rdi, 10

.divide_loop:
  xor rdx, rdx
  div rdi
  add dl, '0'
  mov [rbx], dl
  dec rbx
  test rax, rax
  jnz .divide_loop

  cmp rcx, 1
  jne .done
  mov byte [rbx], '-'
  dec rbx

.done:
  inc rbx
  mov rsi, rbx
  lea rdx, [buffer + 19]
  sub rdx, rbx

  pop rdi
  pop rcx
  pop rbx
  ret

print_result:
  call print_str                ; imprime el mensaje (ej. "Suma = ")
  call number_to_string         ; convierte rax → rsi/rdx
  call print_str                ; imprime el número
  call print_newline            ; imprime \n
  ret

_start:
  movsx r8, word [operando1]    ; cargar operando1 con signo
  movsx r9, word [operando2]    ; cargar operando2 con signo

  ; Suma
  mov rax, r8
  add rax, r9
  mov rsi, msg_add
  mov rdx, len_add
  call print_result

  ; Resta
  mov rax, r8
  sub rax, r9
  mov rsi, msg_sub
  mov rdx, len_sub
  call print_result

  ; Multiplicación
  mov rax, r8
  imul rax, r9
  mov rsi, msg_mul
  mov rdx, len_mul
  call print_result

  ; División
  cmp r9, 0
  je .division_por_cero

  mov rax, r8
  cqo
  idiv r9
  mov rsi, msg_div
  mov rdx, len_div
  call print_result
  jmp .fin_division

.division_por_cero:
  mov rsi, msg_div_zero
  mov rdx, len_div_zero
  call print_str
  call print_newline

.fin_division:
  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall