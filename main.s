/*********************************************************
* @file      main.s
* @authors   Ivan Morataya, Juan Gualim, Oscar Rompich
* @date      June, 2025
* @brief     Temarop 6 - Proyecto 4
**********************************************************/

.syntax unified
.cpu cortex-m4
.thumb

/* ================================
   Direcciones base y offsets
   ================================ */
.equ RCC_BASE,         0x40023800          // Dirección base del sistema de reloj
.equ RCC_AHB1ENR,      (RCC_BASE + 0x30)   // Registro para habilitar reloj de GPIO
.equ GPIOC_BASE,       0x40020800          // Dirección base de GPIOC
.equ GPIOC_MODER,      (GPIOC_BASE + 0x00) // Registro de modo (entrada/salida)
.equ GPIOC_IDR,        (GPIOC_BASE + 0x10) // Registro de entrada (lectura de pines)
.equ GPIOC_ODR,        (GPIOC_BASE + 0x14) // Registro de salida (encendido de pines)

.equ GPIOC_EN,         (1 << 2)            // Bit para habilitar GPIOC en RCC
.equ PRESS_PC13,       (1 << 13)           // Bit correspondiente al botón en PC13

/* ================================
   Punto de entrada principal
   ================================ */
.global __main
__main:

    // Habilita el reloj para el puerto GPIOC
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1, #GPIOC_EN      // Activa bit para GPIOC
    STR R1, [R0]

    // Configura los pines PC1 a PC10 como salida (excepto PC13)
    LDR R0, =GPIOC_MODER
    LDR R1, [R0]
    MOV R2, #1                // Comenzar desde el pin PC1

set_output_loop:
    // Limpia los 2 bits de configuración del pin actual
    MOV R3, #3
    MOV R7, R2
    LSL R7, R7, #1            // R7 = 2*R2
    LSL R3, R3, R7
    BIC R1, R1, R3            // Borra bits del modo anterior

    // Establece el pin como salida (01)
    MOV R3, #1
    LSL R3, R3, R7
    ORR R1, R1, R3            // Coloca los bits necesarios

    ADD R2, R2, #1
    CMP R2, #11               // Hasta PC10 (excluye PC13)
    BLT set_output_loop

    STR R1, [R0]              // Guarda configuración en MODER

    // Inicializa variables:
    MOV R4, #1      // Número de LEDs encendidos (PC1 a PC8)
    MOV R5, #0      // Índice de velocidad actual (0: 1.5s, 1: 0.5s, 2: 2.5s)
    MOV R6, #0      // Estado anterior del botón (para evitar múltiples lecturas)

loop:
    // Leer estado del botón (PC13)
    LDR R0, =GPIOC_IDR
    LDR R1, [R0]
    AND R1, R1, #PRESS_PC13   // Aísla bit de PC13
    CMP R1, #0                // ¿Está presionado? (nivel bajo)
    BNE boton_no_presionado  // Si no está presionado, ir al manejo normal

    // Verifica si antes no estaba presionado
    CMP R6, #0
    BNE check_display         // Si ya estaba presionado antes, omitir cambio

    // Incrementa velocidad (R5 = 0 → 1 → 2 → 0 cíclicamente)
    ADD R5, R5, #1
    CMP R5, #3
    IT EQ
    MOVEQ R5, #0
    MOV R6, #1                // Marca que el botón ya fue presionado

wait_release:
    // Espera hasta que el botón se libere completamente (anti-rebote)
    LDR R0, =GPIOC_IDR
    LDR R1, [R0]
    AND R1, R1, #PRESS_PC13
    CMP R1, #0
    BEQ wait_release          // Si aún está presionado, espera

    BL delay_boton            // Breve pausa tras liberación (anti-rebote físico)

boton_no_presionado:
    MOV R6, #0                // Reinicia estado del botón

check_display:
    // Muestra la velocidad actual en PC9 y PC10
    LDR R0, =GPIOC_ODR
    LDR R1, [R0]
    MOV R2, #0b11
    LSL R2, R2, #9            // Prepara máscara para PC9 y PC10
    BIC R1, R1, R2            // Limpia PC9 y PC10
    LSL R2, R5, #9            // Coloca el valor de R5 en PC9 y PC10
    ORR R1, R1, R2
    STR R1, [R0]

    // Enciende los LEDs del PC1 al PC8 según el valor en R4
    LDR R0, =GPIOC_ODR
    MOV R1, #0                // Registro de salida a escribir
    MOV R2, #1                // Comenzar desde PC1

encender_leds:
    CMP R2, R4
    BGT fin_leds              // Cuando R2 > R4, salir del ciclo

    MOV R3, #1
    LSL R3, R3, R2            // R3 = 1 << R2 (encender PC2, PC3, etc.)
    ORR R1, R1, R3            // Agrega bit a la salida
    ADD R2, R2, #1
    B encender_leds

fin_leds:
    STR R1, [R0]              // Actualiza el registro ODR con los LEDs encendidos

    // Realiza el delay de acuerdo a la velocidad seleccionada
    CMP R5, #0
    BEQ delay_150             // Velocidad media (1.5s)
    CMP R5, #1
    BEQ delay_050             // Velocidad rápida (0.5s)
    B delay_250               // Velocidad lenta (2.5s)

delay_050:
    LDR R3, =2500000          // Aprox. 0.5 segundos
    B delay_loop
delay_150:
    LDR R3, =5500000          // Aprox. 1.5 segundos
    B delay_loop
delay_250:
    LDR R3, =10500000         // Aprox. 2.5 segundos

delay_loop:
    SUBS R3, R3, #1
    BNE delay_loop            // Espera activa (delay)

    // Aumenta el número de LEDs encendidos
    ADD R4, R4, #1
    CMP R4, #9
    IT GE
    MOVGE R4, #1              // Reinicia a 1 si ya se llegó a 8

    B loop                    // Vuelve al inicio del ciclo principal

/* ================================
   Rutina de delay para anti-rebote
   ================================ */
delay_boton:
    LDR R3, =1000000          // Delay corto para evitar rebotes
dloop_btn:
    SUBS R3, R3, #1
    BNE dloop_btn
    BX LR                     // Retorno de subrutina

/* ================================
   Fin del programa
   ================================ */
end:
    B end                     // Bucle infinito (no debe salir)

.align 2
.end
