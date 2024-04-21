//movetype need to be rewrite as cnt[5:3]
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
    input [3:0] sw,
    input [1:0] in_way,
    input [4:0] enable,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue,
    output hsync,
    output vsync,
    output reg [6:0] DISPLAY,
    output reg [3:0] DIGIT,
    output [8:0] led
);

    parameter total_time = 300;

    parameter  [7:0] fish_way = 8'b10110010;
    parameter  [7:0] fish_way1 = 8'b10110010;
    parameter  [7:0] fish_way2 = 8'b01001101;
    parameter  [7:0] fish_way3 = 8'b10110010;
    parameter  [7:0] fish_way4 = 8'b01001101;
    parameter  [7:0] fish_way5 = 8'b10110010;
    parameter  [7:0] fish_way6 = 8'b01001101;
    parameter  [7:0] fish_way7 = 8'b10110010;
    parameter  [7:0] fish_way8 = 8'b01001101;

    parameter [9:0] fish_appear_v [0:7] = {
        10'd415, 10'd235, 10'd295, 10'd325,
        10'd445 ,10'd385, 10'd265, 10'd355
    };
    parameter [9:0] fast_appear_v [0:3] = {
        10'd360, 10'd310, 10'd410, 10'd260
    };


    wire [11:0] data;
    wire clk_25MHz;
    wire clk_div;
    wire clk_21;
    wire clk_19;
    wire clk_20;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    reg [13:0] h_position = 3200;
    reg [13:0] v_position = 2400;

    //for one second
    wire pause;
    wire state;
    assign pause = enable[1];
    assign state = enable[2];
    wire one_second_enable;

    one_second sc1(clk, rst, pause, state, one_second_enable);


    reg [9:0] playtime;
    reg [5:0] score = 0;

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            playtime = 0;
        end
        else if(state == 1'b0) begin
            playtime = 0;
        end
        else if(pause == 1'b0 && one_second_enable == 1'b1) begin
            if(playtime == 500) begin
                playtime = 0;
            end
            else begin
                playtime = playtime + 1;
            end
        end
    end

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



    clock_divide #(13) div0(.clk(clk),.clk_div(clk_div));
    clock_divide #(2) div1(clk, clk_25MHz);
    clock_divide #(21) div21(clk, clk_21);
    clock_divide #(20) div20(clk, clk_20);
    clock_divide #(19) div19(clk, clk_19);

    //fast (fish)
    reg fast_appear = 0;
    reg [9:0] fast_h_position = 0;
    reg [9:0] fast_v_position = 0;
    reg fast_way = 0;
    reg [1:0] fast_movetype = 0;
    reg stolen = 0;
    reg fast_reach_top = 0;

    reg n_fast_appear = 0;
    reg [9:0] n_fast_h_position = 0;
    reg [9:0] n_fast_v_position = 0;
    reg n_fast_way = 0;
    reg [1:0] n_fast_movetype = 0;
    reg n_stolen = 0;
    reg n_fast_reach_top = 0;
    //get fish color
    wire [11:0] fast_color;
    wire fast_back; // 1 for print background 0 for print fish
    

    reg [23:0] cnt1; //for fish1

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            cnt1 = 0;
        end
        else if(cnt1 == 2000000) begin
            cnt1 = 0;
        end
        else begin
            cnt1 = cnt1 + 1;
        end
    end

    reg [23:0] cnt2; //for fast

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            cnt2 = 0;
        end
        else if(cnt2 == 660000) begin
            cnt2 = 0;
        end
        else begin
            cnt2 = cnt2 + 1;
        end
    end



    

    wire [11:0] bait_color;
    wire bait_back; // 1 for print background 0 for print fish
    reg [1:0] bait_mode = 2'b10;
    reg [1:0] bait_cnt;
    reg cut = 0;
    reg [9:0] cut_v = 0;
    bait bait1(bait_mode, h_cnt, v_cnt, v_position, bait_back, bait_color);

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            bait_mode = 2'b10;
            bait_cnt = 2'b00;
            cut = 0;
            cut_v = 0;
            score = 0;
        end
        else if(bait_mode == 2'b01) begin
            if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                bait_mode = 2'b10;
            end
            else begin
                bait_mode = 2'b01;
            end
        end
        else if(bait_mode == 2'b10) begin
            if(stolen == 1) begin
                bait_mode = 2'b01;
            end
            else bait_mode = 2'b10;
        end
        else if(bait_mode == 2'b11) begin
            if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                score = score + 1;
                bait_mode = 2'b10;
            end
            else begin
                bait_mode = 2'b11;
            end
        end
        else begin
            bait_mode = 2'b10;
        end
        
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            fast_h_position <= 0;
            fast_v_position <= 0;
            fast_appear <= 0;
            stolen <= 0;
            fast_way <= 0;
            fast_movetype <= 0;
            fast_reach_top <= 0;
        end
        else begin
            fast_h_position <= n_fast_h_position;
            fast_v_position <= n_fast_v_position;
            fast_appear <= n_fast_appear;
            stolen <= n_stolen;
            fast_way <= n_fast_way;
            fast_movetype <= n_fast_movetype;
            fast_reach_top <= n_fast_reach_top;
        end
    end



    always @(*) begin
        n_fast_appear = fast_appear;
        n_fast_h_position = fast_h_position;
        n_fast_v_position = fast_v_position;
        n_fast_way = fast_way;
        n_fast_movetype = fast_movetype;
        n_stolen = 0;
        n_fast_reach_top = fast_reach_top;

        if((playtime % 10) == 0 && playtime >= 5 && fast_appear == 0) begin
            n_fast_v_position = fast_appear_v[fast_movetype];
            n_fast_h_position = 850;
            n_fast_appear = 1;
            n_stolen = 0;
        end
        else if(fast_appear == 1'b1) begin
            if(fast_way == 0) begin // 0 for left
                if(fast_h_position == 0) begin
                    n_fast_movetype = fast_movetype + 1;
                    n_fast_way = ~fast_way;
                    n_fast_appear = 0;
                end
                else if(enable[0] == 1'b1) begin

                end
                else begin
                    n_fast_h_position = fast_h_position - (cnt2 == 2000);
                    if(cnt1 == 2000) begin
                        if(fast_reach_top == 0) begin
                            if(fast_v_position > fast_appear_v[fast_movetype] - 5) begin
                                n_fast_v_position = fast_v_position  - 1;
                            end
                            else if(fast_v_position <= fast_appear_v[fast_movetype] - 5) begin
                                n_fast_reach_top = 1'b1;
                                n_fast_v_position = fast_v_position  + 1;
                            end
                        end
                        else if(fast_reach_top == 1) begin
                            if(fast_v_position < fast_appear_v[fast_movetype] + 5) begin
                                n_fast_v_position = fast_v_position  + 1;
                            end
                            else if(fast_v_position >= fast_appear_v[fast_movetype] + 5) begin
                                n_fast_reach_top = 1'b0;
                                n_fast_v_position = fast_v_position  - 1;
                            end
                        end 
                    end
                end
                if(fast_h_position <= 325 && fast_h_position >= 314
                    && (v_position / 10) <= fast_v_position + 25 && (v_position / 10) >= fast_v_position - 5) begin
                    n_stolen = 1;
                end
            end
            else if(fast_way == 1) begin // 0 for left
                if(fast_h_position == 720) begin
                    n_fast_movetype = fast_movetype + 1;
                    n_fast_way = ~fast_way;
                    n_fast_appear = 0;
                end
                else if(enable[0] == 1'b1) begin

                end
                else begin
                    n_fast_h_position = fast_h_position + (cnt2 == 2000);
                    if(cnt1 == 2000) begin
                        if(fast_reach_top == 0) begin
                            if(fast_v_position > fast_appear_v[fast_movetype] - 5) begin
                                n_fast_v_position = fast_v_position  - 1;
                            end
                            else if(fast_v_position <= fast_appear_v[fast_movetype] - 5) begin
                                n_fast_reach_top = 1'b1;
                                n_fast_v_position = fast_v_position  + 1;
                            end
                        end
                        else if(fast_reach_top == 1) begin
                            if(fast_v_position < fast_appear_v[fast_movetype] + 5) begin
                                n_fast_v_position = fast_v_position  + 1;
                            end
                            else if(fast_v_position >= fast_appear_v[fast_movetype] + 5) begin
                                n_fast_reach_top = 1'b0;
                                n_fast_v_position = fast_v_position  - 1;
                            end
                        end 
                    end
                end
                if(fast_h_position <= 285 && fast_h_position >= 274
                    && (v_position / 10) <= fast_v_position + 25 && (v_position / 10) >= fast_v_position - 5) begin
                    n_stolen = 1;
                end
            end
        end
    end

    

    //get mouse & line color
    wire [11:0] mouse_line_color;
    wire mouse_line_back; // 1 for print background 0 for print mouse & line
    color c0(h_position, v_position, valid, h_cnt, v_cnt, cut, cut_v, mouse_line_back, mouse_line_color);

    fast fast1(h_cnt, v_cnt, fast_h_position, fast_v_position, fast_way, fast_appear, fast_back, fast_color);





    
    //output vga color
    always @(*) begin
        if(valid == 1'b1) begin
            if(mouse_line_back == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = mouse_line_color;
            end
            else if(fast_back == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = fast_color;
            end
            else if(bait_back == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = bait_color;
            end
            else begin
                {vgaRed, vgaGreen, vgaBlue} = 12'hAEF;
            end

        end
        else begin
            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
        end
    end



    

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
            if(sw[3] == 1'b1) begin
                seg = 0;
            end
            else if(sw == 4'b0000) begin
                seg = v_position / 1000;
            end
            else if(sw == 4'b0001) begin
                seg = h_position / 1000;
            end
            else begin
                seg = 14;
            end
        end 

        2'b01:begin
            DIGIT = 4'b1011;
            if(sw[3] == 1'b1) begin
                seg = (total_time - playtime) / 60;
            end
            else if(sw == 4'b0000) begin
                seg = (v_position % 1000) / 100;
            end
            else if(sw == 4'b0001) begin
                seg = (h_position % 1000) / 100;
            end
            else begin
                seg = 14;
            end
        end

        2'b10:begin
            DIGIT = 4'b1101;
            if(sw[3] == 1'b1) begin
                seg = ((total_time - playtime) % 60) / 10;
            end
            else if(sw == 4'b0000) begin
                seg = (v_position % 100) / 10;
            end
            else if(sw == 4'b0001) begin
                seg = (h_position % 100) / 10;
            end
            else begin
                seg = score / 10;
            end
        end

        2'b11:begin
            DIGIT = 4'b1110;
            if(sw[3] == 1'b1) begin
                seg = (total_time - playtime) % 10;
            end
            else if(sw == 4'b0000) begin
                seg = v_position % 10;
            end
            else if(sw == 4'b0001) begin
                seg = h_position % 10;
            end
            else begin
                seg = score % 10;
            end
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
