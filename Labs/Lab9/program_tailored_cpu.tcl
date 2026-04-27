open_hw_manager
connect_hw_server
open_hw_target
set dev [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE [file normalize "TailoredCPU_onlyX1writtable.bit"] $dev
program_hw_devices $dev
close_hw_manager
