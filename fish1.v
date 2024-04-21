module fish1 (
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [9:0] fish_h_position,
    input [9:0] fish_v_position,
    input [1:0] fish_way,  //0 for go left , 1 for go right , 2 for go up
    input fish_appear, //1 for fish appear 0 for the fish doesn't exist
    output reg background, //1 for print background 0 for print fish
    output reg [11:0] vga
);
    parameter [11:0] fish [0:1399] = {//40*35
        //get rid of up2 line && down three line
        //get rid of 353,351,452,453, 463, 464 etc.
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h575,12'h352,12'h352,12'h575,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h587,
        12'h7AC,12'h8BC,12'h7AC,12'h7AD,12'h9BB,12'h69A,12'h699,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h7AC,
        12'h6AD,12'h8BC,12'h6AD,12'h8BC,12'h7BC,12'h6AD,12'h7AC,12'h8BB,12'h587,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h687,12'h6AC,
        12'h7BC,12'h7AC,12'h7AD,12'h8BC,12'h6AD,12'h6AD,12'h8BC,12'h7AC,12'h6AD,12'h799,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h7AB,12'h6AD,
        12'h8BC,12'h6AD,12'h8BD,12'h7AC,12'h6AD,12'h8BC,12'h7AC,12'h6AD,12'h8AD,12'h8BC,
        12'h8AB,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h575,12'h7AD,12'h6AD,
        12'h8BC,12'h8BD,12'h9CD,12'h9CD,12'h9CD,12'h9CD,12'h8BD,12'h8BC,12'h8AC,12'h6AD,
        12'h7BC,12'h7A9,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h698,12'h7BD,12'h9CE,
        12'hACD,12'hADE,12'hADD,12'hADE,12'hADD,12'hADD,12'h9DE,12'hACD,12'h8CD,12'h8BC,
        12'h8BC,12'h7AC,12'h576,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h586,12'h7AB,12'h688,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h786,12'hACC,12'h9DE,12'hADD,
        12'hADD,12'hADD,12'hADE,12'hADD,12'hADD,12'hADE,12'hADD,12'hADE,12'hADE,12'hADD,
        12'h8BD,12'h8BC,12'h7AB,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h575,12'h7AC,12'h6AD,12'h7AB,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'hAA8,12'hFEC,12'hDDD,12'hADD,12'hADD,
        12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9CD,12'h9CD,12'h9DD,12'h9DE,12'h9DE,
        12'hADE,12'h9CD,12'h7AC,12'h587,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h7AB,12'h6AD,12'h6AD,12'h7AB,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'hCCA,12'hFEC,12'hFEC,12'hFEC,12'hBDD,12'h9DD,
        12'h9DD,12'h9DD,12'h9CD,12'h9CD,12'h9CD,12'h9CD,12'h9CD,12'h9CD,12'h9CD,12'h9CD,
        12'h9CD,12'hADE,12'h9CE,12'h9BB,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h687,12'h6AD,12'h6AD,12'h6AD,12'h8AC,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'hCB9,12'hFDC,12'hFDC,12'hFDC,12'hFDB,12'hDDC,12'h9DD,
        12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9CD,12'h9CD,12'h9CD,12'h9CD,
        12'h9CD,12'h9CD,12'h9DD,12'h9CD,12'h9BA,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h7AB,12'h6AD,12'h6AD,12'h6AD,12'h7AC,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'hAA8,12'hFDC,12'hFDC,12'hFDB,12'hFDC,12'hFDB,12'hEDC,12'hADD,
        12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,
        12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9CD,12'h7A9,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h7AC,12'h6AD,12'h6AD,12'h6AD,12'h7AB,12'h352,12'h352,12'h352,
        12'h352,12'h786,12'hFDC,12'hFDC,12'hFDB,12'hFDB,12'hFDB,12'hFDB,12'hFDB,12'hBDC,
        12'h9DD,12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,
        12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9CD,12'h9CD,12'h9BB,12'h564,12'h352,12'h352,
        12'h352,12'h575,12'h7AC,12'h6AD,12'h6AD,12'h6AD,12'h698,12'h352,12'h352,12'h352,
        12'h352,12'hDDB,12'hFDC,12'hFDB,12'hFDB,12'hFDB,12'hFDB,12'hFDB,12'hFDC,12'hCDC,
        12'h9DD,12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,
        12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9CD,12'h9DD,12'h9CB,12'h352,12'h352,
        12'h352,12'h586,12'h6AC,12'h6AD,12'h6AD,12'h7AD,12'h576,12'h352,12'h352,12'h352,
        12'h886,12'hFEC,12'hFDC,12'hFDB,12'hCBA,12'hCA9,12'hFDB,12'hFDB,12'hFDC,12'hDDC,
        12'h9CD,12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,
        12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9DD,12'h9DD,12'h9CD,12'h9BB,12'h352,
        12'h352,12'h687,12'h6AD,12'h6AD,12'h6AD,12'h7AA,12'h352,12'h352,12'h352,12'h352,
        12'hAA8,12'hFDB,12'hFEC,12'hDCB,12'h666,12'h222,12'hEDB,12'hFDB,12'hFDB,12'hEDC,
        12'h9CD,12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9CE,12'h9CE,12'h9DE,12'h9DD,12'h9DD,
        12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9DD,12'h9CB,
        12'h352,12'h698,12'h6AD,12'h6AD,12'h7AC,12'h575,12'h352,12'h352,12'h352,12'h352,
        12'hAA8,12'hFDB,12'hFDC,12'hDCA,12'h000,12'h211,12'hEDB,12'hFDB,12'hFDB,12'hEDC,
        12'hADD,12'h9DD,12'h9CD,12'h9CD,12'h8CD,12'h7BD,12'h7AD,12'h7BD,12'h7BD,12'h8CE,
        12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9CD,12'h9DD,
        12'h9CC,12'h9CC,12'h6AD,12'h7AC,12'h688,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h9A7,12'hFDB,12'hFDC,12'hFDB,12'hA98,12'hBA9,12'hFDB,12'hFDB,12'hFDB,12'hEDC,
        12'hADD,12'h9DD,12'h9DD,12'h8BD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,
        12'h7BD,12'h9CE,12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9DD,12'h9CD,
        12'h9CD,12'h8CD,12'h8CD,12'h687,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h785,12'hFDC,12'hFDB,12'hFDB,12'hFDC,12'hFDB,12'hFCB,12'hEAA,12'hEAA,12'hEDC,
        12'h9DD,12'h9DD,12'h9CD,12'h7BD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,
        12'h6AD,12'h7BD,12'h9CD,12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9DD,12'h9CD,
        12'hACD,12'h9CE,12'h8BD,12'h698,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'hEDB,12'hFDB,12'hFDB,12'hFDC,12'hFDC,12'hECA,12'hE99,12'hE99,12'hDCB,
        12'h9CD,12'h9DD,12'h9CD,12'h7BD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,
        12'h6AD,12'h6AD,12'h9CE,12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,
        12'h8BA,12'h799,12'h6AD,12'h7AC,12'h7AA,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'hBB9,12'hFDC,12'hFDB,12'hFEC,12'hFDC,12'hECA,12'hE99,12'hE99,12'hDCB,
        12'h9CD,12'h9DD,12'h9CD,12'h7BD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,
        12'h6AD,12'h7BD,12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CC,
        12'h574,12'h575,12'h6AD,12'h6AD,12'h7AC,12'h799,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h674,12'hEDB,12'hFDB,12'hFDC,12'hFDC,12'hFDB,12'hEAA,12'hEAA,12'hCDC,
        12'h9CD,12'h9CD,12'h8CD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,
        12'h7BD,12'h9CD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9CE,12'h9CC,12'h575,
        12'h352,12'h352,12'h7AB,12'h6AD,12'h6AD,12'h7AD,12'h699,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h9A7,12'hFDC,12'hFDC,12'hFDB,12'hFDC,12'hFDB,12'hFDC,12'hBDD,
        12'h9DD,12'h9CD,12'h9CD,12'h8BD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h7BD,
        12'h8CD,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9DE,12'h9CD,12'h9CD,12'h797,12'h352,
        12'h352,12'h352,12'h687,12'h7AD,12'h6AD,12'h6AD,12'h7AC,12'h587,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'hDCA,12'hFDB,12'hFDB,12'hFDB,12'hFDB,12'hEDC,12'hACD,
        12'h9DD,12'h9DD,12'h9CD,12'h9DD,12'h9CD,12'h7BD,12'h7AD,12'h7AD,12'h7BD,12'h9CE,
        12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9DE,12'h9CD,12'h8A9,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h7AA,12'h6AD,12'h6AD,12'h6AD,12'h7AC,12'h475,12'h352,
        12'h352,12'h352,12'h352,12'h675,12'hEDC,12'hFDB,12'hFDC,12'hFDB,12'hCDC,12'h9CD,
        12'h9DD,12'h9DD,12'h9DD,12'h9CD,12'h9CD,12'h9CE,12'h9CD,12'h9CD,12'h9DD,12'h9CD,
        12'h9DD,12'h9CD,12'h9CD,12'h9CE,12'h9CD,12'h9CD,12'h7A9,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h8AB,12'h6AD,12'h6AD,12'h6AD,12'h7AB,12'h352,
        12'h352,12'h352,12'h352,12'h686,12'h8BC,12'hCCB,12'hEDB,12'hEDB,12'hACD,12'h9CD,
        12'h9DD,12'h9DD,12'h9CE,12'h9CE,12'h9CE,12'h9DD,12'h9DD,12'h9DD,12'h9DD,12'h9CD,
        12'h9DD,12'h9CD,12'h9CD,12'h9CD,12'h9BD,12'h798,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h699,12'h7AC,12'h6AD,12'h6AD,12'h687,
        12'h352,12'h352,12'h352,12'h7AA,12'h6AD,12'h7AC,12'hBCC,12'hBCC,12'h8CD,12'h9CD,
        12'h9CD,12'h9CD,12'h8CD,12'h7BD,12'h8CD,12'h9CD,12'h9CD,12'h9CD,12'h9CD,12'h9CD,
        12'h9CD,12'h8CD,12'h8BC,12'h9BC,12'h8AA,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h586,12'h7AA,12'h7AB,12'h798,
        12'h352,12'h352,12'h352,12'h7AC,12'h6AD,12'h6AD,12'h7AC,12'h8BC,12'h9BC,12'h8BC,
        12'h8BC,12'h8BC,12'h7BD,12'h6AD,12'h6AD,12'h7BD,12'h8BC,12'h8BC,12'h8BC,12'h8BC,
        12'h8BC,12'h8BC,12'h9BB,12'h798,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h7AB,12'h6AD,12'h6AD,12'h6AD,12'h8BB,12'h676,12'h8AA,
        12'h9BB,12'h8BC,12'h7BD,12'h6AD,12'h6AD,12'h6AD,12'h7BD,12'h8BC,12'h8BC,12'h8BC,
        12'h8BB,12'h697,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h687,12'h7AC,12'h6AD,12'h7AC,12'h687,12'h352,12'h352,
        12'h575,12'h798,12'h7AB,12'h6AD,12'h6AD,12'h6AD,12'h6AD,12'h8BB,12'h8AA,12'h687,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h688,12'h699,12'h576,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h576,12'h7AD,12'h6AD,12'h6AD,12'h6AD,12'h799,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h7AC,12'h6AD,12'h6AD,12'h6AD,12'h8AA,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h699,12'h6AD,12'h6AD,12'h6AD,12'h7AA,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h7AB,12'h6AC,12'h7AC,12'h575,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h687,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,
        12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352,12'h352
    };
    always @(*) begin
        if(fish_appear == 1'b0) begin
            background = 1;
            vga = 12'h000;
        end
        else if(fish_way == 0) begin
            if(((h_cnt + 40) - fish_h_position) <= 39 && (v_cnt - fish_v_position) <= 34) begin
                if(fish[(v_cnt - fish_v_position) * 40 + (h_cnt + 40 - fish_h_position)] != 12'h352) begin
                    background = 0;
                    vga = fish[(v_cnt - fish_v_position) * 40 + (h_cnt + 40 - fish_h_position)];
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
        else if(fish_way == 1) begin
            if(((h_cnt + 40) - fish_h_position) <= 39 && (v_cnt - fish_v_position) <= 34) begin
                if(fish[(v_cnt - fish_v_position) * 40 + (fish_h_position - h_cnt - 1)] != 12'h352) begin
                    background = 0;
                    vga = fish[(v_cnt - fish_v_position) * 40 + (fish_h_position - h_cnt - 1)];
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
        else if(fish_way == 2) begin
            if((v_cnt - fish_v_position) <= 79 && (fish_h_position - h_cnt) <= 34) begin
                if(fish[(fish_h_position - h_cnt) * 40 + ((v_cnt - fish_v_position)/2)] != 12'h352) begin
                    background = 0;
                    vga = fish[(fish_h_position - h_cnt) * 40 + ((v_cnt - fish_v_position)/2)];
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
        else begin
            background = 1;
            vga = 12'h000;
        end
    end
    
endmodule