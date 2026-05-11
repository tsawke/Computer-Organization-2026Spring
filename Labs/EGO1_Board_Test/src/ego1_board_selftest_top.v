`timescale 1ns / 1ps

module ego1_board_selftest_top (
    input  wire        clk_100m,
    input  wire        rst_btn,
    input  wire [4:0]  pb,
    input  wire [7:0]  sw,
    input  wire [7:0]  dip,

    output wire [15:0] led,

    output wire [7:0]  seg0,
    output wire [7:0]  seg1,
    output wire [7:0]  an,

    output wire [3:0]  vga_r,
    output wire [3:0]  vga_g,
    output wire [3:0]  vga_b,
    output wire        vga_hsync,
    output wire        vga_vsync,

    output wire        audio_pwm,
    output wire        audio_sd_n,

    input  wire        uart_rx,
    output wire        uart_tx,

    input  wire        bt_rx,
    output wire        bt_tx,

    input  wire        ps2_clk,
    input  wire        ps2_data,

    inout  wire [15:0] sram_dq,
    output wire [18:0] sram_addr,
    output wire        sram_oe_n,
    output wire        sram_ce_n,
    output wire        sram_we_n,
    output wire        sram_ub_n,
    output wire        sram_lb_n,

    output wire [7:0]  dac_data,
    output wire        dac_byte2,
    output wire        dac_cs_n,
    output wire        dac_wr1_n,
    output wire        dac_wr2_n,
    output wire        dac_xfer_n,

    input  wire        xadc_vauxp1,
    input  wire        xadc_vauxn1,

    inout  wire [31:0] exp_io
);
    localparam integer CLK_HZ = 100_000_000;

    wire soft_reset = pb[0];

    reg [31:0] tick = 32'd0;
    reg [26:0] second_count = 27'd0;
    reg        one_second = 1'b0;

    always @(posedge clk_100m) begin
        if (soft_reset) begin
            tick <= 32'd0;
            second_count <= 27'd0;
            one_second <= 1'b0;
        end else begin
            tick <= tick + 32'd1;
            if (second_count == CLK_HZ - 1) begin
                second_count <= 27'd0;
                one_second <= 1'b1;
            end else begin
                second_count <= second_count + 27'd1;
                one_second <= 1'b0;
            end
        end
    end

    wire [15:0] led_gpio    = {dip, sw};
    wire [15:0] led_walk    = 16'h0001 << tick[27:24];
    wire [15:0] led_buttons;
    wire [15:0] led_status;

    wire [7:0] uart_rx_byte;
    wire       uart_rx_valid;
    wire       uart_tx_busy;
    reg  [7:0] uart_tx_data = 8'h00;
    reg        uart_tx_start = 1'b0;
    reg  [7:0] uart_last_byte = 8'h00;
    reg        uart_echo_pending = 1'b0;
    reg  [7:0] uart_echo_byte = 8'h00;

    uart_rx_simple #(
        .CLKS_PER_BIT(868)
    ) u_uart_rx (
        .clk(clk_100m),
        .reset(soft_reset),
        .rx(uart_rx),
        .data(uart_rx_byte),
        .valid(uart_rx_valid)
    );

    uart_tx_simple #(
        .CLKS_PER_BIT(868)
    ) u_uart_tx (
        .clk(clk_100m),
        .reset(soft_reset),
        .data(uart_tx_data),
        .start(uart_tx_start),
        .tx(uart_tx),
        .busy(uart_tx_busy)
    );

    wire [7:0] bt_rx_byte;
    wire       bt_rx_valid;
    wire       bt_tx_busy;
    reg  [7:0] bt_tx_data = 8'h00;
    reg        bt_tx_start = 1'b0;
    reg  [7:0] bt_last_byte = 8'h00;
    reg        bt_echo_pending = 1'b0;
    reg  [7:0] bt_echo_byte = 8'h00;

    uart_rx_simple #(
        .CLKS_PER_BIT(10417)
    ) u_bt_rx (
        .clk(clk_100m),
        .reset(soft_reset),
        .rx(bt_rx),
        .data(bt_rx_byte),
        .valid(bt_rx_valid)
    );

    uart_tx_simple #(
        .CLKS_PER_BIT(10417)
    ) u_bt_tx (
        .clk(clk_100m),
        .reset(soft_reset),
        .data(bt_tx_data),
        .start(bt_tx_start),
        .tx(bt_tx),
        .busy(bt_tx_busy)
    );

    wire [7:0] ps2_scan_code;
    wire       ps2_valid;
    reg  [7:0] ps2_last_byte = 8'h00;
    reg        ps2_seen = 1'b0;

    ps2_rx_simple u_ps2_rx (
        .clk(clk_100m),
        .reset(soft_reset),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .data(ps2_scan_code),
        .valid(ps2_valid)
    );

    wire        sram_done;
    wire        sram_pass;
    wire        sram_fail;
    wire [18:0] sram_fail_addr;
    wire [15:0] sram_expected;
    wire [15:0] sram_observed;
    wire [15:0] sram_dq_out;
    wire        sram_dq_oe;
    reg         sram_done_d = 1'b0;

    assign sram_dq = sram_dq_oe ? sram_dq_out : 16'hzzzz;

    sram_selftest #(
        .TEST_WORDS(19'd4096)
    ) u_sram_selftest (
        .clk(clk_100m),
        .reset(soft_reset),
        .start(pb[1]),
        .dq_i(sram_dq),
        .dq_o(sram_dq_out),
        .dq_oe(sram_dq_oe),
        .addr(sram_addr),
        .ce_n(sram_ce_n),
        .oe_n(sram_oe_n),
        .we_n(sram_we_n),
        .ub_n(sram_ub_n),
        .lb_n(sram_lb_n),
        .done(sram_done),
        .pass(sram_pass),
        .fail(sram_fail),
        .fail_addr(sram_fail_addr),
        .expected(sram_expected),
        .observed(sram_observed)
    );

    vga_test_pattern u_vga (
        .clk(clk_100m),
        .reset(soft_reset),
        .sw(sw),
        .dip(dip),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync)
    );

    audio_pwm_tone u_audio (
        .clk(clk_100m),
        .reset(soft_reset),
        .enable(dip[0]),
        .pitch(sw[3:0]),
        .audio_pwm(audio_pwm),
        .audio_sd_n(audio_sd_n)
    );

    dac_sawtooth u_dac (
        .clk(clk_100m),
        .reset(soft_reset),
        .data(dac_data),
        .byte2(dac_byte2),
        .cs_n(dac_cs_n),
        .wr1_n(dac_wr1_n),
        .wr2_n(dac_wr2_n),
        .xfer_n(dac_xfer_n)
    );

    wire [11:0] xadc_aux1_raw;
    wire [11:0] xadc_temp_raw;

    xadc_monitor u_xadc (
        .clk(clk_100m),
        .reset(soft_reset),
        .vauxp1(xadc_vauxp1),
        .vauxn1(xadc_vauxn1),
        .aux1_raw(xadc_aux1_raw),
        .temp_raw(xadc_temp_raw)
    );

    wire [31:0] exp_pattern = {tick[27:20], tick[25:18], sw, dip};
    wire        exp_drive_enable = dip[7] && (sw[7:6] == 2'b11);
    assign exp_io = exp_drive_enable ? exp_pattern : 32'hzzzz_zzzz;

    assign led_buttons = {2'b00, rst_btn, pb, uart_rx_valid, bt_rx_valid, ps2_valid, sram_done, sram_pass, sram_fail, 2'b00};
    assign led_status  = {xadc_aux1_raw[11:4], sram_done, sram_pass, sram_fail, ps2_seen, uart_last_byte[3:0]};
    assign led = (sw[7:6] == 2'b00) ? led_gpio :
                 (sw[7:6] == 2'b01) ? led_walk :
                 (sw[7:6] == 2'b10) ? led_buttons :
                                       led_status;

    reg [31:0] seven_value = 32'h0000_0001;
    reg [7:0]  seven_dots = 8'h00;

    always @(*) begin
        case (sw[5:4])
            2'b00: seven_value = {dip, sw, 2'b00, rst_btn, pb, 8'h01};
            2'b01: seven_value = {3'b000, sram_done, sram_pass, sram_fail, sram_fail_addr[17:0], 8'h02};
            2'b10: seven_value = {uart_last_byte, bt_last_byte, ps2_last_byte, 8'h03};
            default: seven_value = {xadc_temp_raw, xadc_aux1_raw, 8'h04};
        endcase
        seven_dots = {sram_fail, sram_pass, ps2_seen, uart_echo_pending, bt_echo_pending, dip[2:0]};
    end

    sevenseg8 u_sevenseg (
        .clk(clk_100m),
        .reset(soft_reset),
        .value(seven_value),
        .dots(seven_dots),
        .seg0(seg0),
        .seg1(seg1),
        .an(an)
    );

    reg [1:0] msg_id = 2'd0;
    reg [6:0] msg_index = 7'd0;
    reg       msg_active = 1'b1;
    wire [7:0] msg_current_char = message_char(msg_id, msg_index);

    always @(posedge clk_100m) begin
        uart_tx_start <= 1'b0;
        bt_tx_start <= 1'b0;
        sram_done_d <= sram_done;

        if (soft_reset) begin
            uart_last_byte <= 8'h00;
            bt_last_byte <= 8'h00;
            ps2_last_byte <= 8'h00;
            ps2_seen <= 1'b0;
            uart_echo_pending <= 1'b0;
            bt_echo_pending <= 1'b0;
            msg_id <= 2'd0;
            msg_index <= 7'd0;
            msg_active <= 1'b1;
        end else begin
            if (uart_rx_valid) begin
                uart_last_byte <= uart_rx_byte;
                uart_echo_byte <= uart_rx_byte;
                uart_echo_pending <= 1'b1;
            end

            if (bt_rx_valid) begin
                bt_last_byte <= bt_rx_byte;
                bt_echo_byte <= bt_rx_byte;
                bt_echo_pending <= 1'b1;
            end

            if (ps2_valid) begin
                ps2_last_byte <= ps2_scan_code;
                ps2_seen <= 1'b1;
            end

            if (!msg_active) begin
                if (sram_done && !sram_done_d) begin
                    msg_id <= sram_pass ? 2'd1 : 2'd2;
                    msg_index <= 7'd0;
                    msg_active <= 1'b1;
                end else if (one_second) begin
                    msg_id <= 2'd3;
                    msg_index <= 7'd0;
                    msg_active <= 1'b1;
                end else if (uart_echo_pending && !uart_tx_busy) begin
                    uart_tx_data <= uart_echo_byte;
                    uart_tx_start <= 1'b1;
                    uart_echo_pending <= 1'b0;
                end
            end else if (!uart_tx_busy) begin
                if (msg_current_char == 8'h00) begin
                    msg_active <= 1'b0;
                end else begin
                    uart_tx_data <= msg_current_char;
                    uart_tx_start <= 1'b1;
                    msg_index <= msg_index + 7'd1;
                end
            end

            if (bt_echo_pending && !bt_tx_busy) begin
                bt_tx_data <= bt_echo_byte;
                bt_tx_start <= 1'b1;
                bt_echo_pending <= 1'b0;
            end
        end
    end

    function [7:0] message_char;
        input [1:0] id;
        input [6:0] idx;
        begin
            case (id)
                2'd0: begin
                    case (idx)
                        7'd0:  message_char = "E";
                        7'd1:  message_char = "G";
                        7'd2:  message_char = "O";
                        7'd3:  message_char = "1";
                        7'd4:  message_char = " ";
                        7'd5:  message_char = "S";
                        7'd6:  message_char = "E";
                        7'd7:  message_char = "L";
                        7'd8:  message_char = "F";
                        7'd9:  message_char = "T";
                        7'd10: message_char = "E";
                        7'd11: message_char = "S";
                        7'd12: message_char = "T";
                        7'd13: message_char = " ";
                        7'd14: message_char = "R";
                        7'd15: message_char = "E";
                        7'd16: message_char = "A";
                        7'd17: message_char = "D";
                        7'd18: message_char = "Y";
                        7'd19: message_char = 8'h0d;
                        7'd20: message_char = 8'h0a;
                        default: message_char = 8'h00;
                    endcase
                end
                2'd1: begin
                    case (idx)
                        7'd0:  message_char = "S";
                        7'd1:  message_char = "R";
                        7'd2:  message_char = "A";
                        7'd3:  message_char = "M";
                        7'd4:  message_char = " ";
                        7'd5:  message_char = "P";
                        7'd6:  message_char = "A";
                        7'd7:  message_char = "S";
                        7'd8:  message_char = "S";
                        7'd9:  message_char = 8'h0d;
                        7'd10: message_char = 8'h0a;
                        default: message_char = 8'h00;
                    endcase
                end
                2'd2: begin
                    case (idx)
                        7'd0:  message_char = "S";
                        7'd1:  message_char = "R";
                        7'd2:  message_char = "A";
                        7'd3:  message_char = "M";
                        7'd4:  message_char = " ";
                        7'd5:  message_char = "F";
                        7'd6:  message_char = "A";
                        7'd7:  message_char = "I";
                        7'd8:  message_char = "L";
                        7'd9:  message_char = 8'h0d;
                        7'd10: message_char = 8'h0a;
                        default: message_char = 8'h00;
                    endcase
                end
                default: begin
                    case (idx)
                        7'd0:  message_char = "A";
                        7'd1:  message_char = "L";
                        7'd2:  message_char = "I";
                        7'd3:  message_char = "V";
                        7'd4:  message_char = "E";
                        7'd5:  message_char = 8'h0d;
                        7'd6:  message_char = 8'h0a;
                        default: message_char = 8'h00;
                    endcase
                end
            endcase
        end
    endfunction
endmodule

module uart_rx_simple #(
    parameter integer CLKS_PER_BIT = 868
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       rx,
    output reg [7:0]  data,
    output reg        valid
);
    localparam [1:0] S_IDLE  = 2'd0;
    localparam [1:0] S_START = 2'd1;
    localparam [1:0] S_DATA  = 2'd2;
    localparam [1:0] S_STOP  = 2'd3;

    reg [1:0] state = S_IDLE;
    reg [15:0] clk_count = 16'd0;
    reg [2:0] bit_index = 3'd0;
    reg [7:0] rx_shift = 8'h00;
    reg [2:0] rx_sync = 3'b111;

    always @(posedge clk) begin
        rx_sync <= {rx_sync[1:0], rx};
        valid <= 1'b0;

        if (reset) begin
            state <= S_IDLE;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            rx_shift <= 8'h00;
            data <= 8'h00;
        end else begin
            case (state)
                S_IDLE: begin
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (!rx_sync[2]) begin
                        state <= S_START;
                    end
                end
                S_START: begin
                    if (clk_count == (CLKS_PER_BIT / 2)) begin
                        if (!rx_sync[2]) begin
                            clk_count <= 16'd0;
                            state <= S_DATA;
                        end else begin
                            state <= S_IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 16'd1;
                    end
                end
                S_DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        rx_shift[bit_index] <= rx_sync[2];
                        if (bit_index == 3'd7) begin
                            bit_index <= 3'd0;
                            state <= S_STOP;
                        end else begin
                            bit_index <= bit_index + 3'd1;
                        end
                    end else begin
                        clk_count <= clk_count + 16'd1;
                    end
                end
                S_STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        data <= rx_shift;
                        valid <= 1'b1;
                        clk_count <= 16'd0;
                        state <= S_IDLE;
                    end else begin
                        clk_count <= clk_count + 16'd1;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule

module uart_tx_simple #(
    parameter integer CLKS_PER_BIT = 868
) (
    input  wire      clk,
    input  wire      reset,
    input  wire [7:0] data,
    input  wire      start,
    output reg       tx,
    output reg       busy
);
    localparam [1:0] S_IDLE  = 2'd0;
    localparam [1:0] S_START = 2'd1;
    localparam [1:0] S_DATA  = 2'd2;
    localparam [1:0] S_STOP  = 2'd3;

    reg [1:0] state = S_IDLE;
    reg [15:0] clk_count = 16'd0;
    reg [2:0] bit_index = 3'd0;
    reg [7:0] tx_shift = 8'h00;

    initial begin
        tx = 1'b1;
        busy = 1'b0;
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= S_IDLE;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            tx_shift <= 8'h00;
            tx <= 1'b1;
            busy <= 1'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    tx <= 1'b1;
                    busy <= 1'b0;
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (start) begin
                        tx_shift <= data;
                        busy <= 1'b1;
                        state <= S_START;
                    end
                end
                S_START: begin
                    tx <= 1'b0;
                    busy <= 1'b1;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        state <= S_DATA;
                    end else begin
                        clk_count <= clk_count + 16'd1;
                    end
                end
                S_DATA: begin
                    tx <= tx_shift[bit_index];
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        if (bit_index == 3'd7) begin
                            bit_index <= 3'd0;
                            state <= S_STOP;
                        end else begin
                            bit_index <= bit_index + 3'd1;
                        end
                    end else begin
                        clk_count <= clk_count + 16'd1;
                    end
                end
                S_STOP: begin
                    tx <= 1'b1;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        state <= S_IDLE;
                    end else begin
                        clk_count <= clk_count + 16'd1;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule

module ps2_rx_simple (
    input  wire      clk,
    input  wire      reset,
    input  wire      ps2_clk,
    input  wire      ps2_data,
    output reg [7:0] data,
    output reg       valid
);
    reg [2:0] clk_sync = 3'b111;
    reg [2:0] data_sync = 3'b111;
    reg [3:0] bit_count = 4'd0;
    reg [7:0] shift = 8'h00;

    wire clk_fall = (clk_sync[2:1] == 2'b10);

    always @(posedge clk) begin
        clk_sync <= {clk_sync[1:0], ps2_clk};
        data_sync <= {data_sync[1:0], ps2_data};
        valid <= 1'b0;

        if (reset) begin
            bit_count <= 4'd0;
            shift <= 8'h00;
            data <= 8'h00;
        end else if (clk_fall) begin
            if (bit_count == 4'd0) begin
                bit_count <= 4'd1;
            end else if (bit_count <= 4'd8) begin
                shift <= {data_sync[2], shift[7:1]};
                bit_count <= bit_count + 4'd1;
            end else if (bit_count == 4'd9) begin
                bit_count <= 4'd10;
            end else begin
                data <= shift;
                valid <= 1'b1;
                bit_count <= 4'd0;
            end
        end
    end
endmodule

module sram_selftest #(
    parameter [18:0] TEST_WORDS = 19'd4096
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire [15:0] dq_i,
    output reg  [15:0] dq_o,
    output reg         dq_oe,
    output reg  [18:0] addr,
    output reg         ce_n,
    output reg         oe_n,
    output reg         we_n,
    output reg         ub_n,
    output reg         lb_n,
    output reg         done,
    output reg         pass,
    output reg         fail,
    output reg  [18:0] fail_addr,
    output reg  [15:0] expected,
    output reg  [15:0] observed
);
    localparam [2:0] S_IDLE        = 3'd0;
    localparam [2:0] S_WRITE_SETUP = 3'd1;
    localparam [2:0] S_WRITE_HOLD  = 3'd2;
    localparam [2:0] S_READ_SETUP  = 3'd3;
    localparam [2:0] S_READ_WAIT   = 3'd4;
    localparam [2:0] S_READ_CHECK  = 3'd5;
    localparam [2:0] S_DONE        = 3'd6;

    localparam [18:0] LAST_ADDR = TEST_WORDS - 19'd1;

    reg [2:0] state = S_IDLE;
    reg [18:0] index = 19'd0;
    reg [3:0] wait_count = 4'd0;
    reg start_d = 1'b0;
    reg auto_start = 1'b1;

    function [15:0] pattern;
        input [18:0] a;
        begin
            pattern = {a[7:0], a[15:8]} ^ 16'hA55A;
        end
    endfunction

    task disable_sram;
        begin
            ce_n <= 1'b1;
            oe_n <= 1'b1;
            we_n <= 1'b1;
            ub_n <= 1'b1;
            lb_n <= 1'b1;
            dq_oe <= 1'b0;
        end
    endtask

    always @(posedge clk) begin
        start_d <= start;

        if (reset) begin
            state <= S_IDLE;
            index <= 19'd0;
            wait_count <= 4'd0;
            auto_start <= 1'b1;
            done <= 1'b0;
            pass <= 1'b0;
            fail <= 1'b0;
            fail_addr <= 19'd0;
            expected <= 16'h0000;
            observed <= 16'h0000;
            addr <= 19'd0;
            dq_o <= 16'h0000;
            disable_sram();
        end else begin
            case (state)
                S_IDLE: begin
                    disable_sram();
                    if (auto_start || (start && !start_d)) begin
                        auto_start <= 1'b0;
                        done <= 1'b0;
                        pass <= 1'b0;
                        fail <= 1'b0;
                        index <= 19'd0;
                        state <= S_WRITE_SETUP;
                    end
                end
                S_WRITE_SETUP: begin
                    addr <= index;
                    dq_o <= pattern(index);
                    dq_oe <= 1'b1;
                    ce_n <= 1'b0;
                    oe_n <= 1'b1;
                    we_n <= 1'b0;
                    ub_n <= 1'b0;
                    lb_n <= 1'b0;
                    wait_count <= 4'd0;
                    state <= S_WRITE_HOLD;
                end
                S_WRITE_HOLD: begin
                    if (wait_count == 4'd3) begin
                        we_n <= 1'b1;
                        dq_oe <= 1'b0;
                        if (index == LAST_ADDR) begin
                            index <= 19'd0;
                            state <= S_READ_SETUP;
                        end else begin
                            index <= index + 19'd1;
                            state <= S_WRITE_SETUP;
                        end
                    end else begin
                        wait_count <= wait_count + 4'd1;
                    end
                end
                S_READ_SETUP: begin
                    addr <= index;
                    dq_oe <= 1'b0;
                    ce_n <= 1'b0;
                    oe_n <= 1'b0;
                    we_n <= 1'b1;
                    ub_n <= 1'b0;
                    lb_n <= 1'b0;
                    wait_count <= 4'd0;
                    state <= S_READ_WAIT;
                end
                S_READ_WAIT: begin
                    if (wait_count == 4'd4) begin
                        state <= S_READ_CHECK;
                    end else begin
                        wait_count <= wait_count + 4'd1;
                    end
                end
                S_READ_CHECK: begin
                    if (dq_i != pattern(index)) begin
                        fail <= 1'b1;
                        pass <= 1'b0;
                        done <= 1'b1;
                        fail_addr <= index;
                        expected <= pattern(index);
                        observed <= dq_i;
                        disable_sram();
                        state <= S_DONE;
                    end else if (index == LAST_ADDR) begin
                        fail <= 1'b0;
                        pass <= 1'b1;
                        done <= 1'b1;
                        disable_sram();
                        state <= S_DONE;
                    end else begin
                        index <= index + 19'd1;
                        state <= S_READ_SETUP;
                    end
                end
                S_DONE: begin
                    disable_sram();
                    if (start && !start_d) begin
                        done <= 1'b0;
                        pass <= 1'b0;
                        fail <= 1'b0;
                        index <= 19'd0;
                        state <= S_WRITE_SETUP;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule

module sevenseg8 (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] value,
    input  wire [7:0]  dots,
    output reg  [7:0]  seg0,
    output reg  [7:0]  seg1,
    output reg  [7:0]  an
);
    reg [15:0] refresh = 16'd0;
    wire [2:0] idx = refresh[15:13];
    reg [3:0] digit;

    always @(posedge clk) begin
        if (reset) begin
            refresh <= 16'd0;
        end else begin
            refresh <= refresh + 16'd1;
        end
    end

    always @(*) begin
        case (idx)
            3'd0: digit = value[3:0];
            3'd1: digit = value[7:4];
            3'd2: digit = value[11:8];
            3'd3: digit = value[15:12];
            3'd4: digit = value[19:16];
            3'd5: digit = value[23:20];
            3'd6: digit = value[27:24];
            default: digit = value[31:28];
        endcase

        an = 8'b0000_0001 << idx;
        seg0 = 8'h00;
        seg1 = 8'h00;
        if (idx < 3'd4) begin
            seg0 = seg_hex(digit, dots[idx]);
        end else begin
            seg1 = seg_hex(digit, dots[idx]);
        end
    end

    function [7:0] seg_hex;
        input [3:0] h;
        input dot;
        reg [6:0] s;
        begin
            case (h)
                4'h0: s = 7'b0111111;
                4'h1: s = 7'b0000110;
                4'h2: s = 7'b1011011;
                4'h3: s = 7'b1001111;
                4'h4: s = 7'b1100110;
                4'h5: s = 7'b1101101;
                4'h6: s = 7'b1111101;
                4'h7: s = 7'b0000111;
                4'h8: s = 7'b1111111;
                4'h9: s = 7'b1101111;
                4'ha: s = 7'b1110111;
                4'hb: s = 7'b1111100;
                4'hc: s = 7'b0111001;
                4'hd: s = 7'b1011110;
                4'he: s = 7'b1111001;
                default: s = 7'b1110001;
            endcase
            seg_hex = {dot, s};
        end
    endfunction
endmodule

module vga_test_pattern (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] sw,
    input  wire [7:0] dip,
    output reg  [3:0] vga_r,
    output reg  [3:0] vga_g,
    output reg  [3:0] vga_b,
    output wire       vga_hsync,
    output wire       vga_vsync
);
    reg [1:0] div = 2'd0;
    reg [9:0] h = 10'd0;
    reg [9:0] v = 10'd0;
    reg [3:0] next_r;
    reg [3:0] next_g;
    reg [3:0] next_b;

    wire active = (h < 10'd640) && (v < 10'd480);
    assign vga_hsync = ~((h >= 10'd656) && (h < 10'd752));
    assign vga_vsync = ~((v >= 10'd490) && (v < 10'd492));

    always @(posedge clk) begin
        if (reset) begin
            div <= 2'd0;
            h <= 10'd0;
            v <= 10'd0;
            vga_r <= 4'h0;
            vga_g <= 4'h0;
            vga_b <= 4'h0;
        end else if (div == 2'd3) begin
            div <= 2'd0;
            if (h == 10'd799) begin
                h <= 10'd0;
                if (v == 10'd524) begin
                    v <= 10'd0;
                end else begin
                    v <= v + 10'd1;
                end
            end else begin
                h <= h + 10'd1;
            end

            if (!active) begin
                vga_r <= 4'h0;
                vga_g <= 4'h0;
                vga_b <= 4'h0;
            end else begin
                case (h[9:7])
                    3'd0: begin next_r = 4'hf; next_g = 4'h0; next_b = 4'h0; end
                    3'd1: begin next_r = 4'h0; next_g = 4'hf; next_b = 4'h0; end
                    3'd2: begin next_r = 4'h0; next_g = 4'h0; next_b = 4'hf; end
                    3'd3: begin next_r = 4'hf; next_g = 4'hf; next_b = 4'h0; end
                    3'd4: begin next_r = 4'h0; next_g = 4'hf; next_b = 4'hf; end
                    default: begin next_r = {4{sw[0]}}; next_g = {4{dip[0]}}; next_b = 4'hf; end
                endcase
                if (h[5] ^ v[5]) begin
                    next_r = next_r ^ {4{sw[1]}};
                    next_g = next_g ^ {4{sw[2]}};
                    next_b = next_b ^ {4{sw[3]}};
                end
                vga_r <= next_r;
                vga_g <= next_g;
                vga_b <= next_b;
            end
        end else begin
            div <= div + 2'd1;
        end
    end
endmodule

module audio_pwm_tone (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    input  wire [3:0] pitch,
    output wire       audio_pwm,
    output wire       audio_sd_n
);
    reg [15:0] pwm_counter = 16'd0;
    reg [31:0] phase = 32'd0;

    wire [31:0] step = 32'd180000 + {20'd0, pitch, 8'd0};
    wire [15:0] duty = phase[31] ? 16'd49152 : 16'd16384;

    always @(posedge clk) begin
        if (reset) begin
            pwm_counter <= 16'd0;
            phase <= 32'd0;
        end else begin
            pwm_counter <= pwm_counter + 16'd1;
            phase <= phase + step;
        end
    end

    assign audio_pwm = enable ? (pwm_counter < duty) : 1'b0;
    assign audio_sd_n = 1'b1;
endmodule

module dac_sawtooth (
    input  wire      clk,
    input  wire      reset,
    output reg [7:0] data,
    output wire      byte2,
    output wire      cs_n,
    output wire      wr1_n,
    output wire      wr2_n,
    output wire      xfer_n
);
    reg [15:0] div = 16'd0;

    always @(posedge clk) begin
        if (reset) begin
            div <= 16'd0;
            data <= 8'h00;
        end else begin
            div <= div + 16'd1;
            if (div == 16'd0) begin
                data <= data + 8'd1;
            end
        end
    end

    assign byte2 = 1'b1;
    assign cs_n = 1'b0;
    assign wr1_n = 1'b0;
    assign wr2_n = 1'b0;
    assign xfer_n = 1'b0;
endmodule

module xadc_monitor (
    input  wire       clk,
    input  wire       reset,
    input  wire       vauxp1,
    input  wire       vauxn1,
    output reg [11:0] aux1_raw,
    output reg [11:0] temp_raw
);
    wire [15:0] do_out;
    wire        drdy;
    wire        eoc;
    wire [4:0]  channel;
    wire [15:0] vauxp_bus = {14'd0, vauxp1, 1'b0};
    wire [15:0] vauxn_bus = {14'd0, vauxn1, 1'b0};

    reg [6:0] daddr = 7'h11;
    reg [6:0] daddr_pending = 7'h11;

    always @(posedge clk) begin
        if (reset) begin
            daddr <= 7'h11;
            daddr_pending <= 7'h11;
            aux1_raw <= 12'h000;
            temp_raw <= 12'h000;
        end else begin
            if (eoc) begin
                daddr_pending <= daddr;
                daddr <= (daddr == 7'h11) ? 7'h00 : 7'h11;
            end

            if (drdy) begin
                if (daddr_pending == 7'h11) begin
                    aux1_raw <= do_out[15:4];
                end else begin
                    temp_raw <= do_out[15:4];
                end
            end
        end
    end

    XADC #(
        .INIT_40(16'h3000),
        .INIT_41(16'h21AF),
        .INIT_42(16'h0400),
        .INIT_48(16'h0001),
        .INIT_49(16'h0002),
        .SIM_DEVICE("7SERIES")
    ) xadc_inst (
        .ALM(),
        .BUSY(),
        .CHANNEL(channel),
        .DO(do_out),
        .DRDY(drdy),
        .EOC(eoc),
        .EOS(),
        .JTAGBUSY(),
        .JTAGLOCKED(),
        .JTAGMODIFIED(),
        .OT(),
        .MUXADDR(),
        .CONVST(1'b0),
        .CONVSTCLK(1'b0),
        .DADDR(daddr),
        .DCLK(clk),
        .DEN(eoc),
        .DI(16'h0000),
        .DWE(1'b0),
        .RESET(reset),
        .VAUXN(vauxn_bus),
        .VAUXP(vauxp_bus),
        .VN(1'b0),
        .VP(1'b0)
    );
endmodule
