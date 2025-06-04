/*********************************************************
* @file      main.s
* @authors   Ivan Morataya, Juan Gualim, Oscar Rompich
* @date      June, 2025
* @brief     Secuencia de 8 LEDs con retardo de 1.5s
**********************************************************/

.syntax unified
.cpu cortex-m4
.thumb

/* ================================
   Direcciones base y offsets
   ================================ */
.equ RCC_BASE,         0x40023800
.equ RCC_AHB1ENR,      (RCC_BASE + 0x30)
.equ GPIOC_BASE,       0x40020800
.equ GPIOC_MODER,      (GPIOC_BASE + 0x00)
.equ GPIOC_IDR,        (GPIOC_BASE + 0x10)
.equ GPIOC_ODR,        (GPIOC_BASE + 0x14)

.equ GPIOC_EN,         (1 << 2)
.equ PRESS_PC13,       (1 << 13)

/* ================================
   Inicio del programa
   ================================ */
.global __main
__main:

    // Habilitar reloj para GPIOC
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1, #GPIOC_EN
    STR R1, [R0]

 // Configurar PC1-PC10 como salida (excepto PC13)
	LDR R0, =GPIOC_MODER
	LDR R1, [R0]

	MOV R2, #1        // Pin desde PC1
set_output_loop:
    // Calcular 3 << (2*R2) para limpiar
    MOV R3, #3
    MOV R7, R2
    LSL R7, R7, #1
    LSL R3, R3, R7
    BIC R1, R1, R3

    // Calcular 1 << (2*R2) para poner como salida
    MOV R3, #1
    LSL R3, R3, R7
    ORR R1, R1, R3

    ADD R2, R2, #1
    CMP R2, #11
    BLT set_output_loop

STR R1, [R0]


    // Inicializar variables
    MOV R4, #1      // Número de LEDs encendidos (PC1-PC8)
    MOV R5, #0      // Velocidad (0, 1, 2)
    MOV R6, #0      // Estado previo del botón

loop:
    // Leer botón PC13
    LDR R0, =GPIOC_IDR
    LDR R1, [R0]
    AND R1, R1, #PRESS_PC13
    CMP R1, #0
    BNE boton_no_presionado

    // Si no estaba presionado antes, cambiar velocidad
    CMP R6, #0
    BNE check_display      // Ya se presionó, no hacer nada
    ADD R5, R5, #1
    CMP R5, #3
    IT EQ
    MOVEQ R5, #0
    MOV R6, #1             // Marcar que ya se presionó

    // Esperar a que el botón se suelte completamente
wait_release:
    LDR R0, =GPIOC_IDR
    LDR R1, [R0]
    AND R1, R1, #PRESS_PC13
    CMP R1, #0
    BEQ wait_release       // Esperar mientras sigue presionado

    BL delay_boton         // Pequeño delay después de soltar


boton_no_presionado:
    MOV R6, #0

check_display:
    // Mostrar velocidad con PC9 y PC10
    LDR R0, =GPIOC_ODR
    LDR R1, [R0]
    MOV R2, #0b11
    LSL R2, R2, #9      // R2 = 0b11 << 9
    BIC R1, R1, R2      // Limpiar PC9 y PC10
    LSL R2, R5, #9
    ORR R1, R1, R2
    STR R1, [R0]

    // Encender LEDs progresivos (PC1 a PC8 según R4)
    LDR R0, =GPIOC_ODR
    MOV R1, #0
    MOV R2, #1
encender_leds:
    CMP R2, R4
    BGT fin_leds
    MOV R3, #1
    LSL R3, R3, R2
    ORR R1, R1, R3
    ADD R2, R2, #1
    B encender_leds
fin_leds:
    STR R1, [R0]

    // Delay según velocidad
    CMP R5, #0
    BEQ delay_150
    CMP R5, #1
    BEQ delay_050
    B delay_250

delay_050:
    LDR R3, =2500000     // 0.5s aprox
    B delay_loop
delay_150:
    LDR R3, =5500000    // 1.5s aprox
    B delay_loop
delay_250:
    LDR R3, =10500000     // 2.5s aprox


delay_loop:
    SUBS R3, R3, #1
    BNE delay_loop

    // Incrementar número de LEDs
    ADD R4, R4, #1
    CMP R4, #9
    IT GE
    MOVGE R4, #1

    B loop

// Delay anti-rebote
delay_boton:
    LDR R3, =1000000
dloop_btn:
    SUBS R3, R3, #1
    BNE dloop_btn
    BX LR
