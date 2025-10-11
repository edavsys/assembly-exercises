; ============================================================================
; 03_prime_numbers.asm - Lee 10 números del usuario y muestra los primos encontrados
; Plataforma: Linux x86-64 (NASM)
; ============================================================================
; Características:
; - Lee hasta 100 bytes de entrada estándar
; - Parsea números decimales separados por espacios, tabs o saltos de línea
; - Valida que los caracteres sean dígitos (0-9)
; - Detecta números primos (incluye 2 y 3, excluye < 2)
; - Soporta números de hasta 64 bits con signo
; - Imprime primos separados por espacio y cuenta total al final
; ============================================================================

section .data
  msg_input       db "Digite 10 numeros (0-9999) separados por espacio y dar enter: ", 0xA
  len_input       equ $ - msg_input
  msg_primes      db "Numeros primos: "
  len_primes      equ $ - msg_primes
  msg_count       db "Cantidad de primos: "
  len_count       equ $ - msg_count

  space           db " "
  len_space       equ 1
  newline         db 0xA
  len_nl          equ 1

section .bss
  numbers         resq 10       ; array de 10 números (64 bits cada uno)
  input_buffer    resb 100      ; buffer para entrada cruda
  output_buffer   resb 20       ; buffer para conversión de números a texto
  buffer_position resq 1        ; posición actual en input_buffer

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

print_space:
  push rsi
  push rdx
  mov rsi, space
  mov rdx, len_space
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
  mov rdx, 100
  syscall

  mov qword [buffer_position], 0

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

is_prime:
  push rbx
  push rcx
  push rdx
  push r12

  mov r12, rax                  ; guardar n en r12

  cmp r12, 2
  jl .not_prime                 ; n < 2 → no primo
  je .prime                     ; n == 2 → primo

  cmp r12, 3
  je .prime                     ; n == 3 → primo

  mov rax, r12
  and rax, 1
  jz .not_prime                 ; par > 2 → no primo

  mov rbx, 3                    ; probar divisores impares desde 3

.test_loop:
  mov rax, rbx
  mul rbx                       ; rax = rbx * rbx
  cmp rax, r12
  jg .prime                     ; si rbx² > n → es primo

  mov rax, r12
  xor rdx, rdx
  div rbx
  test rdx, rdx
  jz .not_prime                 ; divisible n % rbx == 0? → no primo

  add rbx, 2                    ; siguiente impar
  jmp .test_loop

.prime:
  mov rax, 1
  jmp .done

.not_prime:
  xor rax, rax

.done:
  pop r12
  pop rdx
  pop rcx
  pop rbx
  ret

_start:
  mov rsi, msg_input
  mov rdx, len_input
  call print_str

  call read_stdin

  xor r13, r13                  ; contador de números
  mov r14, numbers              ; puntero al array

.input_loop:
  call parse_next_number
  mov [r14], rax
  add r14, 8
  inc r13
  cmp r13, 10
  jl .input_loop

  mov rsi, msg_primes
  mov rdx, len_primes
  call print_str

  xor r13, r13                  ; contador de primos
  xor r15, r15                  ; índice
  mov r14, numbers              ; reiniciar puntero

.check_loop:
  mov rax, [r14]
  call is_prime

  cmp rax, 1
  jne .next

  mov rax, [r14]                ; recuperar el número original
  call print_number
  call print_space
  inc r13

.next:
  add r14, 8
  inc r15
  cmp r15, 10
  jl .check_loop

  call print_newline

  mov rsi, msg_count
  mov rdx, len_count
  call print_str

  mov rax, r13
  call print_number
  call print_newline

  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall