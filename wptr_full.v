module wptr_full #(parameter ADDR= 4)
(
    output reg wfull,
    output     [ADDR-1:0] waddr,
    output reg [ADDR:0] wptr,
    input      [ADDR:0] wq2_rptr,
	input winc, wclk, wrst_n
);
    reg  [ADDR:0] wbin;
    wire [ADDR:0] wgraynext, wbinnext;
 
    assign waddr     = wbin[ADDR-1:0];
    assign wbinnext  = wbin + (winc & ~wfull);
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;              
	wire wfull_val = (wgraynext=={~wq2_rptr[ADDR:ADDR-1], wq2_rptr[ADDR-2:0]});
 
    always @(posedge wclk or negedge wrst_n)begin
        if (!wrst_n)begin
			wbin<=0;
			wptr<= 0;
		end
        else begin
			wbin<=wbinnext;
			wptr<=wgraynext;
		end
 	end
    always @(posedge wclk or negedge wrst_n)begin
        if (!wrst_n) wfull <= 1'b0;
        else         wfull <= wfull_val;
	end
endmodule
