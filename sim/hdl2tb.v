`timescale 1ns / 1ps
module tb_spi_master();

    parameter WIDTH = 8;
    reg clk;
    reg rst_n;
    reg cpol;
    reg cpha;
    reg start;
    reg [WIDTH-1:0] tx_data;
    wire [WIDTH-1:0] rx_data;
    wire sclk;
    wire mosi;
    wire miso;
    wire ss_n;
    wire busy;
    spi_master #(.DATA_WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .cpol(cpol),
        .cpha(cpha),
        .start(start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n),
        .busy(busy)
    );

    assign miso = (!ss_n) ? mosi : 1'b0;

    // 100 MHz System Clock Generation (10ns period)
    always #5 clk = ~clk;

    initial begin
    
        clk = 0;
        rst_n = 0;
        cpol = 0;
        cpha = 0;
        start = 0;
        tx_data = {WIDTH{1'b0}};
        
        #25;
        rst_n = 1;
        #20;
        // Test Case 1: SPI Mode 0 (CPOL=0, CPHA=0)
        cpol = 1'b0;
        cpha = 1'b0;
        @(posedge clk);
        tx_data = 8'h3C;  
        start = 1;
        @(posedge clk);
        start = 0;
        @(negedge busy);
        #50;
        // Test Case 2: SPI Mode 1 (CPOL=0, CPHA=1)
        cpol = 1'b0;
        cpha = 1'b1;
        @(posedge clk);
        tx_data = 8'h55;  
        start = 1;
        @(posedge clk);
        start = 0;
        @(negedge busy);
        #50;
        // Test Case 3: SPI Mode 2 (CPOL=1, CPHA=0)
        cpol = 1'b1;
        cpha = 1'b0;
        @(posedge clk);
        @(posedge clk);
        tx_data = 8'hAB; 
        start = 1;
        @(posedge clk);
        start = 0;
        @(negedge busy);
        #50;
        // Test Case 4: SPI Mode 3 (CPOL=1, CPHA=1)
        cpol = 1'b1;
        cpha = 1'b1;
        @(posedge clk);
        tx_data = 8'hA5;  
        start = 1;
        @(posedge clk);
        start = 0;
        @(negedge busy);
        #100;
        $finish;
    end

endmodule