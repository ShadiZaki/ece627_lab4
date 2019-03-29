module pe #(parameter D_W = 32)(
	input clk,
	input rst,
	input [D_W-1:0] in_a,
	input [D_W-1:0] in_b,
	input init,
	input [2*D_W-1:0] in_data,
	input in_valid,
	output reg [D_W-1:0] out_a,
	output reg [D_W-1:0] out_b,
	output reg [2*D_W-1:0] out_data,
	output reg out_valid);

	reg [2*D_W-1:0] sum;
	reg valid;
	reg [2*D_W-1:0] data;

	always @(posedge clk) 
	begin
		if(!rst)
		begin
			out_a <= in_a;
			out_b <= in_b;
			valid <= in_valid;
			data <= in_data;
			out_valid <= valid | init;

			if(!init)
			begin
				sum <= in_a * in_b + sum;
				out_data <= data;
			end
			else
			begin
				sum <= in_a * in_b;
				out_data <= sum;
			end
		end
		else
		begin
			out_data <= 0;
			out_valid <= 0;
			out_a <= 0;
			out_b <= 0;
			valid <= 0;
			data <= 0;
			sum <= 0;
		end
	end
endmodule