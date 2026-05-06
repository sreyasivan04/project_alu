`timescale 1ns / 1ps
module ALU_rtl_design #(parameter WIDTH=4)
(OPA,OPB,CIN,CLK,RST,CMD,INP_VALID,CE,MODE,COUT,OFLOW,RES,G,E,L,ERR);
  input [WIDTH-1:0] OPA,OPB;
  input CLK,RST,CE,MODE,CIN;
  input [3:0] CMD;
  input [1:0] INP_VALID;
  output reg [2*WIDTH-1:0] RES = {(2*WIDTH){1'b0}};
  output reg COUT = 1'b0;
  output reg OFLOW = 1'b0;
  output reg G = 1'b0;
  output reg E = 1'b0;
  output reg L = 1'b0;
  output reg ERR = 1'b0;
localparam SHIFT = $clog2(WIDTH);

  reg [WIDTH-1:0] OPA_m, OPB_m;
  reg [1:0] count=2'b00;
 reg signed [WIDTH:0] temp;
    always@(posedge CLK or posedge RST)
      begin
         if(RST)                
          begin
            RES <= {(2*WIDTH){1'b0}};
            COUT<=1'b0;
            OFLOW<=1'b0;
            G<=1'b0;
            E<=1'b0;
            L<=1'b0;
            ERR<=1'b0;
           
          end
          else if (CE)
           begin
     
        if(MODE)          
         begin
          RES <= {(2*WIDTH){1'b0}};
            COUT<=1'b0;
            OFLOW<=1'b0;
            G<=1'b0;
            E<=1'b0;
            L<=1'b0;
            ERR<=1'b0;
          
          case(CMD)             
           4'b0000:            
            begin 
              if (INP_VALID==2'b11)
              begin            
              RES<=OPA+OPB;
             {COUT, RES[WIDTH-1:0]} <= {1'b0, OPA} + {1'b0, OPB};
              end
              else
              ERR<=1'b1;
            end
	   4'b0001:           
            begin
             if (INP_VALID==2'b11)
		begin
             OFLOW<=(OPA<OPB)?1:0;
             RES<=OPA-OPB;
            end
	    else
	     ERR<=1'b1;
	     end
           4'b0010:              
            begin
	       if (INP_VALID==2'b11)
		begin
		RES<= OPA+OPB+CIN;
             {COUT, RES[WIDTH-1:0]} <= OPA + OPB + CIN;
            end
	     else
	     ERR<=1'b1;
	     end
           4'b0011:               
           begin
            if (INP_VALID==2'b11)
		begin
            OFLOW<=(OPA<OPB)?1:0;
            RES<=OPA-OPB-CIN;
           end
            else
	     ERR<=1'b1;
	     end
	     
           4'b0100:          
             begin
              if(INP_VALID ==2'b01 || INP_VALID==2'b11)
                begin
               RES<=OPA+1;
              end
              else
		ERR<=1'b1;
	       end
                 
           4'b0101:            
              begin
              if(INP_VALID ==2'b01 || INP_VALID==2'b11)
                begin
                RES<=OPA-1;
                end
              else
		        ERR<=1'b1;
	          end  
 
           4'b0110:                    
               begin
              if(INP_VALID ==2'b10 || INP_VALID==2'b11)
                begin                 
                 RES<=OPB+1;
                end
                else
		ERR<=1'b1;
	       end
    
           4'b0111:                  
               begin
              if(INP_VALID ==2'b10 || INP_VALID==2'b11)
                begin 
                  RES<=OPB-1;
                end 
                 else
		ERR<=1'b1;
	       end

   
           4'b1000:              
           begin
            if(INP_VALID ==2'b11)
            begin
            if(OPA==OPB)
             begin
               E<=1'b1;
               G<=1'b0;
               L<=1'b0;
             end
            else if(OPA>OPB)
             begin
               E<=1'b0;
               G<=1'b1;
               L<=1'b0;
             end
            else 
             begin
               E<=1'b0;
               G<=1'b0;
               L<=1'b1;
             end
           end
           else
            ERR<=1'b1;
           end
         
          4'b1001:
          begin
        if (INP_VALID == 2'b11)
      begin
        case(count)

            2'd0:
            begin
                
                OPA_m <= OPA + 1;
                OPB_m <= OPB + 1;
                count <= 2'd1;
            end

            2'd1:
            begin

                count <= 2'd2; end

            2'd2:
            begin
                RES   <= OPA_m* OPB_m;
                count <= 2'd0;
            end

        endcase
    end
    else
    begin
        ERR   <= 1'b1;
        count <= 0;
    end
end
           
           4'b1010:
begin
    if (INP_VALID == 2'd3)
    begin
        case(count)

            2'd0:
            begin
                OPA_m <= OPA << 1;
                OPB_m <= OPB;
                count <= 2'd1;
            end

            2'd1:
            begin
                count <= 2'd2;
            end

            2'd2:
            begin
                RES   <= OPA_m * OPB_m;
                count <= 2'd0;
            end

        endcase
    end
    else
    begin
        ERR   <= 1'b1;
        count <= 0;
    end
end  


         4'b1011: begin   
    if (INP_VALID == 2'b11) begin

        temp = $signed(OPA) + $signed(OPB);

       RES <= temp;
        OFLOW <= (OPA[WIDTH-1] == OPB[WIDTH-1]) &&
                 (temp[WIDTH-1] != OPA[WIDTH-1]);
    end else begin
        ERR <= 1'b1;
    end
end
           4'b1100: begin   
    if (INP_VALID == 2'b11) begin

               temp = $signed(OPA) - $signed(OPB);
         RES <= temp;
        
        OFLOW <= (OPA[WIDTH-1] != OPB[WIDTH-1]) &&
                 (temp[WIDTH-1] != OPA[WIDTH-1]);

       
    end else begin
        ERR <= 1'b1;
    end
end
           default:     
            begin
            RES <= {(2*WIDTH){1'b0}};
            COUT<=1'b0;
            OFLOW<=1'b0;
            G<=1'b0;
            E<=1'b0;
            L<=1'b0;
            ERR<=1'b0;
           end
          endcase
         end

        else          
        begin 
           RES<='b0;
           COUT<=1'b0;
           OFLOW<=1'b0;
           G<=1'b0;
           E<=1'b0;
           L<=1'b0;
           ERR<=1'b0;
           case(CMD)    
             4'b0000:          
              begin
               if(INP_VALID==2'b11)
                RES <= {{(WIDTH){1'b0}}, (OPA & OPB)};
               else
                ERR<=1'b1;
               end     
             4'b0001:          
               begin
               if(INP_VALID==2'b11)
                 RES<={{(WIDTH){1'b0}},~(OPA&OPB)};
               else
                ERR<=1'b1;
               end
                 
             4'b0010:              
               begin
               if(INP_VALID==2'b11)
                 RES<={{(WIDTH){1'b0}},OPA|OPB}; 
               else
                ERR<=1'b1;
               end
   
             4'b0011:          
               begin
               if(INP_VALID==2'b11)
                 RES<={{(WIDTH){1'b0}},~(OPA|OPB)};
               else
                ERR<=1'b1;
               end

                
             4'b0100:            
              begin
               if(INP_VALID==2'b11)
                 RES<={{(WIDTH){1'b0}},OPA^OPB}; 
               else
                ERR<=1'b1;
               end
    
             4'b0101:        
		begin
               if(INP_VALID==2'b11)
                RES<={{(WIDTH){1'b0}},~(OPA^OPB)};
                else
                ERR<=1'b1;
               end
  
             4'b0110:             
              begin
               if(INP_VALID==2'b01 || INP_VALID==2'b11)
                 RES<={{(WIDTH){1'b0}},~OPA};  
               else
                ERR<=1'b1;
               end

             4'b0111:            
              begin
               if(INP_VALID==2'b10 || INP_VALID==2'b11)
                 RES<={{(WIDTH){1'b0}},~OPB}; 
               else
                ERR<=1'b1;
               end    

             4'b1000:              
               begin
               if(INP_VALID==2'b01 || INP_VALID==2'b11)
                 RES<={{(WIDTH){1'b0}},OPA>>1}; 
                else
                ERR<=1'b1;
               end  

             4'b1001:             
              begin
               if(INP_VALID==2'b01 || INP_VALID==2'b11)
                RES<={{(WIDTH){1'b0}},OPA<<1}; 
               else
                ERR<=1'b1;
               end   
   
             4'b1010:               
               begin
               if(INP_VALID==2'b10 || INP_VALID==2'b11)
                RES<={{(WIDTH){1'b0}},OPB>>1}; 
               else
                ERR<=1'b1;
               end     

             4'b1011:             
              begin
               if(INP_VALID==2'b10 || INP_VALID==2'b11)
                RES<={{(WIDTH){1'b0}},OPB<<1};
               else
                ERR<=1'b1;
               end
    
            4'b1100: begin                
              if (INP_VALID == 2'b11) begin
                 if (|OPB[WIDTH-1:SHIFT]) begin
                   ERR<= 1'b1;
                end else begin
                    RES <= {{(WIDTH){1'b0}}, (OPA << OPB[SHIFT-1:0]) | (OPA >> (WIDTH - OPB[SHIFT-1:0]))};
                   end
                  end else begin
                   ERR <= 1'b1;
                    end
                  end
            4'b1101: begin                         
             if (INP_VALID == 2'b11) begin
               if (|OPB[WIDTH-1:SHIFT]) begin
                  ERR <= 1'b1;
                end else begin
                  RES <= {{(WIDTH){1'b0}}, (OPA >> OPB[SHIFT-1:0]) | (OPA << (WIDTH - OPB[SHIFT-1:0]))};
                end
                end else begin
                 ERR <= 1'b1;
                 end
                end
             default:   
               begin
               RES <= {(2*WIDTH){1'b0}};
               COUT<=1'b0;
               OFLOW<=1'b0;
               G<=1'b0;
               E<=1'b0;
               L<=1'b0;
               ERR<=1'b0;
               end
          endcase
     end
    end
   end
endmodule


