module D_flip_flap(Q , D , clk , reset);
 input D , clk , reset;
 output Q;
 wire w;
 assign w = reset ? 0 : (clk ? D : w);
 assign Q = reset ? 0 : (clk ? Q : w);
endmodule

module test;
wire q;
reg d , clk , reset;

D_flip_flap mem(q , d , clk , reset);

always #2 clk = ~clk;
initial
 begin
  clk = 1;
  #2 d = 1; reset = 0;
  #8 d = 0; reset = 1; 
 end
endmodule
