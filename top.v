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
    parameter  [3:0] shark_way_array = 4'b0110;
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
    parameter [9:0] shark_appear_v [0:3] = {
        10'd300, 10'd380, 10'd300, 10'd380
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

    //for one second
    wire pause;
    wire state_tmp;
    assign pause = enable[1];
    assign state_tmp = enable[2];
    wire one_second_enable;
    wire half_second_enable;

    reg [1:0] state, next_state; //0 for open scene 1 for playing scene 2 for shark end scene
    reg bite = 0;

    reg [2:0] state2_cnt, n_state2_cnt;

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

    reg [27:0] cnt3; //for mouth

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            cnt3 = 0;
        end
        else if(state == 2'b10) begin
            if(cnt3 == 25000000) begin
                cnt3 = 0;
            end
            else begin
                cnt3 = cnt3 + 1;
            end
        end
        else begin
            cnt3 = 0;
        end
    end



    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            state <= 0;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        if(state == 2'b00) begin
            if(btnm[0] == 1'b1 && (v_position / 10) >= 335 && (v_position / 10) <= 374 && (h_position / 10) >= 290 && (h_position / 10) <= 349 && play_back == 1'b0) begin
                next_state = 2'b01;
            end
        end
        else if(state == 2'b01) begin
            if(bite == 1'b1) begin
                next_state = 2'b10;
            end
        end
        else if(state == 2'b10) begin
            if(state2_cnt == 7) begin
                next_state = 2'b11;
            end
        end
        else if(state == 2'b11) begin
            if(btnm[0] == 1'b1 && (v_position / 10) >= 340 && (v_position / 10) <= 369 && (h_position / 10) >= 308 && (h_position / 10) <= 331 && reverse_back == 1'b0) begin
                next_state = 2'b01;
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            state2_cnt <= 0;
        end
        else begin
            state2_cnt <= n_state2_cnt;
        end
    end

    always @(*) begin
        if(state == 2'b10) begin
            if(cnt3 == 25000000) begin
                n_state2_cnt = state2_cnt + 1;
            end
            else begin
                n_state2_cnt = state2_cnt;
            end
        end
        else begin
            n_state2_cnt = 0;
        end
    end

    one_second sc1(clk, rst, pause, state_tmp, half_second_enable, one_second_enable);


    reg [9:0] playtime;
    reg [5:0] score = 0;

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            playtime = 0;
        end
        else if(state_tmp == 1'b0) begin
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


    



    clock_divide #(13) div0(.clk(clk),.clk_div(clk_div));
    clock_divide #(2) div1(clk, clk_25MHz);
    clock_divide #(21) div21(clk, clk_21);
    clock_divide #(20) div20(clk, clk_20);
    clock_divide #(19) div19(clk, clk_19);



    //shark
    reg shark_appear = 0;
    reg [9:0] shark_h_position = 0;
    reg [9:0] shark_v_position = 0;
    reg shark_way = 0;
    reg [1:0] shark_movetype = 0;

    reg n_shark_appear = 0;
    reg [9:0] n_shark_h_position = 0;
    reg [9:0] n_shark_v_position = 0;
    reg n_shark_way = 0;
    reg [1:0] n_shark_movetype = 0;
    //get fish color
    wire [11:0] shark_color;
    wire shark_back; // 1 for print background 0 for print fish
    


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
            bait_mode = 2'b10;
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
            shark_h_position <= 0;
            shark_v_position <= 0;
            shark_appear <= 0;
            shark_way <= 0;
            shark_movetype <= 0;
        end
        else begin
            shark_h_position <= n_shark_h_position;
            shark_v_position <= n_shark_v_position;
            shark_appear <= n_shark_appear;
            shark_way <= n_shark_way;
            shark_movetype <= n_shark_movetype;
        end
    end



    always @(*) begin
        n_shark_appear = shark_appear;
        n_shark_h_position = shark_h_position;
        n_shark_v_position = shark_v_position;
        n_shark_way = shark_way;
        n_shark_movetype = shark_movetype;

        if((playtime % 10) == 0 && playtime >= 5 && shark_appear == 0) begin
            n_shark_v_position = shark_appear_v[shark_movetype];
            n_shark_h_position = 850;
            n_shark_appear = 1;
        end
        else if(shark_appear == 1'b1) begin
            if(shark_way == 0) begin // 0 for left
                if(shark_h_position == 0) begin
                    n_shark_movetype = shark_movetype + 1;
                    n_shark_way = shark_way_array[shark_movetype];
                    n_shark_appear = 0;
                end
                else if(enable[0] == 1'b1) begin

                end
                else begin
                    if(cnt1 == 2000) begin
                        n_shark_h_position = shark_h_position - 1;
                        if(shark_h_position > 640) begin
                            n_shark_v_position = shark_v_position;
                        end
                        else if(shark_h_position > 580) begin
                            n_shark_v_position = shark_v_position - 1;
                        end
                        else if(shark_h_position > 500) begin
                            n_shark_v_position = shark_v_position + 1;
                        end
                        else if(shark_h_position > 420) begin
                            n_shark_v_position = shark_v_position;
                        end
                        else if(shark_h_position > 320) begin
                            n_shark_v_position = shark_v_position - 1;
                        end
                        else if(shark_h_position > 160) begin
                            n_shark_v_position = shark_v_position + 1;
                        end
                        else if(shark_h_position >= 0) begin
                            n_shark_v_position = shark_v_position - 1;
                        end
                    end
                end
                if((v_position / 10) >= (shark_v_position - 15) && shark_h_position <= 400 && shark_h_position >= 279 && shark_back == 0) begin
                    bite = 1;
                end
                else begin
                    bite = 0;
                end
            end
            else if(shark_way == 1) begin // 0 for left
                if(shark_h_position == 760) begin
                    n_shark_movetype = shark_movetype + 1;
                    n_shark_way = shark_way_array[shark_movetype];
                    n_shark_appear = 0;
                end
                else if(enable[0] == 1'b1) begin

                end
                else begin
                    if(cnt1 == 2000) begin
                        n_shark_h_position = shark_h_position - 1;
                        if(shark_h_position > 640) begin
                            n_shark_v_position = shark_v_position;
                        end
                        else if(shark_h_position > 580) begin
                            n_shark_v_position = shark_v_position - 1;
                        end
                        else if(shark_h_position > 500) begin
                            n_shark_v_position = shark_v_position + 1;
                        end
                        else if(shark_h_position > 420) begin
                            n_shark_v_position = shark_v_position;
                        end
                        else if(shark_h_position > 320) begin
                            n_shark_v_position = shark_v_position - 1;
                        end
                        else if(shark_h_position > 160) begin
                            n_shark_v_position = shark_v_position + 1;
                        end
                        else if(shark_h_position >= 0) begin
                            n_shark_v_position = shark_v_position - 1;
                        end
                    end
                end
                if((v_position / 10) >= (shark_v_position - 15) && shark_h_position <= 400 && shark_h_position >= 279 && shark_back == 0) begin
                    bite = 1;
                end
                else begin
                    bite = 0;
                end
            end
        end
    end


    //get mouse & line color
    wire [11:0] mouse_line_color;
    wire mouse_line_back; // 1 for print background 0 for print mouse & line
    color c0(h_position, v_position, valid, h_cnt, v_cnt, cut, cut_v, state, mouse_line_back, mouse_line_color);

    shark shark1(h_cnt, v_cnt, shark_h_position, shark_v_position, shark_way, shark_appear, shark_back, shark_color);

    wire mouth_back;
    wire [11:0] mouth_color;
    wire play_back;
    wire [11:0] play_color;
    wire pause_back;
    wire [11:0] pause_color;
    wire reverse_back;
    wire [11:0] reverse_color;
    mouth mouth1(h_cnt, v_cnt, state2_cnt, mouth_back, mouth_color);

    play play1(h_cnt, v_cnt, play_back, play_color);
    reverse reverse1(h_cnt, v_cnt, reverse_back, reverse_color);
    pause pause1(h_cnt, v_cnt, pause, pause_back, pause_color);


    
    //output vga color
    always @(*) begin
        if(valid == 1'b1) begin
            if(state == 2'b00) begin
                if(mouse_line_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = mouse_line_color;
                end
                else if(play_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = play_color;
                end
                else begin
                    {vgaRed, vgaGreen, vgaBlue} = 12'hAEF;
                end
            end
            else if(state == 2'b01) begin
                if(mouse_line_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = mouse_line_color;
                end
                else if(pause_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = pause_color;
                end
                else if(shark_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = shark_color;
                end
                else if(bait_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = bait_color;
                end
                else begin
                    {vgaRed, vgaGreen, vgaBlue} = 12'hAEF;
                end
            end
            else if(state == 2'b10) begin
                if(mouth_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = mouth_color;
                end
                else begin
                    {vgaRed, vgaGreen, vgaBlue} = 12'h000;
                end
            end
            else if(state == 2'b11) begin
                if(mouse_line_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = mouse_line_color;
                end
                else if(reverse_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = reverse_color;
                end
                else begin
                    {vgaRed, vgaGreen, vgaBlue} = 12'hAEF;
                end
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
                seg = state2_cnt;
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
                seg = state;
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
        
