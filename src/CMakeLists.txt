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

add_executable( main.elf
	main.s
)

target_include_directories(main.elf PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../include/vendor/)
target_link_options(main.elf PRIVATE 
    ${arch_flags} 
    ${common_flags}
    ${link_flags}
)

target_link_libraries(main.elf
	core
)
