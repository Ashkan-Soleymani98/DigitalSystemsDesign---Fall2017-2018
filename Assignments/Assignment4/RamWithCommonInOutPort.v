module Ram#(parameter size = 1 , parameter wordSize = 1)(address , Data , cs , read);
input [size - 1: 0] address; 
inout [wordSize - 1 : 0] Data;
input cs , read;

reg [wordSize - 1 : 0] storedData [(1<<size) - 1 : 0];
reg [wordSize - 1 : 0] temp = 0; 
reg [wordSize - 1 : 0] n;

genvar i;
generate
 for(i = 0 ; i < wordSize ; i = i + 1)
  begin: write
   bufif1(Data[i] , storedData[address][i] , (read & cs));
//   bufif1(storedData[address][i] , Data[i] , (cs & (!read)));
  end
endgenerate

integer j = 0;
always@(cs or read)
 begin
  if(cs & (!read)) 
   begin
//    for(j = 0 ; j < wordSize ; j = j + 1)
     storedData[address] = Data;
   end
 end
endmodule


module testbench;
wire [3:0] Data;
reg [3:0] tempdata;
reg [1:0]address;
reg cs, read;

Ram #(.size(2) , .wordSize(4)) ram(address , Data , cs , read);
genvar i;
generate
 for(i = 0 ; i < 4 ; i = i + 1)
  begin: write
   bufif1(Data[i] , tempdata[i] , (!read) & cs);
  end
endgenerate

initial 
 begin
  #1 tempdata = 4'b1000; address = 2'b00;
  #1 read = 0; cs = 1;
  #1 cs = 0; read = 1; 
  #1 cs = 1; 
  #1 cs = 0;tempdata = 4'b0000 ; address = 2'b01;
  #1 read = 0 ; cs = 1;
  #1 cs = 0; read = 1;
  #1 cs = 1;
  #1 cs = 0; address = 2'b00;
  #1 cs = 1;
  $display(Data);
 end


endmodule
