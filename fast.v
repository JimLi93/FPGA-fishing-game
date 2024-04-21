module fast (
    input valid,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [9:0] fish_position,
    input [1:0] fish_way,  //0 for go left , 1 for go right , 2 for go up
    output background, //1 for print background 0 for print fish
    output reg [11:0] vga
);

    
endmodule