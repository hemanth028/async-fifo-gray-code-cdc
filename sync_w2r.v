module sync_w2r #(parameter ADDR= 4)
(
    input  rclk, rrst_n,
    input [ADDR:0] wptr,
    output reg [ADDR:0] rq2_wptr
);
    reg [ADDR:0] rq1_wptr;
 
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) begin
			rq2_wptr<=0;
			rq1_wptr<= 0;
		end
        else begin
			rq1_wptr<=wptr;
			rq2_wptr<=rq1_wptr;
		end
endmodule
