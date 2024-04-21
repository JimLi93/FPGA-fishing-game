module fish1_move (
    input clk,
    input rst,
    input [9:0] h,
    input [9:0] v,
    input [1:0] way,  //0 for go left , 1 for go right , 2 for go up
    input appear, //1 for fish appear 0 for the fish doesn't exist
    input [2:0] movetype,
    output reg up,
    output reg [2:0] vm
);
    reg [23:0] cnt;
    reg [23:0] n_cnt;
    reg reach_top = 1'b0;
    reg n_reach_top = 0;
    reg slow_cnt = 0;
    reg n_slow_cnt = 0;

    parameter max = 2000000; //12sec

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            cnt <= 0;
            reach_top <= 0;
            slow_cnt <= 0;
        end
        else begin
            cnt <= n_cnt;
            reach_top <= n_reach_top;
            slow_cnt <= n_slow_cnt;
        end
    end

    always @(*) begin
        if(cnt  >= 3000000) begin
            n_cnt = 0;
            n_slow_cnt = slow_cnt + 1;
        end
        else begin
            n_cnt = cnt + 1;
            n_slow_cnt = slow_cnt;
        end
    end

    always @(*) begin
        vm = 0;
        up = 0;
        n_reach_top = reach_top;
        if(way == 2'b10) begin
            vm = 0;
            up = 0;
        end
        else if(h >= 0 && h <= 720) begin
            if(movetype >= 0) begin
                if(cnt == 1 && slow_cnt == 1) begin
                    vm = 1;
                    if(h > 600) begin
                        up = 1;
                    end
                    else if(h > 520) begin
                        up = 0;
                    end
                    else if(h > 440) begin
                        up = 1;
                    end
                    else if(h > 400) begin
                        up = 0;
                    end
                    else if(h > 340) begin
                        up = 1;
                    end
                    else if(h > 275) begin
                        up = 0;
                    end
                    else if(h > 200) begin
                        up = 1;
                    end
                    else if(h > 156) begin
                        up = 0;
                    end
                    else if(h > 100) begin
                        up = 1;
                    end
                    else if(h > 45) begin
                        up = 0;
                    end
                    else begin
                        up = 1;
                    end         
                end
            end

            else if(movetype == 0) begin
                if(way == 2'b00 && cnt == 1 && slow_cnt == 1) begin
                    if(h > 340) begin
                        vm = 1;
                        up = 0;
                    end
                    else begin
                        vm = 1;
                        up = 1;
                    end         
                end
                else if(way == 2'b01 && cnt == 1 && slow_cnt == 1) begin
                    if(h > 340) begin
                        vm = 1;
                        up = 1;
                    end
                    else begin
                        vm = 1;
                        up = 0;
                    end  
                end
            end

            else if(movetype == 1) begin
                if(way == 2'b00 && cnt == 1) begin
                    if(h < 300) begin
                        vm = 1;
                        up = 1;
                    end
                    else if(h < 150) begin
                        vm = 1;
                        up = 0;
                    end
                    else if(reach_top == 0) begin
                        if(v > 230) begin
                            vm = 1;
                            up = 0;
                        end
                        else if(v <= 230) begin
                            n_reach_top = 1'b1;
                            vm = 1;
                            up = 1;
                        end
                    end
                    else if(reach_top == 1) begin
                        if(v < 240) begin
                            vm = 1;
                            up = 1;
                        end
                        else if(v >= 240) begin
                            n_reach_top = 1'b0;
                            vm = 1;
                            up = 0;
                        end
                    end                
                end
                else if(way == 2'b01 && cnt == 1) begin
                    if(h > 510) begin
                        vm = 1;
                        up = 0;
                    end
                    else if(h > 350) begin
                        vm = 1;
                        up = 1;
                    end
                    else if(reach_top == 0) begin
                        if(v > 230) begin
                            vm = 1;
                            up = 0;
                        end
                        else if(v <= 230) begin
                            n_reach_top = 1'b1;
                            vm = 1;
                            up = 1;
                        end
                        else begin
                            vm = 0;
                            up = 0;
                        end
                    end
                    else begin
                        if(v < 240) begin
                            vm = 1;
                            up = 1;
                        end
                        else if(v >= 240) begin
                            n_reach_top = 1'b0;
                            vm = 1;
                            up = 0;
                        end
                    end
                end
            end

            else if(movetype == 2) begin
                if(way == 2'b00 && cnt == 1) begin
                    if(h > 360) begin
                        if(reach_top == 0) begin
                            if(v > 290) begin
                                vm = 1;
                                up = 0;
                            end
                            else if(v <= 290) begin
                                n_reach_top = 1'b1;
                                vm = 1;
                                up = 1;
                            end
                        end
                        else if(reach_top == 1) begin
                            if(v < 300) begin
                                vm = 1;
                                up = 1;
                            end
                            else if(v >= 300) begin
                                n_reach_top = 1'b0;
                                vm = 1;
                                up = 0;
                            end
                        end
                    end
                    else begin
                        if(h > 300) begin
                            n_reach_top = 1'b1;
                            vm = 1;
                            up = 1;
                        end
                        else if(reach_top == 0) begin
                            if(v > 340) begin
                                vm = 1;
                                up = 0;
                            end
                            else if(v <= 340) begin
                                n_reach_top = 1'b1;
                                vm = 1;
                                up = 1;
                            end
                        end
                        else if(reach_top == 1) begin
                            if(v < 350) begin
                                vm = 1;
                                up = 1;
                            end
                            else if(v >= 350) begin
                                n_reach_top = 1'b0;
                                vm = 1;
                                up = 0;
                            end
                        end
                    end              
                end
                else if(way == 2'b01 && cnt == 1) begin
                    if(h < 300) begin
                        if(reach_top == 0) begin
                            if(v > 290) begin
                                vm = 1;
                                up = 0;
                            end
                            else if(v <= 290) begin
                                n_reach_top = 1'b1;
                                vm = 1;
                                up = 1;
                            end
                        end
                        else if(reach_top == 1) begin
                            if(v < 300) begin
                                vm = 1;
                                up = 1;
                            end
                            else if(v >= 300) begin
                                n_reach_top = 1'b0;
                                vm = 1;
                                up = 0;
                            end
                        end
                    end
                    else begin
                        if(h < 360) begin
                            n_reach_top = 1'b1;
                            vm = 1;
                            up = 1;
                        end
                        else if(reach_top == 0) begin
                            if(v > 340) begin
                                vm = 1;
                                up = 0;
                            end
                            else if(v <= 340) begin
                                n_reach_top = 1'b1;
                                vm = 1;
                                up = 1;
                            end
                        end
                        else if(reach_top == 1) begin
                            if(v < 350) begin
                                vm = 1;
                                up = 1;
                            end
                            else if(v >= 350) begin
                                n_reach_top = 1'b0;
                                vm = 1;
                                up = 0;
                            end
                        end
                    end
                end
            end

            else if(movetype == 3 || movetype == 5 || movetype == 7) begin
                if(cnt == 1 && slow_cnt == 1) begin
                    vm = 1;
                    if(h > 600) begin
                        up = 1;
                    end
                    else if(h > 520) begin
                        up = 0;
                    end
                    else if(h > 440) begin
                        up = 1;
                    end
                    else if(h > 400) begin
                        up = 0;
                    end
                    else if(h > 340) begin
                        up = 1;
                    end
                    else if(h > 275) begin
                        up = 0;
                    end
                    else if(h > 200) begin
                        up = 1;
                    end
                    else if(h > 156) begin
                        up = 0;
                    end
                    else if(h > 100) begin
                        up = 1;
                    end
                    else if(h > 45) begin
                        up = 0;
                    end
                    else begin
                        up = 1;
                    end         
                end
            end
            
            else if(movetype == 4) begin
                if(way == 2'b00 && cnt == 1) begin
                    if(h < 300) begin
                        vm = 1;
                        up = 0;
                    end
                    else if(h < 150) begin
                        vm = 1;
                        up = 1;
                    end
                    else if(reach_top == 0) begin
                        if(v > 440) begin
                            vm = 1;
                            up = 0;
                        end
                        else if(v <= 440) begin
                            n_reach_top = 1'b1;
                            vm = 1;
                            up = 1;
                        end
                    end
                    else if(reach_top == 1) begin
                        if(v < 450) begin
                            vm = 1;
                            up = 1;
                        end
                        else if(v >= 450) begin
                            n_reach_top = 1'b0;
                            vm = 1;
                            up = 0;
                        end
                    end                
                end
                else if(way == 2'b01 && cnt == 1) begin
                    if(h > 510) begin
                        vm = 1;
                        up = 1;
                    end
                    else if(h > 350) begin
                        vm = 1;
                        up = 0;
                    end
                    else if(reach_top == 0) begin
                        if(v > 440) begin
                            vm = 1;
                            up = 0;
                        end
                        else if(v <= 440) begin
                            n_reach_top = 1'b1;
                            vm = 1;
                            up = 1;
                        end
                        else begin
                            vm = 0;
                            up = 0;
                        end
                    end
                    else begin
                        if(v < 450) begin
                            vm = 1;
                            up = 1;
                        end
                        else if(v >= 450) begin
                            n_reach_top = 1'b0;
                            vm = 1;
                            up = 0;
                        end
                    end
                end
            end

            

            else if(movetype == 6) begin
                if(way == 2'b00 && cnt == 1 && slow_cnt == 1) begin
                    if(h > 340) begin
                        vm = 1;
                        up = 1;
                    end
                    else begin
                        vm = 1;
                        up = 0;
                    end         
                end
                else if(way == 2'b01 && cnt == 1 && slow_cnt == 1) begin
                    if(h > 340) begin
                        vm = 1;
                        up = 0;
                    end
                    else begin
                        vm = 1;
                        up = 1;
                    end  
                end
            end

        end
    end


    
    
endmodule