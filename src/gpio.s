.syntax unified
.cpu cortex-m4
.thumb

GPIOC_MODER = 0x40020800
GPIOx_MODER_MODE13 = 0x0C000000
GPIOx_MODER_MODE13_0 = 0x04000000
GPIOC_OTYPER = 0x40020804
GPIOx_OTYPER_OT13 = 0x2000
GPIOC_PUPDR = 0x4002080C
GPIOx_PUPDR_PUPD13 = 0x0C000000
GPIOC_BSRR = 0x40020818
GPIOx_BSRR_BS13 = 0x00002000
GPIOx_BSRR_BR13 = 0x20000000
RCC_AHB1ENR = 0x40023830

.global main
main:
        bl led_setup
led_switch:
        ldr r1, = GPIOC_BSRR
        ldr r0, = GPIOx_BSRR_BS13
        str r0, [r1]
        bl delay
        
        ldr r1, =GPIOC_BSRR
        ldr r0, =GPIOx_BSRR_BR13
        str r0, [r1]
        bl delay
        
        b led_switch
        
led_setup:
        ldr r1, = RCC_AHB1ENR 
        ldr r0, [r1] @ save actual data to register
        orr r0, #0x4 @ GPIOC
        str r0, [r1]  @ enable GPIOC               
        
        ldr r1, = GPIOC_MODER
        ldr r0, [r1]
        ldr r2, = GPIOx_MODER_MODE13
        mvns r2,r2
        and r0, r2 @ clear PC13
        orr r0, #GPIOx_MODER_MODE13_0 @ set PC13 as output
        str r0, [r1]
        
        ldr r1, = GPIOC_OTYPER 
        ldr r0, [r1]
        ldr r2, = GPIOx_OTYPER_OT13
        mvns r2, r2
        and r0, r2 @ set PC13 to 0
        str r0, [r1]
        
        ldr r1, = GPIOC_PUPDR
        ldr r0, [r1]
        ldr r2, =GPIOx_PUPDR_PUPD13
        mvns r2, r2
        and r0, r2 @ PC13 no-push no-pull
        str r0, [r1]

        bx lr
        
delay:
        ldr r0, =0xfffff8
while_delay:
        subs r0, #1
        bne while_delay
        bx lr