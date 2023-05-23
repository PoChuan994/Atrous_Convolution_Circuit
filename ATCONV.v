`timescale 1ns/10ps
module  ATCONV(
	input		clk,
	input		reset,
	output	reg	busy,	
	input		ready,	
			
	output reg	[11:0]	iaddr,
	input signed [12:0]	idata,
	
	output	reg 	cwr,
	output  reg	[11:0]	caddr_wr,
	output reg 	[12:0] 	cdata_wr,
	
	output	reg 	crd,
	output reg	[11:0] 	caddr_rd,
	input 	[12:0] 	cdata_rd,
	
	output reg 	csel
	);

//=================================================
//            write your design below
//=================================================
	parameter 	IDLE = 'd0,
				RequestData_L0 = 'd1,
				GetData_L0 = 'd2,
				Save2Mem0 = 'd3,
				RequestData_L1 = 'd4,
				GetData_L1 = 'd5,
				Save2Mem1 = 'd6,
				Result = 'd7;
	
	reg [3:0] state, nextstate;

	reg [12:0] kernelvalue, tmp;

	reg [3:0] convNum;
	reg [12:0] orin_iaddr;

	reg layer0_fin, layer1_fin;

	always @(*) begin
		case (state)
			IDLE: begin
				case (layer0_fin)
					'd0: nextstate = RequestData_L0;
					'd1: nextstate = RequestData_L1;
				endcase
			end
			RequestData_L0: nextstate = GetData_L0;
			GetData_L0:begin
				case (convNum<'d9)
					'd0: nextstate = Save2Mem0;
					'd1: nextstate = RequestData_L0; 
				endcase
			end
			Save2Mem0: begin
				case (layer0_fin=='d1)
					'd0: nextstate = RequestData_L0;
					'd1: nextstate = IDLE;
				endcase
			end
			RequestData_L1: nextstate = GetData_L1;
			GetData_L1: begin
				case (convNum<'d4)
					'd0: nextstate = Save2Mem1;
					'd1: nextstate = RequestData_L1;
				endcase
			end
			Save2Mem1: begin
				case (layer1_fin=='b1)
					'd0: nextstate = RequestData_L1;
					'd1: nextstate = Result;
				endcase
			end
			default: nextstate = IDLE;
		endcase
	end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			busy<='d0;
			iaddr='d0;
			orin_iaddr='d0;
			kernelvalue='d0;
			caddr_wr='b111111111111;
			state = IDLE;
			layer0_fin = 'd0;
			layer1_fin = 'd0;
			convNum = 'd0;
			orin_iaddr = 'd0;
			cdata_wr = 'd0;
		end else begin
			state = nextstate;
			if (ready) begin
				busy <='d1;
			end
			case (state)
				IDLE: begin
					orin_iaddr='d0;
				end
				RequestData_L0: begin
					if (busy) begin
					// Left_Top_Corner
					if ( orin_iaddr=='d0 || orin_iaddr=='d1 || orin_iaddr=='d64 || orin_iaddr== 'd65) begin
						case (convNum)
							'd0: iaddr = orin_iaddr;
							'd1: iaddr = 'd0;
							'd2: iaddr = {11'b00000000000,orin_iaddr[0]};
							'd3: iaddr = {11'b00000000001, orin_iaddr[0]};
							'd4: begin
								case (orin_iaddr>'d63)
									'd0: iaddr = 'd0;
									'd1: iaddr = 'd64;
								endcase
							end
							'd5: iaddr = orin_iaddr+'d2;
							'd6: begin
								case (orin_iaddr[5:0]=='b0)
									'd0: iaddr = orin_iaddr+'d127;
									'd1: iaddr = orin_iaddr+'d128;
								endcase
							end
							'd7: iaddr = orin_iaddr+'d128;
							'd8: iaddr = orin_iaddr+'d130;
						endcase
					end 
					// Right_Top_Corner
					else if ( orin_iaddr=='d62 || orin_iaddr =='d63 || orin_iaddr == 'd126 || orin_iaddr=='d127) begin
						case (convNum)
							'd0: iaddr = orin_iaddr;
							'd1: begin
								iaddr = orin_iaddr-'d2;
								iaddr = {6'b000000, iaddr[5:0]};
							end
							'd2: iaddr = {6'b000000,orin_iaddr[5:0]};
							'd3: iaddr = 'd63;
							'd4: iaddr = orin_iaddr-'d2;
							'd5: begin
								case (orin_iaddr>'d64)
									'd0: iaddr = 'd63;
									'd1: iaddr = 'd127;
								endcase
							end
							'd6: iaddr = orin_iaddr + 126;
							'd7: iaddr = orin_iaddr + 128;
							'd8: begin
								case (orin_iaddr[5:0]==63)
									'd0: iaddr = orin_iaddr+129;
									'd1: iaddr = orin_iaddr+128;
								endcase
							end
						endcase
					end 
					// Left_Bottom_Corner
					else if ( orin_iaddr=='d3968 || orin_iaddr =='d3969 || orin_iaddr == 'd4032 || orin_iaddr=='d4033) begin
						case (convNum)
							'd0: iaddr = orin_iaddr;
							'd1: begin
								case (orin_iaddr[0]=='d0)
									'd0: iaddr = orin_iaddr-'d129;
									'd1: iaddr = orin_iaddr-'d128;
								endcase
							end
							'd2: iaddr = orin_iaddr - 'd128;
							'd3: iaddr = orin_iaddr - 'd126;
							'd4: begin
								case (orin_iaddr>'d3970)
									'd0: iaddr = 'd3968;
									'd1: iaddr = 'd4032;
								endcase
							end
							'd5: iaddr = orin_iaddr +'d2;
							'd6: iaddr = 'd4032;
							'd7: begin
								case (orin_iaddr<'d4032)
									'd0: iaddr = orin_iaddr;
									'd1: iaddr = orin_iaddr+'d64;
								endcase
							end
							'd8: begin
								case (orin_iaddr<'d4032)
									'd0: iaddr = orin_iaddr+'d2;
									'd1: iaddr = orin_iaddr+'d66;
								endcase
							end
						endcase
					end
					// Right_Bottom_Corner
					else if ( orin_iaddr=='d4030 || orin_iaddr =='d4031 || orin_iaddr == 'd4094 || orin_iaddr=='d4095) begin
						case (convNum)
							'd0: iaddr = orin_iaddr;
							'd1: iaddr = orin_iaddr - 'd130;
							'd2: iaddr = orin_iaddr - 'd128; 
							'd3: begin
								case (orin_iaddr[5:0]=='d63)
									'd0: iaddr = orin_iaddr-'d127;
									'd1: iaddr = orin_iaddr-'d128;
								endcase
							end
							'd4: iaddr = orin_iaddr - 'd2;
							'd5: begin
								case (orin_iaddr>'d4032)
									'd0: iaddr = 'd4031;
									'd1: iaddr = 'd4095;
								endcase
							end
							'd6: begin
								case (orin_iaddr>'d4032)
									'd0: iaddr = orin_iaddr+'d62;
									'd1: iaddr = orin_iaddr-'d2;
								endcase
							end
							'd7: begin
								if (orin_iaddr[5:0]=='d63) begin
									iaddr = 'd4095;
								end else begin
									iaddr = 'd4094;
								end
							end
							'd8: iaddr = 'd4095;
						endcase
					end
					// Top_Edge
					else if (( orin_iaddr>1 && orin_iaddr<62 )||( orin_iaddr>65 && orin_iaddr<126 )) begin
						case (convNum)
							'd0: iaddr = orin_iaddr;
							'd1: begin
								iaddr = orin_iaddr-'d2;
								iaddr = {6'b000000, iaddr[5:0]};
							end
							'd2: iaddr = {6'b000000, orin_iaddr[5:0]};
							'd3: begin
								iaddr = orin_iaddr + 'd2;
								iaddr = {6'b000000, iaddr[5:0]};
							end
							'd4: iaddr = orin_iaddr-'d2;
							'd5: iaddr = orin_iaddr+'d2;
							'd6: iaddr = orin_iaddr+'d126;
							'd7: iaddr = orin_iaddr+'d128;
							'd8: iaddr = orin_iaddr+'d130;
						endcase

					end
					// Bottom_Edge
					// case '6,'7,'8 should do hardware sharing
					else if ((orin_iaddr>3969 && orin_iaddr<4030)||(orin_iaddr>4033 && orin_iaddr<4094)) begin
						case (convNum)
							'd0: iaddr = orin_iaddr;
							'd1: iaddr = orin_iaddr-'d130;
							'd2: iaddr = orin_iaddr-'d128;
							'd3: iaddr = orin_iaddr-'d126;
							'd4: iaddr = orin_iaddr-'d2;
							'd5: iaddr = orin_iaddr+'d2;
							'd6: iaddr = (orin_iaddr>'d4031)?orin_iaddr-'d2:orin_iaddr+'d62;
							'd7: iaddr = (orin_iaddr>'d4031)?orin_iaddr:orin_iaddr+'d64;
							'd8: iaddr = (orin_iaddr>'d4031)?orin_iaddr+'d2:orin_iaddr+'d66;
						endcase
					end
					// Left_Edge
					// case 'd1,'d4,'d6 should do hardware sharing
					else if ((orin_iaddr[5:0]=='d0||orin_iaddr[5:0]=='d1) && ( orin_iaddr!='d0 || orin_iaddr!='d1 || orin_iaddr!='d64 || orin_iaddr!='d65 || orin_iaddr!='d3968 || orin_iaddr!='d3969 || orin_iaddr!='d4032 || orin_iaddr!='d4033)) begin
						case (convNum)
							'd0: iaddr = orin_iaddr;
							'd1: iaddr = (orin_iaddr[0]==0)?orin_iaddr-'d128:orin_iaddr-'d129;
							'd2: iaddr = orin_iaddr-'d128;
							'd3: iaddr = orin_iaddr-'d126;
							'd4: iaddr = (orin_iaddr[0]==0)?orin_iaddr:orin_iaddr-1;
							'd5: iaddr = orin_iaddr+'d2;
							'd6: iaddr = (orin_iaddr[0]==0)?orin_iaddr+'d128:orin_iaddr+'d127;
							'd7: iaddr = orin_iaddr+'d128;
							'd8: iaddr = orin_iaddr+'d130;
						endcase
					end
					// Right_Edge
					// hardware sharing
					else if (( orin_iaddr[5:0]=='d62||orin_iaddr[5:0]=='d63) && (orin_iaddr!='d62 || orin_iaddr!='d63 || orin_iaddr!='d126 || orin_iaddr!='d127 || orin_iaddr!='d4030 || orin_iaddr!='d4031 || orin_iaddr!='d4094 || orin_iaddr!='d4095 )) begin
						case (convNum)
							'd0: iaddr = orin_iaddr;
							'd1: iaddr = orin_iaddr-130;
							'd2: iaddr = orin_iaddr-128;
							'd3: iaddr = (orin_iaddr[0]=='d1)?orin_iaddr-'d128:orin_iaddr-'d127;
							'd4: iaddr = orin_iaddr-'d2;
							'd5: iaddr = (orin_iaddr[0]=='d1)?orin_iaddr:orin_iaddr+'d1;
							'd6: iaddr = orin_iaddr+'d126;
							'd7: iaddr = orin_iaddr+'d128;
							'd8: iaddr = (orin_iaddr[0]=='d1)?orin_iaddr+'d128:orin_iaddr+'d129;
						endcase
					end
					// General_Case
					else begin
							case (convNum)
								'd0: iaddr = orin_iaddr;
								'd1: iaddr = orin_iaddr-'d130;
								'd2: iaddr = orin_iaddr-'d128;
								'd3: iaddr = orin_iaddr-'d126;
								'd4: iaddr = orin_iaddr-'d2;
								'd5: iaddr = orin_iaddr+'d2;
								'd6: iaddr = orin_iaddr+'d126;
								'd7: iaddr = orin_iaddr+'d128;
								'd8: iaddr = orin_iaddr+'d130;
							endcase
						end
					end
				end
				GetData_L0: begin
					tmp = -idata;
					case (convNum)
						'd0: begin
							tmp = idata;
						end
						'd1, 'd3, 'd6, 'd8: begin
							tmp = $signed(tmp)>>>4;
						end
						'd2, 'd7: begin
							tmp = $signed(tmp)>>>3;
						end
						'd4, 'd5: begin
							tmp = $signed(tmp)>>>2;
						end 
					endcase
					kernelvalue = kernelvalue + tmp;
					convNum = convNum + 'd1;
				end
				Save2Mem0: begin
					iaddr = orin_iaddr+'d1;
					orin_iaddr = orin_iaddr+'d1;
					case (orin_iaddr=='d4096)
						'd0: begin
							layer0_fin='d0;		
						end
						'd1: begin
							layer0_fin='d1;
							orin_iaddr = 'd0;
						end
					endcase
					// reset convNum => 9 kernel value computing finish
					convNum = 'd0;
					// bias
					kernelvalue = kernelvalue + 13'b1111111110100;
					// ReLU
					if (kernelvalue[12]=='b0) begin
						// kernelvalue >=0
						cdata_wr = kernelvalue;
					end else begin
						// kernelvalue <0
						cdata_wr = 'd0;
					end
					// write data into mem0
					csel = 0;
					cwr <= 1;
					caddr_wr = caddr_wr +'d1;
					kernelvalue = 'd0;
				end
				RequestData_L1: begin
					case (convNum)
						'd0: caddr_rd = orin_iaddr;
						'd1: caddr_rd = orin_iaddr + 'd1;
						'd2: caddr_rd = orin_iaddr + 'd64;
						'd3: caddr_rd = orin_iaddr + 'd65;
					endcase
					csel = 'd0;
					crd = 'd1;
					cwr <= 'd0;
				end
				GetData_L1: begin
					// cdata_wr是可以讀取的嗎？
					// signed/unsigned compare
					case ($signed(cdata_rd)>$signed(kernelvalue))
						'd0: begin
							kernelvalue = kernelvalue;
						end
						'd1: begin
							kernelvalue = cdata_rd;
						end
					endcase
					convNum = convNum + 'd1;
				end
				Save2Mem1: begin
					// Round up
					case (kernelvalue[3:0]=='d0)	// check whether fraction of cdata_wr is zero
						'd0: begin
							kernelvalue[12:4] = kernelvalue[12:4] + 'd1;
							cdata_wr = {kernelvalue[12:4], 4'b0000};
						end
						'd1: begin
							cdata_wr = kernelvalue[12:0];
						end
					endcase
					// update memory reading address
					case (orin_iaddr[5:0]=='d62)
						'd0: orin_iaddr = orin_iaddr + 'd2;
						'd1: orin_iaddr = orin_iaddr + 'd66;
					endcase
					// for test
					// if (orin_iaddr=='d4030) begin
					if (orin_iaddr=='d4098) begin
						layer1_fin = 'b1;
					end
					// reset convNum
					convNum = 'd0;
					// save output to Layer1 memory
					csel = 'd1;
					crd = 'd0;
					cwr <= 'd1;
					kernelvalue = 'd0;
					caddr_wr = caddr_wr +'d1;
				end
				Result: begin
					busy <= 'd0;
				end
			endcase
		end
	end	

endmodule