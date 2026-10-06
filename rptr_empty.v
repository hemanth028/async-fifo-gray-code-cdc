module rptr_empty #(parameter ADDR= 4)
(
    output reg              rempty,
    output     [ADDR-1:0] 	raddr,
    output reg [ADDR:0]	 	rptr,        // Gray, goes to sync_r2w
    input      [ADDR:0] 	rq2_wptr,    // synchronized Gray write pointer
    input                   rinc, rclk, rrst_n
);
    reg  [ADDR:0] rbin;
    wire [ADDR:0] rgraynext, rbinnext;
 
    assign raddr     = rbin[ADDR-1:0];
    assign rbinnext  = rbin + (rinc & ~rempty);
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;      // binary -> Gray
 
    // EMPTY: next read Gray pointer equals synchronized write Gray pointer
    wire rempty_val = (rgraynext == rq2_wptr);
 
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n)begin 
			rbin<=0;
			rptr<= 0;
		end
        else begin     
			rbin <=rbinnext;
			rptr <=rgraynext;
		end
 
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) rempty <= 1'b1;                    // empty after reset
        else         rempty <= rempty_val;
endmodule
