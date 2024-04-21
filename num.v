module num (
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [5:0] score,
    input [9:0] playtime,
    input [1:0] state,
    output reg background //1 for print background 0 for print fish
);  
    parameter [0:0] alpha_s [0:143]= { //9*16
        0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,1,

        0,0,1,1,1,1,1,1,1,
        0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,
        1,1,1,1,1,1,1,0,0,

        1,1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,

        0,0,0,0,0,0,0,0,0
    };
    parameter [0:0] alpha_c [0:127]= { //8*16
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,

        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,0,0,0,0,0,0,

        0,0,0,0,0,0,0,0
    };
    parameter [0:0] alpha_o [0:127]= { //8*16
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,

        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,

        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,        
        0,0,0,0,0,0,0,0,

        0,0,0,0,0,0,0,0
    };

    parameter [0:0] alpha_r [0:127]= { //8*16
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,

        0,0,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,1,1,1,1,1,
        0,0,0,0,1,1,1,1,

        0,0,0,0,0,1,1,1,
        0,0,0,0,0,0,1,1,
        0,0,1,0,0,0,0,1,
        0,0,1,1,0,0,0,0,
        0,0,1,1,1,0,0,0,

        0,0,1,1,1,1,0,0
    };
    parameter [0:0] alpha_e [0:127]= { //8*16
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,

        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,1,1,

        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,  
        0,0,0,0,0,0,0,0,

        0,0,0,0,0,0,0,0
    };

    parameter [0:0] num1 [0:119] = { //8*15
        
        1,1,1,0,0,1,1,1,
        1,1,0,0,0,1,1,1,
        1,0,0,0,0,1,1,1,
        0,0,0,0,0,1,1,1,
        1,1,1,0,0,1,1,1,

        1,1,1,0,0,1,1,1,
        1,1,1,0,0,1,1,1,
        1,1,1,0,0,1,1,1,
        1,1,1,0,0,1,1,1,
        1,1,1,0,0,1,1,1,

        1,1,1,0,0,1,1,1,
        1,1,1,0,0,1,1,1,
        1,1,1,0,0,1,1,1,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0
    };
    parameter [0:0] num2 [0:119] = { //8*15
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,

        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,1,1,

        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0
    };
    parameter [0:0] num3 [0:119] = { //8*15
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,

        1,1,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,

        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0
    };
    parameter [0:0] num4 [0:119] = { //8*15
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,

        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        1,1,1,1,1,1,0,0,

        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0

    };
    parameter [0:0] num5 [0:119] = { //8*15
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,

        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        1,1,1,1,1,1,0,0,

        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0
    };
    parameter [0:0] num6 [0:119] = { //8*15
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,

        0,0,1,1,1,1,1,1,
        0,0,1,1,1,1,1,1,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,0,0,

        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0
    };
    parameter [0:0] num7 [0:119] = { //8*15
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,

        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,

        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0
    };
    parameter [0:0] num8 [0:119] = { //8*15
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,

        0,0,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,

        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0
    };
    parameter [0:0] num9 [0:119] = { //8*15
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,

        0,0,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,

        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        1,1,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0
    };
    parameter [0:0] num0 [0:119] = { //8*15
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,

        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,

        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,1,1,1,1,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0
    };



    always @(*) begin
        background = 1;
        if(v_cnt >= 18 && v_cnt <= 33 && state == 2'b01) begin
            if(h_cnt >= 20 && h_cnt <= 29) begin //T
                if(v_cnt >= 18 && v_cnt <= 20) begin
                    background = 0;
                end
                else if(h_cnt >= 24 && h_cnt <= 25) begin
                    background = 0;
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 32 && h_cnt <= 37) begin //I
                if(v_cnt >= 18 && v_cnt <= 19) begin
                    background = 0;
                end
                else if(v_cnt >= 32 && v_cnt <= 33) begin
                    background = 0;
                end
                else if(h_cnt >= 34 && h_cnt <= 35) begin
                    background = 0;
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 40 && h_cnt <= 49) begin //M
                if(v_cnt >= 18 && v_cnt <= 20) begin
                    background = 0;
                end
                else if(h_cnt >= 40 && h_cnt <= 41) begin
                    background = 0;
                end
                else if(h_cnt >= 44 && h_cnt <= 45) begin
                    background = 0;
                end
                else if(h_cnt >= 48 && h_cnt <= 49) begin
                    background = 0;
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 52 && h_cnt <= 59) begin //E
                if(v_cnt >= 18 && v_cnt <= 19) begin
                    background = 0;
                end
                else if(v_cnt >= 25 && v_cnt <= 26) begin
                    background = 0;
                end
                else if(v_cnt >= 32 && v_cnt <= 33) begin
                    background = 0;
                end
                else if(h_cnt >= 52 && h_cnt <= 53) begin
                    background = 0;
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 82 && h_cnt <= 90) begin //S
                if(v_cnt >= 18 && v_cnt <= 20) begin
                    background = 0;
                end
                else if(v_cnt >= 24 && v_cnt <= 26) begin
                    background = 0;
                end
                else if(v_cnt >= 31 && v_cnt <= 33) begin
                    background = 0;
                end
                else if(h_cnt >= 82 && h_cnt <= 83 && v_cnt >= 21 && v_cnt <= 23) begin
                    background = 0;
                end
                else if(h_cnt >= 89 && h_cnt <= 90 && v_cnt >= 27 && v_cnt <= 30) begin
                    background = 0;
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 93 && h_cnt <= 100) begin //C
                if(v_cnt >= 18 && v_cnt <= 19) begin
                    background = 0;
                end
                else if(v_cnt >= 32 && v_cnt <= 33) begin
                    background = 0;
                end
                else if(h_cnt >= 93 && h_cnt <= 94) begin
                    background = 0;
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 103 && h_cnt <= 110) begin //O
                if(v_cnt >= 18 && v_cnt <= 19) begin
                    background = 0;
                end
                else if(v_cnt >= 32 && v_cnt <= 33) begin
                    background = 0;
                end
                else if(h_cnt >= 103 && h_cnt <= 104) begin
                    background = 0;
                end
                else if(h_cnt >= 109 && h_cnt <= 110) begin
                    background = 0;
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 113 && h_cnt <= 120) begin //R
                if(v_cnt >= 18 && v_cnt <= 19) begin
                    background = 0;
                end
                else if(v_cnt >= 24 && v_cnt <= 25) begin
                    background = 0;
                end
                else if(h_cnt >= 113 && h_cnt <= 114) begin
                    background = 0;
                end
                else if(h_cnt >= 119 && h_cnt <= 120 && v_cnt >= 20 && v_cnt <= 23) begin
                    background = 0;
                end
                else if(h_cnt == 115 && v_cnt >= 26 && v_cnt <= 29) begin
                    background = 0;
                end
                else if(h_cnt == 116 && v_cnt >= 27 && v_cnt <= 30) begin
                    background = 0;
                end
                else if(h_cnt == 117 && v_cnt >= 28 && v_cnt <= 31) begin
                    background = 0;
                end
                else if(h_cnt == 118 && v_cnt >= 29 && v_cnt <= 32) begin
                    background = 0;
                end
                else if(h_cnt == 119 && v_cnt >= 30 && v_cnt <= 33) begin
                    background = 0;
                end
                else if(h_cnt == 120 && v_cnt >= 31 && v_cnt <= 33) begin
                    background = 0;
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 123 && h_cnt <= 130) begin //E
                if(v_cnt >= 18 && v_cnt <= 19) begin
                    background = 0;
                end
                else if(v_cnt >= 25 && v_cnt <= 26) begin
                    background = 0;
                end
                else if(v_cnt >= 32 && v_cnt <= 33) begin
                    background = 0;
                end
                else if(h_cnt >= 123 && h_cnt <= 124) begin
                    background = 0;
                end
                else begin
                    background = 1;
                end
            end
            else begin
                background = 1;
            end

        end

        else if(v_cnt >= 50 && v_cnt <= 64 && state == 2'b01) begin
            if(h_cnt >= 18 && h_cnt <= 25) begin
                background = num0[(v_cnt - 50) * 8 + (h_cnt - 18)];
            end
            else if(h_cnt >= 28 && h_cnt <= 35) begin
                if((playtime / 60) == 0) begin
                    background = num0[(v_cnt - 50) * 8 + (h_cnt - 28)];
                end
                else if((playtime / 60) == 1) begin
                    background = num1[(v_cnt - 50) * 8 + (h_cnt - 28)];
                end
                else if((playtime / 60) == 2) begin
                    background = num2[(v_cnt - 50) * 8 + (h_cnt - 28)];
                end
                else if((playtime / 60) == 3) begin
                    background = num3[(v_cnt - 50) * 8 + (h_cnt - 28)];
                end
                else if((playtime / 60) == 4) begin
                    background = num4[(v_cnt - 50) * 8 + (h_cnt - 28)];
                end
                else if((playtime / 60) == 5) begin
                    background = num5[(v_cnt - 50) * 8 + (h_cnt - 28)];
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 39 && h_cnt <= 40) begin
                if(v_cnt >= 53 && v_cnt <= 55) begin
                    background = 0;
                end
                else if(v_cnt >= 59 && v_cnt <= 61) begin
                    background = 0;
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 44 && h_cnt <= 51) begin
                if(((playtime % 60) / 10) == 0) begin
                    background = num0[(v_cnt - 50) * 8 + (h_cnt - 44)];
                end
                else if(((playtime % 60) / 10) == 1) begin
                    background = num1[(v_cnt - 50) * 8 + (h_cnt - 44)];
                end
                else if(((playtime % 60) / 10) == 2) begin
                    background = num2[(v_cnt - 50) * 8 + (h_cnt - 44)];
                end
                else if(((playtime % 60) / 10) == 3) begin
                    background = num3[(v_cnt - 50) * 8 + (h_cnt - 44)];
                end
                else if(((playtime % 60) / 10) == 4) begin
                    background = num4[(v_cnt - 50) * 8 + (h_cnt - 44)];
                end
                else if(((playtime % 60) / 10) == 5) begin
                    background = num5[(v_cnt - 50) * 8 + (h_cnt - 44)];
                end
                else if(((playtime % 60) / 10) == 6) begin
                    background = num6[(v_cnt - 50) * 8 + (h_cnt - 44)];
                end
                else if(((playtime % 60) / 10) == 7) begin
                    background = num7[(v_cnt - 50) * 8 + (h_cnt - 44)];
                end
                else if(((playtime % 60) / 10) == 8) begin
                    background = num8[(v_cnt - 50) * 8 + (h_cnt - 44)];
                end
                else if(((playtime % 60) / 10) == 9) begin
                    background = num9[(v_cnt - 50) * 8 + (h_cnt - 44)];
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 54 && h_cnt <= 61) begin
                if((playtime % 10) == 0) begin
                    background = num0[(v_cnt - 50) * 8 + (h_cnt - 54)];
                end
                else if((playtime % 10) == 1) begin
                    background = num1[(v_cnt - 50) * 8 + (h_cnt - 54)];
                end
                else if((playtime % 10) == 2) begin
                    background = num2[(v_cnt - 50) * 8 + (h_cnt - 54)];
                end
                else if((playtime % 10) == 3) begin
                    background = num3[(v_cnt - 50) * 8 + (h_cnt - 54)];
                end
                else if((playtime % 10) == 4) begin
                    background = num4[(v_cnt - 50) * 8 + (h_cnt - 54)];
                end
                else if((playtime % 10) == 5) begin
                    background = num5[(v_cnt - 50) * 8 + (h_cnt - 54)];
                end
                else if((playtime % 10) == 6) begin
                    background = num6[(v_cnt - 50) * 8 + (h_cnt - 54)];
                end
                else if((playtime % 10) == 7) begin
                    background = num7[(v_cnt - 50) * 8 + (h_cnt - 54)];
                end
                else if((playtime % 10) == 8) begin
                    background = num8[(v_cnt - 50) * 8 + (h_cnt - 54)];
                end
                else if((playtime % 10) == 9) begin
                    background = num9[(v_cnt - 50) * 8 + (h_cnt - 54)];
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 96 && h_cnt <= 103) begin
                if((score / 10) == 0) begin
                    background = num0[(v_cnt - 50) * 8 + (h_cnt - 96)];
                end
                else if((score / 10) == 1) begin
                    background = num1[(v_cnt - 50) * 8 + (h_cnt - 96)];
                end
                else if((score / 10) == 2) begin
                    background = num2[(v_cnt - 50) * 8 + (h_cnt - 96)];
                end
                else if((score / 10) == 3) begin
                    background = num3[(v_cnt - 50) * 8 + (h_cnt - 96)];
                end
                else if((score / 10) == 4) begin
                    background = num4[(v_cnt - 50) * 8 + (h_cnt - 96)];
                end
                else if((score / 10) == 5) begin
                    background = num5[(v_cnt - 50) * 8 + (h_cnt - 96)];
                end
                else if((score / 10) == 6) begin
                    background = num6[(v_cnt - 50) * 8 + (h_cnt - 96)];
                end
                else if((score / 10) == 7) begin
                    background = num7[(v_cnt - 50) * 8 + (h_cnt - 96)];
                end
                else if((score / 10) == 8) begin
                    background = num8[(v_cnt - 50) * 8 + (h_cnt - 96)];
                end
                else if((score / 10) == 9) begin
                    background = num9[(v_cnt - 50) * 8 + (h_cnt - 96)];
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 110 && h_cnt <= 117) begin
                if((score % 10) == 0) begin
                    background = num0[(v_cnt - 50) * 8 + (h_cnt - 110)];
                end
                else if((score % 10) == 1) begin
                    background = num1[(v_cnt - 50) * 8 + (h_cnt - 110)];
                end
                else if((score % 10) == 2) begin
                    background = num2[(v_cnt - 50) * 8 + (h_cnt - 110)];
                end
                else if((score % 10) == 3) begin
                    background = num3[(v_cnt - 50) * 8 + (h_cnt - 110)];
                end
                else if((score % 10) == 4) begin
                    background = num4[(v_cnt - 50) * 8 + (h_cnt - 110)];
                end
                else if((score % 10) == 5) begin
                    background = num5[(v_cnt - 50) * 8 + (h_cnt - 110)];
                end
                else if((score % 10) == 6) begin
                    background = num6[(v_cnt - 50) * 8 + (h_cnt - 110)];
                end
                else if((score % 10) == 7) begin
                    background = num7[(v_cnt - 50) * 8 + (h_cnt - 110)];
                end
                else if((score % 10) == 8) begin
                    background = num8[(v_cnt - 50) * 8 + (h_cnt - 110)];
                end
                else if((score % 10) == 9) begin
                    background = num9[(v_cnt - 50) * 8 + (h_cnt - 110)];
                end
                else begin
                    background = 1;
                end
            end
            else begin
                background = 1;
            end
        end
        else if(v_cnt >= 240 && v_cnt <= 271 && state == 2'b11) begin
            if(h_cnt >= 270 && h_cnt <= 287) begin //S
                background = alpha_s[((v_cnt - 240)>>1) * 9 + ((h_cnt - 270)>>1)];
            end
            else if(h_cnt >= 292 && h_cnt <= 307) begin //C
                background = alpha_c[((v_cnt - 240)>>1) * 8 + ((h_cnt - 292)>>1)];
            end
            else if(h_cnt >= 312 && h_cnt <= 327) begin //O
                background = alpha_o[((v_cnt - 240)>>1) * 8 + ((h_cnt - 312)>>1)];
            end
            else if(h_cnt >= 332 && h_cnt <= 347) begin //R
                background = alpha_r[((v_cnt - 240)>>1) * 8 + ((h_cnt - 332)>>1)];
            end
            else if(h_cnt >= 352 && h_cnt <= 367) begin //E
                background = alpha_e[((v_cnt - 240)>>1) * 8 + ((h_cnt - 352)>>1)];
            end
            else begin
                background = 1;
            end
        end
        else if(v_cnt >= 290 && v_cnt <= 319 && state == 2'b11) begin
            if(h_cnt >= 302 && h_cnt <= 317) begin 
                if((score / 10) == 0) begin
                    background = num0[((v_cnt - 290)>>1) * 8 + ((h_cnt - 302)>>1)];
                end
                else if((score / 10) == 1) begin
                    background = num1[((v_cnt - 290)>>1) * 8 + ((h_cnt - 302)>>1)];
                end
                else if((score / 10) == 2) begin
                    background = num2[((v_cnt - 290)>>1) * 8 + ((h_cnt - 302)>>1)];
                end
                else if((score / 10) == 3) begin
                    background = num3[((v_cnt - 290)>>1) * 8 + ((h_cnt - 302)>>1)];
                end
                else if((score / 10) == 4) begin
                    background = num4[((v_cnt - 290)>>1) * 8 + ((h_cnt - 302)>>1)];
                end
                else if((score / 10) == 5) begin
                    background = num5[((v_cnt - 290)>>1) * 8 + ((h_cnt - 302)>>1)];
                end
                else if((score / 10) == 6) begin
                    background = num6[((v_cnt - 290)>>1) * 8 + ((h_cnt - 302)>>1)];
                end
                else if((score / 10) == 7) begin
                    background = num7[((v_cnt - 290)>>1) * 8 + ((h_cnt - 302)>>1)];
                end
                else if((score / 10) == 8) begin
                    background = num8[((v_cnt - 290)>>1) * 8 + ((h_cnt - 302)>>1)];
                end
                else if((score / 10) == 9) begin
                    background = num9[((v_cnt - 290)>>1) * 8 + ((h_cnt - 302)>>1)];
                end
                else begin
                    background = 1;
                end
            end
            else if(h_cnt >= 322 && h_cnt <= 337) begin 
                if((score % 10) == 0) begin
                    background = num0[((v_cnt - 290)>>1) * 8 + ((h_cnt - 322)>>1)];
                end
                else if((score % 10) == 1) begin
                    background = num1[((v_cnt - 290)>>1) * 8 + ((h_cnt - 322)>>1)];
                end
                else if((score % 10) == 2) begin
                    background = num2[((v_cnt - 290)>>1) * 8 + ((h_cnt - 322)>>1)];
                end
                else if((score % 10) == 3) begin
                    background = num3[((v_cnt - 290)>>1) * 8 + ((h_cnt - 322)>>1)];
                end
                else if((score % 10) == 4) begin
                    background = num4[((v_cnt - 290)>>1) * 8 + ((h_cnt - 322)>>1)];
                end
                else if((score % 10) == 5) begin
                    background = num5[((v_cnt - 290)>>1) * 8 + ((h_cnt - 322)>>1)];
                end
                else if((score % 10) == 6) begin
                    background = num6[((v_cnt - 290)>>1) * 8 + ((h_cnt - 322)>>1)];
                end
                else if((score % 10) == 7) begin
                    background = num7[((v_cnt - 290)>>1) * 8 + ((h_cnt - 322)>>1)];
                end
                else if((score % 10) == 8) begin
                    background = num8[((v_cnt - 290)>>1) * 8 + ((h_cnt - 322)>>1)];
                end
                else if((score % 10) == 9) begin
                    background = num9[((v_cnt - 290)>>1) * 8 + ((h_cnt - 322)>>1)];
                end
                else begin
                    background = 1;
                end
            end
            else begin
                background = 1;
            end
        end
        else begin
            background = 1;
        end
    end

    

endmodule