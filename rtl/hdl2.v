
module spi_master #(
    parameter DATA_WIDTH = 8                     
)(
    input wire clk,                             
    input wire rst_n,                         
    input wire cpol,                           
    input wire cpha,                           
    input wire start,                       
    input wire [DATA_WIDTH-1:0] tx_data,         
    output reg [DATA_WIDTH-1:0] rx_data,     
    output reg sclk,                          
    output reg mosi,                         
    input wire miso,                         
    output reg ss_n,                             
    output reg busy                              
);
    parameter IDLE  = 1'b0,
              TRANS = 1'b1;
    reg state;
    reg [4:0] bit_counter;                       
    reg [DATA_WIDTH-1:0] tx_shift_reg;
    reg [DATA_WIDTH-1:0] rx_shift_reg;
    reg [3:0] clk_div;                           
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            sclk <= 1'b0;
            mosi <= 1'b0;
            ss_n <= 1'b1;
            busy <= 1'b0;
            rx_data <= {DATA_WIDTH{1'b0}};
            bit_counter <= 5'd0;
            tx_shift_reg <= {DATA_WIDTH{1'b0}};
            rx_shift_reg <= {DATA_WIDTH{1'b0}};
            clk_div <= 4'd0;
        end else begin
            case (state)
                IDLE: begin
                    sclk <= cpol;               
                    ss_n <= 1'b1;
                    busy <= 1'b0;
                    clk_div <= 4'd0;
                    if (start) begin
                        tx_shift_reg <= tx_data;
                        ss_n <= 1'b0;           
                        busy <= 1'b1;
                        bit_counter <= DATA_WIDTH;
                        state <= TRANS;
                        mosi <= tx_data[DATA_WIDTH-1];
                    end
                end
                TRANS: begin
                    clk_div <= clk_div + 1'b1;
                    if (clk_div == 4'd3) begin
                        clk_div <= 4'd0;
                        sclk <= ~sclk;
                        if (sclk == cpol) begin
                            if (cpha == 1'b0) begin
                                rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], miso};
                            end else begin
                                mosi <= tx_shift_reg[DATA_WIDTH-1];
                                tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0};
                            end
                        end else begin
                            if (cpha == 1'b0) begin                 
                                mosi <= tx_shift_reg[DATA_WIDTH-1];
                                tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0};
                                bit_counter <= bit_counter - 1'b1;
                                if (bit_counter == 5'd1) begin
                                    state <= IDLE;
                                    ss_n <= 1'b1;
                                    rx_data <= {rx_shift_reg[DATA_WIDTH-2:0], miso};
                                    busy <= 1'b0;
                                end
                            end else begin
                                rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], miso};
                                bit_counter <= bit_counter - 1'b1;
                                if (bit_counter == 5'd1) begin
                                    state <= IDLE;
                                    ss_n <= 1'b1;
                                    rx_data <= {rx_shift_reg[DATA_WIDTH-2:0], miso};
                                    busy <= 1'b0;
                                end
                            end
                        end
                    end
                end
            endcase
        end
    end
endmodule