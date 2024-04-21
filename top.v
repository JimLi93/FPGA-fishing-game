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
    wire [16:0] pixel_addr;
    reg [16:0] tmp_pixel_addr;
    wire [11:0] pixel;
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

    reg crab_type;
    reg n_crab_type;


    clock_divide #(13) div0(.clk(clk),.clk_div(clk_div));
    clock_divide #(2) div1(clk, clk_25MHz);
    clock_divide #(21) div21(clk, clk_21);
    clock_divide #(20) div20(clk, clk_20);
    clock_divide #(19) div19(clk, clk_19);

    reg [19:0] cnt1; //only used here
    reg [7:0] fish_way = 8'b10110010; 

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            cnt1 = 0;
        end
        else if(cnt1 == 1500) begin
            cnt1 = 0;
        end
        else begin
            cnt1 = cnt1 + 1;
        end
    end

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
    reg fish1_appear1 = 1;
    reg [9:0] fish1_h_position1 = 400;
    reg [9:0] fish1_v_position1 = 320;
    wire [2:0] fish1_h_movement1;
    wire [2:0] fish1_v_movement1;
    reg [1:0] fish1_way1 = 0;
    reg [2:0] fish1_movetype1 = 0;
    fish1_move f1_move1(clk, rst, fish1_h_position1, fish1_v_position1, fish1_way1, fish1_appear1 ,fish1_movetype1, v_position, fish1_h_movement1, fish1_v_movement1);

    wire [11:0] bait_color;
    wire bait_back; // 1 for print background 0 for print fish
    reg [1:0] bait_mode;
    reg [1:0] bait_cnt;
    reg cut;
    reg [9:0] cut_v;
    bait bait1(bait_mode, h_cnt, v_cnt, v_position, bait_back, bait_color);

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            bait_mode = 2'b10;
            bait_cnt = 2'b00;
            cut = 0;
            cut_v = 0;
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
            else begin
                bait_mode = 2'b10;
                bait_cnt = 0;
                cut = 0;
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            fish1_v_position1 = 320;
            fish1_h_position1 = 400;
            fish1_way1 = 0;
        end
        else begin
            if(bait_mode == 2'b10) begin
                //fish1_v_position1 = fish1_v_position1 + fish1_v_movement1;
                if(fish1_way1 == 2'b00) begin
                    if(fish1_h_position1 == 0) begin
                        fish1_h_position1 = 700;
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
                    else fish1_h_position1 = fish1_h_position1 - fish1_h_movement1;
                end
                else if(fish1_way1 == 2'b01) begin
                    if(fish1_h_position1 == 720) begin
                        fish1_h_position1 = 1000;
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
                    else fish1_h_position1 = fish1_h_position1 + fish1_h_movement1;
                end
                else if(fish1_way1 == 2'b10) begin
                    if(btnm[0] == 1'b1 && (v_position / 10) <= 62) begin
                        fish1_way1 = in_way;
                        fish1_v_position1 = 400;
                        if(in_way == 0) begin
                            fish1_h_position1 = 800;
                        end 
                        else fish1_h_position1 = 900;
                    end
                    else begin
                        fish1_h_position1 = 298;
                        fish1_v_position1 = (v_position / 10 > 62) ? v_position / 10 : 62;
                    end
                end
            end
            else if(bait_mode == 2'b01) begin
                //fish1_v_position1 = fish1_v_position1 + fish1_v_movement1;
                if(fish1_way1 == 2'b00) begin
                    if(fish1_h_position1 == 0) begin
                        fish1_h_position1 = 700;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position1 = fish1_h_position1;
                    end
                    else fish1_h_position1 = fish1_h_position1 - fish1_h_movement1;
                end
                else if(fish1_way1 == 2'b01) begin
                    if(fish1_h_position1 == 720) begin
                        fish1_h_position1 = 1000;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position1 = fish1_h_position1;
                    end
                    else fish1_h_position1 = fish1_h_position1 + fish1_h_movement1;
                end
                else if(fish1_way1 == 2'b10) begin
                    fish1_h_position1 = 298;
                    fish1_v_position1 = (v_position / 10 > 62) ? v_position / 10 : 62;
                end
            end
            else if(bait_mode == 2'b00) begin
                //fish1_v_position1 = fish1_v_position1 + fish1_v_movement1;
                if(fish1_way1 == 2'b00) begin
                    if(fish1_h_position1 == 0) begin
                        fish1_h_position1 = 700;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position1 = fish1_h_position1;
                    end
                    else fish1_h_position1 = fish1_h_position1 - fish1_h_movement1;
                end
                else if(fish1_way1 == 2'b01) begin
                    if(fish1_h_position1 == 720) begin
                        fish1_h_position1 = 1000;
                    end
                    else if(enable[0] == 1'b1) begin
                        fish1_h_position1 = fish1_h_position1;
                    end
                    else fish1_h_position1 = fish1_h_position1 + fish1_h_movement1;
                end
                else if(fish1_way1 == 2'b10) begin
                    fish1_h_position1 = 298;
                    fish1_v_position1 = (v_position / 10 > 62) ? v_position / 10 : 62;
                end
            end
            
        end
    end
    
    //get mouse & line color
    wire [11:0] mouse_line_color;
    wire mouse_line_back; // 1 for print background 0 for print mouse & line
    color c0(h_position, v_position, valid, h_cnt, v_cnt, cut, cut_v, mouse_line_back, mouse_line_color);

    //get fish color
    wire [11:0] fish1_color1;
    wire fish1_back1; // 1 for print background 0 for print fish
    fish1 f1(h_cnt, v_cnt, fish1_h_position1, fish1_v_position1, fish1_way1, fish1_appear1, fish1_back1, fish1_color1);

    //crab - 1

    always @(posedge clk_19, posedge rst) begin
        if(rst == 1'b1) begin
            crab_h_position1 = 700;
            crab_v_position1 = 380;
            crab_way1 = 0;
            crab_appear1 = 0;
            crab_movement1 = 0;
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
                    if(fish_way[crab_movement1] == 1'b0) begin
                        crab_h_position1 = 1023;
                    end
                    else begin
                        crab_h_position1 = 670;
                    end
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
                    if(fish_way[crab_movement1] == 1'b0) begin
                        crab_h_position1 = 1023;
                    end
                    else begin
                        crab_h_position1 = 670;
                    end
                end
                crab_h_position1 = crab_h_position1 + 1;
            end
        end
    end

    //crab - 2

    always @(posedge clk_19, posedge rst) begin
        if(rst == 1'b1) begin
            crab_h_position2 = 700;
            crab_v_position2 = 250;
            crab_way2 = 0;
            crab_appear2 = 0;
            crab_movement2 = 4;
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
                    if(fish_way[crab_movement2] == 1'b1) begin
                        crab_h_position2 = 1023;
                    end
                    else begin
                        crab_h_position2 = 670;
                    end
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
                    if(fish_way[crab_movement2] == 1'b1) begin
                        crab_h_position2 = 1023;
                    end
                    else begin
                        crab_h_position2 = 670;
                    end
                end
                crab_h_position2 = crab_h_position2 + 1;
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
            if(mouse_line_back == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = mouse_line_color;
            end
            else if(fish1_back1 == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = fish1_color1;
            end
            else if(bait_back == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = bait_color;
            end
            else if(crab_back1 == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = crab_color1;
            end
            else if(crab_back2 == 1'b0) begin
                {vgaRed, vgaGreen, vgaBlue} = crab_color2;
            end
            else begin
                {vgaRed, vgaGreen, vgaBlue} = pixel;
            end

        end
        else begin
            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
        end
    end


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
            if(sw[3] == 1'b1) begin
                seg = 0;
            end
            else if(sw == 4'b0100) begin
                seg = crab_v_position1 / 1000;
            end
            else if(sw == 4'b0101) begin
                seg = crab_h_position1 / 1000;
            end
            else if(sw == 4'b0110) begin
                seg = crab_v_position2 / 1000;
            end
            else if(sw == 4'b0111) begin
                seg = crab_h_position2 / 1000;
            end
            else if(sw == 4'b0000) begin
                seg = fish1_v_position1 / 1000;
            end
            else if(sw == 4'b0001) begin
                seg = fish1_h_position1 / 1000;
            end
            else if(sw == 4'b0010) begin
                seg = v_position / 1000;
            end
            else if(sw == 4'b0011) begin
                seg = h_position / 1000;
            end
            else begin
                seg = fish1_h_position1 / 1000;
            end
        end 

        2'b01:begin
            DIGIT = 4'b1011;
            if(sw[3] == 1'b1) begin
                seg = (total_time - playtime) / 60;
            end
            else if(sw == 4'b0100) begin
                seg = (crab_v_position1 % 1000) / 100;
            end
            else if(sw == 4'b0101) begin
                seg = (crab_h_position1 % 1000) / 100;
            end
            else if(sw == 4'b0110) begin
                seg = (crab_v_position2 % 1000) / 100;
            end
            else if(sw == 4'b0111) begin
                seg = (crab_h_position2 % 1000) / 100;
            end
            else if(sw == 4'b0000) begin
                seg = (fish1_v_position1 % 1000) / 100;
            end
            else if(sw == 4'b0001) begin
                seg = (fish1_h_position1 % 1000) / 100;
            end
            else if(sw == 4'b0010) begin
                seg = (v_position % 1000) / 100;
            end
            else if(sw == 4'b0011) begin
                seg = (h_position % 1000) / 100;
            end
            else begin
                seg = (fish1_h_position1 % 1000) / 100;
            end
        end

        2'b10:begin
            DIGIT = 4'b1101;
            if(sw[3] == 1'b1) begin
                seg = ((total_time - playtime) % 60) / 10;
            end
            else if(sw == 4'b0100) begin
                seg = (crab_v_position1 % 100) / 10;
            end
            else if(sw == 4'b0101) begin
                seg = (crab_h_position1 % 100) / 10;
            end
            else if(sw == 4'b0110) begin
                seg = (crab_v_position2 % 100) / 10;
            end
            else if(sw == 4'b0111) begin
                seg = (crab_h_position2 % 100) / 10;
            end
            else if(sw == 4'b0000) begin
                seg = (fish1_v_position1 % 100) / 10;
            end
            else if(sw == 4'b0001) begin
                seg = (fish1_h_position1 % 100) / 10;
            end
            else if(sw == 4'b0010) begin
                seg = (v_position % 100) / 10;
            end
            else if(sw == 4'b0011) begin
                seg = (h_position % 100) / 10;
            end
            else begin
                seg = (fish1_h_position1 % 100) / 10;
            end
        end

        2'b11:begin
            DIGIT = 4'b1110;
            if(sw[3] == 1'b1) begin
                seg = (total_time - playtime) % 10;
            end
            else if(sw == 4'b0100) begin
                seg = crab_v_position1 % 10;
            end
            else if(sw == 4'b0101) begin
                seg = crab_h_position1 % 10;
            end
            else if(sw == 4'b0110) begin
                seg = crab_v_position2 % 10;
            end
            else if(sw == 4'b0111) begin
                seg = crab_h_position2 % 10;
            end
            else if(sw == 4'b0000) begin
                seg = fish1_v_position1 % 10;
            end
            else if(sw == 4'b0001) begin
                seg = fish1_h_position1 % 10;
            end
            else if(sw == 4'b0010) begin
                seg = v_position % 10;
            end
            else if(sw == 4'b0011) begin
                seg = h_position % 10;
            end
            else begin
                seg = fish1_h_position1 % 10;
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
