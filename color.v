module color (
    input [13:0] h_position,
    input [13:0] v_position,
    input valid,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [11:0] pixel,
    output reg [11:0] vga
);
    always @(*) begin
        if(valid == 1) begin
            if(h_cnt <=258 && h_cnt >=258 && v_cnt >= 72 && v_cnt <= (v_position / 10)) begin
                vga = 12'hfff;
            end
            else if(h_cnt >= (h_position / 10)) begin
                if((h_position / 10) == h_cnt && v_cnt - (v_position / 10) < 10) begin
                    vga = 12'hfff;
                end
                else if(( h_cnt - (h_position / 10) ) == 1 && v_cnt - (v_position / 10) > 0 && v_cnt - (v_position / 10) < 9) begin
                    vga = 12'hfff;
                end
                else if(( h_cnt - (h_position / 10) ) == 2 && v_cnt - (v_position / 10) > 1 && v_cnt - (v_position / 10) < 9) begin
                    vga = 12'hfff;
                end
                else if(( h_cnt - (h_position / 10) ) == 3 && v_cnt - (v_position / 10) > 2 && v_cnt - (v_position / 10) < 8) begin
                    vga = 12'hfff;
                end
                else if(( h_cnt - (h_position / 10) ) == 4 && v_cnt - (v_position / 10) > 3 && v_cnt - (v_position / 10) < 8) begin
                    vga = 12'hfff;
                end
                else if(( h_cnt - (h_position / 10) ) == 5 && v_cnt - (v_position / 10) > 4 && v_cnt - (v_position / 10) < 7) begin
                    vga = 12'hfff;
                end
                else if(( h_cnt - (h_position / 10) ) == 6 && v_cnt - (v_position / 10) == 6) begin
                    vga = 12'hfff;
                end
                else begin
                    vga = pixel;
                end
            end
            else begin
                vga = pixel;
            end
        end
        else begin
            vga = 12'h0;
        end
    end

endmodule