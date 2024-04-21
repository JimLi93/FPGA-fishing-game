# FPGA Fishing Game

## Introduction

The game is inspired by the fishing mini-game in Mole's World. This project is to recreate the game as faithfully as possible. 
The entire gameplay is controlled by the mouse and displayed through VGA on the screen. 

## Hardware and Software

### Software

Xilinx Vivado : https://www.xilinx.com/support/download.html

### Hardware

Basys 3 FPGA Board

## How to play

Game time : 3 minutes.

During the game, player should use the mouse to the cursor on the screen to do the fishing. The height of the fishing line moves with the height of the cursor. Both will be on the same horizontal plane.

There are totally four kinds of fish:

* Nemo:  
The fish the player should catch, scoring one point for each catch. The player should place the fish bait on the fishing line in front of Nemo's mouth to catch it. After catching Nemo, the cursor should be moved higher than the top of the fishing rod, and the left mouse button should be clicked to count as a successful catch.

* Yellow Fish:  
The yellow fish will steal the bait on the fishing line. If the bait is stolen, the player should move the cursor to the bait tray and click the left mouse button to replenish the bait.

* Crab:     
When the crab passes through the fishing line, it will cut the line.

* Shark:    
The player should avoid touching the shark at all costs. If the fishing line, hook, bait, or caught fish touches the shark, the game will end.

## Reference

#### Mouse controlling code source:

https://blog.sina.com.cn/s/blog_735f2910010158ri.html

#### Image source :

https://zh.pngtree.com/

