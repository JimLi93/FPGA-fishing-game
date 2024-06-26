module one_second (
    input clk,
    input rst,
    input pause,
    input [1:0] state,
    output half_second,
    output one_second_enable
);
    reg [27:0] cnt;
    reg [27:0] n_cnt;

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            cnt <= 0;
        end
        else begin
            cnt <= n_cnt;
        end
    end

    always @(*) begin
        if(state != 2'b01) begin
            n_cnt = 0;
        end
        else if(pause == 1'b1) begin
            n_cnt = cnt;
        end
        else if(cnt == 99999999) begin
            n_cnt = 0;
        end
        else begin
            n_cnt = cnt + 1;
        end
    end

    assign one_second_enable = (cnt >= 99999999) ? 1'b1 : 1'b0;
    assign half_second = (cnt == 99999999 || cnt == 49999999) ? 1'b1 : 1'b0;

endmodule