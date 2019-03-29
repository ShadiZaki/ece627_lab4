module counter #(parameter WIDTH = 32, parameter HEIGHT = 32)(
	input clk,
	input rst,
	input enable_row_count,
	output reg [$clog2(WIDTH)-1:0] column_counter,
	output reg [$clog2(HEIGHT)-1:0] row_counter
	);

	wire flag;
	assign flag = (column_counter == WIDTH-1) ? 1:0;

	always @(posedge clk)
	begin
		if(rst)
		begin
			column_counter <= 0;
			row_counter <= 0;
		end
		else
		begin
			column_counter <= (column_counter + 1) % WIDTH;

			if(enable_row_count && flag)
            begin
                row_counter <= (row_counter + 1) % HEIGHT;
            end
		end
	end
endmodule