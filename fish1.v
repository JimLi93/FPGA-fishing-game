module fish1 (
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [9:0] fish_h_position,
    input [9:0] fish_v_position,
    input [1:0] fish_way,  //0 for go left , 1 for go right , 2 for go up
    input fish_appear, //1 for fish appear 0 for the fish doesn't exist
    input [3:0] num,
    output reg background, //1 for print background 0 for print fish
    output reg [11:0] vga
);
    parameter [11:0] fish [0:1319] = {//40*33
        //get rid of up1 line && down 1 line
        //get rid of 353,351,452,453, 463, 464 etc.
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h321,12'h232,12'h321,
        12'h721,12'hA32,12'h430,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h721,12'hB32,12'hC31,12'hB31,
        12'hC30,12'hD30,12'hB32,12'h221,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h321,12'hC31,12'hD30,12'hC31,12'hC31,
        12'hC31,12'hC30,12'hD31,12'h820,12'h410,12'h520,12'h410,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h420,12'hD31,12'hC31,12'hC30,12'hD30,
        12'hD30,12'hD31,12'hD31,12'hC30,12'hC31,12'hC30,12'hB32,12'h310,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h932,12'hC30,12'hC31,12'hD31,12'hC30,
        12'hC30,12'hD30,12'hD30,12'hC30,12'hC30,12'hD30,12'hC30,12'h831,12'h221,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h551,12'h752,12'h952,12'hA52,12'h331,12'hFDE,12'hFDD,12'hFCC,12'hEB9,12'hD97,
        12'hC53,12'hD31,12'hD30,12'hC30,12'hD30,12'hD30,12'hC30,12'hC31,12'h411,12'h221,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h641,12'hC53,
        12'hE52,12'hE52,12'hE52,12'hE52,12'hB32,12'h9A9,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hC75,12'hE52,12'hC30,12'hC30,12'hC31,12'hC30,12'hD31,12'hB31,12'h510,
        12'h442,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h652,12'hC53,12'hE52,12'hE52,
        12'hE52,12'hE52,12'hE52,12'hE52,12'hD53,12'h311,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFD,12'hD53,12'hE52,12'hE52,12'hB30,12'hA31,12'hC31,12'hD30,12'hC31,
        12'h631,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h952,12'hE52,12'hE52,12'hE51,12'hE51,
        12'hE52,12'hE52,12'hE52,12'hE52,12'hE52,12'h631,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFF,12'hC75,12'hE52,12'hE52,12'hE52,12'h543,12'hC76,12'hC31,12'hD30,
        12'hC31,12'h321,12'h352,12'h352,12'h352,12'h352,12'h541,12'h541,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'hA62,12'hE52,12'hE51,12'hE52,12'hD53,12'hD53,
        12'hD54,12'hD52,12'hE51,12'hE52,12'hE52,12'h932,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFF,12'hFA9,12'hE52,12'hE52,12'hE52,12'h622,12'hFFF,12'hB77,12'hC30,
        12'hD31,12'h621,12'h352,12'h352,12'h352,12'hA53,12'hD52,12'hE52,12'hB52,12'h441,
        12'h352,12'h352,12'h352,12'hA53,12'hF42,12'hE52,12'hD64,12'hFDC,12'hFFF,12'hFFF,
        12'hFFF,12'hFCA,12'hE53,12'hE51,12'hE52,12'hA42,12'hEEE,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFF,12'hE98,12'hE52,12'hE52,12'hE51,12'h932,12'hEFF,12'hFFE,12'hD53,
        12'hC30,12'h721,12'h352,12'h352,12'hFFD,12'hD53,12'hE52,12'hE51,12'hE52,12'h952,
        12'h352,12'h352,12'h752,12'hE52,12'hE52,12'hD64,12'hCAA,12'h322,12'h333,12'hDDD,
        12'hFFF,12'hFFF,12'hFB9,12'hE52,12'hE52,12'h832,12'hEFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFF,12'hC75,12'hE52,12'hE52,12'hE52,12'h942,12'hFEF,12'hFFF,12'hC65,
        12'hD52,12'h732,12'h575,12'hFFE,12'hEFF,12'hFCB,12'hE52,12'hE52,12'hF42,12'hB42,
        12'h352,12'h352,12'hD52,12'hE52,12'hE52,12'hECB,12'hEEE,12'hAAA,12'h000,12'h000,
        12'hFFF,12'hFFF,12'hFFF,12'hD53,12'hE52,12'h521,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFF,12'hD63,12'hE52,12'hE52,12'hE52,12'h832,12'hFFF,12'hFFF,12'hDA9,
        12'hE52,12'hD97,12'hFFF,12'hFFF,12'hFFF,12'hFFE,12'hE52,12'hE52,12'hE51,12'hA42,
        12'h352,12'h852,12'hE52,12'hE52,12'hD53,12'h988,12'hEEE,12'h777,12'h000,12'h000,
        12'hFFF,12'hFFF,12'hFFF,12'hD75,12'hE52,12'h321,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFF,12'hD52,12'hE52,12'hE52,12'hE52,12'h621,12'hFFF,12'hFFF,12'hDBB,
        12'hE52,12'hE98,12'hFFF,12'hFFF,12'hFFF,12'hFFE,12'hE52,12'hE52,12'hE52,12'h942,
        12'h352,12'hC52,12'hE52,12'hE52,12'hC63,12'hAAA,12'h000,12'h000,12'h000,12'h000,
        12'hFFF,12'hFFF,12'hFFF,12'hD87,12'hB53,12'h999,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFE,12'hE52,12'hE52,12'hE52,12'hE52,12'h422,12'hFFF,12'hFFF,12'hDA9,
        12'hE52,12'hE87,12'hFFF,12'hFFF,12'hFFF,12'hFFE,12'hE52,12'hE52,12'hE52,12'h832,
        12'h352,12'hE52,12'hE52,12'hE52,12'hC53,12'hFFF,12'h111,12'h000,12'h000,12'h444,
        12'hFFF,12'hFFF,12'hFFF,12'hD86,12'h831,12'hEEF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFE,12'hE52,12'hE52,12'hE52,12'hD52,12'h666,12'hFFF,12'hFFF,12'hB77,
        12'hE52,12'hD87,12'hFFF,12'hFFF,12'hFFF,12'hFFE,12'hE52,12'hE52,12'hE52,12'h731,
        12'h552,12'hE52,12'hE52,12'hE52,12'hE52,12'hFFE,12'hEEF,12'h888,12'h888,12'hFFF,
        12'hFFF,12'hFFF,12'hFFF,12'hC64,12'h621,12'hC97,12'hE64,12'hDA8,12'hFFF,12'hFFF,
        12'hFFF,12'hFED,12'hE53,12'hE52,12'hE52,12'hA42,12'hA99,12'hFFF,12'hFFF,12'hB53,
        12'hE52,12'hE99,12'hFFF,12'hFFF,12'hFFF,12'hFFE,12'hE52,12'hE52,12'hE52,12'h521,
        12'h651,12'hE52,12'hE52,12'hE52,12'hE52,12'hE98,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFF,12'hFDC,12'hD54,12'hC52,12'hE42,12'hE51,12'hE53,12'hFFF,12'hFFF,
        12'hFFF,12'hFDB,12'hE52,12'hE52,12'hE52,12'h831,12'hDDD,12'hFFF,12'hFFF,12'hC53,
        12'hE52,12'hFBA,12'hFFF,12'hFFF,12'hFFF,12'hFDC,12'hE52,12'hE52,12'hE51,12'h421,
        12'h551,12'hE52,12'hE52,12'hE52,12'hE51,12'hE53,12'hECA,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hFFE,12'hD64,12'hC41,12'hE52,12'hE52,12'hE52,12'hD86,12'hFFF,12'hFFF,
        12'hFFF,12'hEB9,12'hE52,12'hE52,12'hE52,12'h731,12'hEEF,12'hFFF,12'hFEE,12'hD52,
        12'hE52,12'hFDC,12'hFFF,12'hFFF,12'hFFF,12'hD98,12'hE52,12'hE52,12'hE52,12'h311,
        12'h551,12'hE52,12'hE52,12'hE52,12'hE52,12'hE51,12'hE53,12'hD75,12'hFBA,12'hFCB,
        12'hFA9,12'hC63,12'hE52,12'hB31,12'hE52,12'hE52,12'hF42,12'hEA9,12'hFFF,12'hFFF,
        12'hFFF,12'hC86,12'hE52,12'hE52,12'hE52,12'h721,12'hFFF,12'hFFF,12'hEDC,12'hD52,
        12'hE52,12'hFED,12'hFFF,12'hFFF,12'hFFF,12'hD75,12'hE52,12'hE52,12'hE52,12'h211,
        12'h352,12'hD52,12'hE52,12'hE52,12'hE52,12'hE52,12'hE52,12'hF52,12'hE51,12'hE52,
        12'hE52,12'hE52,12'hF52,12'h720,12'hD53,12'hE51,12'hE52,12'hEA8,12'hFFF,12'hFFF,
        12'hFFF,12'hD63,12'hE52,12'hE52,12'hE52,12'h731,12'hEFE,12'hFFF,12'hECB,12'hD52,
        12'hE52,12'hFED,12'hFFF,12'hFFF,12'hFFF,12'hD53,12'hE52,12'hE52,12'hD52,12'h310,
        12'h352,12'h952,12'hE52,12'hE52,12'hE52,12'hE52,12'hE52,12'hE52,12'hE53,12'hD52,
        12'hE52,12'hE52,12'hE52,12'h620,12'hFFD,12'hD86,12'hD65,12'hFFE,12'hFFF,12'hFFF,
        12'hFFF,12'hD53,12'hE52,12'hE52,12'hE52,12'h731,12'hEEE,12'hFFF,12'hD98,12'hD52,
        12'hE42,12'hFFE,12'hFFF,12'hFFF,12'hFFF,12'hE53,12'hE52,12'hE52,12'hD52,12'h311,
        12'h352,12'h551,12'hE52,12'hE52,12'hE52,12'hE52,12'hE52,12'hE51,12'hC43,12'h310,
        12'hE52,12'hE52,12'hE52,12'h621,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFF,12'hD52,12'hE52,12'hE52,12'hE52,12'h831,12'hEDE,12'hFFF,12'hB64,12'hE52,
        12'hD53,12'hEED,12'hFFF,12'hFFF,12'hFFE,12'hE52,12'hE52,12'hE52,12'hD52,12'h221,
        12'h352,12'h352,12'hC63,12'hE52,12'hE52,12'hD52,12'hD52,12'hB53,12'h310,12'h931,
        12'hE52,12'hE52,12'hE52,12'h731,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFFE,12'hE52,12'hE52,12'hE52,12'hE52,12'h831,12'hDDD,12'hFFE,12'hC43,12'hE52,
        12'h952,12'h352,12'hFFF,12'hFFF,12'hFFE,12'hE52,12'hE52,12'hE52,12'hD52,12'h232,
        12'h352,12'h352,12'h641,12'hD53,12'h510,12'h411,12'h310,12'h511,12'hC53,12'hE52,
        12'hE51,12'hE52,12'hE51,12'hA43,12'hBBB,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFEC,12'hE52,12'hE52,12'hE52,12'hE52,12'h832,12'hDDD,12'hFFF,12'hD53,12'hE52,
        12'h310,12'h352,12'h664,12'hFFF,12'hFCB,12'hE52,12'hE52,12'hF41,12'h942,12'h352,
        12'h352,12'h352,12'h352,12'hA52,12'hE53,12'hB52,12'hC53,12'hD52,12'hE52,12'hE52,
        12'hE52,12'hE52,12'hF51,12'hC53,12'h777,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hFCB,12'hE52,12'hE52,12'hE52,12'hE52,12'h831,12'hEED,12'hEDD,12'hE51,12'hC30,
        12'h831,12'h352,12'h352,12'h676,12'hC75,12'hE42,12'hE52,12'hD53,12'h420,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'hB53,12'hF52,12'hE51,12'hE52,12'hE52,12'hE52,
        12'hE52,12'hE52,12'hE52,12'hE52,12'h422,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hE98,12'hE52,12'hE52,12'hE52,12'hE52,12'h721,12'hEFF,12'hEBA,12'hD40,12'hD30,
        12'hB32,12'h231,12'h352,12'h352,12'h642,12'h952,12'hA52,12'h531,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h542,12'hC63,12'hE52,12'hE52,12'hE52,12'hE52,
        12'hE52,12'hE52,12'hE52,12'hE52,12'h731,12'hFFF,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hD75,12'hE52,12'hE52,12'hE52,12'hE52,12'h521,12'hFFF,12'hA53,12'hC31,12'hD30,
        12'h832,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h953,12'hE52,12'hE52,12'hE52,
        12'hE52,12'hE52,12'hE52,12'hE52,12'hA42,12'hBCC,12'hFFF,12'hFFF,12'hFFF,12'hFFF,
        12'hD53,12'hE51,12'hE52,12'hE52,12'hE52,12'h421,12'hB53,12'hC31,12'hD31,12'h931,
        12'h221,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h551,12'hB52,12'hE52,
        12'hE52,12'hE52,12'hE52,12'hE52,12'hC53,12'h889,12'hFFF,12'hFFF,12'hEFF,12'hFDC,
        12'hD53,12'hE52,12'hE52,12'hE52,12'hD42,12'hC31,12'hD31,12'hC30,12'hD30,12'h521,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h541,
        12'hA52,12'hC53,12'hD52,12'hD52,12'hB53,12'h888,12'hFFF,12'hFFF,12'hFFF,12'hC86,
        12'hE51,12'hD41,12'hD30,12'hC30,12'hD30,12'hD30,12'h821,12'h721,12'h821,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h441,12'h541,12'h541,12'h352,12'h352,12'h352,12'h352,12'h420,
        12'hB31,12'hB31,12'h931,12'h921,12'hB32,12'h932,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352

    };
    always @(*) begin
        if(fish_appear == 1'b0) begin
            background = 1;
            vga = 12'h000;
        end
        else if(fish_way == 0) begin
            if(((h_cnt + 40) - fish_h_position) <= 39 && (v_cnt - fish_v_position) <= 32) begin
                if(fish[(v_cnt - fish_v_position) * 40 + (h_cnt + 40 - fish_h_position)] != 12'h352) begin
                    background = 0;
                    vga = fish[(v_cnt - fish_v_position) * 40 + (h_cnt + 40 - fish_h_position)];
                end
                else begin
                    background = 1;
                    vga = 12'h000;
                end
                if(((h_cnt + 40) - fish_h_position) <= 2 && (v_cnt - fish_v_position) <= 4) begin
                    if(num == 1) begin
                        if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 1) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 2) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2 && (v_cnt - fish_v_position) == 1) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) == 3) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 3) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 4) begin
                        if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) <= 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 5) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) == 1) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2 && (v_cnt - fish_v_position) == 3) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 6) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2 && (v_cnt - fish_v_position) == 3) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 7) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 8) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                end
            end
            else begin
                background = 1;
                vga = 12'h000;
            end
        end
        else if(fish_way == 1) begin
            if(((h_cnt + 40) - fish_h_position) <= 39 && (v_cnt - fish_v_position) <= 32) begin
                if(fish[(v_cnt - fish_v_position) * 40 + (fish_h_position - h_cnt - 1)] != 12'h352) begin
                    background = 0;
                    vga = fish[(v_cnt - fish_v_position) * 40 + (fish_h_position - h_cnt - 1)];
                end
                else begin
                    background = 1;
                    vga = 12'h000;
                end
                if(((h_cnt + 40) - fish_h_position) <= 2 && (v_cnt - fish_v_position) <= 4) begin
                    if(num == 1) begin
                        if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 1) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 2) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2 && (v_cnt - fish_v_position) == 1) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) == 3) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 3) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 4) begin
                        if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) <= 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 5) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) == 1) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2 && (v_cnt - fish_v_position) == 3) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 6) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2 && (v_cnt - fish_v_position) == 3) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 7) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 8) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                end
            end
            else begin
                background = 1;
                vga = 12'h000;
            end
            
        end
        else if(fish_way == 2) begin
            if((v_cnt - fish_v_position) <= 79 && (fish_h_position - h_cnt) <= 32) begin
                if(fish[(fish_h_position - h_cnt) * 40 + ((v_cnt - fish_v_position)/2)] != 12'h352) begin
                    background = 0;
                    vga = fish[(fish_h_position - h_cnt) * 40 + ((v_cnt - fish_v_position)/2)];
                end
                else begin
                    background = 1;
                    vga = 12'h000;
                end
                if(((h_cnt + 40) - fish_h_position) <= 2 && (v_cnt - fish_v_position) <= 4) begin
                    if(num == 1) begin
                        if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 1) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 2) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2 && (v_cnt - fish_v_position) == 1) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) == 3) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 3) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 4) begin
                        if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) <= 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 5) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0 && (v_cnt - fish_v_position) == 1) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2 && (v_cnt - fish_v_position) == 3) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 6) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2 && (v_cnt - fish_v_position) == 3) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 7) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                    else if(num == 8) begin
                        if((v_cnt - fish_v_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if((v_cnt - fish_v_position) == 4) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 0) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                        else if(((h_cnt + 40) - fish_h_position) == 2) begin
                            background = 0;
                            vga = 12'hfff;
                        end
                    end
                end
            end
            else begin
                background = 1;
                vga = 12'h000;
            end
        end
        else begin
            background = 1;
            vga = 12'h000;
        end
    end
    
endmodule

