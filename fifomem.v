module fifomem #(
    parameter WIDTH = 8,
    parameter ADDR  = 8
)(
    input                  wclk,
    input  [WIDTH-1:0]     wdata,
    input                  wclken,
    input  [ADDR-1:0]      waddr,
    input  [ADDR-1:0]      raddr,
    input                  wfull,
    output [WIDTH-1:0]     rdata
);

localparam DEPTH = 1 << ADDR;//for 2^(ADDR)

reg [WIDTH-1:0] mem [0:DEPTH-1];

always @(posedge wclk) begin
    if (wclken && !wfull) begin
        mem[waddr] <= wdata;
    end
end

assign rdata = mem[raddr];

endmodule
