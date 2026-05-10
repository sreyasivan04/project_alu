`timescale 1ns/1ps

        module alu_testbench;
     parameter WIDTH=4, C=4;    
    reg [WIDTH-1:0] OPA, OPB;
    reg CLK, RST, CE, MODE, CIN;
    reg [1:0] INP_VALID;
    reg [C-1:0] CMD;
    
    
    wire [2*WIDTH-1:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;

    wire [2*WIDTH-1:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;

    
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;

   
    ALU_Design #(.N(WIDTH) ,.C(C)) dut (
        .OPA(OPA), .OPB(OPB), .CIN(CIN),
        .CLK(CLK), .RST(RST), .CMD(CMD),
        .CE(CE), .MODE(MODE),.INP_VALID(INP_VALID),
        .COUT(COUT_dut), .OFLOW(OFLOW_dut),
        .RES(RES_dut),
        .G(G_dut), .E(E_dut), .L(L_dut),
        .ERR(ERR_dut)
    );

  
    alu_reference_model #(.WIDTH(WIDTH)) ref (
        .OPA(OPA), .OPB(OPB), .CIN(CIN),
        .MODE(MODE), .CMD(CMD),.INP_VALID(INP_VALID),
        .CE(CE),
        .RES(RES_ref),
        .COUT(COUT_ref), .OFLOW(OFLOW_ref),
        .G(G_ref), .E(E_ref), .L(L_ref),
        .ERR(ERR_ref)
    );

   
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    
    initial begin
      
        RST = 1; CE = 1; CIN = 0;
        OPA = 0; OPB = 0; MODE = 0; CMD = 0;
        
        @(posedge CLK);
        RST = 0;  
        @(posedge CLK);

        
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();

        
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        
        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");

        #100;
        $finish;
    end

    
    task test_arithmetic();
        begin
            
            apply_test(4'd15, 4'd15, 4'b0000, 2'b11, "ADD (cout,max+max)",2);
            apply_test(4'd0, 4'd0, 4'b0000, 2'b11, "ADD(min+min",2);
            apply_test(4'd15, 4'd15, 4'b1111, 2'b11, "ADD(ERR,invalid command)",2);
            apply_test(4'd15, 4'd15, 4'b0000, 2'b01, "ADD(ERR,invalid input)",2);
            apply_test(4'd10, 4'd1, 4'b0000, 2'b11, "ADD(basic)",2);
            
          
            apply_test(4'd15, 4'd15, 4'b0001,2'b11, "SUB(max-max)",2);
            apply_test(4'd0, 4'd0, 4'b0001,2'b11, "SUB(min-min)",2);
            apply_test(4'd7, 4'd15, 4'b0001,2'b11, "SUB(overflow)",2);
            apply_test(4'd15, 4'd15, 4'b0001,2'b01, "SUB(invalid input)",2);
            apply_test(4'd10, 4'd5, 4'b1111,2'b11, "SUB(invalid command)",2);
            
            
            CIN = 1;
            apply_test(4'd10, 4'd5,  4'b0010, 2'b11, "ADD_CIN(basic)",2);
            apply_test(4'd15, 4'd15, 4'b0010, 2'b11, "ADD_CIN(cout)",2);
            apply_test(4'd0,  4'd0,  4'b0010, 2'b11, "ADD_CIN(min+min)",2);
            apply_test(4'd15, 4'd15, 4'b0010, 2'b01, "ADD_CIN(invalid input)",2);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "ADD_CIN(invalid command)",2);
            CIN = 0;
            
            CIN = 1;
            apply_test(4'd10, 4'd5, 4'b0011, 2'b11,"SUB_CIN(no borrow)", 2);
            apply_test(4'd5, 4'd10, 4'b0011, 2'b11,"SUB_CIN(borrow)", 2);
            apply_test(4'd0, 4'd0, 4'b0011, 2'b11,"SUB_CIN(CIN borrow)", 2);
            apply_test(4'd8, 4'd7, 4'b0011, 2'b11, "SUB_CIN(zero result)", 2);
            apply_test(4'd15, 4'd15, 4'b0011, 2'b11,"SUB_CIN(equal operands)", 2);
            CIN = 0;
            
            
            
            apply_test(4'd15, 4'd0, 4'b0100, 2'b01, "INC_A(only A valid)",2);
            apply_test(4'd15, 4'd0, 4'b0100, 2'b11, "INC_A(both valid)",2);
            apply_test(4'd0,  4'd0, 4'b0100, 2'b01, "INC_A(min)",2);
            apply_test(4'd10, 4'd0, 4'b0100, 2'b01, "INC_A(basic)",2);
            apply_test(4'd10, 4'd0, 4'b0100, 2'b00, "INC_A(invalid input)",2);
            apply_test(4'd10, 4'd0, 4'b1111, 2'b01, "INC_A(invalid command)",2);

            
            apply_test(4'd15, 4'd0, 4'b0101, 2'b01, "DEC_A(only A valid)",2);
            apply_test(4'd15, 4'd0, 4'b0101, 2'b11, "DEC_A(both valid)",2);
            apply_test(4'd0,  4'd0, 4'b0101, 2'b01, "DEC_A(min)",2);
            apply_test(4'd10, 4'd0, 4'b0101, 2'b01, "DEC_A(basic)",2);
            apply_test(4'd10, 4'd0, 4'b0101, 2'b00, "DEC_A(invalid input)",2);
            apply_test(4'd10, 4'd0, 4'b1111, 2'b01, "DEC_A(invalid command)",2);
            
            
             
            apply_test(4'd0, 4'd15, 4'b0110, 2'b10, "INC_B(only B valid)",2);
            apply_test(4'd0, 4'd15, 4'b0110, 2'b11, "INC_B(both valid)",2);
            apply_test(4'd0, 4'd0,  4'b0110, 2'b10, "INC_B(min)",2);
            apply_test(4'd0, 4'd10, 4'b0110, 2'b10, "INC_B(basic)",2);
            apply_test(4'd0, 4'd10, 4'b0110, 2'b00, "INC_B(invalid input)",2);
            apply_test(4'd0, 4'd10, 4'b1111, 2'b10, "INC_B(invalid command)",2);

            
            apply_test(4'd0, 4'd15, 4'b0111, 2'b10, "DEC_B(only B valid)",2);
            apply_test(4'd0, 4'd15, 4'b0111, 2'b11, "DEC_B(both valid)",2);
            apply_test(4'd0, 4'd0,  4'b0111, 2'b10, "DEC_B(min)",2);
            apply_test(4'd0, 4'd10, 4'b0111, 2'b10, "DEC_B(basic)",2);
            apply_test(4'd0, 4'd10, 4'b0111, 2'b00, "DEC_B(invalid input)",2);
            apply_test(4'd0, 4'd10, 4'b1111, 2'b10, "DEC_B(invalid command)",2);
            
             
            apply_test(4'd10, 4'd10, 4'b1000, 2'b11, "CMP(equal)",2);
            apply_test(4'd15, 4'd10, 4'b1000, 2'b11, "CMP(greater)",2);
            apply_test(4'd5,  4'd10, 4'b1000, 2'b11, "CMP(less)",2);
            apply_test(4'd0,  4'd0,  4'b1000, 2'b11, "CMP(min=min)",2);
            apply_test(4'd15, 4'd15, 4'b1000, 2'b11, "CMP(max=max)",2);
            apply_test(4'd10, 4'd5,  4'b1000, 2'b00, "CMP(invalid input)",2);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "CMP(invalid command)",2);
            
           
            apply_test(4'd0,  4'd0,  4'b1001, 2'b11, "CMD9(min)",3);
            apply_test(4'd2,  4'd3,  4'b1001, 2'b11, "CMD9(basic)",3);
            apply_test(4'd15, 4'd15, 4'b1001, 2'b11, "CMD9(max)",3);
            apply_test(4'd7,  4'd8,  4'b1001, 2'b11, "CMD9(mixed)",3);
            apply_test(4'd10, 4'd5,  4'b1001, 2'b00, "CMD9(invalid input)",3);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "CMD9(invalid command)",3);
            
                    
            apply_test(4'd0,  4'd0,  4'b1010, 2'b11, "CMD10(min)",3);
            apply_test(4'd2,  4'd3,  4'b1010, 2'b11, "CMD10(basic)",3);
            apply_test(4'd15, 4'd15, 4'b1010, 2'b11, "CMD10(max)",3);
            apply_test(4'd8,  4'd2,  4'b1010, 2'b11, "CMD10(shift overflow)",3);
            apply_test(4'd10, 4'd5,  4'b1010, 2'b00, "CMD10(invalid input)",3);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "CMD10(invalid command)",3);
            
           
            apply_test(4'd5,  4'd5,  4'b1011, 2'b11, "CMD11(equal)",2);
            apply_test(4'd6,  4'd2,  4'b1011, 2'b11, "CMD11(greater)",2);
            apply_test(4'd2,  4'd6,  4'b1011, 2'b11, "CMD11(less)",2);
            apply_test(4'd15, 4'd14, 4'b1011, 2'b11, "CMD11(-1 > -2)",2);
            apply_test(4'd14, 4'd15, 4'b1011, 2'b11, "CMD11(-2 < -1)",2);
            apply_test(4'd7,  4'd1,  4'b1011, 2'b11, "CMD11(overflow +)",2);
            apply_test(4'd8,  4'd15, 4'b1011, 2'b11, "CMD11(overflow -)",2);
            apply_test(4'd7,  4'd15, 4'b1011, 2'b11, "CMD11(+7 + -1)",2);
            apply_test(4'd0,  4'd0,  4'b1011, 2'b11, "CMD11(0+0)",2);
            apply_test(4'd10, 4'd5,  4'b1011, 2'b00, "CMD11(invalid input)",2);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "CMD11(invalid command)",2);
            
           
        
            apply_test(4'd5,  4'd5,  4'b1100, 2'b11, "CMD12(equal)",2);
            apply_test(4'd6,  4'd2,  4'b1100, 2'b11, "CMD12(greater)",2);
            apply_test(4'd2,  4'd6,  4'b1100, 2'b11, "CMD12(less)",2);
            apply_test(4'd15, 4'd14, 4'b1100, 2'b11, "CMD12(-1 > -2)",2);
            apply_test(4'd14, 4'd15, 4'b1100, 2'b11, "CMD12(-2 < -1)",2);
            apply_test(4'd7,  4'd15, 4'b1100, 2'b11, "CMD12(overflow +)",2);
            apply_test(4'd8,  4'd1,  4'b1100, 2'b11, "CMD12(overflow -)",2);
            apply_test(4'd5,  4'd15, 4'b1100, 2'b11, "CMD12(+5 - -1)",2);
            apply_test(4'd15, 4'd5,  4'b1100, 2'b11, "CMD12(-1 - +5)",2);
            apply_test(4'd0,  4'd0,  4'b1100, 2'b11, "CMD12(0-0)",2);
            apply_test(4'd10, 4'd5,  4'b1100, 2'b00, "CMD12(invalid input)",2);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "CMD12(invalid command)",2);       
        end
    endtask

    
    task test_logical();
        begin
        
            
            apply_test(4'b1010, 4'b1100, 4'b0000, 2'b11, "AND(basic)",2);
            apply_test(4'b1111, 4'b1111, 4'b0000, 2'b11, "AND(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b0000, 2'b11, "AND(all zeros)",2);
            apply_test(4'b1111, 4'b0000, 4'b0000, 2'b11, "AND(one zero)",2);
            apply_test(4'b1010, 4'b0101, 4'b0000, 2'b11, "AND(alternate)",2);
            apply_test(4'b1000, 4'b1000, 4'b0000, 2'b11, "AND(MSB)",2);
            apply_test(4'b0001, 4'b0001, 4'b0000, 2'b11, "AND(LSB)",2);
            apply_test(4'b0110, 4'b1011, 4'b0000, 2'b11, "AND(random)",2);
            apply_test(4'b1010, 4'b1100, 4'b0000, 2'b00, "AND(invalid input)",2);
            apply_test(4'b1010, 4'b1100, 4'b0000, 2'b01, "AND(only A valid)",2);
            apply_test(4'b1010, 4'b1100, 4'b0000, 2'b10, "AND(only B valid)",2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "AND(invalid command)",2);
            
            apply_test(4'b1010, 4'b1100, 4'b0001, 2'b11, "NAND(basic)",2);
            apply_test(4'b1111, 4'b1111, 4'b0001, 2'b11, "NAND(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b0001, 2'b11, "NAND(all zeros)",2);
            apply_test(4'b1111, 4'b0000, 4'b0001, 2'b11, "NAND(one zero)",2);
            apply_test(4'b1010, 4'b0101, 4'b0001, 2'b11, "NAND(alternate)",2);
            apply_test(4'b1000, 4'b1000, 4'b0001, 2'b11, "NAND(MSB)",2);
            apply_test(4'b0001, 4'b0001, 4'b0001, 2'b11, "NAND(LSB)",2);
            apply_test(4'b0110, 4'b1011, 4'b0001, 2'b11, "NAND(random)",2);
            apply_test(4'b1010, 4'b1100, 4'b0001, 2'b00, "NAND(invalid input)",2);
            apply_test(4'b1010, 4'b1100, 4'b0001, 2'b01, "NAND(only A valid)",2);
            apply_test(4'b1010, 4'b1100, 4'b0001, 2'b10, "NAND(only B valid)",2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "NAND(invalid command)",2);


            apply_test(4'b1010, 4'b1100, 4'b0010, 2'b11, "OR(basic)",2);
            apply_test(4'b1111, 4'b1111, 4'b0010, 2'b11, "OR(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b0010, 2'b11, "OR(all zeros)",2);
            apply_test(4'b1111, 4'b0000, 4'b0010, 2'b11, "OR(one zero)",2);
            apply_test(4'b1010, 4'b0101, 4'b0010, 2'b11, "OR(alternate)",2);
            apply_test(4'b1000, 4'b0000, 4'b0010, 2'b11, "OR(MSB)",2);
            apply_test(4'b0001, 4'b0000, 4'b0010, 2'b11, "OR(LSB)",2);
            apply_test(4'b0110, 4'b1011, 4'b0010, 2'b11, "OR(random)",2);
            apply_test(4'b1010, 4'b1100, 4'b0010, 2'b00, "OR(invalid input)",2);
            apply_test(4'b1010, 4'b1100, 4'b0010, 2'b01, "OR(only A valid)",2);
            apply_test(4'b1010, 4'b1100, 4'b0010, 2'b10, "OR(only B valid)",2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "OR(invalid command)",2);

         
            apply_test(4'b1010, 4'b1100, 4'b0011, 2'b11, "NOR(basic)",2);
            apply_test(4'b1111, 4'b1111, 4'b0011, 2'b11, "NOR(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b0011, 2'b11, "NOR(all zeros)",2);
            apply_test(4'b1111, 4'b0000, 4'b0011, 2'b11, "NOR(one zero)",2);
            apply_test(4'b1010, 4'b0101, 4'b0011, 2'b11, "NOR(alternate)",2);
            apply_test(4'b1000, 4'b0000, 4'b0011, 2'b11, "NOR(MSB)",2);
            apply_test(4'b0001, 4'b0000, 4'b0011, 2'b11, "NOR(LSB)",2);
            apply_test(4'b0110, 4'b1011, 4'b0011, 2'b11, "NOR(random)",2);
            apply_test(4'b1010, 4'b1100, 4'b0011, 2'b00, "NOR(invalid input)",2);
            apply_test(4'b1010, 4'b1100, 4'b0011, 2'b01, "NOR(only A valid)",2);
            apply_test(4'b1010, 4'b1100, 4'b0011, 2'b10, "NOR(only B valid)",2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "NOR(invalid command)",2);
            
            
            apply_test(4'b1010, 4'b1100, 4'b0100, 2'b11, "XOR(basic)",2);
            apply_test(4'b1111, 4'b1111, 4'b0100, 2'b11, "XOR(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b0100, 2'b11, "XOR(all zeros)",2);
            apply_test(4'b1111, 4'b0000, 4'b0100, 2'b11, "XOR(opposite)",2);
            apply_test(4'b1010, 4'b0101, 4'b0100, 2'b11, "XOR(alternate)",2);
            apply_test(4'b1000, 4'b1000, 4'b0100, 2'b11, "XOR(MSB)",2);
            apply_test(4'b0001, 4'b0001, 4'b0100, 2'b11, "XOR(LSB)",2);
            apply_test(4'b0110, 4'b1011, 4'b0100, 2'b11, "XOR(random)",2);
            apply_test(4'b1010, 4'b1100, 4'b0100, 2'b00, "XOR(invalid input)",2);
            apply_test(4'b1010, 4'b1100, 4'b0100, 2'b01, "XOR(only A valid)",2);
            apply_test(4'b1010, 4'b1100, 4'b0100, 2'b10, "XOR(only B valid)",2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "XOR(invalid command)",2);
            
           
           apply_test(4'b1010, 4'b1100, 4'b0101, 2'b11, "XNOR(basic)",2);
           apply_test(4'b1111, 4'b1111, 4'b0101, 2'b11, "XNOR(all ones)",2);
           apply_test(4'b0000, 4'b0000, 4'b0101, 2'b11, "XNOR(all zeros)",2);
           apply_test(4'b1111, 4'b0000, 4'b0101, 2'b11, "XNOR(opposite)",2);
           apply_test(4'b1010, 4'b0101, 4'b0101, 2'b11, "XNOR(alternate)",2);
           apply_test(4'b1000, 4'b1000, 4'b0101, 2'b11, "XNOR(MSB)",2);
           apply_test(4'b0001, 4'b0001, 4'b0101, 2'b11, "XNOR(LSB)",2);
           apply_test(4'b0110, 4'b1011, 4'b0101, 2'b11, "XNOR(random)",2);
           apply_test(4'b1010, 4'b1100, 4'b0101, 2'b00, "XNOR(invalid input)",2);
           apply_test(4'b1010, 4'b1100, 4'b0101, 2'b01, "XNOR(only A valid)",2);
           apply_test(4'b1010, 4'b1100, 4'b0101, 2'b10, "XNOR(only B valid)",2);
           apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "XNOR(invalid command)",2);
            
            
            apply_test(4'b1010, 4'b0000, 4'b0110, 2'b01, "NOT_A(basic)",2);
            apply_test(4'b1111, 4'b0000, 4'b0110, 2'b01, "NOT_A(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b0110, 2'b01, "NOT_A(all zeros)",2);
            apply_test(4'b1000, 4'b0000, 4'b0110, 2'b01, "NOT_A(MSB)",2);
            apply_test(4'b0001, 4'b0000, 4'b0110, 2'b01, "NOT_A(LSB)",2);
            apply_test(4'b1010, 4'b0000, 4'b0110, 2'b11, "NOT_A(both valid)",2);
            apply_test(4'b1010, 4'b0000, 4'b0110, 2'b00, "NOT_A(invalid input)",2);
            apply_test(4'b1010, 4'b0000, 4'b0110, 2'b10, "NOT_A(only B valid)",2);
            apply_test(4'b1010, 4'b0000, 4'b1111, 2'b01, "NOT_A(invalid command)",2);

            
            apply_test(4'b0000, 4'b1010, 4'b0111, 2'b10, "NOT_B(basic)",2);
            apply_test(4'b0000, 4'b1111, 4'b0111, 2'b10, "NOT_B(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b0111, 2'b10, "NOT_B(all zeros)",2);
            apply_test(4'b0000, 4'b1000, 4'b0111, 2'b10, "NOT_B(MSB)",2);
            apply_test(4'b0000, 4'b0001, 4'b0111, 2'b10, "NOT_B(LSB)",2);
            apply_test(4'b0000, 4'b1010, 4'b0111, 2'b11, "NOT_B(both valid)",2);
            apply_test(4'b0000, 4'b1010, 4'b0111, 2'b00, "NOT_B(invalid input)",2);
            apply_test(4'b0000, 4'b1010, 4'b0111, 2'b01, "NOT_B(only A valid)",2);
            apply_test(4'b0000, 4'b1010, 4'b1111, 2'b10, "NOT_B(invalid command)",2);
            
            
            apply_test(4'b1010, 4'b0000, 4'b1000, 2'b01, "SHR1_A(basic)",2);
            apply_test(4'b1111, 4'b0000, 4'b1000, 2'b01, "SHR1_A(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b1000, 2'b01, "SHR1_A(all zeros)",2);
            apply_test(4'b1000, 4'b0000, 4'b1000, 2'b01, "SHR1_A(MSB)",2);
            apply_test(4'b0001, 4'b0000, 4'b1000, 2'b01, "SHR1_A(LSB)",2);
            apply_test(4'b1010, 4'b0000, 4'b1000, 2'b11, "SHR1_A(both valid)",2);
            apply_test(4'b1010, 4'b0000, 4'b1000, 2'b00, "SHR1_A(invalid input)",2);
            apply_test(4'b1010, 4'b0000, 4'b1000, 2'b10, "SHR1_A(only B valid)",2);
            apply_test(4'b1010, 4'b0000, 4'b1111, 2'b01, "SHR1_A(invalid command)",2);

            apply_test(4'b1010, 4'b0000, 4'b1001, 2'b01, "SHL1_A(basic)",2);
            apply_test(4'b1111, 4'b0000, 4'b1001, 2'b01, "SHL1_A(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b1001, 2'b01, "SHL1_A(all zeros)",2);
            apply_test(4'b1000, 4'b0000, 4'b1001, 2'b01, "SHL1_A(MSB)",2);
            apply_test(4'b0001, 4'b0000, 4'b1001, 2'b01, "SHL1_A(LSB)",2);
            apply_test(4'b1010, 4'b0000, 4'b1001, 2'b11, "SHL1_A(both valid)",2);
            apply_test(4'b1010, 4'b0000, 4'b1001, 2'b00, "SHL1_A(invalid input)",2);
            apply_test(4'b1010, 4'b0000, 4'b1001, 2'b10, "SHL1_A(only B valid)",2);
            apply_test(4'b1010, 4'b0000, 4'b1111, 2'b01, "SHL1_A(invalid command)",2);
            
            apply_test(4'b0000, 4'b1010, 4'b1010, 2'b10, "SHR1_B(basic)",2);
            apply_test(4'b0000, 4'b1111, 4'b1010, 2'b10, "SHR1_B(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b1010, 2'b10, "SHR1_B(all zeros)",2);
            apply_test(4'b0000, 4'b1000, 4'b1010, 2'b10, "SHR1_B(MSB)",2);
            apply_test(4'b0000, 4'b0001, 4'b1010, 2'b10, "SHR1_B(LSB)",2);
            apply_test(4'b0000, 4'b1010, 4'b1010, 2'b11, "SHR1_B(both valid)",2);
            apply_test(4'b0000, 4'b1010, 4'b1010, 2'b00, "SHR1_B(invalid input)",2);
            apply_test(4'b0000, 4'b1010, 4'b1010, 2'b01, "SHR1_B(only A valid)",2);
            apply_test(4'b0000, 4'b1010, 4'b1111, 2'b10, "SHR1_B(invalid command)",2);

         
            apply_test(4'b0000, 4'b1010, 4'b1011, 2'b10, "SHL1_B(basic)",2);
            apply_test(4'b0000, 4'b1111, 4'b1011, 2'b10, "SHL1_B(all ones)",2);
            apply_test(4'b0000, 4'b0000, 4'b1011, 2'b10, "SHL1_B(all zeros)",2);
            apply_test(4'b0000, 4'b1000, 4'b1011, 2'b10, "SHL1_B(MSB)",2);
            apply_test(4'b0000, 4'b0001, 4'b1011, 2'b10, "SHL1_B(LSB)",2);
            apply_test(4'b0000, 4'b1010, 4'b1011, 2'b11, "SHL1_B(both valid)",2);
            apply_test(4'b0000, 4'b1010, 4'b1011, 2'b00, "SHL1_B(invalid input)",2);
            apply_test(4'b0000, 4'b1010, 4'b1011, 2'b01, "SHL1_B(only A valid)",2);
            apply_test(4'b0000, 4'b1010, 4'b1111, 2'b10, "SHL1_B(invalid command)",2);


            apply_test(4'b1010, 4'b0000, 4'b1100, 2'b11, "ROL_A_B(rot0)",2);
            apply_test(4'b1010, 4'b0001, 4'b1100, 2'b11, "ROL_A_B(rot1)",2);
            apply_test(4'b1010, 4'b0010, 4'b1100, 2'b11, "ROL_A_B(rot2)",2);
            apply_test(4'b1010, 4'b0011, 4'b1100, 2'b11, "ROL_A_B(rot3)",2);
            apply_test(4'b1111, 4'b0001, 4'b1100, 2'b11, "ROL_A_B(all ones)",2);
            apply_test(4'b0000, 4'b0010, 4'b1100, 2'b11, "ROL_A_B(all zeros)",2);
            apply_test(4'b1001, 4'b0001, 4'b1100, 2'b11, "ROL_A_B(pattern1)",2);
            apply_test(4'b0110, 4'b0010, 4'b1100, 2'b11, "ROL_A_B(pattern2)",2);
            apply_test(4'b1010, 4'b1000, 4'b1100, 2'b11, "ROL_A_B(ERR upper bit)",2);
            apply_test(4'b1010, 4'b1111, 4'b1100, 2'b11, "ROL_A_B(ERR upper nibble)",2);
            apply_test(4'b1010, 4'b0001, 4'b1100, 2'b01, "ROL_A_B(only A valid)",2);
            apply_test(4'b1010, 4'b0001, 4'b1100, 2'b10, "ROL_A_B(only B valid)",2);
            apply_test(4'b1010, 4'b0001, 4'b1100, 2'b00, "ROL_A_B(invalid input)",2);
            apply_test(4'b1010, 4'b0001, 4'b1111, 2'b11, "ROL_A_B(invalid command)",2);


            apply_test(4'b1010, 4'b0000, 4'b1101, 2'b11, "ROR_A_B(rot0)",2);
            apply_test(4'b1010, 4'b0001, 4'b1101, 2'b11, "ROR_A_B(rot1)",2);
            apply_test(4'b1010, 4'b0010, 4'b1101, 2'b11, "ROR_A_B(rot2)",2);
            apply_test(4'b1010, 4'b0011, 4'b1101, 2'b11, "ROR_A_B(rot3)",2);
            apply_test(4'b1111, 4'b0001, 4'b1101, 2'b11, "ROR_A_B(all ones)",2);
            apply_test(4'b0000, 4'b0010, 4'b1101, 2'b11, "ROR_A_B(all zeros)",2);
            apply_test(4'b1001, 4'b0001, 4'b1101, 2'b11, "ROR_A_B(pattern1)",2);
            apply_test(4'b0110, 4'b0010, 4'b1101, 2'b11, "ROR_A_B(pattern2)",2);
            apply_test(4'b1010, 4'b1000, 4'b1101, 2'b11, "ROR_A_B(ERR upper bit)",2);
            apply_test(4'b1010, 4'b1111, 4'b1101, 2'b11, "ROR_A_B(ERR upper nibble)",2);
            apply_test(4'b1010, 4'b0001, 4'b1101, 2'b01, "ROR_A_B(only A valid)",2);
            apply_test(4'b1010, 4'b0001, 4'b1101, 2'b10, "ROR_A_B(only B valid)",2);
            apply_test(4'b1010, 4'b0001, 4'b1101, 2'b00, "ROR_A_B(invalid input)",2);
            apply_test(4'b1010, 4'b0001, 4'b1111, 2'b11, "ROR_A_B(invalid command)",2);
           
        end
    endtask

   
   task apply_test 
(
    input [WIDTH-1:0] a, b,
    input [3:0] cmd,
    input [1:0] inp_valid,
    input [80*8:1] test_name,
    input integer wait_cycles
);
integer i;

begin


    @(negedge CLK);

    OPA = a;
    OPB = b;
    CMD = cmd;
    INP_VALID = inp_valid;


    for(i=0; i<=wait_cycles; i=i+1)
        @(posedge CLK);


    test_count = test_count + 1;

    if(compare_outputs(1'b0)) begin
        $display("[PASS] %s", test_name);
        pass_count = pass_count + 1;
    end
    else begin
        $display("[FAIL] %s", test_name);
        display_mismatch();
        fail_count = fail_count + 1;
    end

end
endtask

    
  function [0:0] compare_outputs;
input dummy;

begin
    compare_outputs =
        (RES_dut    === RES_ref)   &&
        (COUT_dut  === COUT_ref)  &&
        (OFLOW_dut === OFLOW_ref) &&
        (G_dut     === G_ref)     &&
        (E_dut     === E_ref)     &&
        (L_dut     === L_ref)     &&
        (ERR_dut   === ERR_ref);
end
endfunction

    
   

   
    task display_mismatch();
        begin
            $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_dut, COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut);
            $display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_ref, COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref);
        end
    endtask

    
    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, alu_testbench);
    end

endmodule

