module bait (
    input [1:0] mode, //0 for nothing //1 for only hook // 2 for hook+bait
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [9:0] mouse_v,
    output reg background, //1 for print background 0 for print fish
    output reg [11:0] vga
);
    parameter [11:0] bait_pic [0:104] = {//7*15
        //get rid of down one line
        //get rid of 353,351,452,453, 463, 464 etc.
        12'h352,12'h352,12'h575,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h454,12'h977,12'h455,12'h352,12'h352,12'h352,
        12'h352,12'h554,12'h855,12'h444,12'h352,12'h352,12'h352,
        12'h352,12'h666,12'h765,12'h555,12'h352,12'h352,12'h352,
        12'h352,12'h556,12'h765,12'h455,12'h355,12'h352,12'h352,
        12'h352,12'h566,12'h665,12'h345,12'h253,12'h352,12'h352,
        12'h352,12'h455,12'h777,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h566,12'h889,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h778,12'h788,12'h355,12'h255,12'h352,12'h352,
        12'h352,12'h899,12'h789,12'h352,12'h254,12'h356,12'h352,
        12'h352,12'h99A,12'h899,12'h455,12'h454,12'h677,12'h565,
        12'h352,12'h888,12'h999,12'h566,12'h555,12'h999,12'h788,
        12'h352,12'h677,12'h999,12'h889,12'h888,12'hAAA,12'h688,
        12'h352,12'h566,12'h989,12'h99A,12'h999,12'h899,12'h466,
        12'h352,12'h352,12'h567,12'h678,12'h678,12'h466,12'h352
    };

    parameter [11:0] bait_pic_2 [0:151] = {//8*19
        //get rid of down one line
        //get rid of 353,351,452,453, 463, 464 etc. //553
        12'h865,12'h866,12'h875,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h865,12'h865,12'h764,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h766,12'h766,12'h654,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h665,12'h665,12'h554,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h554,12'h665,12'h554,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h443,12'h766,12'h766,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h554,12'h888,12'h888,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h565,12'h998,12'h553,12'h551,12'h352,12'h352,12'h352,12'h352,
        12'h666,12'hA99,12'h753,12'h962,12'hB94,12'h773,12'h352,12'h352,
        12'h676,12'hA99,12'h742,12'hA62,12'hB83,12'hB94,12'h562,12'h352,
        12'h666,12'h999,12'h754,12'h642,12'h962,12'hC84,12'h773,12'h352,
        12'h565,12'h988,12'h888,12'h766,12'h753,12'h962,12'h763,12'h352,
        12'h553,12'h887,12'h988,12'h877,12'h754,12'h952,12'h663,12'h352,
        12'h552,12'h763,12'h875,12'h766,12'h643,12'h952,12'h864,12'h352,
        12'h552,12'h862,12'h851,12'h542,12'h553,12'h952,12'h852,12'h352,
        12'h352,12'h652,12'hA73,12'h862,12'h552,12'h961,12'hA72,12'h663,
        12'h352,12'h352,12'h973,12'hA83,12'h552,12'hA72,12'hC94,12'hBA6,
        12'h352,12'h352,12'h963,12'hA84,12'h452,12'h983,12'hDA6,12'hBA6,
        12'h352,12'h352,12'h973,12'h984,12'h352,12'h352,12'h995,12'h673
        //12'h453,12'h352,12'h352,12'h352,12'h562,12'h463,12'h352,12'h352,12'h352,12'h352
    };

    always @(*) begin
        if(mode == 2'b00) begin
            background = 1;
            vga = 12'h000;
        end
        else if(mode == 2'b01) begin
            if(h_cnt >= 277 && h_cnt <= 283) begin
                if(mouse_v <= 62) begin
                    if(v_cnt <= 76 && v_cnt >= 62 && bait_pic[(v_cnt - 62) * 7 + (h_cnt - 277)] != 12'h352) begin
                        background = 0;
                        vga = bait_pic[(v_cnt - 62) * 7 + (h_cnt - 277)];
                    end
                    else begin
                        background = 1;
                        vga = 12'h000;
                    end
                end
                else begin
                    if(v_cnt <= (mouse_v + 14) && v_cnt >= mouse_v  && bait_pic[(v_cnt - mouse_v) * 7 + (h_cnt - 277)] != 12'h352) begin
                        background = 0;
                        vga = bait_pic[(v_cnt - mouse_v) * 7 + (h_cnt - 277)];
                    end
                    else begin
                        background = 1;
                        vga = 12'h000;
                    end
                end
            end
            else begin
                background = 1;
                vga = 12'h000;
            end
        end
        else if(mode == 2'b10) begin
            if(h_cnt >= 278 && h_cnt <= 285) begin
                if((mouse_v) <= 62) begin
                    if(v_cnt <= 80 && v_cnt >= 62 && bait_pic_2[(v_cnt - 62) * 8 + (h_cnt - 278)] != 12'h352) begin
                        background = 0;
                        vga = bait_pic_2[(v_cnt - 62) * 8 + (h_cnt - 278)];
                    end
                    else begin
                        background = 1;
                        vga = 12'h000;
                    end
                end
                else begin
                    if(v_cnt <= ((mouse_v) + 18) && v_cnt >= (mouse_v) && bait_pic_2[(v_cnt - (mouse_v)) * 8 + (h_cnt - 278)] != 12'h352) begin
                        background = 0;
                        vga = bait_pic_2[(v_cnt - (mouse_v)) * 8 + (h_cnt - 278)];
                    end
                    else begin
                        background = 1;
                        vga = 12'h000;
                    end
                end
            end
            else begin
                background = 1;
                vga = 12'h000;
            end
        end
        else begin
            if(h_cnt >= 278 && h_cnt <= 285) begin
                if((mouse_v) <= 62) begin
                    if(v_cnt <= 80 && v_cnt >= 62 && bait_pic_2[(v_cnt - 62) * 8 + (h_cnt - 278)] != 12'h352) begin
                        background = 0;
                        vga = bait_pic_2[(v_cnt - 62) * 8 + (h_cnt - 278)];
                    end
                    else begin
                        background = 1;
                        vga = 12'h000;
                    end
                end
                else begin
                    if(v_cnt <= ((mouse_v) + 18) && v_cnt >= (mouse_v) && bait_pic_2[(v_cnt - (mouse_v)) * 8 + (h_cnt - 278)] != 12'h352) begin
                        background = 0;
                        vga = bait_pic_2[(v_cnt - (mouse_v)) * 8 + (h_cnt - 278)];
                    end
                    else begin
                        background = 1;
                        vga = 12'h000;
                    end
                end
            end
            else begin
                background = 1;
                vga = 12'h000;
            end
        end
         
    end

endmodule

