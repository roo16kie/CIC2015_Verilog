module SET ( clk , rst, en, central, radius, mode, busy, valid, candidate );

input clk, rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0] mode;
output busy;
output reg valid;
output reg [7:0] candidate;

////////////////////////////////
////////Define Somethings///////
////////////////////////////////

parameter IDLE = 2'b00 ;
parameter  EN  = 2'b01 ;
parameter BUSY = 2'b11 ;
parameter  OP  = 2'b10 ;

wire signed [3:0] a1, a2, b1, b2, c1, c2 ;
wire      a , b , c ,d ,g ;

wire signed [8:0] r,t,v ;

reg signed [3:0] x ,y  ;
//wire signed [8:0] i,j,k ,h ,m ,n ;
reg [1:0] cs , ns , mod;

reg signed [3:0] Ax ,Ay ,Bx ,By ,Cx ,Cy ;
reg signed [3:0] Ar , Br , Cr ;
reg signed [8:0] i , j , k ,h ,m ,n ,q ,w,z ;
reg [1:0] counter ;


reg [7:0] count , num ;


assign a1 = x-Ax ;
assign a2 = y-Ay ;
assign b1 = x-Bx ;
assign b2 = y-By ;
assign c1 = x-Cx ;
assign c2 = y-Cy ;
/*
assign i = a1*a1 + a2*a2 ;
assign j = b1*b1 + b2*b2 ;
assign k = c1*c1 + c2*c2 ;
assign h = Ar*Ar ;
assign m = Br*Br ;
assign n = Cr*Cr ;
*/
assign r = i + h ;
assign t = j + m ;
assign v = k + n ;

assign a = (r <= q);
assign b = (t <= w);
assign c = (v <= z);

assign d = ((!a)&b)|(a&(!b)) ;

assign g = ( a & b & (!c) ) | ( a & (!b) & c ) |  ( (!a) & b & c ) ;


always@(posedge clk)
begin
	if(ns==OP)
	begin
		if(counter==2'd0)
		begin
			i <= a1*a1 ;
			j <= b1*b1 ;
			k <= c1*c1 ;
		end
		else if(counter==2'd1)
		begin
			h <= a2*a2 ;
			m <= b2*b2 ;
			n <= c2*c2 ;			
		end
		else if(counter==2'd2)
		begin
			q <= Ar*Ar ;
			w <= Br*Br ;
			z <= Cr*Cr ;
		end
	end
	
end



always@(posedge clk or posedge rst)
begin
	if(rst)
		valid <= 0 ;
	else if(count==8'd64)
		valid <= 1 ;
	else
		valid <= 0 ;
		
end


always@(posedge clk or posedge rst)
begin
	if(rst)
		num <= 8'd0 ;
	else if(ns==BUSY)
	begin
		if(mod==2'b00)
		begin
			if(a)
				num <= num + 8'd1 ;
		end
		else if(mod==2'b01)
		begin
			if(b&a)
				num <= num + 8'd1 ;
		end
		else if(mod==2'b10)
		begin
			if(d)
				num <= num + 8'd1 ;
		end
		else if(mod==2'b11)
		begin
			if(g)
				num <= num + 8'd1 ;
		end
	end
	else if(ns==IDLE)
		num <= 8'd0 ;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		candidate <= 8'd0 ;
	else if(count==8'd64)
	begin
		if(mod==2'b00)
		begin
			if(a)
				candidate <= num  ;
			else
				candidate <= num ;
		end
		else if(mod==2'b01)
		begin
			if(b&a)
				candidate <= num  ;
			else
				candidate <= num ;		
			end
		else if(mod==2'b10)
		begin
			if(d)
				candidate <= num  ;
			else
				candidate <= num	 ;	
		end
		else if(mod==2'b11)
		begin
			if(g)
				candidate <= num  ;
			else
				candidate <= num ;
		end
	end
	else
		candidate <= 8'd0 ;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		counter <= 2'd0 ;
	else if(counter==2'd3)
		counter <= 2'd0 ;
	else if(ns==OP)
		counter <= counter + 2'd1 ;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
	begin x <= 4'd1 ; y <= 4'd1 ;      end
	else if(ns==BUSY)
		begin
			if(count==8'd7||count==8'd15||count==8'd23||count==8'd31||count==8'd39||count==8'd47||count==8'd55)
			begin x <= 4'd1 ; y <= y + 4'd1 ; end 
			else 
			begin x <= x + 4'd1 ; y <= y ;   end
		end
	else if(ns==IDLE)
	begin
			if(count==8'd64)
			begin x <= 4'd1 ; y <= 4'd1 ;      end
	end
end



always@(posedge clk or posedge rst)
begin
	if(rst)
		count <= 8'd0 ;
	else if(count==8'd64)
		count <= 8'd0 ;
	else if(counter==2'd3)
		count <= count + 8'd1 ;
end






always@(posedge clk or posedge rst)
begin
	if(rst)
		cs <= IDLE ;
	else
		cs <= ns ;
end

always@(*)
begin
	case(cs)
		IDLE : if(en)
				ns = EN ;
			   else
			    ns = IDLE ;
		EN :   if(~en)
				ns = OP ;
			   else
			    ns = EN   ;
		BUSY:  if(count==8'd64)
				ns = IDLE ;
			   else
			    ns = OP ;
				
		OP :   if(counter==2'd3) 
				ns = BUSY ;
			   else
			    ns = OP  ;
		
	default : ns = IDLE ;	
	endcase
end

assign busy = (ns==BUSY||ns==OP||cs==BUSY) ;







always@(posedge clk)
	if(en)
	begin
		Ax <= central[23:20] ;
		Ay <= central[19:16] ;
		Bx <= central[15:12] ;
		By <= central[11:8] ;
		Cx <= central[7:4] ;
		Cy <= central[3:0] ;
		Ar <= radius[11:8] ;
		Br <= radius[7:4] ;
		Cr <= radius[3:0] ;
		mod <= mode ;
	end
/*always@(posedge clk)
	if(en)
		Ay <= central[19:16] ;
always@(posedge clk)
	if(en)
		Bx <= central[15:12] ;
always@(posedge clk)
	if(en)
		By <= central[11:8] ;
always@(posedge clk)
	if(en)
		Cx <= central[7:4] ;
always@(posedge clk)
	if(en)
		Cy <= central[3:0] ;	
always@(posedge clk)
	if(en)
		Ar <= radius[11:8] ;
always@(posedge clk)
	if(en)
		Br <= radius[7:4] ;
always@(posedge clk)
	if(en)
		Cr <= radius[3:0] ;	
always@(posedge clk)
	if(en)
		mod <= mode ;		
*/













endmodule


