// Gridfinity Module Generator
// Copyright 2023 Chris Cogdon
// Licence: CC-BY-SA-4.0 
// https://www.github.com/chmarr/gridfinity-boxes
//
// This template creates a simple box of a given size.
//
// Note, all "heights" in the parameters use the bottom of the box as zero.

// The number of Gridfinity squares for this box
gridfinity_count = [1, 2];

// The height of the box walls, not including the stacking lip.
// If a stacking rim is selected, this will be rounded up to a multiple of 7
box_height=35;

// Wether or not to add a stacking lip.
add_stacking_lip=true;

// The radius of the curve added to the internal surface.
internal_radius=10;

// On which sides to place curves. [right, back, left, front].
internal_radius_sides = [false, true, false, true];

// Whether or not to insert holes at the bottom of the box. 0=no holes, 1=corners only, 2=everywhere.
gridfinity_holes=0;

// And now the fun stuff.
module customizer_break(){}

use <gridfinity_boxes.scad>
$fn = 40;

gridfinity_module_base(gridfinity_count, holes=gridfinity_holes);
adjusted_box_height = add_stacking_lip ? ceil(box_height/7)*7 : box_height;
gridfinity_wall(gridfinity_count, adjusted_box_height-7);
gridfinity_internal_fillets(gridfinity_count, internal_radius, sides=internal_radius_sides);
if(add_stacking_lip){
    gridfinity_stacking_lip(gridfinity_count, adjusted_box_height);
}