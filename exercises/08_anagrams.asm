; ============================================================================
; 08_anagrams.asm - Verifica si dos cadenas tienen los mismos caracteres
; Plataforma: Linux x86-64 (NASM)
; ============================================================================
; Características:
; - Lee entrada única con formato: "cadena1|cadena2"
; - Usa tablas de frecuencia para comparar caracteres (256 ASCII)
; - Determina si ambas cadenas contienen los mismos caracteres
; - Soporta cadenas de hasta 100 caracteres cada una
; ============================================================================

section .data
  msg_input         db "Ingrese dos cadenas separadas por '|': ", 0xA
  len_input         equ $ - msg_input
  msg_anagrams      db "SI tienen los mismos caracteres (son anagramas)"
  len_anagrams      equ $ - msg_anagrams
  msg_not_anagrams  db "NO tienen los mismos caracteres"
  len_not_anagrams  equ $ - msg_not_anagrams

  newline           db 0xA
  len_nl            equ 1

section .bss
  input_buffer      resb 300    ; buffer para entrada completa
  string1           resb 100    ; primera cadena extraída
  string2           resb 100    ; segunda cadena extraída
  freq_table1       resb 256    ; tabla de frecuencias para string1
  freq_table2       resb 256    ; tabla de frecuencias para string2
  len1              resq 1      ; longitud de string1
  len2              resq 1      ; longitud de string2

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
  mov rdx, 300
  syscall

  pop rdx
  pop rsi
  pop rdi
  pop rax
  ret

parse_input:
  push rbx
  push rcx
  push rsi
  push rdi

  mov rsi, input_buffer
  mov rdi, string1
  xor rcx, rcx                  ; contador de caracteres en string1

.find_separator:
  movzx rbx, byte [rsi]
  cmp bl, 0
  je .end_string1               ; fin de entrada sin separador
  cmp bl, 0xA
  je .end_string1               ; salto de línea sin separador
  cmp bl, '|'
  je .found_separator           ; encontramos el separador

  mov [rdi], bl
  inc rsi
  inc rdi
  inc rcx
  jmp .find_separator

.found_separator:
  mov byte [rdi], 0             ; terminar string1 con null
  mov [len1], rcx               ; guardar longitud de string1
  inc rsi                       ; saltar el separador

  ; Ahora extraer string2
  mov rdi, string2
  xor rcx, rcx                  ; contador de caracteres en string2

.extract_string2:
  movzx rbx, byte [rsi]
  cmp bl, 0
  je .end_string2
  cmp bl, 0xA
  je .end_string2
  cmp bl, 0xD
  je .end_string2

  mov [rdi], bl
  inc rsi
  inc rdi
  inc rcx
  jmp .extract_string2

.end_string2:
  mov byte [rdi], 0             ; terminar string2 con null
  mov [len2], rcx               ; guardar longitud de string2
  jmp .done

.end_string1:                   ; No se encontró separador, considerar todo como string1
  mov byte [rdi], 0
  mov [len1], rcx
  mov qword [len2], 0           ; string2 vacía

.done:
  pop rdi
  pop rsi
  pop rcx
  pop rbx
  ret

clear_freq_table:
  push rax
  push rcx
  push rdi

  mov rcx, 256                  ; 256 bytes (todos los caracteres ASCII)
  xor al, al                    ; al = 0
  rep stosb                     ; llenar con ceros

  pop rdi
  pop rcx
  pop rax
  ret

calculate_frequencies:
  push rax
  push rbx
  push rcx
  push rsi
  push rdi

  call clear_freq_table

  ; Si la cadena está vacía, terminar
  test rcx, rcx
  jz .done

.count_loop:
  ; Obtener el carácter actual
  movzx rax, byte [rsi]         ; rax = carácter (extendido a 64 bits)

  ; Incrementar la frecuencia de este carácter
  inc byte [rdi + rax]

  ; Avanzar al siguiente carácter
  inc rsi
  dec rcx
  jnz .count_loop

.done:
  pop rdi
  pop rsi
  pop rcx
  pop rbx
  pop rax
  ret

compare_frequencies:
  push rbx
  push rcx
  push rdx
  push rsi
  push rdi

  mov rcx, 256                  ; comparar los 256 bytes

.compare_loop:
  ; Obtener bytes de ambas tablas
  mov al, [rsi]
  mov dl, [rdi]

  cmp al, dl
  jne .different

  inc rsi
  inc rdi
  dec rcx
  jnz .compare_loop

  ; Si llegamos aquí, todas las frecuencias son iguales
  mov rax, 1
  jmp .done

.different:
  xor rax, rax

.done:
  pop rdi
  pop rsi
  pop rdx
  pop rcx
  pop rbx
  ret

_start:
  mov rsi, msg_input
  mov rdx, len_input
  call print_str

  call read_stdin

  call parse_input

  mov rsi, string1
  mov rcx, [len1]
  mov rdi, freq_table1
  call calculate_frequencies

  mov rsi, string2
  mov rcx, [len2]
  mov rdi, freq_table2
  call calculate_frequencies

  mov rsi, freq_table1
  mov rdi, freq_table2
  call compare_frequencies


  cmp rax, 1
  je .are_anagrams              ; Mostrar resultado

  mov rsi, msg_not_anagrams
  mov rdx, len_not_anagrams
  call print_str
  jmp .print_newline

.are_anagrams:
  mov rsi, msg_anagrams
  mov rdx, len_anagrams
  call print_str

.print_newline:
  call print_newline

  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall