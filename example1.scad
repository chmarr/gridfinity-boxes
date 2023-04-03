// Gridfinity Module Generator
// Copyright 2023 Chris Cogdon
// Licence: CC-BY-SA-3.0
// https://www.github.com/chmarr/gridfinity-boxes

// This example creates a simple gridfinity 1x1 box, 14mm (2U) high, plus the 4.4mm stacking lip.

$fn = 60;
use <gridfinity_boxes.scad>

count=[1,1];
gridfinity_module_base(count);
gridfinity_wall(count, height=7);
gridfinity_internals_mass(count, 0, radius=4);
gridfinity_stacking_lip(count,z_offset=14);
