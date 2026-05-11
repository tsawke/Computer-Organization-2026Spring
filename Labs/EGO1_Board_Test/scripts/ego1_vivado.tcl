set SCRIPT_DIR [file dirname [file normalize [info script]]]
set ROOT_DIR   [file normalize [file join $SCRIPT_DIR ".."]]
set SRC_DIR    [file join $ROOT_DIR "src"]
set XDC_FILE   [file join $ROOT_DIR "constraints" "ego1_v2_2_board.xdc"]
set BUILD_DIR  [file join $ROOT_DIR "build"]
set OUT_DIR    [file join $ROOT_DIR "output"]
set PROJ_DIR   [file join $BUILD_DIR "vivado_project"]
set PROJ_NAME  "ego1_board_selftest"
set TOP_NAME   "ego1_board_selftest_top"
set PART_NAME  "xc7a35tcsg324-1"
set BIT_FILE   [file join $OUT_DIR "ego1_board_selftest.bit"]
set MCS_FILE   [file join $OUT_DIR "ego1_board_selftest_n25q32.mcs"]

proc timestamp {} {
    return [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
}

proc log_info {msg} {
    puts "[timestamp] $msg"
}

proc ensure_dirs {} {
    file mkdir $::BUILD_DIR
    file mkdir $::OUT_DIR
}

proc run_completed {run_name} {
    set run_obj [get_runs $run_name]
    set status [get_property STATUS $run_obj]
    set progress [get_property PROGRESS $run_obj]
    if {$progress ne "100%"} {
        error "$run_name did not finish: $status"
    }
    if {[string match -nocase "*fail*" $status] || [string match -nocase "*error*" $status]} {
        error "$run_name failed: $status"
    }
}

proc build_project {} {
    ensure_dirs
    log_info "Creating Vivado project for $::PART_NAME"
    create_project $::PROJ_NAME $::PROJ_DIR -part $::PART_NAME -force
    set_property target_language Verilog [current_project]
    set_property simulator_language Verilog [current_project]

    set verilog_files [glob -nocomplain [file join $::SRC_DIR "*.v"]]
    if {[llength $verilog_files] == 0} {
        error "No Verilog files found under $::SRC_DIR"
    }
    read_verilog $verilog_files
    read_xdc $::XDC_FILE
    set_property top $::TOP_NAME [current_fileset]
    update_compile_order -fileset sources_1

    log_info "Running synthesis"
    launch_runs synth_1 -jobs 4
    wait_on_run synth_1
    run_completed synth_1

    log_info "Running implementation through route_design"
    launch_runs impl_1 -to_step route_design -jobs 4
    wait_on_run impl_1
    run_completed impl_1

    open_run impl_1
    set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
    set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

    report_utilization -file [file join $::OUT_DIR "utilization.rpt"]
    report_timing_summary -file [file join $::OUT_DIR "timing_summary.rpt"]

    log_info "Writing bitstream: $::BIT_FILE"
    write_bitstream -force $::BIT_FILE
    validate_bitstream
    close_project
    log_info "Build complete"
}

proc validate_bitstream {} {
    if {![file exists $::BIT_FILE]} {
        error "Bitstream was not generated: $::BIT_FILE"
    }
    set size [file size $::BIT_FILE]
    if {$size < 1000000} {
        error "Bitstream looks too small ($size bytes): $::BIT_FILE"
    }
    log_info "Bitstream size: $size bytes"
}

proc ensure_bitstream {} {
    if {![file exists $::BIT_FILE]} {
        log_info "Bitstream not found; building first"
        build_project
    } else {
        validate_bitstream
    }
}

proc open_ego1_hw {} {
    open_hw_manager
    connect_hw_server
    if {[catch {set targets [get_hw_targets]} target_err]} {
        error "No hw_target found. Connect and power the EGo1 board, then check the USB/JTAG driver. Vivado said: $target_err"
    }
    if {[llength $targets] == 0} {
        error "No hw_target found. Connect and power the EGo1 board, then check the USB/JTAG driver."
    }
    open_hw_target

    set devices [get_hw_devices *xc7a35t*]
    if {[llength $devices] == 0} {
        set devices [get_hw_devices]
    }
    if {[llength $devices] == 0} {
        error "No FPGA device found. Check EGo1 power, JTAG cable, and drivers."
    }

    set dev [lindex $devices 0]
    current_hw_device $dev
    refresh_hw_device -update_hw_probes false $dev
    return $dev
}

proc print_device_properties {dev} {
    puts "Hardware device: $dev"
    set props [list_property $dev]
    foreach prop {PART PART_NAME DEVICE_ID IDCODE DNA_CHAIN SERIAL_NUMBER PROGRAM.HW_CFGMEM_TYPE} {
        if {[lsearch -exact $props $prop] >= 0} {
            puts "  $prop = [get_property $prop $dev]"
        }
    }
}

proc probe_board {} {
    log_info "Opening hardware target"
    if {[catch {
        set dev [open_ego1_hw]
        print_device_properties $dev
        if {![catch {set sysmons [get_hw_sysmons]} sysmon_err] && [llength $sysmons] > 0} {
            foreach sysmon $sysmons {
                catch {refresh_hw_sysmon $sysmon}
                if {![catch {report_hw_sysmon -return_string $sysmon} sysmon_report]} {
                    puts $sysmon_report
                } else {
                    puts "SysMon object: $sysmon"
                }
            }
        } else {
            puts "No hardware SysMon object reported by this Vivado version."
        }
    } err]} {
        catch {close_hw_manager}
        error $err
    }
    close_hw_manager
    log_info "Probe complete"
}

proc program_fpga {} {
    ensure_bitstream
    log_info "Programming FPGA through JTAG: $::BIT_FILE"
    if {[catch {
        set dev [open_ego1_hw]
        print_device_properties $dev
        set_property PROGRAM.FILE $::BIT_FILE $dev
        program_hw_devices $dev
        refresh_hw_device $dev
    } err]} {
        catch {close_hw_manager}
        error $err
    }
    close_hw_manager
    log_info "JTAG programming complete"
}

proc write_mcs {} {
    ensure_bitstream
    log_info "Writing SPI flash image: $::MCS_FILE"
    write_cfgmem -force -format mcs -interface spix4 -size 4 \
        -loadbit "up 0x0 $::BIT_FILE" \
        -file $::MCS_FILE
    log_info "MCS image complete"
}

proc program_flash {} {
    write_mcs
    log_info "Programming N25Q32 SPI flash through JTAG"
    if {[catch {
        set dev [open_ego1_hw]
        set parts [get_cfgmem_parts {n25q32-3.3v-spi-x1_x2_x4}]
        if {[llength $parts] == 0} {
            error "Vivado cannot find cfgmem part n25q32-3.3v-spi-x1_x2_x4"
        }
        create_hw_cfgmem -hw_device $dev [lindex $parts 0]
        set cfgmem [current_hw_cfgmem]
        set_property PROGRAM.ADDRESS_RANGE {use_file} $cfgmem
        set_property PROGRAM.FILES [list $::MCS_FILE] $cfgmem
        set_property PROGRAM.BLANK_CHECK 0 $cfgmem
        set_property PROGRAM.ERASE 1 $cfgmem
        set_property PROGRAM.CFG_PROGRAM 1 $cfgmem
        set_property PROGRAM.VERIFY 1 $cfgmem
        program_hw_cfgmem -hw_cfgmem $cfgmem
    } err]} {
        catch {close_hw_manager}
        error $err
    }
    close_hw_manager
    log_info "SPI flash programming complete"
}

proc clean_outputs {} {
    if {[file exists $::BUILD_DIR]} {
        file delete -force $::BUILD_DIR
    }
    if {[file exists $::OUT_DIR]} {
        file delete -force $::OUT_DIR
    }
    log_info "Removed build and output directories"
}

proc usage {} {
    puts "Usage:"
    puts "  vivado -mode batch -source scripts/ego1_vivado.tcl -tclargs build"
    puts "  vivado -mode batch -source scripts/ego1_vivado.tcl -tclargs program"
    puts "  vivado -mode batch -source scripts/ego1_vivado.tcl -tclargs all"
    puts "  vivado -mode batch -source scripts/ego1_vivado.tcl -tclargs probe"
    puts "  vivado -mode batch -source scripts/ego1_vivado.tcl -tclargs mcs"
    puts "  vivado -mode batch -source scripts/ego1_vivado.tcl -tclargs flash"
    puts "  vivado -mode batch -source scripts/ego1_vivado.tcl -tclargs clean"
}

set cmd "build"
if {[llength $argv] > 0} {
    set cmd [string tolower [lindex $argv 0]]
}

set exit_code 0
if {[catch {
    switch -- $cmd {
        build   { build_project }
        program { program_fpga }
        all     { build_project; program_fpga }
        probe   { probe_board }
        mcs     { write_mcs }
        flash   { program_flash }
        clean   { clean_outputs }
        help    { usage }
        default {
            usage
            error "Unknown command: $cmd"
        }
    }
} err]} {
    puts "ERROR: $err"
    set exit_code 1
}
exit $exit_code
