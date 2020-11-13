//`timescale 1ns/1ns

module bit4_binary_adder(s , a , b);
 input[3:0] a;
 input[3:0] b;
 output[4:0] s;

 wire[3:1] ca;
 fulladder fulladder1(s[0] , ca[1] , a[0] , b[0] , 0);
 fulladder fulladder2(s[1] , ca[2] , a[1] , b[1] , ca[1]);
 fulladder fulladder3(s[2] , ca[3] , a[2] , b[2] , ca[2]);
 fulladder fulladder4(s[3] , s[4] , a[3] , b[3] , ca[3]);
endmodule 

module fulladder(s , carry , a , b , c);
 input a , b , c;
 output carry , s;
  
 wire l, m, n;

 halfadder halfadder1(s , n , m , c);
 halfadder halfadder2(m , l , a , b);
 or(carry , l , n);

endmodule

module halfadder(s , carry , a , b);
 input a , b;
 output s , carry;
 reg s , carry;

 always@(b)
  begin
   #2 carry = a & b;
   #3 s = a ^ b;
  end
 always@(a)
  begin
   #2 carry = a & b;
   #3 s = a ^ b;
  end

endmodule 

module simulutus;
 reg[3:0] a;
 reg [3:0] b;
 wire[4:0] s;
 bit4_binary_adder adder(s , a , b);
  
 initial 
  begin 
   a = 4'd0; b = 4'd15;
  end
 initial
  begin 
   $monitor($time , " Sum = %b" , s);
  end
endmodule
