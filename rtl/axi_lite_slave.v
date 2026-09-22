module axi_lite_slave #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 4
)(
    input wire clk,
    input wire rst_n,

    // Write Address Channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire                          s_axi_awvalid,
    output reg                           s_axi_awready,

    // Write Data Channel
    input  wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
    input  wire                          s_axi_wvalid,
    output reg                           s_axi_wready,

    // Write Response Channel
    output reg [1:0]                     s_axi_bresp,
    output reg                           s_axi_bvalid,
    input  wire                          s_axi_bready,

    // Read Address Channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire                          s_axi_arvalid,
    output reg                           s_axi_arready,

    // Read Data Channel
    output reg [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output reg [1:0]                     s_axi_rresp,
    output reg                           s_axi_rvalid,
    input  wire                          s_axi_rready
);

    // Internal Registers (4 registers of 32-bit)
    reg [C_S_AXI_DATA_WIDTH-1:0] reg0, reg1, reg2, reg3;

    // Address decoding helper
    wire [1:0] axi_awaddr_index = s_axi_awaddr[3:2];
    wire [1:0] axi_araddr_index = s_axi_araddr[3:2];

    // Write State Machine & Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready <= 1'b0;
            s_axi_wready  <= 1'b0;
            s_axi_bvalid  <= 1'b0;
            s_axi_bresp   <= 2'b00;
            reg0 <= 0; reg1 <= 0; reg2 <= 0; reg3 <= 0;
        end else begin
            // Simple AW & W ready handshake
            s_axi_awready <= 1'b1;
            s_axi_wready  <= 1'b1;

            if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00; // OKAY response
                
                case (axi_awaddr_index)
                    2'b00: reg0 <= s_axi_wdata;
                    2'b01: reg1 <= s_axi_wdata;
                    2'b10: reg2 <= s_axi_wdata;
                    2'b11: reg3 <= s_axi_wdata;
                endcase
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

    // Read State Machine & Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_arready <= 1'b0;
            s_axi_rvalid  <= 1'b0;
            s_axi_rresp   <= 2'b00;
            s_axi_rdata   <= 0;
        end else begin
            s_axi_arready <= 1'b1;

            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rvalid <= 1'b1;
                s_axi_rresp  <= 2'b00; // OKAY response
                
                case (axi_araddr_index)
                    2'b00: s_axi_rdata <= reg0;
                    2'b01: s_axi_rdata <= reg1;
                    2'b10: s_axi_rdata <= reg2;
                    2'b11: s_axi_rdata <= reg3;
                endcase
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

endmodule
