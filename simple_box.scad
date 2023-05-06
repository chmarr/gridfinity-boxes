// Gridfinity Module Generator
// Copyright 2023 Chris Cogdon
// Licence: CC-BY-SA-4.0 
// https://www.github.com/chmarr/gridfinity-boxes
//
// This template creates a simple box of a given size, with a small internal fillet and holes
// in the base to glue-in magnets. If you want a box with more
// features and options, use "featureful_box.scad".

// The number of Gridfinity squares for this box
gridfinity_count = [3, 2];

// The height of the box walls in gridfinity units of 7mm, not including the stacking lip.
gridfinity_box_height=5;


// And now the fun stuff.
module customizer_break(){}

use <gridfinity_boxes.scad>
$fn = 40;

gridfinity_module_base(gridfinity_count, holes=1);
gridfinity_wall(gridfinity_count, gridfinity_box_height*7 - 7);
gridfinity_internal_fillets(gridfinity_count, radius=5, sides=[false,true,false,true]);
gridfinity_stacking_lip(gridfinity_count, gridfinity_box_height*7 - 7);