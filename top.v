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
    input [4:0] enable,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue,
    output hsync,
    output vsync
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
    wire clk_23;
    wire clk_19;
    wire clk_20;
    wire [16:0] pixel_addr;
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


    //for one second
    wire pause;
    wire state_tmp;
    assign pause = enable[1];
    assign state_tmp = enable[2];
    wire one_second_enable;
    wire half_second_enable;
    reg [9:0] playtime;
    reg [5:0] score = 0;

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
            if(btnm[0] == 1'b1 && v_position >= 3350 && v_position <= 3740 && h_position >= 2900 && h_position <= 3490 && play_back == 1'b0) begin
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
            else if(playtime == 300) begin
                next_state = 2'b11;
            end
        end
        else if(state == 2'b11) begin
            if(btnm[0] == 1'b1 && v_position >= 3400 && v_position <= 3690 && h_position >= 3080 && h_position <= 3310 && reverse_back == 1'b0) begin
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


    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            playtime = 0;
        end
        else if(state_tmp == 1'b0) begin
            playtime = 0;
        end
        else if(state != 2'b01) begin
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


    


    clock_divide #(2) div1(clk, clk_25MHz);
    clock_divide #(23) div23(clk, clk_23);
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

    reg crab_type;
    reg n_crab_type;

    //crab - 1
    reg [2:0] crab_amount;
    reg crab_appear1 = 0;
    reg [9:0] crab_h_position1;
    reg [9:0] crab_v_position1;
    reg  crab_way1;
    reg [2:0] crab_movement1; //decide the position of v and the way(left or right)

    //crab - 2
    reg crab_appear2 = 0;
    reg [9:0] crab_h_position2;
    reg [9:0] crab_v_position2;
    reg  crab_way2;
    reg [2:0] crab_movement2; //decide the position of v and the way(left or right)

    //fish1 - 1
    reg [2:0] fish1_amount;
    reg fish1_appear1, fish1_appear2, fish1_appear3, fish1_appear4, fish1_appear5, fish1_appear6;
    reg [9:0] fish1_h_position1, fish1_h_position2, fish1_h_position3, fish1_h_position4, fish1_h_position5, fish1_h_position6;
    reg [9:0] fish1_v_position1, fish1_v_position2, fish1_v_position3, fish1_v_position4, fish1_v_position5, fish1_v_position6;
    wire [2:0] fish1_v_movement1, fish1_v_movement2, fish1_v_movement3, fish1_v_movement4, fish1_v_movement5, fish1_v_movement6;
    reg [1:0] fish1_way1, fish1_way2, fish1_way3, fish1_way4, fish1_way5, fish1_way6;
    reg [2:0] fish1_movetype1, fish1_movetype2, fish1_movetype3, fish1_movetype4, fish1_movetype5, fish1_movetype6;
    wire fish1_up1, fish1_up2, fish1_up3, fish1_up4, fish1_up5, fish1_up6;
    //get fish color
    wire [11:0] fish1_color1, fish1_color2, fish1_color3, fish1_color4, fish1_color5, fish1_color6;
    wire fish1_back1, fish1_back2, fish1_back3, fish1_back4, fish1_back5, fish1_back6; // 1 for print background 0 for print fish

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

    wire [11:0] bait_color;
    wire bait_back; // 1 for print background 0 for print fish
    reg [1:0] bait_mode = 2'b10;
    reg [1:0] bait_cnt;
    reg cut = 0;
    reg [9:0] cut_v = 0;
    bait bait1(bait_mode, h_cnt, v_cnt, v_position, bait_back, bait_color);
    fish1_move f1_move1(clk, rst, fish1_h_position1, fish1_v_position1, fish1_way1, fish1_appear1 ,fish1_movetype1, fish1_up1, fish1_v_movement1);
    fish1_move f1_move2(clk, rst, fish1_h_position2, fish1_v_position2, fish1_way2, fish1_appear2 ,fish1_movetype2, fish1_up2, fish1_v_movement2);
    fish1_move f1_move3(clk, rst, fish1_h_position3, fish1_v_position3, fish1_way3, fish1_appear3 ,fish1_movetype3, fish1_up3, fish1_v_movement3);
    fish1_move f1_move4(clk, rst, fish1_h_position4, fish1_v_position4, fish1_way4, fish1_appear4 ,fish1_movetype4, fish1_up4, fish1_v_movement4);
    fish1_move f1_move5(clk, rst, fish1_h_position5, fish1_v_position5, fish1_way5, fish1_appear5 ,fish1_movetype5, fish1_up5, fish1_v_movement5);
    fish1_move f1_move6(clk, rst, fish1_h_position6, fish1_v_position6, fish1_way6, fish1_appear6 ,fish1_movetype6, fish1_up6, fish1_v_movement6);

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            bait_mode = 2'b10;
            bait_cnt = 2'b00;
            cut = 0;
            cut_v = 0;
            score = 0;
        end
        else if(bait_mode == 2'b00) begin
            if(bait_cnt == 2'b11) begin
                bait_mode = 2'b10;
                bait_cnt = 0;
                cut = 0;
            end
            else if(one_second_enable == 1'b1) begin
                bait_mode = 2'b00;
                bait_cnt = bait_cnt + 1;
            end
            else if(cut == 1'b1 && cut_v >= crab_v_position1 && crab_h_position1 <= 309 && crab_h_position1 >= 279) begin
                bait_mode = 2'b00;
                bait_cnt = 0;
                cut = 1;
                cut_v = crab_v_position1;
            end
            else if(cut == 1'b0 && (v_position / 10) >= crab_v_position1 && crab_h_position1 <= 309 && crab_h_position1 >= 279) begin
                bait_mode = 2'b00;
                bait_cnt = 0;
                cut = 1;
                cut_v = crab_v_position1;
            end
            else if(cut == 1'b1 && cut_v >= crab_v_position2 && crab_h_position2 <= 309 && crab_h_position2 >= 279) begin
                bait_mode = 2'b00;
                bait_cnt = 0;
                cut = 1;
                cut_v = crab_v_position2;
            end
            else if(cut == 1'b0 && (v_position / 10) >= crab_v_position2 && crab_h_position2 <= 309 && crab_h_position2 >= 279) begin
                bait_mode = 2'b00;
                bait_cnt = 0;
                cut = 1;
                cut_v = crab_v_position2;
            end
            else if(cut == 1'b1 && (v_position / 10) <= cut_v) begin
                cut = 0;
                bait_mode = 2'b00;
                bait_cnt = bait_cnt;
            end
            else begin
                bait_mode = 2'b00;
                bait_cnt = bait_cnt;
                cut = cut;
            end
        end
        else if(bait_mode == 2'b01) begin
            if((v_position / 10) >= crab_v_position1 && crab_h_position1 <= 309 && crab_h_position1 >= 279) begin
                bait_mode = 2'b00;
                bait_cnt = 0;
                cut = 1;
                cut_v = crab_v_position1;
            end
            else if((v_position / 10) >= crab_v_position2 && crab_h_position2 <= 309 && crab_h_position2 >= 279) begin
                bait_mode = 2'b00;
                bait_cnt = 0;
                cut = 1;
                cut_v = crab_v_position2;
            end
            else if(btnm[0] == 1'b1 && v_position <= 620) begin
                bait_mode = 2'b10;
                bait_cnt = 0;
                cut = 0;
            end
            else begin
                bait_mode = 2'b01;
                bait_cnt = 0;
                cut = 0;
            end
        end
        else if(bait_mode == 2'b10) begin
            if((v_position / 10) >= crab_v_position1 && crab_h_position1 <= 309 && crab_h_position1 >= 279) begin
                bait_mode = 2'b00;
                bait_cnt = 0;
                cut = 1;
                cut_v = crab_v_position1;
            end
            else if((v_position / 10) >= crab_v_position2 && crab_h_position2 <= 309 && crab_h_position2 >= 279) begin
                bait_mode = 2'b00;
                bait_cnt = 0;
                cut = 1;
                cut_v = crab_v_position2;
            end
            else if(fish1_way1 == 2'b10 && fish1_appear1 == 1'b1) begin
                bait_mode = 2'b11;
            end
            else if(fish1_way2 == 2'b10 && fish1_appear2 == 1'b1) begin
                bait_mode = 2'b11;
            end
            else if(fish1_way3 == 2'b10 && fish1_appear3 == 1'b1) begin
                bait_mode = 2'b11;
            end
            else if(fish1_way4 == 2'b10 && fish1_appear4 == 1'b1) begin
                bait_mode = 2'b11;
            end
            else if(fish1_way5 == 2'b10 && fish1_appear5 == 1'b1) begin
                bait_mode = 2'b11;
            end
            else if(fish1_way6 == 2'b10 && fish1_appear6 == 1'b1) begin
                bait_mode = 2'b11;
            end
            else if(stolen == 1) begin
                bait_mode = 2'b01;
            end
            else begin
                bait_mode = 2'b10;
                bait_cnt = 0;
                cut = 0;
            end
        end
        else if(bait_mode == 2'b11) begin
            if((v_position / 10) >= crab_v_position1 && crab_h_position1 <= 309 && crab_h_position1 >= 279) begin
                bait_mode = 2'b00;
                bait_cnt = 0;
                cut = 1;
                cut_v = crab_v_position1;
            end
            else if((v_position / 10) >= crab_v_position2 && crab_h_position2 <= 309 && crab_h_position2 >= 279) begin
                bait_mode = 2'b00;
                bait_cnt = 0;
                cut = 1;
                cut_v = crab_v_position2;
            end
            else if(btnm[0] == 1'b1 && v_position <= 620) begin
                score = score + 1;
                bait_mode = 2'b10;
            end
            else begin
                bait_mode = 2'b11;
                bait_cnt = 0;
                cut = 0;
            end
        end
        else begin
            bait_mode = 2'b10;
        end
        
    end


    always @(posedge clk, posedge rst) begin //shark
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

    always @(*) begin //shark
        n_shark_appear = shark_appear;
        n_shark_h_position = shark_h_position;
        n_shark_v_position = shark_v_position;
        n_shark_way = shark_way;
        n_shark_movetype = shark_movetype;
        if(state != 2'b01) begin
            n_shark_appear = 0;
        end
        else if((playtime % 10) == 0 && playtime >= 5 && shark_appear == 0) begin
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

    //crab - 1
    always @(posedge clk_20, posedge rst) begin
        if(rst == 1'b1) begin
            crab_h_position1 = 700;
            crab_v_position1 = 380;
            crab_way1 = 0;
            crab_appear1 = 0;
            crab_movement1 = 0;
        end
        else if(state != 2'b01) begin
            crab_appear1 = 0;
        end
        else if(playtime == 10 && crab_appear1 == 0) begin
            crab_h_position1 = 700;
            crab_v_position1 = 380;
            crab_way1 = 0;
            crab_appear1 = 1;
            crab_movement1 = 2;
        end
        else if(pause == 1'b0 && crab_appear1 == 1'b1) begin
            if(crab_way1 == 1'b0) begin  //0 for go left
                if(crab_h_position1 == 0) begin
                    crab_movement1 = crab_movement1 + 3;
                    crab_way1 = fish_way[crab_movement1];
                    crab_v_position1 = 240 + 30 * crab_movement1;
                    crab_h_position1 = 840;
                end
                else begin
                    crab_h_position1 = crab_h_position1 - 1;
                end
            end
            else begin //1 for go right
                if(crab_h_position1 == 670) begin
                    crab_movement1 = crab_movement1 + 3;
                    crab_way1 = fish_way[crab_movement1];
                    crab_v_position1 = 240 + 30 * crab_movement1;
                    crab_h_position1 = 840;
                end
                crab_h_position1 = crab_h_position1 + 1;
            end
        end
    end

    //crab - 2
    always @(posedge clk_20, posedge rst) begin
        if(rst == 1'b1) begin
            crab_h_position2 = 700;
            crab_v_position2 = 250;
            crab_way2 = 0;
            crab_appear2 = 0;
            crab_movement2 = 4;
        end
        else if(state != 2'b01) begin
            crab_appear2 = 0;
        end
        else if(playtime == 12 && crab_appear2 == 0) begin
            crab_h_position2 = 700;
            crab_v_position2 = 250;
            crab_way2 = 1;
            crab_appear2 = 1;
            crab_movement2 = 4;
        end
        else if(pause == 1'b0 && crab_appear2 == 1'b1) begin
            if(crab_way2 == 1'b0) begin  //0 for go left
                if(crab_h_position2 == 0) begin
                    crab_movement2 = crab_movement2 + 5;
                    crab_way2 = ~fish_way[crab_movement2];
                    crab_v_position2 = 240 + 30 * crab_movement2;
                    crab_h_position2 = 840;
                end
                else begin
                    crab_h_position2 = crab_h_position2 - 1;
                end
            end
            else begin //1 for go right
                if(crab_h_position2 == 670) begin
                    crab_movement2 = crab_movement2 + 5;
                    crab_way2 = ~fish_way[crab_movement2];
                    crab_v_position2 = 240 + 30 * crab_movement2;
                    crab_h_position2 = 840;
                end
                crab_h_position2 = crab_h_position2 + 1;
            end
        end
    end

    
    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            fish1_v_position1 = 415;
            fish1_h_position1 = 400;
            fish1_way1 = 0;
            fish1_movetype1 = 0;
            fish1_appear1 = 0;
        end
        else if(state != 2'b01) begin
            fish1_appear1 = 0;
        end
        else if(playtime == 0) begin
            fish1_v_position1 = fish_appear_v[1];
            fish1_h_position1 = 900;
            fish1_way1 = fish_way1[1];
            fish1_movetype1 = 1;
            fish1_appear1 = 1;
        end
        else begin
            if(bait_mode == 2'b10) begin
                if(fish1_way1 == 2'b00) begin // 0 for left
                    if(fish1_h_position1 == 0) begin
                        fish1_h_position1 = 850;
                        fish1_movetype1 = fish1_movetype1 + 1;
                        fish1_way1 = fish_way1[fish1_movetype1];
                        fish1_v_position1 = fish_appear_v[fish1_movetype1];
                    end
                    else if(fish1_h_position1 <= 325 && fish1_h_position1 >= 314
                            && (v_position / 10) <= fish1_v_position1 + 25 && (v_position / 10) >= fish1_v_position1 - 5) begin
                        fish1_way1 = 2'b10;
                        fish1_h_position1 = 298;
                        fish1_v_position1 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position1 = fish1_h_position1;
                    end
                    else begin
                        fish1_h_position1 = fish1_h_position1 - (cnt1 == 2000);
                        if(fish1_up1 == 1'b1) begin
                            fish1_v_position1 = fish1_v_position1 + fish1_v_movement1;
                        end
                        else begin
                            fish1_v_position1 = fish1_v_position1 - fish1_v_movement1;
                        end
                    end
                end
                else if(fish1_way1 == 2'b01) begin // 1 for right
                    if(fish1_h_position1 == 720) begin
                        fish1_h_position1 = 850;
                        fish1_movetype1 = fish1_movetype1 + 1;
                        fish1_way1 = fish_way1[fish1_movetype1];
                        fish1_v_position1 = fish_appear_v[fish1_movetype1];
                    end
                    else if(fish1_h_position1 <= 285 && fish1_h_position1 >= 274
                            && (v_position / 10) <= fish1_v_position1 + 25 && (v_position / 10) >= fish1_v_position1 - 5) begin
                        fish1_way1 = 2'b10;
                        fish1_h_position1 = 298;
                        fish1_v_position1 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position1 = fish1_h_position1;
                    end
                    else begin
                        fish1_h_position1 = fish1_h_position1 + (cnt1 == 2000);
                        if(fish1_up1 == 1'b1) begin
                            fish1_v_position1 = fish1_v_position1 + fish1_v_movement1;
                        end
                        else begin
                            fish1_v_position1 = fish1_v_position1 - fish1_v_movement1;
                        end
                    end
                end
                else if(fish1_way1 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position1 = 850;
                        fish1_movetype1 = fish1_movetype1 + 1;
                        fish1_way1 = fish_way1[fish1_movetype1];
                        fish1_v_position1 = fish_appear_v[fish1_movetype1];
                    end
                    else if(cut == 1) begin
                        fish1_way1 = 0;
                    end
                    else begin
                        fish1_h_position1 = 298;
                        fish1_v_position1 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
            else begin
                if(fish1_way1 == 2'b00) begin
                    if(fish1_h_position1 == 0) begin
                        fish1_h_position1 = 850;
                        fish1_movetype1 = fish1_movetype1 + 1;
                        fish1_way1 = fish_way1[fish1_movetype1];
                        fish1_v_position1 = fish_appear_v[fish1_movetype1];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position1 = fish1_h_position1;
                    end
                    else begin
                        fish1_h_position1 = fish1_h_position1 - (cnt1 == 2000);
                        if(fish1_up1 == 1'b1) begin
                            fish1_v_position1 = fish1_v_position1 + fish1_v_movement1;
                        end
                        else begin
                            fish1_v_position1 = fish1_v_position1 - fish1_v_movement1;
                        end
                    end
                end
                else if(fish1_way1 == 2'b01) begin
                    if(fish1_h_position1 == 720) begin
                        fish1_h_position1 = 850;
                        fish1_movetype1 = fish1_movetype1 + 1;
                        fish1_way1 = fish_way1[fish1_movetype1];
                        fish1_v_position1 = fish_appear_v[fish1_movetype1];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position1 = fish1_h_position1;
                    end
                    else begin
                        fish1_h_position1 = fish1_h_position1 + (cnt1 == 2000);
                        if(fish1_up1 == 1'b1) begin
                            fish1_v_position1 = fish1_v_position1 + fish1_v_movement1;
                        end
                        else begin
                            fish1_v_position1 = fish1_v_position1 - fish1_v_movement1;
                        end
                    end
                end
                else if(fish1_way1 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position1 = 850;
                        fish1_movetype1 = fish1_movetype1 + 1;
                        fish1_way1 = fish_way1[fish1_movetype1];
                        fish1_v_position1 = fish_appear_v[fish1_movetype1];
                    end
                    else if(cut == 1) begin
                        fish1_way1 = 0;
                    end
                    else begin
                        fish1_h_position1 = 298;
                        fish1_v_position1 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            fish1_v_position2 = 415;
            fish1_h_position2 = 400;
            fish1_way2 = 0;
            fish1_movetype2 = 0;
            fish1_appear2 = 0;
        end
        else if(state != 2'b01) begin
            fish1_appear2 = 0;
        end
        else if(playtime == 3) begin
            fish1_v_position2 = fish_appear_v[2];
            fish1_h_position2 = 900;
            fish1_way2 = fish_way2[2];
            fish1_movetype2 = 2;
            fish1_appear2 = 1;
        end
        else begin
            if(bait_mode == 2'b10) begin
                if(fish1_way2 == 2'b00) begin // 0 for left
                    if(fish1_h_position2 == 0) begin
                        fish1_h_position2 = 850;
                        fish1_movetype2 = fish1_movetype2 + 7;
                        fish1_way2 = fish_way2[fish1_movetype2];
                        fish1_v_position2 = fish_appear_v[fish1_movetype2];
                    end
                    else if(fish1_h_position2 <= 325 && fish1_h_position2 >= 314
                            && (v_position / 10) <= fish1_v_position2 + 25 && (v_position / 10) >= fish1_v_position2 - 5) begin
                        fish1_way2 = 2'b10;
                        fish1_h_position2 = 298;
                        fish1_v_position2 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position2 = fish1_h_position2;
                    end
                    else begin
                        fish1_h_position2 = fish1_h_position2 - (cnt1 == 2000);
                        if(fish1_up2 == 1'b1) begin
                            fish1_v_position2 = fish1_v_position2 + fish1_v_movement2;
                        end
                        else begin
                            fish1_v_position2 = fish1_v_position2 - fish1_v_movement2;
                        end
                    end
                end
                else if(fish1_way2 == 2'b01) begin // 1 for right
                    if(fish1_h_position2 == 720) begin
                        fish1_h_position2 = 850;
                        fish1_movetype2 = fish1_movetype2 + 7;
                        fish1_way2 = fish_way2[fish1_movetype2];
                        fish1_v_position2 = fish_appear_v[fish1_movetype2];
                    end
                    else if(fish1_h_position2 <= 285 && fish1_h_position2 >= 274
                            && (v_position / 10) <= fish1_v_position2 + 25 && (v_position / 10) >= fish1_v_position2 - 5) begin
                        fish1_way2 = 2'b10;
                        fish1_h_position2 = 298;
                        fish1_v_position2 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position2 = fish1_h_position2;
                    end
                    else begin
                        fish1_h_position2 = fish1_h_position2 + (cnt1 == 2000);
                        if(fish1_up2 == 1'b1) begin
                            fish1_v_position2 = fish1_v_position2 + fish1_v_movement2;
                        end
                        else begin
                            fish1_v_position2 = fish1_v_position2 - fish1_v_movement2;
                        end
                    end
                end
                else if(fish1_way2 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position2 = 850;
                        fish1_movetype2 = fish1_movetype2 + 7;
                        fish1_way2 = fish_way2[fish1_movetype2];
                        fish1_v_position2 = fish_appear_v[fish1_movetype2];
                    end
                    else if(cut == 1) begin
                        fish1_way2 = 0;
                    end
                    else begin
                        fish1_h_position2 = 298;
                        fish1_v_position2 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
            else begin
                if(fish1_way2 == 2'b00) begin
                    if(fish1_h_position2 == 0) begin
                        fish1_h_position2 = 850;
                        fish1_movetype2 = fish1_movetype2 + 7;
                        fish1_way2 = fish_way2[fish1_movetype2];
                        fish1_v_position2 = fish_appear_v[fish1_movetype2];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position2 = fish1_h_position2;
                    end
                    else begin
                        fish1_h_position2 = fish1_h_position2 - (cnt1 == 2000);
                        if(fish1_up2 == 1'b1) begin
                            fish1_v_position2 = fish1_v_position2 + fish1_v_movement2;
                        end
                        else begin
                            fish1_v_position2 = fish1_v_position2 - fish1_v_movement2;
                        end
                    end
                end
                else if(fish1_way2 == 2'b01) begin
                    if(fish1_h_position2 == 720) begin
                        fish1_h_position2 = 850;
                        fish1_movetype2 = fish1_movetype2 + 7;
                        fish1_way2 = fish_way2[fish1_movetype2];
                        fish1_v_position2 = fish_appear_v[fish1_movetype2];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position2 = fish1_h_position2;
                    end
                    else begin
                        fish1_h_position2 = fish1_h_position2 + (cnt1 == 2000);
                        if(fish1_up2 == 1'b1) begin
                            fish1_v_position2 = fish1_v_position2 + fish1_v_movement2;
                        end
                        else begin
                            fish1_v_position2 = fish1_v_position2 - fish1_v_movement2;
                        end
                    end
                end
                else if(fish1_way2 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position2 = 850;
                        fish1_movetype2 = fish1_movetype2 + 7;
                        fish1_way2 = fish_way2[fish1_movetype2];
                        fish1_v_position2 = fish_appear_v[fish1_movetype2];
                    end
                    else if(cut == 1) begin
                        fish1_way2 = 0;
                    end
                    else begin
                        fish1_h_position2 = 298;
                        fish1_v_position2 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            fish1_v_position3 = 415;
            fish1_h_position3 = 400;
            fish1_way3 = 0;
            fish1_movetype3 = 0;
            fish1_appear3 = 0;
        end
        else if(state != 2'b01) begin
            fish1_appear3 = 0;
        end
        else if(playtime == 5) begin
            fish1_v_position3 = fish_appear_v[3];
            fish1_h_position3 = 900;
            fish1_way3 = fish_way3[3];
            fish1_movetype3 = 3;
            fish1_appear3 = 1;
        end
        else begin
            if(bait_mode == 2'b10) begin
                if(fish1_way3 == 2'b00) begin // 0 for left
                    if(fish1_h_position3 == 0) begin
                        fish1_h_position3 = 850;
                        fish1_movetype3 = fish1_movetype3 + 3;
                        fish1_way3 = fish_way3[fish1_movetype3];
                        fish1_v_position3 = fish_appear_v[fish1_movetype3];
                    end
                    else if(fish1_h_position3 <= 325 && fish1_h_position3 >= 314
                            && (v_position / 10) <= fish1_v_position3 + 25 && (v_position / 10) >= fish1_v_position3 - 5) begin
                        fish1_way3 = 2'b10;
                        fish1_h_position3 = 298;
                        fish1_v_position3 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position3 = fish1_h_position3;
                    end
                    else begin
                        fish1_h_position3 = fish1_h_position3 - (cnt1 == 2000);
                        if(fish1_up3 == 1'b1) begin
                            fish1_v_position3 = fish1_v_position3 + fish1_v_movement3;
                        end
                        else begin
                            fish1_v_position3 = fish1_v_position3 - fish1_v_movement3;
                        end
                    end
                end
                else if(fish1_way3 == 2'b01) begin // 1 for right
                    if(fish1_h_position3 == 720) begin
                        fish1_h_position3 = 850;
                        fish1_movetype3 = fish1_movetype3 + 3;
                        fish1_way3 = fish_way3[fish1_movetype3];
                        fish1_v_position3 = fish_appear_v[fish1_movetype3];
                    end
                    else if(fish1_h_position3 <= 285 && fish1_h_position3 >= 274
                            && (v_position / 10) <= fish1_v_position3 + 25 && (v_position / 10) >= fish1_v_position3 - 5) begin
                        fish1_way3 = 2'b10;
                        fish1_h_position3 = 298;
                        fish1_v_position3 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position3 = fish1_h_position3;
                    end
                    else begin
                        fish1_h_position3 = fish1_h_position3 + (cnt1 == 2000);
                        if(fish1_up3 == 1'b1) begin
                            fish1_v_position3 = fish1_v_position3 + fish1_v_movement3;
                        end
                        else begin
                            fish1_v_position3 = fish1_v_position3 - fish1_v_movement3;
                        end
                    end
                end
                else if(fish1_way3 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position3 = 850;
                        fish1_movetype3 = fish1_movetype3 + 3;
                        fish1_way3 = fish_way3[fish1_movetype3];
                        fish1_v_position3 = fish_appear_v[fish1_movetype3];
                    end
                    else if(cut == 1) begin
                        fish1_way3 = 0;
                    end
                    else begin
                        fish1_h_position3 = 298;
                        fish1_v_position3 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
            else begin
                if(fish1_way3 == 2'b00) begin
                    if(fish1_h_position3 == 0) begin
                        fish1_h_position3 = 850;
                        fish1_movetype3 = fish1_movetype3 + 3;
                        fish1_way3 = fish_way3[fish1_movetype3];
                        fish1_v_position3 = fish_appear_v[fish1_movetype3];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position3 = fish1_h_position3;
                    end
                    else begin
                        fish1_h_position3 = fish1_h_position3 - (cnt1 == 2000);
                        if(fish1_up3 == 1'b1) begin
                            fish1_v_position3 = fish1_v_position3 + fish1_v_movement3;
                        end
                        else begin
                            fish1_v_position3 = fish1_v_position3 - fish1_v_movement3;
                        end
                    end
                end
                else if(fish1_way3 == 2'b01) begin
                    if(fish1_h_position3 == 720) begin
                        fish1_h_position3 = 850;
                        fish1_movetype3 = fish1_movetype3 + 3;
                        fish1_way3 = fish_way3[fish1_movetype3];
                        fish1_v_position3 = fish_appear_v[fish1_movetype3];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position3 = fish1_h_position3;
                    end
                    else begin
                        fish1_h_position3 = fish1_h_position3 + (cnt1 == 2000);
                        if(fish1_up3 == 1'b1) begin
                            fish1_v_position3 = fish1_v_position3 + fish1_v_movement3;
                        end
                        else begin
                            fish1_v_position3 = fish1_v_position3 - fish1_v_movement3;
                        end
                    end
                end
                else if(fish1_way3 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position3 = 850;
                        fish1_movetype3 = fish1_movetype3 + 3;
                        fish1_way3 = fish_way3[fish1_movetype3];
                        fish1_v_position3 = fish_appear_v[fish1_movetype3];
                    end
                    else if(cut == 1) begin
                        fish1_way3 = 0;
                    end
                    else begin
                        fish1_h_position3 = 298;
                        fish1_v_position3 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            fish1_v_position4 = 415;
            fish1_h_position4 = 400;
            fish1_way4 = 0;
            fish1_movetype4 = 0;
            fish1_appear4 = 0;
        end
        else if(state != 2'b01) begin
            fish1_appear4 = 0;
        end
        else if(playtime == 7) begin
            fish1_v_position4 = fish_appear_v[4];
            fish1_h_position4 = 900;
            fish1_way4 = fish_way4[4];
            fish1_movetype4 = 4;
            fish1_appear4 = 1;
        end
        else begin
            if(bait_mode == 2'b10) begin
                if(fish1_way4 == 2'b00) begin // 0 for left
                    if(fish1_h_position4 == 0) begin
                        fish1_h_position4 = 850;
                        fish1_movetype4 = fish1_movetype4 + 1;
                        fish1_way4 = fish_way4[fish1_movetype4];
                        fish1_v_position4 = fish_appear_v[fish1_movetype4];
                    end
                    else if(fish1_h_position4 <= 325 && fish1_h_position4 >= 314
                            && (v_position / 10) <= fish1_v_position4 + 25 && (v_position / 10) >= fish1_v_position4 - 5) begin
                        fish1_way4 = 2'b10;
                        fish1_h_position4 = 298;
                        fish1_v_position4 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position4 = fish1_h_position4;
                    end
                    else begin
                        fish1_h_position4 = fish1_h_position4 - (cnt1 == 2000);
                        if(fish1_up4 == 1'b1) begin
                            fish1_v_position4 = fish1_v_position4 + fish1_v_movement4;
                        end
                        else begin
                            fish1_v_position4 = fish1_v_position4 - fish1_v_movement4;
                        end
                    end
                end
                else if(fish1_way4 == 2'b01) begin // 1 for right
                    if(fish1_h_position4 == 720) begin
                        fish1_h_position4 = 850;
                        fish1_movetype4 = fish1_movetype4 + 1;
                        fish1_way4 = fish_way4[fish1_movetype4];
                        fish1_v_position4 = fish_appear_v[fish1_movetype4];
                    end
                    else if(fish1_h_position4 <= 285 && fish1_h_position4 >= 274
                            && (v_position / 10) <= fish1_v_position4 + 25 && (v_position / 10) >= fish1_v_position4 - 5) begin
                        fish1_way4 = 2'b10;
                        fish1_h_position4 = 298;
                        fish1_v_position4 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position4 = fish1_h_position4;
                    end
                    else begin
                        fish1_h_position4 = fish1_h_position4 + (cnt1 == 2000);
                        if(fish1_up4 == 1'b1) begin
                            fish1_v_position4 = fish1_v_position4 + fish1_v_movement4;
                        end
                        else begin
                            fish1_v_position4 = fish1_v_position4 - fish1_v_movement4;
                        end
                    end
                end
                else if(fish1_way4 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position4 = 850;
                        fish1_movetype4 = fish1_movetype4 + 1;
                        fish1_way4 = fish_way4[fish1_movetype4];
                        fish1_v_position4 = fish_appear_v[fish1_movetype4];
                    end
                    else if(cut == 1) begin
                        fish1_way4 = 0;
                    end
                    else begin
                        fish1_h_position4 = 298;
                        fish1_v_position4 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
            else begin
                if(fish1_way4 == 2'b00) begin
                    if(fish1_h_position4 == 0) begin
                        fish1_h_position4 = 850;
                        fish1_movetype4 = fish1_movetype4 + 1;
                        fish1_way4 = fish_way4[fish1_movetype4];
                        fish1_v_position4 = fish_appear_v[fish1_movetype4];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position4 = fish1_h_position4;
                    end
                    else begin
                        fish1_h_position4 = fish1_h_position4 - (cnt1 == 2000);
                        if(fish1_up4 == 1'b1) begin
                            fish1_v_position4 = fish1_v_position4 + fish1_v_movement4;
                        end
                        else begin
                            fish1_v_position4 = fish1_v_position4 - fish1_v_movement4;
                        end
                    end
                end
                else if(fish1_way4 == 2'b01) begin
                    if(fish1_h_position4 == 720) begin
                        fish1_h_position4 = 850;
                        fish1_movetype4 = fish1_movetype4 + 1;
                        fish1_way4 = fish_way4[fish1_movetype4];
                        fish1_v_position4 = fish_appear_v[fish1_movetype4];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position4 = fish1_h_position4;
                    end
                    else begin
                        fish1_h_position4 = fish1_h_position4 + (cnt1 == 2000);
                        if(fish1_up4 == 1'b1) begin
                            fish1_v_position4 = fish1_v_position4 + fish1_v_movement4;
                        end
                        else begin
                            fish1_v_position4 = fish1_v_position4 - fish1_v_movement4;
                        end
                    end
                end
                else if(fish1_way4 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position4 = 850;
                        fish1_movetype4 = fish1_movetype4 + 1;
                        fish1_way4 = fish_way4[fish1_movetype4];
                        fish1_v_position4 = fish_appear_v[fish1_movetype4];
                    end
                    else if(cut == 1) begin
                        fish1_way4 = 0;
                    end
                    else begin
                        fish1_h_position4 = 298;
                        fish1_v_position4 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            fish1_v_position5 = 415;
            fish1_h_position5 = 400;
            fish1_way5 = 0;
            fish1_movetype5 = 0;
            fish1_appear5 = 0;
        end
        else if(state != 2'b01) begin
            fish1_appear5 = 0;
        end
        else if(playtime == 10) begin
            fish1_v_position5 = fish_appear_v[5];
            fish1_h_position5 = 900;
            fish1_way5 = fish_way5[5];
            fish1_movetype5 = 5;
            fish1_appear5 = 1;
        end
        else begin
            if(bait_mode == 2'b10) begin
                if(fish1_way5 == 2'b00) begin // 0 for left
                    if(fish1_h_position5 == 0) begin
                        fish1_h_position5 = 850;
                        fish1_movetype5 = fish1_movetype5 + 5;
                        fish1_way5 = fish_way5[fish1_movetype5];
                        fish1_v_position5 = fish_appear_v[fish1_movetype5];
                    end
                    else if(fish1_h_position5 <= 325 && fish1_h_position5 >= 314
                            && (v_position / 10) <= fish1_v_position5 + 25 && (v_position / 10) >= fish1_v_position5 - 5) begin
                        fish1_way5 = 2'b10;
                        fish1_h_position5 = 298;
                        fish1_v_position5 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position5 = fish1_h_position5;
                    end
                    else begin
                        fish1_h_position5 = fish1_h_position5 - (cnt1 == 2000);
                        if(fish1_up5 == 1'b1) begin
                            fish1_v_position5 = fish1_v_position5 + fish1_v_movement5;
                        end
                        else begin
                            fish1_v_position5 = fish1_v_position5 - fish1_v_movement5;
                        end
                    end
                end
                else if(fish1_way5 == 2'b01) begin // 1 for right
                    if(fish1_h_position5 == 720) begin
                        fish1_h_position5 = 850;
                        fish1_movetype5 = fish1_movetype5 + 5;
                        fish1_way5 = fish_way5[fish1_movetype5];
                        fish1_v_position5 = fish_appear_v[fish1_movetype5];
                    end
                    else if(fish1_h_position5 <= 285 && fish1_h_position5 >= 274
                            && (v_position / 10) <= fish1_v_position5 + 25 && (v_position / 10) >= fish1_v_position5 - 5) begin
                        fish1_way5 = 2'b10;
                        fish1_h_position5 = 298;
                        fish1_v_position5 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position5 = fish1_h_position5;
                    end
                    else begin
                        fish1_h_position5 = fish1_h_position5 + (cnt1 == 2000);
                        if(fish1_up5 == 1'b1) begin
                            fish1_v_position5 = fish1_v_position5 + fish1_v_movement5;
                        end
                        else begin
                            fish1_v_position5 = fish1_v_position5 - fish1_v_movement5;
                        end
                    end
                end
                else if(fish1_way5 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position5 = 850;
                        fish1_movetype5 = fish1_movetype5 + 5;
                        fish1_way5 = fish_way5[fish1_movetype5];
                        fish1_v_position5 = fish_appear_v[fish1_movetype5];
                    end
                    else if(cut == 1) begin
                        fish1_way5 = 5;
                    end
                    else begin
                        fish1_h_position5 = 298;
                        fish1_v_position5 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
            else begin
                if(fish1_way5 == 2'b00) begin
                    if(fish1_h_position5 == 0) begin
                        fish1_h_position5 = 850;
                        fish1_movetype5 = fish1_movetype5 + 5;
                        fish1_way5 = fish_way5[fish1_movetype5];
                        fish1_v_position5 = fish_appear_v[fish1_movetype5];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position5 = fish1_h_position5;
                    end
                    else begin
                        fish1_h_position5 = fish1_h_position5 - (cnt1 == 2000);
                        if(fish1_up5 == 1'b1) begin
                            fish1_v_position5 = fish1_v_position5 + fish1_v_movement5;
                        end
                        else begin
                            fish1_v_position5 = fish1_v_position5 - fish1_v_movement5;
                        end
                    end
                end
                else if(fish1_way5 == 2'b01) begin
                    if(fish1_h_position5 == 720) begin
                        fish1_h_position5 = 850;
                        fish1_movetype5 = fish1_movetype5 + 5;
                        fish1_way5 = fish_way5[fish1_movetype5];
                        fish1_v_position5 = fish_appear_v[fish1_movetype5];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position5 = fish1_h_position5;
                    end
                    else begin
                        fish1_h_position5 = fish1_h_position5 + (cnt1 == 2000);
                        if(fish1_up5 == 1'b1) begin
                            fish1_v_position5 = fish1_v_position5 + fish1_v_movement5;
                        end
                        else begin
                            fish1_v_position5 = fish1_v_position5 - fish1_v_movement5;
                        end
                    end
                end
                else if(fish1_way5 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position5 = 850;
                        fish1_movetype5 = fish1_movetype5 + 5;
                        fish1_way5 = fish_way5[fish1_movetype5];
                        fish1_v_position5 = fish_appear_v[fish1_movetype5];
                    end
                    else if(cut == 1) begin
                        fish1_way5 = 0;
                    end
                    else begin
                        fish1_h_position5 = 298;
                        fish1_v_position5 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            fish1_v_position6 = 415;
            fish1_h_position6 = 400;
            fish1_way6 = 0;
            fish1_movetype6 = 0;
            fish1_appear6 = 0;
        end
        else if(state != 2'b01) begin
            fish1_appear6 = 0;
        end
        else if(playtime == 13) begin
            fish1_v_position6 = fish_appear_v[6];
            fish1_h_position6 = 900;
            fish1_way6 = fish_way6[6];
            fish1_movetype6 = 6;
            fish1_appear6 = 1;
        end
        else begin
            if(bait_mode == 2'b10) begin
                if(fish1_way6 == 2'b00) begin // 0 for left
                    if(fish1_h_position6 == 0) begin
                        fish1_h_position6 = 850;
                        fish1_movetype6 = fish1_movetype6 + 5;
                        fish1_way6 = fish_way6[fish1_movetype6];
                        fish1_v_position6 = fish_appear_v[fish1_movetype6];
                    end
                    else if(fish1_h_position6 <= 325 && fish1_h_position6 >= 314
                            && (v_position / 10) <= fish1_v_position6 + 25 && (v_position / 10) >= fish1_v_position6 - 5) begin
                        fish1_way6 = 2'b10;
                        fish1_h_position6 = 298;
                        fish1_v_position6 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position6 = fish1_h_position6;
                    end
                    else begin
                        fish1_h_position6 = fish1_h_position6 - (cnt1 == 2000);
                        if(fish1_up6 == 1'b1) begin
                            fish1_v_position6 = fish1_v_position6 + fish1_v_movement6;
                        end
                        else begin
                            fish1_v_position6 = fish1_v_position6 - fish1_v_movement6;
                        end
                    end
                end
                else if(fish1_way6 == 2'b01) begin // 1 for right
                    if(fish1_h_position6 == 720) begin
                        fish1_h_position6 = 850;
                        fish1_movetype6 = fish1_movetype6 + 5;
                        fish1_way6 = fish_way6[fish1_movetype6];
                        fish1_v_position6 = fish_appear_v[fish1_movetype6];
                    end
                    else if(fish1_h_position6 <= 285 && fish1_h_position6 >= 274
                            && (v_position / 10) <= fish1_v_position6 + 25 && (v_position / 10) >= fish1_v_position6 - 5) begin
                        fish1_way6 = 2'b10;
                        fish1_h_position6 = 298;
                        fish1_v_position6 = (v_position > 620) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position6 = fish1_h_position6;
                    end
                    else begin
                        fish1_h_position6 = fish1_h_position6 + (cnt1 == 2000);
                        if(fish1_up6 == 1'b1) begin
                            fish1_v_position6 = fish1_v_position6 + fish1_v_movement6;
                        end
                        else begin
                            fish1_v_position6 = fish1_v_position6 - fish1_v_movement6;
                        end
                    end
                end
                else if(fish1_way6 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position6 = 850;
                        fish1_movetype6 = fish1_movetype6 + 5;
                        fish1_way6 = fish_way6[fish1_movetype6];
                        fish1_v_position6 = fish_appear_v[fish1_movetype6];
                    end
                    else if(cut == 1) begin
                        fish1_way6 = 0;
                    end
                    else begin
                        fish1_h_position6 = 298;
                        fish1_v_position6 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
            else begin
                if(fish1_way6 == 2'b00) begin
                    if(fish1_h_position6 == 0) begin
                        fish1_h_position6 = 850;
                        fish1_movetype6 = fish1_movetype6 + 5;
                        fish1_way6 = fish_way6[fish1_movetype6];
                        fish1_v_position6 = fish_appear_v[fish1_movetype6];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position6 = fish1_h_position6;
                    end
                    else begin
                        fish1_h_position6 = fish1_h_position6 - (cnt1 == 2000);
                        if(fish1_up6 == 1'b1) begin
                            fish1_v_position6 = fish1_v_position6 + fish1_v_movement6;
                        end
                        else begin
                            fish1_v_position6 = fish1_v_position6 - fish1_v_movement6;
                        end
                    end
                end
                else if(fish1_way6 == 2'b01) begin
                    if(fish1_h_position6 == 720) begin
                        fish1_h_position6 = 850;
                        fish1_movetype6 = fish1_movetype6 + 5;
                        fish1_way6 = fish_way6[fish1_movetype6];
                        fish1_v_position6 = fish_appear_v[fish1_movetype6];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position6 = fish1_h_position6;
                    end
                    else begin
                        fish1_h_position6 = fish1_h_position6 + (cnt1 == 2000);
                        if(fish1_up6 == 1'b1) begin
                            fish1_v_position6 = fish1_v_position6 + fish1_v_movement6;
                        end
                        else begin
                            fish1_v_position6 = fish1_v_position6 - fish1_v_movement6;
                        end
                    end
                end
                else if(fish1_way6 == 2'b10) begin
                    if(btnm[0] == 1'b1 && v_position <= 620) begin
                        fish1_h_position6 = 850;
                        fish1_movetype6 = fish1_movetype6 + 5;
                        fish1_way6 = fish_way6[fish1_movetype6];
                        fish1_v_position6 = fish_appear_v[fish1_movetype6];
                    end
                    else if(cut == 1) begin
                        fish1_way6 = 0;
                    end
                    else begin
                        fish1_h_position6 = 298;
                        fish1_v_position6 = (v_position > 620) ? v_position / 10 : 62;
                    end
                end
            end
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
        if(state != 2'b01) begin
            n_fast_appear = 0;
        end
        else if((playtime % 10) == 0 && playtime >= 5 && fast_appear == 0) begin
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
                    && (v_position / 10) <= fast_v_position + 25 && (v_position / 10) >= fast_v_position - 5 && bait_mode == 2'b10) begin
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
                    && (v_position / 10) <= fast_v_position + 25 && (v_position / 10) >= fast_v_position - 5 && bait_mode == 2'b10) begin
                    n_stolen = 1;
                end
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            crab_type <= 0;
        end
        else begin
            crab_type <= n_crab_type;
        end
    end

    always @(*) begin
        if(one_second_enable == 1'b1) begin
            n_crab_type = ~crab_type;
        end
        else begin
            n_crab_type = crab_type;
        end
    end


    //get mouse & line color
    wire [11:0] mouse_line_color;
    wire mouse_line_back; // 1 for print background 0 for print mouse & line
    color c0(h_position, v_position, valid, h_cnt, v_cnt, cut, cut_v, state, mouse_line_back, mouse_line_color);

    fish1 f1(h_cnt, v_cnt, fish1_h_position1, fish1_v_position1, fish1_way1, fish1_appear1, 4'd1, fish1_back1, fish1_color1);
    fish1 f2(h_cnt, v_cnt, fish1_h_position2, fish1_v_position2, fish1_way2, fish1_appear2, 4'd2, fish1_back2, fish1_color2);
    fish1 f3(h_cnt, v_cnt, fish1_h_position3, fish1_v_position3, fish1_way3, fish1_appear3, 4'd3, fish1_back3, fish1_color3);
    fish1 f4(h_cnt, v_cnt, fish1_h_position4, fish1_v_position4, fish1_way4, fish1_appear4, 4'd4, fish1_back4, fish1_color4);
    fish1 f5(h_cnt, v_cnt, fish1_h_position5, fish1_v_position5, fish1_way5, fish1_appear5, 4'd5, fish1_back5, fish1_color5);
    fish1 f6(h_cnt, v_cnt, fish1_h_position6, fish1_v_position6, fish1_way6, fish1_appear6, 4'd6, fish1_back6, fish1_color6);

    shark shark1(h_cnt, v_cnt, shark_h_position, shark_v_position, shark_way, shark_appear, shark_back, shark_color);
    fast fast1(h_cnt, v_cnt, fast_h_position, fast_v_position, fast_way, fast_appear, fast_back, fast_color);
    //get crab1 color
    wire [11:0] crab_color1;
    wire crab_back1; // 1 for print background 0 for print crab
    crab c1(h_cnt, v_cnt, crab_h_position1, crab_v_position1, crab_way1, crab_appear1, crab_type, crab_back1, crab_color1);
    //get crab2 color
    wire [11:0] crab_color2;
    wire crab_back2; // 1 for print background 0 for print crab
    crab c2(h_cnt, v_cnt, crab_h_position2, crab_v_position2, crab_way2, crab_appear2, crab_type, crab_back2, crab_color2);


    


    
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
                    {vgaRed, vgaGreen, vgaBlue} = pixel;
                end
            end
            else if(state == 2'b01) begin
                if(mouse_line_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = mouse_line_color;
                end
                else if(pause_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = pause_color;
                end
                else if(fish1_back1 == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = fish1_color1;
                end
                else if(fish1_back2 == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = fish1_color2;
                end
                else if(fish1_back3 == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = fish1_color3;
                end
                else if(fish1_back4 == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = fish1_color4;
                end
                else if(fish1_back5 == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = fish1_color5;
                end
                else if(fish1_back6 == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = fish1_color6;
                end
                else if(fast_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = fast_color;
                end
                else if(crab_back1 == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = crab_color1;
                end
                else if(crab_back2 == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = crab_color2;
                end
                else if(shark_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = shark_color;
                end
                else if(bait_back == 1'b0) begin
                    {vgaRed, vgaGreen, vgaBlue} = bait_color;
                end
                else begin
                    {vgaRed, vgaGreen, vgaBlue} = pixel;
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
                    {vgaRed, vgaGreen, vgaBlue} = pixel;
                end
            end
            else begin
                {vgaRed, vgaGreen, vgaBlue} = pixel;
            end
        end
        else begin
            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
        end
    end

    reg [8:0] position;
      //640*480 --> 320*240
    assign pixel_addr = (v_cnt >= 150) ? (h_cnt>>1)+320*(v_cnt>>1)% 76800 : 
    (((h_cnt>>1) + position) >=320) ?  ( ( (h_cnt>>1) + position - 320 )+320*(v_cnt>>1))% 76800 : ( ( (h_cnt>>1) + position )+320*(v_cnt>>1))% 76800;

    always@(posedge clk_23, posedge rst) begin
        if(rst)
            position <= 0;
        else begin
            if(position < 319)
                position <= position + 1;
            else
                position <= 0;
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
      
endmodule
        
