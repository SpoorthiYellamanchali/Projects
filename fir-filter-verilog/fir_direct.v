
module fir_direct(
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

reg signed [47:0] acc;

integer i;

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

            
            for(i=N-1;i>0;i=i-1)
                x[i] <= x[i-1];

            x[0] <= x_in;

            
            acc = 0;

            for(i=0;i<N;i=i+1)
                acc = acc + x[i]*coeff[i];

            
            y_out <= acc >>> FRAC;

        end

    end

end

endmodule
