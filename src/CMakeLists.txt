project(${CMAKE_PROJECT_NAME})


add_library( core OBJECT 
	${CMAKE_CURRENT_SOURCE_DIR}/../include/vendor/startup_stm32f411xe.s
	${CMAKE_CURRENT_SOURCE_DIR}/../include/vendor/system_stm32f4xx.c
	# ${CMAKE_CURRENT_SOURCE_DIR}/../include/vendor/segger_fault_handler.c
)
target_include_directories(core PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../include/vendor/)
target_link_options(core PRIVATE 
    ${arch_flags} 
    ${common_flags}
    ${link_flags}
)

add_executable( gpio.elf
	gpio.s
)

target_include_directories(gpio.elf PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../include/vendor/)
target_link_options(gpio.elf PRIVATE 
    ${arch_flags} 
    ${common_flags}
    ${link_flags}
)

target_link_libraries(gpio.elf
	core
)

add_executable( ram.elf
	ram.s
)

target_include_directories(ram.elf PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../include/vendor/)
target_link_options(ram.elf PRIVATE 
    ${arch_flags} 
    ${common_flags}
    ${link_flags}
)

target_link_libraries(ram.elf
	core
)
