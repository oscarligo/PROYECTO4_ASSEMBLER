
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

.equ GPIOC_IDR_OFFSET, 0x10
.equ GPIOC_IDR, (GPIOC_BASE + GPIOC_IDR_OFFSET)

.equ PRESS_PC13, (1 << 13) 


/*==================
    Salidas
====================*/


/****Arreglo de LEDs para indicar el estado ****/


// Puerto PC1

.equ GPIOC_BASE, 0x40020800
.equ GPIOC_MODER_OFFSET, 0x00
.equ GPIOC_MODER, (GPIOC_BASE + GPIOC_MODER_OFFSET)

.equ MODER1_OUT, (1 << 2) 

.equ GPIOC_ODR_OFFSET, 0x14
.equ GPIOC_ODR, (GPIOC_BASE + GPIOC_ODR_OFFSET)

.equ LED1_ON, (1 << 1)
.equ LED1_OFF, (0 << 1)


// Puerto PC2

// Puerto PC3

// Puerto PC4

// Puerto PC5

// Puerto PC6

// Puerto PC7

// Puerto PC8


/****LEDs para indicar la velocidad de los cambios de estado****/



.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.global __main

__main:




end:
	B end


.section .data



	.align
	.end
