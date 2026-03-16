// FIR filter using genvar (parallel multipliers)

module fir_genvar(
    input clk,
    input rst_n,
    input valid_in,
    input signed [15:0] x_in,
    output reg signed [15:0] y_out,
    output reg valid_out
);

parameter N = 101;
parameter FRAC = 14;

reg signed [15:0] coeff [0:N-1];
reg signed [15:0] x [0:N-1];

wire signed [31:0] mult [0:N-1];

reg signed [47:0] acc;

integer i;

// parallel multipliers
genvar k;
generate
    for(k=0;k<N;k=k+1)
    begin
        assign mult[k] = x[k] * coeff[k];
    end
endgenerate


// combinational sum
always @(*)
begin

    acc = 0;

    for(i=0;i<N;i=i+1)
        acc = acc + mult[i];

end


// sequential part
always @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin
        y_out <= 0;
        valid_out <= 0;

        for(i=0;i<N;i=i+1)
            x[i] <= 0;
    end

    else
    begin

        valid_out <= valid_in;

        if(valid_in)
        begin

            // shift register
            for(i=N-1;i>0;i=i-1)
                x[i] <= x[i-1];

            x[0] <= x_in;

            // scale output
            y_out <= acc >>> FRAC;

        end

    end

end

endmodule
