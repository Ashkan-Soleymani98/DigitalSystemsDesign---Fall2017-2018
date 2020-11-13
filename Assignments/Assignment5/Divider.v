module Divider(quotient , remain , in1 , in2 , S , E , clk);
 input[15:0] in1;
 input[7:0] in2;
 input S , clk;
 output[7:0] remain;
 output[7:0] quotient;
 output E;
 
 reg r3Assign;
 wire[15:0] R1out;
 reg R1load;
 Register#(16) R1(R1out , R1load , 1'b0 , 1'b0 , 1'b0 , in1 , clk);
 
 wire[7:0] R2out;
 reg R2load;
 Register#(8) R2(R2out , R2load , 1'b0 , 1'b0 , 1'b0 , in2 , clk);

 reg SE , RE;
 flip_flap Eflip_flap(E , SE , RE , clk);

 wire[7:0] R3out;
 reg[8:0] R3in ;
 reg  R3load , R3shl , R3shlIn;
 Register#(9) R3(R3out , R3load ,  R3shl , 1'b0 , R3shlIn , R3in , clk);

 wire[7:0] R4out;
 reg R4load , R4shl , R4shlIn;
 Register#(8) R4(R4out , R4load , R4shl , 1'b0 , R4shlIn , 8'd0 , clk);

 reg [3:0]R6;
 wire OrR6;
 ReductionOr#(4) reductionOrR6(OrR6 , R6);

 wire less;
 Comparer#(8) comparer(less , R2out , R3out);

 reg R7load;
 Register#(8) R7(quotient , R7load , 1'b0 , 1'b0 , 1'b0 , R4out , clk);

 reg R8load;
 Register#(8) R8(remain , R8load , 1'b0 , 1'b0 , 1'b0 , R3out , clk);
 
 initial 
  begin
   if(in2 == 0)
    begin
     $display("divided by zero!");
     $stop
    end
  end

 integer asmBlock = 0; // 0 -> INIT , 1 -> PROCESS , 2 -> TEMP
 always@(posedge clk)
  begin
   R1load = 0;
   R2load = 0;
   R3load = 0;
   R4load = 0;
   R7load = 0;
   R8load = 0;
   R3shl = 0;
   R4shl = 0; 
   RE = 0;
   SE = 0;
   if(asmBlock == 0)
    begin
     if(S == 1)
      begin
       R1load = 1;
       R2load = 1;
       RE = 1;
       R3in = in1[15:8];
       R3load = 1;
       R4load = 1;
       R6 = 8;
       asmBlock = 1;
      end    
    end 
   else if(asmBlock == 1)
    begin 
     if(OrR6 == 0)
       begin
        SE = 1;
        R7load = 1;
        R8load = 1;
        asmBlock = 0;
       end
     else if(OrR6 == 1)
       begin
        if(less == 1)
          begin
           R4shl = 1;
           R4shlIn = 1;
           R3in = R3out - R2out;
           asmBlock = 2;
          end
        else if(less == 0)
          begin
           R4shl = 1;
           R4shlIn = 0;
           R3shl = 1;
           R3shlIn = in1[R6 - 1];
           R6 = R6 - 1;
          end
        end
     end
    else if(asmBlock == 2)
     begin
      R3shl = 1;
      R3shlIn = in1[R6 - 1];
      R6 = R6 - 1;
      $stop;
     end       
  end 

endmodule

module ReductionOr#(parameter size = 1)(out , in);
 input [size - 1:0] in;
 output out;
 reg out;
 always@(in)
  out = |(in);
endmodule

module Comparer#(parameter size = 1)(less , a , b);
 input[size - 1:0] a , b;
 output less;
 reg less;

 always@(a or b)
  begin
   if(a < b)
    less = 1'b1; 
   else
    less = 1'b0;
  end
endmodule

module flip_flap(q , s , r , clk);
 input r , s , clk;
 output q;
 reg q;

 always@(posedge clk)
  begin
   if(s == 1)
    q = 1;
   if(r == 1)
    q = 0;
  end
endmodule 

module Register#(parameter size = 1)(out , load , shl , dec , shIn ,  in , clk);
 input[size - 1:0] in;
 input load;
 input shl;
 input clk;
 input shIn;
 input dec;
 output [size - 1:0] out;
 reg [size - 1:0] out;

 reg[size:0] temp;
 always@(posedge clk)
  begin
   if(load == 1)
    out = in;
   else if(shl == 1)
    begin
     temp = out << 1;
     if(temp > (1<<size - 1))
       $display($time , " Overflow !!! :))))) temp = " , temp);
     out = temp;
     out[0] = shIn;
    end
   else if(dec == 1)
     out = out - 1;
  end
endmodule

module simulate;
 wire[7:0] quotient , remain;
 wire E;
 reg[15:0] in1;
 reg[7:0] in2;
 reg S , clk;
 always #2 clk = ~clk;
// Register#(3) register(out , load , shl , dec , shIn , in , clk);
 Divider divider(quotient , remain , in1 , in2 , S , E , clk);
 initial 
  begin
   clk = 1;
   #3 in1 = 12; in2 = 3; S = 1;
  end
endmodule
