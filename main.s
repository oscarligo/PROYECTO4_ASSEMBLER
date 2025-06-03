/*********************************************************
* @file      main.s
* @authors   Ivan Morataya, Juan Gualim, Oscar Rompich
* @date      June, 2025
* @brief     Secuencia de 8 LEDs con retardo de 1.5s
**********************************************************/

/*==================
    DEFINICIONES
====================*/

.equ RCC_BASE,           0x40023800
.equ AHB1ENR_OFFSET,     0x30
.equ RCC_AHB1ENR,        (RCC_BASE + AHB1ENR_OFFSET)
.equ GPIOC_EN,           (1 << 2)

.equ GPIOC_BASE,         0x40020800
.equ GPIOC_MODER,        (GPIOC_BASE + 0x00)
.equ GPIOC_ODR,          (GPIOC_BASE + 0x14)

.equ MODER_MASK,         0x3FFFF          // Bits 1-16 para PC1–PC8 en modo salida
.equ LED_MASK,           0x1FE            // Bits 1–8 (LED1 a LED8)
.equ DELAY_COUNT,        22500000         // Aprox. 1.5 segundos (ajustable)

/*==================
    INICIO DEL CÓDIGO
====================*/

.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.global __main

__main:

    // ===================== Habilitar reloj GPIOC =====================
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1, #GPIOC_EN
    STR R1, [R0]

    // ===================== Configurar PC1-PC8 como salida =====================
    LDR R0, =GPIOC_MODER
    LDR R1, [R0]
    // Limpiar los bits del 2 al 17 (PC1 a PC8)
    LDR R2, =MODER_MASK
    BIC R1, R1, R2
    // Establecer modo salida para PC1-PC8 (01b cada uno = 01 01 01 01 ...)
    LDR R2, =0x55554  // bin: 0101 0101 0101 0101 0100
    ORR R1, R1, R2
    STR R1, [R0]

loop_main:
    MOV R4, #1          // Comenzar con un LED (bit 1 activo)

loop_leds:
    // Encender los LEDs según el valor actual de R4
    LDR R0, =GPIOC_ODR
    STR R4, [R0]        // Escribir valor de salida (LEDs)

    // Retardo de 1.5 segundos
    LDR R0, =DELAY_COUNT
    BL delay

    // Verificar si ya se encendieron los 8 LEDs
    CMP R4, #LED_MASK   // Comparar con 0x1FE (LEDs 1 a 8 encendidos)
    BEQ restart         // Si ya están todos, reiniciar ciclo

    // Sumar el siguiente bit (agregar un LED encendido)
    LSL R4, R4, #1      // Desplazar a la izquierda
    ORR R4, R4, #1      // Encender el siguiente LED

    B loop_leds         // Repetir

restart:
    B loop_main         // Reiniciar desde un LED encendido

end:
    B end               // Bucle infinito

/*===========================
    SUBRUTINA DE RETARDO
===========================*/

delay:
    MOV R2, R0
delay_loop:
    SUBS R2, R2, #1
    BNE delay_loop
    BX LR

.section .data
DELAY_COUNT: .word 22500000    // Aprox. 1.5s para STM32 a 16 MHz (ajustar según tu reloj)
