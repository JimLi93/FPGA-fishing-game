module bait (
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [13:0] mouse_v,
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
    always @(*) begin
        if(h_cnt >= 256 && h_cnt <= 262) begin
            if((mouse_v / 10) <= 72) begin
                if(v_cnt <= 86 && v_cnt >= 72 && bait_pic[(v_cnt - 72) * 7 + (h_cnt - 256)] != 12'h352) begin
                    background = 0;
                    vga = bait_pic[(v_cnt - 72) * 7 + (h_cnt - 256)];
                end
                else begin
                    background = 1;
                    vga = 12'h000;
                end
            end
            else begin
                if(v_cnt <= ((mouse_v / 10) + 14) && v_cnt >= (mouse_v / 10) && bait_pic[(v_cnt - (mouse_v / 10)) * 7 + (h_cnt - 256)] != 12'h352) begin
                    background = 0;
                    vga = bait_pic[(v_cnt - (mouse_v / 10)) * 7 + (h_cnt - 256)];
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



    
endmodule