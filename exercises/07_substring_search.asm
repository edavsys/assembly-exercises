; ============================================================================
; 07_substring_search.asm - Busca una subcadena dentro de un texto principal
; Plataforma: Linux x86-64 (NASM)
; ============================================================================
; Características:
; - Lee entrada única con formato: "texto principal|subcadena"
; - Busca subcadena usando comparación byte por byte
; - Retorna posición (0-based) si encuentra, o indica que no es subcadena
; - Soporta textos de hasta 200 caracteres
; ============================================================================

section .data
  msg_input       db "Ingrese el texto principal y la subcadena separados por '|': ", 0xA
  len_input       equ $ - msg_input
  msg_found       db "SI es subcadena (encontrada en posicion "
  len_found       equ $ - msg_found
  msg_not_found   db "NO es subcadena"
  len_not_found   equ $ - msg_not_found
  msg_close       db ")"
  len_close       equ 1

  newline         db 0xA
  len_nl          equ 1
  separator       db "|"

section .bss
  input_buffer    resb 300      ; buffer para entrada completa
  main_text       resb 200      ; texto principal extraído
  search_text     resb 100      ; subcadena a buscar
  output_buffer   resb 20       ; buffer para conversión de números
  main_len        resq 1        ; longitud del texto principal
  search_len      resq 1        ; longitud de la subcadena

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

parse_input:
  push rbx
  push rcx
  push rsi
  push rdi
  push r12
  push r13

  mov rsi, input_buffer
  mov rdi, main_text
  xor rcx, rcx                  ; contador de caracteres en texto principal

.find_separator:
  movzx rbx, byte [rsi]
  cmp bl, 0
  je .end_main                  ; fin de entrada sin separador
  cmp bl, 0xA
  je .end_main                  ; salto de línea sin separador
  cmp bl, '|'
  je .found_separator           ; encontramos el separador

  mov [rdi], bl
  inc rsi
  inc rdi
  inc rcx
  jmp .find_separator

.found_separator:
  mov byte [rdi], 0             ; terminar texto principal con null
  mov [main_len], rcx           ; guardar longitud del texto principal
  inc rsi                       ; saltar el separador

  mov rdi, search_text
  xor rcx, rcx                  ; contador de caracteres en subcadena

.extract_search:
  movzx rbx, byte [rsi]
  cmp bl, 0
  je .end_search
  cmp bl, 0xA
  je .end_search
  cmp bl, 0xD
  je .end_search

  mov [rdi], bl
  inc rsi
  inc rdi
  inc rcx
  jmp .extract_search

.end_search:
  mov byte [rdi], 0             ; terminar subcadena con null
  mov [search_len], rcx         ; guardar longitud de la subcadena
  jmp .done

.end_main:                      ; No se encontró separador, considerar todo como texto principal
  mov byte [rdi], 0
  mov [main_len], rcx
  mov qword [search_len], 0     ; subcadena vacía

.done:
  pop r13
  pop r12
  pop rdi
  pop rsi
  pop rcx
  pop rbx
  ret

find_substring:
  push rbx
  push rcx
  push rdx
  push rsi
  push rdi
  push r12
  push r13
  push r14
  push r15

  mov r12, rsi                  ; r12 = texto principal
  mov r13, rdi                  ; r13 = subcadena
  mov r14, rcx                  ; r14 = longitud texto principal
  mov r15, rdx                  ; r15 = longitud subcadena

  ; Si subcadena es más larga que texto, no puede estar
  cmp r15, r14
  jg .not_found

  ; Si subcadena está vacía, se considera encontrada en posición 0
  cmp r15, 0
  je .found_at_zero

  ; Calcular límite de búsqueda: main_len - search_len + 1
  mov rbx, r14
  sub rbx, r15
  inc rbx                       ; rbx = número de posiciones a verificar

  xor r8, r8                    ; r8 = posición actual en texto principal

.search_loop:
  cmp r8, rbx
  jge .not_found

  ; Comparar subcadena desde posición actual
  mov rsi, r12
  add rsi, r8                   ; rsi = texto principal + offset
  mov rdi, r13                  ; rdi = subcadena
  mov rcx, r15                  ; rcx = longitud subcadena

  ; Comparar byte por byte
  push r8
  push rbx
  xor rbx, rbx                  ; rbx = índice dentro de subcadena

.compare_loop:
  cmp rbx, rcx
  je .match_found               ; todos los bytes coinciden

  mov al, [rsi + rbx]
  mov dl, [rdi + rbx]
  cmp al, dl
  jne .no_match                 ; diferencia encontrada

  inc rbx
  jmp .compare_loop

.match_found:
  pop rbx
  pop r8
  mov rax, r8                   ; retornar posición
  jmp .done

.no_match:
  pop rbx
  pop r8
  inc r8                        ; siguiente posición
  jmp .search_loop

.found_at_zero:
  xor rax, rax
  jmp .done

.not_found:
  mov rax, -1

.done:
  pop r15
  pop r14
  pop r13
  pop r12
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

  mov rsi, main_text
  mov rdi, search_text
  mov rcx, [main_len]
  mov rdx, [search_len]
  call find_substring

  cmp rax, -1
  je .not_found

  push rax                      ; Subcadena encontrada y guardar posición

  mov rsi, msg_found
  mov rdx, len_found
  call print_str

  pop rax                       ; recuperar posición
  call print_number

  mov rsi, msg_close
  mov rdx, len_close
  call print_str

  jmp .print_newline

.not_found:
  mov rsi, msg_not_found
  mov rdx, len_not_found
  call print_str

.print_newline:
  call print_newline

  mov rax, 60                   ; sys_exit
  xor rdi, rdi                  ; status = 0
  syscall