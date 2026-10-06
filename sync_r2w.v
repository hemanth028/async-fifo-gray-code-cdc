module sync_r2w#(parameter ADDR=4)
				(
				input wclk,
				input wrst_n,
				input [ADDR:0] rptr,
				output reg [ADDR:0] wq2_rptr
				);
reg [ADDR:0]wq1_rptr;

always@(posedge wclk or negedge wrst_n)begin
	if(!wrst_n)begin
		wq1_rptr<=0;
		wq2_rptr<=0;
	end
	else begin
		wq1_rptr<=rptr;
		wq2_rptr<=wq1_rptr;
	end
end
endmodule
