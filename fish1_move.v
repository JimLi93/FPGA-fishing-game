module fish1_move (
    input clk,
    input rst,
    input [9:0] h,
    input [9:0] v,
    input [1:0] way,  //0 for go left , 1 for go right , 2 for go up
    input appear, //1 for fish appear 0 for the fish doesn't exist
    input [2:0] movetype,
    input [13:0] mouse_v,
    output reg [2:0] hm,
    output reg [2:0] vm
);
    reg [23:0] cnt;
    reg [23:0] n_cnt;

    parameter max = 2000000; //12sec

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            cnt <= 0;
        end
        else begin
            cnt <= n_cnt;
        end
    end

    always @(*) begin
        vm = 0;
        if(cnt >= 2000000) begin
            n_cnt = 0;
            hm = 1;
        end
        else begin
            n_cnt = cnt + 1;
            hm = 0;
        end
    end


    
    
endmodule