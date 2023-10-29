.syntax unified
.cpu cortex-m4
.thumb

.global main
main:
        bl led_setup
led_switch:
        ldr r1, =0x40020818 @ GPIOC_BSRR
        ldr r0, =0x00002000 @ set PC13
        str r0, [r1]
        bl delay
        
        ldr r1, =0x40020818
        ldr r0, =0x20000000 @ reset PC13
        str r0, [r1]
        bl delay
        
        b led_switch
        
led_setup:
        @ RCC_AHB1ENR
        ldr r1, = 0x40023830 
        ldr r0, [r1] @ save actual data to register
        orr r0, #0x4 @ GPIOC
        str r0, [r1]  @ enable GPIOC               
        
        @ GPIOC_MODER
        ldr r1, =0x40020800 
        ldr r0, [r1]
        and r0, #0xF3FFFFFF @ clear PC13
        orr r0, #0x04000000 @ set PC13 as output
        str r0, [r1]
        
        ldr r1, = 0x40020804 @ GPIOC_OTYPER
        ldr r0, [r1]
        ldr r2, = 0xdfff
        and r0, r2 @ set PC13 to 0
        str r0, [r1]
        
        @ GPIOC_PUPDR
        ldr r1, = 0x4002080C 
        ldr r0, [r1]
        and r0, #0xF3FFFFFF @ PC13 no-push no-pull
        str r0, [r1]

        bx lr
        
delay:
        ldr r0, =0xfffff
while_delay:
        subs r0, #1
        bne while_delay
        bx lr