// Gridfinity Module Generator
// Copyright 2023 Chris Cogdon
// Licence: CC-BY-SA-4.0 
// https://www.github.com/chmarr/gridfinity-boxes
//
// This template creates a simple box of a given size.
//
// Note, all "heights" in the parameters use the bottom of the box as zero.

// The number of Gridfinity squares for this box
gridfinity_count = [3, 2];

// The height of the box walls, not including the stacking lip.
// If a stacking rim is selected, this will be rounded up to a multiple of 7
box_height=35;

// Wether or not to add a stacking lip.
add_stacking_lip=true;

// The radius of the curve added to the internal surface.
internal_radius=8;

// On which sides to place curves. [right, back, left, front].
internal_radius_sides = [false, true, false, true];

// How many dividers in the X and Y dimension. [0,0] means no dividers.
dividers = [0, 0];

// If there are dividers, what should the wall thickness be.
divider_thickness = 1.2;

// If not "undef", what should the height of the dividers be, measured from the internal bottom.
// If "undef", the dividers will be to the top of the box (minus the stacking lip).
divider_height = undef;

// Whether or not to insert holes at the bottom of the box. 0=no holes, 1=corners only, 2=everywhere, 3-slide-in holes in corners
gridfinity_holes=0;

// Width of slide-in magnet hole (only if gridfinity_holes==3)
gridfinity_hole_width=5.9;

// Height of slide-in magnet hole (only if gridfinity_holes==3)
gridfinity_hole_height=2.2;

// Width of a labelling tab at the top-rear of the box. Use '0' for no label.
label_width=0;

// And now the fun stuff.
module customizer_break(){}

use <gridfinity_boxes.scad>
$fn = 40;
divider_height_ = divider_height == undef ? box_height - 7 : divider_height;

gridfinity_module_base(gridfinity_count, holes=gridfinity_holes, hole_width=gridfinity_hole_width, hole_height=gridfinity_hole_height);
adjusted_box_height = add_stacking_lip ? ceil(box_height/7)*7 : box_height;
gridfinity_wall(gridfinity_count, adjusted_box_height-7);
gridfinity_internal_dividers(gridfinity_count, dividers, divider_thickness, divider_height_, internal_radius, sides=internal_radius_sides);
gridfinity_label_tab(gridfinity_count, label_width, box_height-7);
if(add_stacking_lip){
    gridfinity_stacking_lip(gridfinity_count, adjusted_box_height);
}