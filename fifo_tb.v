`include "fifo_top.v"
module fifo_tb;
	 parameter WIDTH=8;
	 parameter ADDR=2;


	 reg wclk,rclk;
	 reg wrst_n,rrst_n;
	 reg winc,rinc;
	 reg [WIDTH-1:0]wdata;
	 wire [WIDTH-1:0]rdata;
	 wire wfull,rempty;

	 fifo_top #(WIDTH,ADDR)dut(.rdata(rdata), .wfull(wfull), .rempty(rempty),
        .wdata(wdata), .winc(winc), .wclk(wclk), .wrst_n(wrst_n),
        .rinc(rinc),   .rclk(rclk), .rrst_n(rrst_n));
	
	always #5 wclk=~wclk;
	always #7 rclk=~rclk;

	task write(input [WIDTH-1:0]value);
		begin
			@(negedge wclk);
			if(wfull)
				$display("FIFO FULL value %h cant be written",value);
			else begin
				winc=1;
				wdata=value;
				@(negedge wclk);
				winc=0;
				$display("%h written",value); 
			end
		end
	endtask

	task read;
		begin
			@(negedge rclk);
			if(rempty)
				$display("FIFO empty");
			else begin
				$display("%h read",rdata);
				rinc=1;
				@(negedge rclk);
				rinc=0;
			end
		end
	endtask
	initial begin
		wclk = 0;
		rclk = 0;
		wrst_n = 0;
		rrst_n = 0;
		winc = 0;
		rinc = 0;
		wdata = 0;
		#20;
		wrst_n=1;
		rrst_n=1;
		#30;
	 	$display("   rempty=%b wfull=%b", rempty, wfull);//expect 1,0

		write(8'hA);
		write(8'hB);
		repeat(4)@(negedge rclk);//waiting for syncronizers to settle the data(2FF)
		$display("rempty=%b (expected:0)",rempty);
		read;
		read;
		repeat(4)@(negedge rclk);
		$display("rempty=%b (expected:1)",rempty);//checking the rempty flag

		write(8'hC);
        write(8'hD);
        write(8'hE);
        write(8'hF);
		repeat(2)@(negedge wclk);
		$display("Wfull=%b(expected 1)",wfull);
		write(8'hEE);//wont be written since full
		read;
		repeat(3)@(negedge wclk);
		read;
		read;
		read;
		repeat(3)@(negedge rclk);
		$finish;
	end
	 initial begin
        #1000000;
        $display("TIMEOUT");
        $finish;
    end
endmodule
