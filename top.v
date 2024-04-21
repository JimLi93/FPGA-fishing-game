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

    reg [23:0] cnt1; //only used here
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



    //fish1 - 1
    reg [2:0] fish1_amount;
    reg fish1_appear1, fish1_appear2, fish1_appear3, fish1_appear4, fish1_appear5, fish1_appear6, fish1_appear7, fish1_appear8;
    reg [9:0] fish1_h_position1, fish1_h_position2, fish1_h_position3, fish1_h_position4, fish1_h_position5, fish1_h_position6, fish1_h_position7, fish1_h_position8;
    reg [9:0] fish1_v_position1, fish1_v_position2, fish1_v_position3, fish1_v_position4, fish1_v_position5, fish1_v_position6, fish1_v_position7, fish1_v_position8;
    wire [2:0] fish1_v_movement1, fish1_v_movement2, fish1_v_movement3, fish1_v_movement4, fish1_v_movement5, fish1_v_movement6, fish1_v_movement7, fish1_v_movement8;
    reg [1:0] fish1_way1, fish1_way2, fish1_way3, fish1_way4, fish1_way5, fish1_way6, fish1_way7, fish1_way8;
    reg [2:0] fish1_movetype1, fish1_movetype2, fish1_movetype3, fish1_movetype4, fish1_movetype5, fish1_movetype6, fish1_movetype7, fish1_movetype8;
    wire fish1_up1, fish1_up2, fish1_up3, fish1_up4, fish1_up5, fish1_up6, fish1_up7, fish1_up8;
    //get fish color
    wire [11:0] fish1_color1, fish1_color2, fish1_color3, fish1_color4, fish1_color5, fish1_color6, fish1_color7, fish1_color8;
    wire fish1_back1, fish1_back2, fish1_back3, fish1_back4, fish1_back5, fish1_back6, fish1_back7, fish1_back8; // 1 for print background 0 for print fish

    

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
    fish1_move f1_move7(clk, rst, fish1_h_position7, fish1_v_position7, fish1_way7, fish1_appear7 ,fish1_movetype7, fish1_up7, fish1_v_movement7);
    fish1_move f1_move8(clk, rst, fish1_h_position8, fish1_v_position8, fish1_way8, fish1_appear8 ,fish1_movetype8, fish1_up8, fish1_v_movement8);

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            bait_mode = 2'b10;
            bait_cnt = 2'b00;
            cut = 0;
            cut_v = 0;
            score = 0;
        end
        else if(bait_mode == 2'b10) begin
            if(fish1_way1 == 2'b10 && fish1_appear1 == 1'b1) begin
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
            else if(fish1_way7 == 2'b10 && fish1_appear7 == 1'b1) begin
                bait_mode = 2'b11;
            end
            else if(fish1_way8 == 2'b10 && fish1_appear8 == 1'b1) begin
                bait_mode = 2'b11;
            end
            else begin
                bait_mode = 2'b10;
            end
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
            fish1_v_position1 = 415;
            fish1_h_position1 = 400;
            fish1_way1 = 0;
            fish1_movetype1 = 0;
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
                        fish1_v_position1 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position1 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position1 = 850;
                        fish1_movetype1 = fish1_movetype1 + 1;
                        fish1_way1 = fish_way1[fish1_movetype1];
                        fish1_v_position1 = fish_appear_v[fish1_movetype1];
                    end
                    else begin
                        fish1_h_position1 = 298;
                        fish1_v_position1 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position1 = 850;
                        fish1_movetype1 = fish1_movetype1 + 1;
                        fish1_way1 = fish_way1[fish1_movetype1];
                        fish1_v_position1 = fish_appear_v[fish1_movetype1];
                    end
                    else begin
                        fish1_h_position1 = 298;
                        fish1_v_position1 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position2 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position2 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position2 = 850;
                        fish1_movetype2 = fish1_movetype2 + 7;
                        fish1_way2 = fish_way2[fish1_movetype2];
                        fish1_v_position2 = fish_appear_v[fish1_movetype2];
                    end
                    else begin
                        fish1_h_position2 = 298;
                        fish1_v_position2 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position2 = 850;
                        fish1_movetype2 = fish1_movetype2 + 7;
                        fish1_way2 = fish_way2[fish1_movetype2];
                        fish1_v_position2 = fish_appear_v[fish1_movetype2];
                    end
                    else begin
                        fish1_h_position2 = 298;
                        fish1_v_position2 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position3 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position3 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position3 = 850;
                        fish1_movetype3 = fish1_movetype3 + 3;
                        fish1_way3 = fish_way3[fish1_movetype3];
                        fish1_v_position3 = fish_appear_v[fish1_movetype3];
                    end
                    else begin
                        fish1_h_position3 = 298;
                        fish1_v_position3 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position3 = 850;
                        fish1_movetype3 = fish1_movetype3 + 3;
                        fish1_way3 = fish_way3[fish1_movetype3];
                        fish1_v_position3 = fish_appear_v[fish1_movetype3];
                    end
                    else begin
                        fish1_h_position3 = 298;
                        fish1_v_position3 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position4 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position4 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position4 = 850;
                        fish1_movetype4 = fish1_movetype4 + 1;
                        fish1_way4 = fish_way4[fish1_movetype4];
                        fish1_v_position4 = fish_appear_v[fish1_movetype4];
                    end
                    else begin
                        fish1_h_position4 = 298;
                        fish1_v_position4 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position4 = 850;
                        fish1_movetype4 = fish1_movetype4 + 1;
                        fish1_way4 = fish_way4[fish1_movetype4];
                        fish1_v_position4 = fish_appear_v[fish1_movetype4];
                    end
                    else begin
                        fish1_h_position4 = 298;
                        fish1_v_position4 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position5 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position5 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position5 = 850;
                        fish1_movetype5 = fish1_movetype5 + 5;
                        fish1_way5 = fish_way5[fish1_movetype5];
                        fish1_v_position5 = fish_appear_v[fish1_movetype5];
                    end
                    else begin
                        fish1_h_position5 = 298;
                        fish1_v_position5 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position5 = 850;
                        fish1_movetype5 = fish1_movetype5 + 5;
                        fish1_way5 = fish_way5[fish1_movetype5];
                        fish1_v_position5 = fish_appear_v[fish1_movetype5];
                    end
                    else begin
                        fish1_h_position5 = 298;
                        fish1_v_position5 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position6 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                        fish1_v_position6 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position6 = 850;
                        fish1_movetype6 = fish1_movetype6 + 5;
                        fish1_way6 = fish_way6[fish1_movetype6];
                        fish1_v_position6 = fish_appear_v[fish1_movetype6];
                    end
                    else begin
                        fish1_h_position6 = 298;
                        fish1_v_position6 = (v_position / 10 > 62) ? v_position / 10 : 62;
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
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position6 = 850;
                        fish1_movetype6 = fish1_movetype6 + 5;
                        fish1_way6 = fish_way6[fish1_movetype6];
                        fish1_v_position6 = fish_appear_v[fish1_movetype6];
                    end
                    else begin
                        fish1_h_position6 = 298;
                        fish1_v_position6 = (v_position / 10 > 62) ? v_position / 10 : 62;
                    end
                end
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            fish1_v_position7 = 415;
            fish1_h_position7 = 400;
            fish1_way7 = 0;
            fish1_movetype7 = 0;
            fish1_appear7 = 0;
        end
        else if(playtime == 17) begin
            fish1_v_position7 = fish_appear_v[7];
            fish1_h_position7 = 900;
            fish1_way7 = fish_way7[7];
            fish1_movetype7 = 7;
            fish1_appear7 = 1;
        end
        else begin
            if(bait_mode == 2'b10) begin
                if(fish1_way7 == 2'b00) begin // 0 for left
                    if(fish1_h_position7 == 0) begin
                        fish1_h_position7 = 850;
                        fish1_movetype7 = fish1_movetype7 + 7;
                        fish1_way7 = fish_way7[fish1_movetype7];
                        fish1_v_position7 = fish_appear_v[fish1_movetype7];
                    end
                    else if(fish1_h_position7 <= 325 && fish1_h_position7 >= 314
                            && (v_position / 10) <= fish1_v_position7 + 25 && (v_position / 10) >= fish1_v_position7 - 5) begin
                        fish1_way7 = 2'b10;
                        fish1_h_position7 = 298;
                        fish1_v_position7 = (v_position / 10 > 62) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position7 = fish1_h_position7;
                    end
                    else begin
                        fish1_h_position7 = fish1_h_position7 - (cnt1 == 2000);
                        if(fish1_up7 == 1'b1) begin
                            fish1_v_position7 = fish1_v_position7 + fish1_v_movement7;
                        end
                        else begin
                            fish1_v_position7 = fish1_v_position7 - fish1_v_movement7;
                        end
                    end
                end
                else if(fish1_way7 == 2'b01) begin // 1 for right
                    if(fish1_h_position7 == 720) begin
                        fish1_h_position7 = 850;
                        fish1_movetype7 = fish1_movetype7 + 7;
                        fish1_way7 = fish_way7[fish1_movetype7];
                        fish1_v_position7 = fish_appear_v[fish1_movetype7];
                    end
                    else if(fish1_h_position7 <= 285 && fish1_h_position7 >= 274
                            && (v_position / 10) <= fish1_v_position7 + 25 && (v_position / 10) >= fish1_v_position7 - 5) begin
                        fish1_way7 = 2'b10;
                        fish1_h_position7 = 298;
                        fish1_v_position7 = (v_position / 10 > 62) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position7 = fish1_h_position7;
                    end
                    else begin
                        fish1_h_position7 = fish1_h_position7 + (cnt1 == 2000);
                        if(fish1_up7 == 1'b1) begin
                            fish1_v_position7 = fish1_v_position7 + fish1_v_movement7;
                        end
                        else begin
                            fish1_v_position7 = fish1_v_position7 - fish1_v_movement7;
                        end
                    end
                end
                else if(fish1_way7 == 2'b10) begin
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position7 = 850;
                        fish1_movetype7 = fish1_movetype7 + 7;
                        fish1_way7 = fish_way7[fish1_movetype7];
                        fish1_v_position7 = fish_appear_v[fish1_movetype7];
                    end
                    else begin
                        fish1_h_position7 = 298;
                        fish1_v_position7 = (v_position / 10 > 62) ? v_position / 10 : 62;
                    end
                end
            end
            else begin
                if(fish1_way7 == 2'b00) begin
                    if(fish1_h_position7 == 0) begin
                        fish1_h_position7 = 850;
                        fish1_movetype7 = fish1_movetype7 + 7;
                        fish1_way7 = fish_way7[fish1_movetype7];
                        fish1_v_position7 = fish_appear_v[fish1_movetype7];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position7 = fish1_h_position7;
                    end
                    else begin
                        fish1_h_position7 = fish1_h_position7 - (cnt1 == 2000);
                        if(fish1_up7 == 1'b1) begin
                            fish1_v_position7 = fish1_v_position7 + fish1_v_movement7;
                        end
                        else begin
                            fish1_v_position7 = fish1_v_position7 - fish1_v_movement7;
                        end
                    end
                end
                else if(fish1_way7 == 2'b01) begin
                    if(fish1_h_position7 == 720) begin
                        fish1_h_position7 = 850;
                        fish1_movetype7 = fish1_movetype7 + 7;
                        fish1_way7 = fish_way7[fish1_movetype7];
                        fish1_v_position7 = fish_appear_v[fish1_movetype7];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position7 = fish1_h_position7;
                    end
                    else begin
                        fish1_h_position7 = fish1_h_position7 + (cnt1 == 2000);
                        if(fish1_up7 == 1'b1) begin
                            fish1_v_position7 = fish1_v_position7 + fish1_v_movement7;
                        end
                        else begin
                            fish1_v_position7 = fish1_v_position7 - fish1_v_movement7;
                        end
                    end
                end
                else if(fish1_way7 == 2'b10) begin
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position7 = 850;
                        fish1_movetype7 = fish1_movetype7 + 7;
                        fish1_way7 = fish_way7[fish1_movetype7];
                        fish1_v_position7 = fish_appear_v[fish1_movetype7];
                    end
                    else begin
                        fish1_h_position7 = 298;
                        fish1_v_position7 = (v_position / 10 > 62) ? v_position / 10 : 62;
                    end
                end
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            fish1_v_position8 = 415;
            fish1_h_position8 = 400;
            fish1_way8 = 0;
            fish1_movetype8 = 0;
            fish1_appear8 = 0;
        end
        else if(playtime == 20) begin
            fish1_v_position8 = fish_appear_v[0];
            fish1_h_position8 = 900;
            fish1_way8 = fish_way8[0];
            fish1_movetype8 = 0;
            fish1_appear8 = 1;
        end
        else begin
            if(bait_mode == 2'b10) begin
                if(fish1_way8 == 2'b00) begin // 0 for left
                    if(fish1_h_position8 == 0) begin
                        fish1_h_position8 = 850;
                        fish1_movetype8 = fish1_movetype8 + 3;
                        fish1_way8 = fish_way8[fish1_movetype8];
                        fish1_v_position8 = fish_appear_v[fish1_movetype8];
                    end
                    else if(fish1_h_position8 <= 325 && fish1_h_position8 >= 314
                            && (v_position / 10) <= fish1_v_position8 + 25 && (v_position / 10) >= fish1_v_position8 - 5) begin
                        fish1_way8 = 2'b10;
                        fish1_h_position8 = 298;
                        fish1_v_position8 = (v_position / 10 > 62) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position8 = fish1_h_position8;
                    end
                    else begin
                        fish1_h_position8 = fish1_h_position8 - (cnt1 == 2000);
                        if(fish1_up8 == 1'b1) begin
                            fish1_v_position8 = fish1_v_position8 + fish1_v_movement8;
                        end
                        else begin
                            fish1_v_position8 = fish1_v_position8 - fish1_v_movement8;
                        end
                    end
                end
                else if(fish1_way8 == 2'b01) begin // 1 for right
                    if(fish1_h_position8 == 720) begin
                        fish1_h_position8 = 850;
                        fish1_movetype8 = fish1_movetype8 + 3;
                        fish1_way8 = fish_way8[fish1_movetype8];
                        fish1_v_position8 = fish_appear_v[fish1_movetype8];
                    end
                    else if(fish1_h_position8 <= 285 && fish1_h_position8 >= 274
                            && (v_position / 10) <= fish1_v_position8 + 25 && (v_position / 10) >= fish1_v_position8 - 5) begin
                        fish1_way8 = 2'b10;
                        fish1_h_position8 = 298;
                        fish1_v_position8 = (v_position / 10 > 62) ? v_position / 10 : 62;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position8 = fish1_h_position8;
                    end
                    else begin
                        fish1_h_position8 = fish1_h_position8 + (cnt1 == 2000);
                        if(fish1_up8 == 1'b1) begin
                            fish1_v_position8 = fish1_v_position8 + fish1_v_movement8;
                        end
                        else begin
                            fish1_v_position8 = fish1_v_position8 - fish1_v_movement8;
                        end
                    end
                end
                else if(fish1_way8 == 2'b10) begin
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position8 = 850;
                        fish1_movetype8 = fish1_movetype8 + 3;
                        fish1_way8 = fish_way8[fish1_movetype8];
                        fish1_v_position8 = fish_appear_v[fish1_movetype8];
                    end
                    else begin
                        fish1_h_position8 = 298;
                        fish1_v_position8 = (v_position / 10 > 62) ? v_position / 10 : 62;
                    end
                end
            end
            else begin
                if(fish1_way8 == 2'b00) begin
                    if(fish1_h_position8 == 0) begin
                        fish1_h_position8 = 850;
                        fish1_movetype8 = fish1_movetype8 + 3;
                        fish1_way8 = fish_way8[fish1_movetype8];
                        fish1_v_position8 = fish_appear_v[fish1_movetype8];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position8 = fish1_h_position8;
                    end
                    else begin
                        fish1_h_position8 = fish1_h_position8 - (cnt1 == 2000);
                        if(fish1_up8 == 1'b1) begin
                            fish1_v_position8 = fish1_v_position8 + fish1_v_movement8;
                        end
                        else begin
                            fish1_v_position8 = fish1_v_position8 - fish1_v_movement8;
                        end
                    end
                end
                else if(fish1_way8 == 2'b01) begin
                    if(fish1_h_position8 == 720) begin
                        fish1_h_position8 = 850;
                        fish1_movetype8 = fish1_movetype8 + 3;
                        fish1_way8 = fish_way8[fish1_movetype8];
                        fish1_v_position8 = fish_appear_v[fish1_movetype8];
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position8 = fish1_h_position8;
                    end
                    else begin
                        fish1_h_position8 = fish1_h_position8 + (cnt1 == 2000);
                        if(fish1_up8 == 1'b1) begin
                            fish1_v_position8 = fish1_v_position8 + fish1_v_movement8;
                        end
                        else begin
                            fish1_v_position8 = fish1_v_position8 - fish1_v_movement8;
                        end
                    end
                end
                else if(fish1_way8 == 2'b10) begin
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_h_position8 = 850;
                        fish1_movetype8 = fish1_movetype8 + 3;
                        fish1_way8 = fish_way8[fish1_movetype8];
                        fish1_v_position8 = fish_appear_v[fish1_movetype8];
                    end
                    else begin
                        fish1_h_position8 = 298;
                        fish1_v_position8 = (v_position / 10 > 62) ? v_position / 10 : 62;
                    end
                end
            end
        end
    end

    //get mouse & line color
    wire [11:0] mouse_line_color;
    wire mouse_line_back; // 1 for print background 0 for print mouse & line
    color c0(h_position, v_position, valid, h_cnt, v_cnt, cut, cut_v, mouse_line_back, mouse_line_color);

    fish1 f1(h_cnt, v_cnt, fish1_h_position1, fish1_v_position1, fish1_way1, fish1_appear1, 4'd1, fish1_back1, fish1_color1);
    fish1 f2(h_cnt, v_cnt, fish1_h_position2, fish1_v_position2, fish1_way2, fish1_appear2, 4'd2, fish1_back2, fish1_color2);
    fish1 f3(h_cnt, v_cnt, fish1_h_position3, fish1_v_position3, fish1_way3, fish1_appear3, 4'd3, fish1_back3, fish1_color3);
    fish1 f4(h_cnt, v_cnt, fish1_h_position4, fish1_v_position4, fish1_way4, fish1_appear4, 4'd4, fish1_back4, fish1_color4);
    fish1 f5(h_cnt, v_cnt, fish1_h_position5, fish1_v_position5, fish1_way5, fish1_appear5, 4'd5, fish1_back5, fish1_color5);
    fish1 f6(h_cnt, v_cnt, fish1_h_position6, fish1_v_position6, fish1_way6, fish1_appear6, 4'd6, fish1_back6, fish1_color6);
    fish1 f7(h_cnt, v_cnt, fish1_h_position7, fish1_v_position7, fish1_way7, fish1_appear7, 4'd7, fish1_back7, fish1_color7);
    fish1 f8(h_cnt, v_cnt, fish1_h_position8, fish1_v_position8, fish1_way8, fish1_appear8, 4'd8, fish1_back8, fish1_color8);





    
    //output vga color
    always @(*) begin
        if(valid == 1'b1) begin
            if(mouse_line_back == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = mouse_line_color;
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
            else if(fish1_back7 == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = fish1_color7;
            end
            else if(fish1_back8 == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = fish1_color8;
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
