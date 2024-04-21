//mouse is good but the background picture is not


`timescale 1ns/100ps
module clock_divide #(parameter n=27) (clk,clk_div);
    
    input clk;
    output clk_div;

    reg [n-1:0] num = 0;
    wire [n-1:0] next_num;

    always @(posedge clk) begin
        num<=next_num;
    end

    assign next_num=num+1;
    assign clk_div=num[n-1];
endmodule

module final (
    input clk,
    input rst,
    inout ps2c,
    inout ps2d,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output reg [6:0] DISPLAY,
    output reg [3:0] DIGIT,
    output [8:0] led
);

    wire [11:0] data;
    wire clk_25MHz;
    wire clk_div;
    wire [16:0] pixel_addr;
    reg [16:0] tmp_pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    reg [13:0] h_position = 3200;
    reg [13:0] v_position = 2400;


    reg [9:0] p_reg;  
    wire [9:0] p_next;
    reg [9:0] q_reg;  
    wire [9:0] q_next;  
    wire [8:0] xm;  
    wire [8:0] ym;
    wire [2:0] btnm;  
    wire m_done_tick;
    reg [8:0] tmp1;
    reg [8:0] tmp2;

    reg [3:0] seg;
    reg [1:0] stage = 0;

    
    color c0(h_position, v_position, valid, h_cnt, v_cnt, pixel, {vgaRed, vgaGreen, vgaBlue});
    

    clock_divide #(13) div0(.clk(clk),.clk_div(clk_div));
    clock_divide #(2) div1(clk, clk_25MHz);

    assign pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1))% 76800;  //640*480 --> 320*240

    mouse mouse_unit1  
    (.clk(clk), .reset(rst), .ps2d(ps2d), .ps2c(ps2c),  
    .xm(xm), .ym(ym), .btnm(btnm),  
    .m_done_tick(m_done_tick));

    always @(posedge clk, posedge rst) begin
        if (rst)  begin
            p_reg <= 0; 
            h_position = 3200;
        end
        else begin
            if(p_reg != p_next) begin
                if(p_reg[9:7] == 0 && p_next[9:7] == 3'b111) begin
                    if(h_position < tmp1) begin
                        h_position = 0;
                    end
                    else h_position = h_position - tmp1;
                end
                else if(p_reg[9:7] == 3'b111 && p_next[9:7] == 0) begin
                    if(h_position + tmp1 >= 6400) begin
                        h_position = 6400;
                    end
                    else h_position = h_position + tmp1;
                end
                else if(p_reg > p_next) begin
                    if(h_position < tmp1) begin
                        h_position = 0;
                    end
                    else h_position = h_position - tmp1;
                end
                else if(p_reg < p_next) begin
                    if(h_position + tmp1 >= 6400) begin
                        h_position = 6400;
                    end
                    else h_position = h_position + tmp1;
                end
            end
            p_reg <= p_next;
        end
    end

    always @(*) begin
        if(xm[8] == 0) begin //right
            tmp1 = xm[7:0] << 1;
        end
        else begin
            tmp1 = ~xm[7:0] << 1;
        end
    end


    assign p_next = (~m_done_tick) ? p_reg : // no activity   
           p_reg + {xm[8], xm};   // x movement 

    always @(posedge clk, posedge rst) begin
        if (rst)  begin
            q_reg <= 0; 
            v_position = 2400;
        end  
        else begin
            if(q_reg != q_next) begin
                if(q_reg[9:7] == 0 && q_next[9:7] == 3'b111) begin
                    if(v_position + tmp2 >= 4800) begin
                        v_position = 4800;
                    end
                    else v_position = v_position + tmp2;
                end
                else if(q_reg[9:7] == 3'b111 && q_next[9:7] == 0) begin
                    if(v_position < tmp2) begin
                        v_position = 0;
                    end
                    else v_position = v_position - tmp2;
                end
                else if(q_reg > q_next) begin
                    if(v_position + tmp2 >= 4800) begin
                        v_position = 4800;
                    end
                    else v_position = v_position + tmp2;
                end
                else if(q_reg < q_next) begin
                    if(v_position < tmp2) begin
                        v_position = 0;
                    end
                    else v_position = v_position - tmp2;
                end
            end
            q_reg <= q_next;
        end
    end

    always @(*) begin
        if(ym[8] == 0) begin //up?
            tmp2 = ym[7:0] << 1;
        end
        else begin
            tmp2 = ~ym[7:0] << 1;
        end
    end
    assign q_next = (~m_done_tick) ? q_reg : // no activity   
           q_reg + {ym[8], ym};   // y movement 
    


 
    blk_mem_gen_0 blk_mem_gen_0_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel)
    ); 

    vga_controller   vga_inst(
        .pclk(clk_25MHz),
        .reset(rst),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );

    always @(posedge clk_div) begin
        stage <= stage + 1'b1;
    end

    always @(*) begin
        case(stage) 
        2'b00:begin
            DIGIT = 4'b0111;
            seg = v_position / 1000;
        end 

        2'b01:begin
            DIGIT = 4'b1011;
            seg = (v_position % 1000) / 100;
        end

        2'b10:begin
            DIGIT = 4'b1101;
            seg = (v_position % 100) / 10;
        end

        2'b11:begin
            DIGIT = 4'b1110;
            seg = v_position % 10;
        end
        
        endcase
    end

    always @(*) begin
        case(seg)
        4'b0000: DISPLAY = 7'b1000000; //0 64
        4'b0001: DISPLAY = 7'b1111001; //1 121 
        4'b0010: DISPLAY = 7'b0100100; //2 36
        4'b0011: DISPLAY = 7'b0110000; //3 48
        4'b0100: DISPLAY = 7'b0011001; //4 25
        4'b0101: DISPLAY = 7'b0010010; //5 18
        4'b0110: DISPLAY = 7'b0000010; //6 2
        4'b0111: DISPLAY = 7'b1111000; //7 120
        4'b1000: DISPLAY = 7'b0000000; //8 0
        4'b1001: DISPLAY = 7'b0010000; //9 16
        4'b1010: DISPLAY = 7'b0001000; //10 A
        4'b1011: DISPLAY = 7'b0010010; //11 S
        4'b1100: DISPLAY = 7'b1000110; //12 C
        4'b1101: DISPLAY = 7'b0111111; //13 -
        default: DISPLAY = 7'b1111111;
        endcase
    end
      
endmodule
