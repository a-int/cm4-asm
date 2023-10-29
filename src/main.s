.syntax unified
.cpu cortex-m4
.thumb

.global main
main:
        bl led_setup

        ldr r1, = 0x40020814 @ GPIOC
        ldr r0, = 0x00002000 @ C13 push-pull
        str r0, [r1]
        
        b .
        
led_setup:
        ldr r1, = 0x40023830 @ RCC_AHB1ENR
        ldr r0, = 0x4 @ GPIOC
        str r0, [r1]  @ enable GPIOC               

        ldr r1, = 0x40020800 @ GPIOC
        ldr r0, = 0x08000000 @ C13 output
        str r0, [r1]

        ldr r1, = 0x40020804 @ GPIOC
        ldr r0, = 0x00000000 @ C13 push-pull
        str r0, [r1]

        ldr r1, = 0x4002080C @ GPIOC
        ldr r0, = 0x00000000 @ C13 no-push no-pull
        str r0, [r1]

        bx lr
        