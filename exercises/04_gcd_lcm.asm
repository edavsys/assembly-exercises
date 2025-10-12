; ============================================================================
; 04_gcd_lcm.asm - Calcula el MCD y MCM de dos números ingresados por el usuario
; Plataforma: Linux x86-64 (NASM)
; ============================================================================
; Características:
; - Lee dos números decimales separados por espacio
; - Valida que los caracteres sean dígitos (0-9)
; - Calcula MCD usando el algoritmo de Euclides
; - Calcula MCM usando la fórmula: MCM(a,b) = (a * b) / MCD(a,b)
; - Maneja correctamente el caso en que uno de los números es cero
; - Soporta números de hasta 64 bits (asume entrada pequeña: 0-9999)
; ============================================================================

section .data
  msg_input       db "Digite 2 numeros (0-9999) separados por espacio y dar enter: ", 0xA
  len_input       equ $ - msg_input
  msg_mcd         db "MCD = "
  len_mcd         equ $ - msg_mcd
  msg_mcm         db "MCM = "
  len_mcm         equ $ - msg_mcm

  newline         db 0xA
  len_nl          equ 1

section .bss
  input_buffer    resb 50       ; buffer para entrada cruda
  output_buffer   resb 20       ; buffer para conversión de números
  buffer_position resq 1        ; posición actual en input_buffer
  num1            resq 1        ; primer número
  num2            resq 1        ; segundo número

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
  push rax
  push rdi
  push rsi
  push rdx

  mov rax, 0                    ; sys_read
  mov rdi, 0                    ; stdin
  mov rsi, input_buffer
  mov rdx, 50
  syscall

  mov qword [buffer_position], 0; reiniciar posición de parseo

  pop rdx
  pop rsi
  pop rdi
  pop rax
  ret

parse_next_number:
  push rbx
  push rcx
  push rsi

  mov rsi, input_buffer
  add rsi, [buffer_position]

  xor rax, rax                  ; acumulador del número

.skip_whitespace:
  movzx rbx, byte [rsi]
  cmp bl, 0
  je .done
  cmp bl, ' '
  je .next
  cmp bl, 0xA
  je .next
  cmp bl, 0xD
  je .next
  cmp bl, 9
  je .next
  jmp .convert

.next:
  inc rsi
  inc qword [buffer_position]
  jmp .skip_whitespace

.convert:
  movzx rbx, byte [rsi]
  cmp bl, '0'
  jl .done
  cmp bl, '9'
  jg .done

  sub bl, '0'
  imul rax, rax, 10
  add rax, rbx

  inc rsi
  inc qword [buffer_position]
  jmp .convert

.done:
  pop rsi
  pop rcx
  pop rbx
  ret

number_to_string:
  push rbx
  push rcx
  push rdi

  mov rbx, output_buffer + 19
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
  lea rdx, [output_buffer + 19]
  sub rdx, rbx

  pop rdi
  pop rcx
  pop rbx
  ret

print_number:
  call number_to_string
  call print_str
  ret

calculate_gcd:
  push rbx

  test rax, rax
  jz .return_rbx
  test rbx, rbx
  jz .return_rax

.euclid_loop:
  test rbx, rbx
  jz .done
  xor rdx, rdx
  div rbx
  mov rax, rbx
  mov rbx, rdx
  jmp .euclid_loop

.return_rbx:
  mov rax, rbx
  jmp .done

.return_rax:

.done:
  pop rbx
  ret

calculate_lcm:
  push rbx
  push rcx
  push r12

  mov rcx, rax                  ; rcx = a
  push rbx                      ; guardar b
  call calculate_gcd            ; rax = MCD
  mov r12, rax                  ; r12 = MCD
  pop rbx                       ; rbx = b

  test r12, r12
  jz .lcm_zero

  mov rax, rcx                  ; rax = a
  xor rdx, rdx
  div r12                       ; rax = a / MCD
  mul rbx                       ; rax = (a / MCD) * b

  jmp .lcm_done

.lcm_zero:
  xor rax, rax

.lcm_done:
  pop r12
  pop rcx
  pop rbx
  ret

_start:
  mov rsi, msg_input
  mov rdx, len_input
  call print_str

  call read_stdin

  call parse_next_number
  mov [num1], rax

  call parse_next_number
  mov [num2], rax

  mov rax, [num1]
  mov rbx, [num2]
  call calculate_gcd

  mov rsi, msg_mcd
  mov rdx, len_mcd
  call print_str

  call print_number
  call print_newline

  mov rax, [num1]
  mov rbx, [num2]
  call calculate_lcm

  mov rsi, msg_mcm
  mov rdx, len_mcm
  call print_str

  call print_number
  call print_newline

  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall