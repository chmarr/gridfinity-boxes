// Gridfinity Module Generator
// Copyright 2023 Chris Cogdon
// Licence: CC-BY-SA-4.0 
// https://www.github.com/chmarr/gridfinity-boxes
//
// This template creates a box with inserts for parts of a given size.
//
// Note, all "heights" in the parameters use the bottom of the box as zero.

// The number of Gridfinity squares for this box
gridfinity_count = [3,2];

// The size of the insert: [x, y, and depth]
insert_size = [40, 10, 20];

// The number of inserts present
insert_count = [2,4];

// The height of the box walls, not including the stacking lip.
// If a stacking rim is selected, this will be rounded up to a multiple of 7
box_height=22;

// The height of the internal surface.
internal_height=20;

// Wether or not to add a stacking lip.
add_stacking_lip=false;

// The radius of the curve added to the internal surface.
internal_radius=2;

// The radius of the curve subtracted from the top of the insert.
insert_top_radius=2;

// The radius of the curve at the bottom of the insert.
insert_bottom_radius=0;

// Whether or not to insert holes at the bottom of the box. 0=no holes, 1=corners only, 2=everywhere.
gridfinity_holes=0;

// And now the fun stuff.
module customizer_break(){}

use <gridfinity_boxes.scad>

// Adjust this if you want even smoother curves, at the cost of processing time.
$fn = 40;

// Add the module base
gridfinity_module_base(gridfinity_count, holes=gridfinity_holes);

// Add the side walls using the adjusted height
adjusted_box_height = add_stacking_lip ? ceil(box_height/7)*7 : box_height;
gridfinity_wall(gridfinity_count, adjusted_box_height-7);

// We use the square_bores to subtract away from the internal mass
difference() {
    gridfinity_internal_mass(gridfinity_count, internal_height-7);
    // The "render" function is used as otherwise the resulting object causes preview issues.
    render(convexity=3) gridfinity_square_bores(gridfinity_count, insert_size, internal_height, insert_count, top_radius=insert_top_radius, bottom_radius=insert_bottom_radius);
}

// Add rounded fillets to the internal mass
gridfinity_internal_fillets(gridfinity_count, internal_radius, z_offset=internal_height);

// Add the stacking lip, if selected.
if(add_stacking_lip){
    gridfinity_stacking_lip(gridfinity_count, adjusted_box_height);
}