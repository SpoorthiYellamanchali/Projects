`timescale 1ns/1ps

module tb_optimized;

parameter N = 101;
parameter SAMPLES = 500;

reg clk;
reg rst_n;
reg valid_in;
reg signed [15:0] x_in;

wire signed [15:0] y_out;
wire valid_out;

fir_optimized dut(
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .x_in(x_in),
    .y_out(y_out),
    .valid_out(valid_out)
);

// clock
initial clk = 0;
always #5 clk = ~clk;


// memory
integer coeff [0:N-1];
integer sig [0:SAMPLES-1];
integer out [0:SAMPLES+N];

integer i;
integer j;
integer k;
integer fd;
integer temp;
integer count;


// load coefficients
task load_coeff;
begin

    fd = $fopen("coefficients.txt","r");

    for(i=0;i<N;i=i+1)
        temp = $fscanf(fd,"%d\n",coeff[i]);

    $fclose(fd);

    for(i=0;i<N;i=i+1)
        dut.coeff[i] = coeff[i];

end
endtask


// load signal
task load_signal;
input [200*8:1] name;
begin

    fd = $fopen(name,"r");

    for(i=0;i<SAMPLES;i=i+1)
        temp = $fscanf(fd,"%d\n",sig[i]);

    $fclose(fd);

end
endtask


// reset
task reset;
begin

    rst_n = 0;
    valid_in = 0;
    x_in = 0;

    repeat(5) @(posedge clk);

    rst_n = 1;

end
endtask


// run filter
task run_filter;
begin

    count = 0;

    for(j=0;j<SAMPLES;j=j+1)
    begin

        @(posedge clk);

        valid_in = 1;
        x_in = sig[j];

        @(negedge clk);

        if(valid_out)
        begin
            out[count] = y_out;
            count = count + 1;
        end

    end

end
endtask


// save output
task save_output;
input [200*8:1] name;
begin

    fd = $fopen(name,"w");

    for(k=0;k<count;k=k+1)
        $fdisplay(fd,"%d",out[k]);

    $fclose(fd);

end
endtask


initial
begin

    load_coeff;

    load_signal("signal_950Hz.txt");
    reset;
    run_filter;
    save_output("verilog_optimized_950Hz.txt");

    load_signal("signal_1100Hz.txt");
    reset;
    run_filter;
    save_output("verilog_optimized_1100Hz.txt");

    load_signal("signal_2000Hz.txt");
    reset;
    run_filter;
    save_output("verilog_optimized_2000Hz.txt");

    $display("optimized simulation done");

    $finish;

end

endmodule
