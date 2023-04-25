// Magnet Hole Tester for Gridfinity Module Generator
// Copyright 2023 Chris Cogdon
// Licence: CC-BY-SA-4.0 
// https://www.github.com/chmarr/gridfinity-boxes
//
// Creates a model to test various sizes of holes for the Gridfinity-common 6x2mm magnet,
// or magnets of any size by adjusting the parameters below. A "dot" is placed at the
// first, or smallest, hole to ease orientation.

// hole width for the middle hole. Typically the 'ideal' size.
median_hole_width=6.0; // [2.0:0.1:10.0]

// side difference between holes
step_size=0.1; // [0.05:0.01:0.2]

// number of holes. Should be an odd number so that the median_hole_width is the middle hole
number_of_holes=7; // [3:2:15]

// the height of the hole. Since we're intending to squeeze the sides, and that magnet heights are variable, this should be distinctly larger than the magnet height
hole_height=2.2; // [1.0:0.1:5.2]

// the height of the floor
floor_height=0.4; // [0.1:0.05:1.0]

/* [Advanced Options] */
// object depth
object_depth=6; // [5:1:15]

// object height
object_height=6; // [5:1:15]

// inter-hole spacing
interhole_spacing=5; // [2:1:10]

module customizer_stop () {}
epsilon=0.005;


module hole_sampler() {
    holes_to_either_side = (number_of_holes-1)/2;
    first_hole = median_hole_width - holes_to_either_side * step_size;
    object_width = median_hole_width * number_of_holes + interhole_spacing * (number_of_holes+1);
    
    difference() {
        cube([object_width, object_depth, object_height]);
        translate([interhole_spacing, -epsilon, floor_height])
            for(i=[0:number_of_holes-1]) {
                hole_size=first_hole + i*step_size;
                echo("Hole size:", hole_size)
                translate([i*(median_hole_width + interhole_spacing),0,0])
                    cube([hole_size, object_depth+2*epsilon, hole_height]);
            }
    translate([2,2,object_height-1+epsilon]) cylinder(h=1, d=1.5, $fn=40);
    }
}

hole_sampler();