module systolic #(parameter D_W = 8, parameter N = 3, parameter M = 6)(
    input wire clk,
    input wire rst,
    input wire enable_row_count_m0,
    output wire [$clog2(M)-1:0] column_m0,
    output wire [$clog2(M/N)-1:0] row_m0,
    output wire [$clog2(M/N)-1:0] column_m1,
    output wire [$clog2(M)-1:0] row_m1,
    input wire [D_W-1:0] m0 [N-1:0],
    input wire [D_W-1:0] m1 [N-1:0],
    output wire [2*D_W-1:0] m2 [N-1:0],
    output wire [N-1:0] valid_m2
    );

    counter #(.WIDTH(M), .HEIGHT(M/N))
    counter_m1
    (
        .clk(clk),
        .rst(rst),
        .enable_row_count(1'b1),
        .column_counter(row_m1),
        .row_counter(column_m1)
    );

    counter #(.WIDTH(M), .HEIGHT (M/N))
    counter_m0
    (
        .clk(clk),
        .rst(rst),
        .enable_row_count(enable_row_count_m0),
        .column_counter(column_m0),
        .row_counter(row_m0)
    );

    wire [D_W-1:0] horizontal [N-1:0][N:0];
    wire [D_W-1:0] vertical [N:0][N-1:0];
    wire [2*D_W-1:0] data [N-1:0][N:0];
    wire valid [N-1:0][N:0];

    genvar row_col_index;
    generate
        for(row_col_index = 0; row_col_index < N; row_col_index = row_col_index+1)
        begin
            assign horizontal[row_col_index][0] = m0[row_col_index];
            assign vertical[0][row_col_index] = m1[row_col_index];
        end
    endgenerate

    genvar pe_index0, pe_index1;
    generate
        for(pe_index0 = 0; pe_index0 < N; pe_index0 = pe_index0+1)
        begin
            for(pe_index1 = 0; pe_index1 < N; pe_index1 = pe_index1+1)
            begin
                pe #(.D_W(D_W))
                pe_inst
                (
                    .clk(clk),
                    .rst(rst),
                    .in_a(horizontal[pe_index0][pe_index1]),
                    .in_b(vertical[pe_index0][pe_index1]),
                    .init(init[pe_index0][pe_index1]),
                    .in_data(data[pe_index0][pe_index1]),
                    .in_valid(valid[pe_index0][pe_index1]),
                    .out_a(horizontal[pe_index0][pe_index1+1]),
                    .out_b(vertical[pe_index0+1][pe_index1]),
                    .out_data(data[pe_index0][pe_index1+1]),
                    .out_valid(valid[pe_index0][pe_index1+1])
                );
            end
        end
    endgenerate

    genvar row_index;
    generate
        for(row_index = 0; row_index < N; row_index = row_index+1)
        begin
            assign m2[row_index] = data[row_index][N];
            assign valid_m2[row_index] = valid[row_index][N];

            assign valid[row_index][0] = 0;
            assign data[row_index][0] = 0;
        end
    endgenerate

    reg init_val = 0;

    reg [N-1:0] init [N-1:0];
    reg [2*N-2:0] delay;
    reg valid_stop = 0;

    integer diag = N;
    integer x;
    integer k;
    integer i;
    integer j;

    always@(posedge clk)
    begin
        delay[0] <= init_val;

        for(x = 1; x < 2*N-1; x = x+1)
        begin
            delay[x] <= delay[x-1];
        end

        if(row_m1 == M-1 && row_m0 == (M/N)-1 && column_m1 == (M/N)-1)
        begin
            valid_stop <= 1;
        end

        if(column_m0 == M-1 && !valid_stop)
        begin
            init_val <= 1;
        end
        else
        begin
            init_val <= 0;
        end
    end

    always@(*)
    begin
        diag = N;

        for(k = 0; k < N; k = k + 1)
        begin
            j = k;
            for (i = 0; i < k+1; i = i+1)
            begin
                init[i][j] <= delay[k];
                j = j-1;
            end
        end

        for(k = N-2; k > 0; k = k-1)
        begin
            j = N-1;
            for (i = N-k-1; i < N; i = i+1)
            begin
                init[i][j] <= delay[diag];
                j = j-1;
            end
            diag = diag + 1;
        end

        init[N-1][N-1] <= delay[2*N-2];
    end
endmodule