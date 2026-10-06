`include "fifomem.v"
`include "rptr_empty.v"
`include "sync_r2w.v"
`include "sync_w2r.v"
`include "wptr_full.v"

module fifo_top #(parameter WIDTH = 8,
				  parameter ADDR = 4)(
  				  input              winc, wclk, wrst_n,
  				  input  [WIDTH-1:0] wdata,
  				  input              rinc, rclk, rrst_n,
  				  output [WIDTH-1:0] rdata,
  				  output             wfull,
  				  output             rempty
				  );
    wire [ADDR-1:0] waddr, raddr;
    wire [ADDR:0]   wptr, rptr, wq2_rptr, rq2_wptr;
 
    sync_r2w  #(ADDR) sync_r2w (.wq2_rptr(wq2_rptr), 
								.rptr(rptr),
                                .wclk(wclk),
								.wrst_n(wrst_n)
								);
 
    sync_w2r  #(ADDR) sync_w2r (.rq2_wptr(rq2_wptr),
							    .wptr(wptr),
                                .rclk(rclk),
								.rrst_n(rrst_n)
								);
 
    fifomem   #(WIDTH, ADDR) fifomem(.rdata(rdata),
									 .wdata(wdata),
									 .waddr(waddr),
									 .raddr(raddr),
                 					 .wclken(winc),
									 .wfull(wfull),
									 .wclk(wclk)
									 );
 
    rptr_empty #(ADDR) rptr_empty(.rempty(rempty),
								  .raddr(raddr),
								  .rptr(rptr),
                 				  .rq2_wptr(rq2_wptr),
								  .rinc(rinc),
								  .rclk(rclk),
								  .rrst_n(rrst_n)
								  );
 
    wptr_full  #(ADDR) wptr_full(.wfull(wfull),
								 .waddr(waddr),
								 .wptr(wptr),
                 				 .wq2_rptr(wq2_rptr),
								 .winc(winc),
                 				 .wclk(wclk),
								 .wrst_n(wrst_n)
								 );
endmodule
