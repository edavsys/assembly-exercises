<div align="center">
  <h1>💻 Ejercicios en Ensamblador x86-64 💻</h1>
  <p>Ejercicios de programación en <strong>Ensamblador x86-64</strong> usando sintaxis <strong>NASM (Netwide Assembler)</strong></p>

![Assembly](https://img.shields.io/badge/Assembly-007ACC?logo=assemblyscript&logoColor=007ACC&labelColor=fff&color=007ACC)
![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=A81D33&labelColor=fff&color=A81D33)
![NASM](https://img.shields.io/badge/NASM-007ACC?logo=assemblyscript&logoColor=007ACC&labelColor=fff&color=007ACC)

</div>

## 🌟 Descripción

Este repositorio contiene ejercicios de programación en **Ensamblador x86-64** usando sintaxis **NASM**. Los ejemplos prácticos incluyen:

- Interacción directa con **syscalls** del kernel Linux.
- Manejo de registros de 64 bits (`RAX`, `RBX`, `RCX`, `RDX`, etc.).
- Operaciones a nivel de hardware.
- Manipulación de memoria y cadenas.

## 📂 Ejercicios

| #   | Ejercicio                   | Nivel | Descripción                                                 |
| --- | --------------------------- | ----- | ----------------------------------------------------------- |
| 1   | **Operaciones Aritméticas** | 🟢    | Suma, resta, multiplicación y división de dos números.      |
| 2   | **Fibonacci**               | 🟢    | Genera la serie de Fibonacci desde f(0) hasta f(93).        |
| 3   | **Números Primos**          | 🟡    | Detecta números primos entre 10 valores ingresados.         |
| 4   | **MCD y MCM**               | 🟡    | Calcula el Máximo Común Divisor y Mínimo Común Múltiplo.    |
| 5   | **Comparar Cadenas**        | 🟡    | Compara dos cadenas para verificar igualdad.                |
| 6   | **Eliminar Números**        | 🟡    | Elimina todos los dígitos numéricos de una cadena.          |
| 7   | **Buscar Subcadena**        | 🔴    | Detecta una subcadena dentro de otra cadena.                |
| 8   | **Anagramas**               | 🔴    | Verifica si dos palabras son anagramas (mismos caracteres). |

## 📋 Requisitos de instalación

- **Sistema operativo**: WSL2 en Windows o distribuciones Linux (Debian, Ubuntu, Arch, etc.).
- **Arquitectura**: x86-64 (64 bits).
- **NASM**: versión 2.16 o superior.
- **GNU Linker (ld)**: versión 2.44 o superior.

## 🚀 Cómo ejecutar los ejercicios

### 🖥️ WSL Debian (Recomendado)

1. **Instalar WSL con Debian** en PowerShell como Administrador (solo primera vez):
   ```bash
   wsl --install -d Debian
   ```
2. **Reiniciar la máquina**. Al acceder a Debian, configurar usuario/contraseña al solicitarse.
3. **Instalar NASM y herramientas de compilación**:
   ```bash
   sudo apt update
   ```
   ```bash
   sudo apt install nasm build-essential -y
   ```
4. **Verificar instalación**:
   ```bash
   nasm -v        # versión de nasm - ej. NASM version 2.16.03
   ```
   ```bash
   ld -v          # versión de ld   - ej. GNU ld (GNU Binutils for Debian) 2.44
   ```
   ```bash
   uname -m       # arquitectura    - ej. x86_64
   ```
5. **Navegar a la carpeta de ejercicios**. Ajustar la ruta según la ubicación del repositorio:
   ```bash
   cd /mnt/.../assembly-exercises/exercises
   ```
6. **Ensamblar el código**. Convierte el archivo `.asm` en un archivo objeto `.o`:
   ```bash
   nasm -f elf64 01_arithmetic_operations.asm -o exercise.o
   ```
7. **Enlazar y crear el ejecutable**:
   ```bash
   ld exercise.o -o exercise
   ```
8. **Ejecutar el programa**:
   ```bash
   ./exercise
   ```
9. **Todo en un solo comando**:
   ```bash
   nasm -f elf64 01_arithmetic_operations.asm -o exercise.o && ld exercise.o -o exercise && ./exercise
   ```

### 🌐 OneCompiler (Sin instalación)

Ejecución del código sin necesidad de instalación:

1. Abrir **[OneCompiler - Assembly](https://onecompiler.com/assembly)**.
2. Copiar y pegar el código del ejercicio.
3. Si el ejercicio requiere entrada del usuario:
   - Ir al panel **STDIN**.
   - Ingresar los valores separados por un espacio.
4. Hacer clic en **Run**.

## 📖 Documentación Oficial

Para profundizar más:

- **[NASM Documentation](https://www.nasm.us/doc/)** - Manual completo de ensamblador.
- **[x86-64 Reference](https://www.felixcloutier.com/x86/)** - Referencia de instrucciones x86-64.
- **[Linux Syscall Table](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)** - Tabla de syscalls para x86-64.

<div align="center">
  <br>
  <img src="https://img.shields.io/badge/Hecho%20con-Ensamblador%20%26%20Curiosidad-007ACC?style=for-the-badge" alt="Made with Assembly">
  <br><br>
  <p>⭐ <strong>Si resulta útil, considerar dejar una estrella</strong> ⭐</p>
</div>
