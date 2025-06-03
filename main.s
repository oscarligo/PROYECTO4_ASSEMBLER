
/*********************************************************
* @file      main.s
* @author    Ivan Morataya
*			 Juan Gualim
*			 Oscar Rompich - 24880
* @date      June, 2025
* @brief     Secuencia de 8 bits 

* @details
*			(descripcion del proyecto)

**********************************************************/

/*==================
    DEFINICIONES
====================*/

// CLK AHB1 

.equ RCC_BASE, 0x40023800
.equ AHB1ENR_OFFSET, 0x30
.equ RCC_AHB1ENR, (RCC_BASE + AHB1ENR_OFFSET)

.equ GPIOC_EN, (1 << 2)


/*==================
    Entradas
====================*/


// Puerto PC13 para entrada de pushbutton

.equ GPIOC_BASE, 0x40020800
.equ GPIOC_MODER_OFFSET, 0x00
.equ GPIOC_MODER, (GPIOC_BASE + GPIOC_MODER_OFFSET)

// GPIOC como IDR

.equ GPIOC_IDR_OFFSET, 0x10
.equ GPIOC_IDR, (GPIOC_BASE + GPIOC_IDR_OFFSET)


.equ PRESS_PC13, (1 << 13) 

// Puerto PC14 para entrada de pushbutton

.equ PRESS_PC14, (1 << 14)


/*==================
    Salidas
====================*/

/*********LEDs para indicar el estado *********/

// GPIOC como ODR

.equ GPIOC_ODR_OFFSET, 0x14
.equ GPIOC_ODR, (GPIOC_BASE + GPIOC_ODR_OFFSET)


// Puerto PC1

.equ MODER1_OUT, (1 << 2) 
.equ LED1_ON, (1 << 1)
.equ LED1_OFF, (0 << 1)

// Puerto PC2

.equ MODER2_OUT, (1 << 4)
.equ LED2_ON, (1 << 2)
.equ LED2_OFF, (0 << 2)

// Puerto PC3

.equ MODER3_OUT, (1 << 6)
.equ LED3_ON, (1 << 3)
.equ LED3_OFF, (0 << 3)

// Puerto PC4

.equ MODER4_OUT, (1 << 8)
.equ LED4_ON, (1 << 4)
.equ LED4_OFF, (0 << 4)

// Puerto PC5

.equ MODER5_OUT, (1 << 10)
.equ LED5_ON, (1 << 5)
.equ LED5_OFF, (0 << 5)

// Puerto PC6

.equ MODER6_OUT, (1 << 12)
.equ LED6_ON, (1 << 6)
.equ LED6_OFF, (0 << 6)

// Puerto PC7

.equ MODER7_OUT, (1 << 14)
.equ LED7_ON, (1 << 7)
.equ LED7_OFF, (0 << 7)

// Puerto PC8

.equ MODER8_OUT, (1 << 16)
.equ LED8_ON, (1 << 8)
.equ LED8_OFF, (0 << 8)


/*********LEDs para indicar la velocidad de los cambios de estado*********/


// Puerto PC9

.equ MODER9_OUT, (1 << 18)
.equ LED9_ON, (1 << 9)
.equ LED9_OFF, (0 << 9)

// Puerto PC10

.equ MODER10_OUT, (1 << 20)
.equ LED10_ON, (1 << 10)
.equ LED10_OFF, (0 << 10)


.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.global __main

__main:

	// Habilitar el reloj del puerto C
	LDR R0, =RCC_AHB1ENR
	LDR R1, [R0]
	ORR R1, R1, #GPIOC_EN
	STR R1, [R0]

	// Configurar los pines PC1 a PC10 
	LDR R0, =GPIOC_MODER
	LDR R1, [R0]
	ORR R1, R1, #MODER1_OUT | MODER2_OUT | MODER3_OUT | MODER4_OUT | MODER5_OUT | MODER6_OUT | MODER7_OUT | MODER8_OUT | MODER9_OUT | MODER10_OUT
	STR R1, [R0]




end:
	B end


.section .data


low_speed:			.word 7500000
medium_speed:		.word 5000000
high_speed:			.word 2500000



	.align
	.end
