project(${CMAKE_PROJECT_NAME})


add_library( core OBJECT 
	startup.s
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

add_executable( test.elf
	test.s
)

target_include_directories(test.elf PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../include/vendor/)
target_link_options(test.elf PRIVATE 
    ${arch_flags} 
    ${common_flags}
    ${link_flags}
)

target_link_libraries(test.elf
	core
)
