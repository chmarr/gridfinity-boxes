// Gridfinity Module Generator
// Copyright 2023 Chris Cogdon
// Licence: CC-BY-SA-3.0
// https://www.github.com/chmarr/gridfinity-boxes
//
// To use, either modify the example at the bottom of this file, or create a new scad file and
// have "use <gridfinity_boxes.scad" at the top of that file.

$fn=40;
epsilon = 0.001; // a small value to make difference() look nice.

// *********************************
// Constants derived from spec sheet

module_side=41.5;
module_radius_1=3.75;  // because using diameters for fillets is non-standard.
module_radius_2=1.6;
module_radius_3=0.8;
module_base_height=5;
module_spacing=42;
module_unit_height=7;
module_internal_square = module_side - 2*module_radius_1;
internal_radius = module_radius_3;
internal_side=module_side - 2*(1.9 + 0.7);

// ***************************************************************************
// The following functions and modules are not expected to be called directly.

function coalesce(a, b) = a == undef ? b : a;
function module_dim(count) = [module_side+(count.x-1)*module_spacing, module_side + (count.y-1) * module_spacing];
function internal_dim(count) = [internal_side+(count.x-1)*module_spacing, internal_side+(count.y-1)*module_spacing];
function module_internal_dim(count) = [module_internal_square+(count.x-1)*module_spacing, module_internal_square+(count.y-1)*module_spacing];
function add_point_and_number(dim, addition) = [dim.x+addition, dim.y+addition];
function determine_hole_corners(count, current_count, holes_selection) =
    [
    // Rear-right
    holes_selection==2 || holes_selection==1 && current_count.x==count.x-1 && current_count.y==count.y-1,
    // Rear-left
    holes_selection==2 || holes_selection==1 && current_count.x==0 && current_count.y==count.y-1,
    // Front-left
    holes_selection==2 || holes_selection==1 && current_count.x==0 && current_count.y==0,
    // Front-right
    holes_selection==2 || holes_selection==1 && current_count.x==count.x-1 && current_count.y==0
    ];

// rounded_wedge - creates a prism with rounded sides of different radii at top and bottom
// size - x,y size of wedge at bottom. Also, see 'external'
// radius1 - corner radius at bottom
// radius2 - corner radius at top
// external - if true, then the result is a box where the bottom is 'size', and the corners subtracted
//            the top is smaller or larger, depending on radius2
//          - if false, then the result is 'size' _plus_ the radii added on all four sides.
module rounded_wedge(size, radius1, radius2, external=false){
    radius2_ = radius2 == undef ? radius1 : radius2;
    x = external ? size.x : size.x - radius1;
    y = external ? size.y : size.y - radius1;
    minkowski(){
        cube([x, y, epsilon]);
        cylinder(r1=radius1, r2=radius2_, h=size.z);
    }  
}

// isolated_fillet - creates an fillet to be added to other solids.
// radius - the curve radius
// length - length of the fillet
module isolated_fillet(radius, length) {
    difference() {
        cube([radius, radius, length]);
        translate([radius, radius, -epsilon])
            cylinder(r=radius, h=length + 2*epsilon);
    }
}

module gridfinity_module_outline(count) {
    translate([-module_side/2 + module_radius_1, -module_side/2 + module_radius_1])
        offset(r=module_radius_1)
        square([module_side + (count.x-1) * module_spacing - 2*module_radius_1,
            module_side + (count.y-1) * module_spacing - 2*module_radius_1]);
}

module gridfinity_internal_outline(count){
    translate([-internal_side/2 + internal_radius, -internal_side/2 + internal_radius])
        offset(r=internal_radius)
        square(add_point_and_number(internal_dim(count), -2*internal_radius));
}

module gridfinity_wall_outline(count) {
    difference(){
        gridfinity_module_outline(count);
        gridfinity_internal_outline(count);
    }
}

// gridfinity_base_hole - creates an object to remove hole in base for magnets or screws.
module gridfinity_base_hole() {
    // Constants derived from spec sheet.
    outer_hole_diameter = 6.5;
    outer_hole_depth = 2.0;
    inner_hole_diameter = 3.0;
    inner_hole_depth_relative = 2.0; // Spec sheet says 2.5 max. 2.0 used here
    inner_hole_depth = outer_hole_depth + inner_hole_depth_relative;
    cylinder(h=outer_hole_depth, d=outer_hole_diameter);
    cylinder(h=inner_hole_depth, d=inner_hole_diameter);
}

// gridfinity_base_holes - create up to 4 holes in the proper locations in the gridfinity insert
// corners - Indicates which corners are to have the magnet/screw hole placed in the base.
//           A 4-tuple, being these corners [back-right, back-left, front-left, front-right]
module gridfinity_base_holes(corners=[1,1,1,1]) {
    // Constants derived_from_spec_sheet
    hole_offset_from_radius_3 = 4.8;
    offset = module_side/2 - module_radius_1 + module_radius_3 - hole_offset_from_radius_3;
    if (corners[0]) {
        translate([offset,offset]) gridfinity_base_hole();
    }
    if (corners[1]) {
        translate([-offset,offset]) gridfinity_base_hole();
    }
    if (corners[2]) {
        translate([-offset,-offset]) gridfinity_base_hole();
    }
    if (corners[3]) {
        translate([offset,-offset]) gridfinity_base_hole();
    }
}

// gridfinity_plane_insert - creates a gridfinity-compatible base, with origin at the bottom-center.
module gridfinity_plane_insert() {
    // Constants derived from spec sheet.
    height_0 = module_radius_2-module_radius_3; // heights also become radii as angles are 45deg.
    height_1 = 1.8;
    height_2 = module_radius_1-module_radius_2;
    // This part should not be necessary, but included to add tolerance to
    // the peak of the gridfinity base.
    height_3 = module_base_height - height_0 - height_1 - height_2;
    translate([-module_internal_square/2, -module_internal_square/2]) {
        translate([0, 0, 0])
        rounded_wedge([module_internal_square, module_internal_square, height_0], height_0, 2*height_0, external=true);
        translate([0, 0, height_0])
            rounded_wedge([module_internal_square, module_internal_square, height_1], 2*height_0, external=true);
        translate([0, 0, height_0+height_1])
            rounded_wedge([module_internal_square, module_internal_square, height_2], 2*height_0, 2*height_0 + height_2, external=true);
        translate([0, 0, height_0+height_1+height_2])
            rounded_wedge([module_internal_square, module_internal_square, height_3], 2*height_0 + height_2, external=true);
    }
}

// gridfinity_insert - creates a gridfinity-compatible base, with origin at bottom-center.
// corners - Indicates which corners are to have the magnet/screw hole placed in the base.
//           A 4-tuple, being these corners [back-right, back-left, front-left, front-right]
module gridfinity_insert(corners=[1,1,1,1]) {
    difference() {
        gridfinity_plane_insert();
        translate([0,0,-epsilon])
            gridfinity_base_holes(corners);
    }
}

module gridfinity_module_mass(count, height, z_offset=module_unit_height) {
    // Height and z_offset should typically be a multiple of 7.
    translate([0,0, z_offset])
        linear_extrude(height=height)
        gridfinity_module_outline(count);
}

module gridfinity_square_bore_top_fillet_part(size, radius, extension, part){
    if(part==0) { // right
        translate([size.x/2,-size.y/2-extension,0])
            rotate([-90,0,0])
            isolated_fillet(radius, size.y + 2*extension + 2*epsilon);
    }
    if(part==1) { // back
        translate([size.x/2+extension,size.y/2,0])
            rotate([-90,0,90])
            isolated_fillet(radius, size.x + 2*extension + 2*epsilon);
    }
    if(part==2) { // left
        translate([-size.x/2,size.y/2+extension,0])
            rotate([-90,0,180])
            isolated_fillet(radius, size.y + 2*extension + 2*epsilon);
    }
    if(part==3) { // front
        translate([-size.x/2-extension,-size.y/2,0])
            rotate([-90,0,-90])
            isolated_fillet(radius, size.x + 2*extension + 2*epsilon);
    }
}

module gridfinity_square_bore_top_fillet(size, radius, sides) {
    corner_pairs=[[0,1],[1,2],[2,3],[3,0]];
    for(side = [for (i=[0:3]) if (sides[i]) i]) {
        gridfinity_square_bore_top_fillet_part(size, radius, 0, side);
    }
    for(pair = corner_pairs) {
        if(sides[pair[0]] && sides[pair[1]]) { //back-right
            intersection_for(side=pair) {
                gridfinity_square_bore_top_fillet_part(size, radius, radius, side);
            }
        }
    }   
}

module gridfinity_single_square_bore(size, top_radius=0, bottom_radius=0, top_sides=[1,1,1,1], bottom_sides=[1,1,1,1]) {
    translate([0,0,epsilon]) {
        difference() {
            translate([-size.x/2, -size.y/2, -size.z]) cube(size);
            if(bottom_radius>0){
                if(bottom_sides[0]) { // right
                    translate([size.x/2+epsilon, -size.y/2-epsilon, -size.z-epsilon])
                        rotate([90,0,180])
                        isolated_fillet(bottom_radius, size.y + 2*epsilon);
                }
                if(bottom_sides[1]) { // back
                    translate([size.x/2+epsilon, size.y/2+epsilon, -size.z-epsilon])
                        rotate([90,0,-90])
                        isolated_fillet(bottom_radius, size.x + 2*epsilon);
                
                }
                if(bottom_sides[2]) { // left
                    translate([-size.x/2-epsilon, size.y/2+epsilon, -size.z-epsilon])
                        rotate([90,0,0])
                        isolated_fillet(bottom_radius, size.y + 2*epsilon);
                }
                if(bottom_sides[3]) { // front
                    translate([-size.x/2-epsilon, -size.y/2-epsilon, -size.z-epsilon])
                        rotate([90,0,90])
                        isolated_fillet(bottom_radius, size.x + 2*epsilon);
                }
            }
        }
        if(top_radius>0){
                gridfinity_square_bore_top_fillet(size, top_radius, top_sides);
        }
    }
}

// ********************************************************************************************
// The following modules are expected to be called by the user to create the desired container.

// Common Parameters:
// count - [x,y] of number of gridfinity modules making up the object
// height - height of the component, with its base starting at the z_offset. Typically a multiple of
//          the module_unit_height of 7.
// z_offset - the bottom offset of the component. Defaults to "module_unit_height" of 7, which is then
//            typically the top of the module base. If not 7, then typically a multiple thereof.
// 
// 

// gridfinity_module_base - creates the base for our object. Consisting of 1 or more inserts and a 
//                          base covering/joining all inserts. The object's origin is the bottom-center
//                          of the "insert" created if count is [1,1], with the rest extending
//                          along the X and Y axes.
//                          A "lid" for a container can be created by using just this module.
// count - see Common Parameters above.
// holes - Selects where to put magnet/screw holes. 0-none, 1-corners only, 2-everywhere
//         Currently,
module gridfinity_module_base(count, holes=0) {
    plane_height = module_unit_height - module_base_height;
    for(x=[0:count.x-1]) {
        for(y=[0:count.y-1]) {
            translate([x * module_spacing, y*module_spacing])
                gridfinity_insert(corners=determine_hole_corners(count, [x,y], holes));
        }
    }
    gridfinity_module_mass(count, plane_height, module_base_height);
}

// gridfinity_internal_mass - creates a solid block bounded by the object's walls.
// count, height, z_offset - see Common Parameters above.
module gridfinity_internal_mass(count, height, z_offset=module_unit_height) {
    translate([0, 0, z_offset])
        linear_extrude(height=height)
            gridfinity_internal_outline(count);
}

module gridfinity_square_bores(count, size, z_offset, repeat=[1,1], top_radius=0, bottom_radius=0,
                              top_sides=[1,1,1,1], bottom_sides=[1,1,1,1]){
    dim = internal_dim(count);
    total_space = [dim.x-size.x*repeat.x, dim.y-size.y*repeat.y];
    interval_space = [total_space.x/(repeat.x+1), total_space.y/(repeat.y+1)];
    repeat_space = [size.x+interval_space.x, size.y+interval_space.y];
    start_coord = [-internal_side/2+size.x/2+interval_space.x, -internal_side/2+size.y/2+interval_space.y];
    
    echo(dim, total_space, interval_space, repeat_space, start_coord);
    
    for(x=[0: repeat.x-1]) {
        for(y=[0: repeat.y-1]) {
            translate([start_coord.x+x*repeat_space.x, start_coord.y+y*repeat_space.y,z_offset])
                gridfinity_single_square_bore(size, top_radius, bottom_radius, top_sides, bottom_sides);
        }
    }
}

// gridfinity_wall - creates the side walls of the module, with the solid forming the sides of
//                   the external and internal outlines.
// count, height, z_offset - see Common Parameters above.
module gridfinity_wall(count, height, z_offset=module_unit_height) {
    // Height and z_offset should be multiple of 7.
    translate([0, 0, z_offset])
        linear_extrude(height=height)
        gridfinity_wall_outline(count);
}

// gridfinity_internal_fillets - creates rounded fillets which sit atop the module_base or
//                               internal_mass. Can be called multiple times if different
//                               radii for the sides is required.
// count, radius, z_offset - see Common Parameters above.
// sides - specifies which sides the fillet will be created, where non-zero creates that fillet.
//         The positions are [right, back, left, top]. Defaults to all sides.
module gridfinity_internal_fillets(count, radius, sides=[1,1,1,1], z_offset=module_unit_height) {
    internal = internal_dim(count);
    if ( radius > 0 ) {
        if ( sides[0] ) {
            // x=N side ; right
            translate([internal.x - internal_side/2, -internal_side/2, z_offset])
                rotate([90,0,180])
                isolated_fillet(radius, internal.y);
        }
        if ( sides[1] ) {
            // y=N side ; back
            translate([internal.x - internal_side/2, internal.y - internal_side/2, z_offset])
                rotate([90,0,-90])
                isolated_fillet(radius, internal.x);
        }
        if ( sides[2] ) {
            // x=0 side ; left
            translate([-internal_side/2, internal.y - internal_side/2, z_offset])
                rotate([90, 0, 0])
                isolated_fillet(radius, internal.y);
        }
        if ( sides[3] ) {
            // y=0 side ; front
            translate([-internal_side/2, -internal_side/2, z_offset])
                rotate([90,0,90])
                isolated_fillet(radius, internal.x);
        }
    }
}

// gridfinity_stacking_lip - Adds a fixed height lip to the object to allow other Gridfinity modules
//                           to rest atop it.
// count, z_offset - see Common Parameters above.
module gridfinity_stacking_lip(count, z_offset) {
    // Constants derived from spec sheet
    height_3 = 1.9;
    radius_3 = module_radius_1;
    height_2 = 1.8;
    radius_2 = radius_3 - height_3;
    height_1 = 0.7;
    radius_1 = radius_2;
    radius_0 = radius_1 - height_1;
    base = module_internal_dim(count);
    stacking_lip_height = height_1 + height_2 + height_3; // 4.4mm
    translate([0,0,z_offset])
    difference () {
        linear_extrude(height=stacking_lip_height)
            gridfinity_wall_outline(count);
        translate([-module_internal_square/2, -module_internal_square/2]) {
            rounded_wedge([base.x, base.y, height_1], radius_0, radius_1, external=true);
            translate([0, 0, height_1])
                rounded_wedge([base.x, base.y, height_2], radius_1, radius_2, external=true);
            translate([0, 0, height_1 + height_2])
                rounded_wedge([base.x, base.y, height_3], radius_2, radius_3, external=true);
        }
    }
}

// ******************************************************
// An example that utilizes all the expected features.
// This may be modified directly, or this .scad file "used" by another file 

// Create an object with the following gridfinity dimensions
count=[3, 2];

// Create the module base. No holes. height=7 and z_offset=0 fixed.
gridfinity_module_base(count, holes=0);

// at z_offset=7 (default), create walls 14 high.
gridfinity_wall(count, 14);

// at z_offset=7 (default), create a thicker base (not too useful, for demonstration purposes)
gridfinity_internal_mass(count, 7);

// at z_offset=14 (because of internal mass), create fillets at back and front of radius 5.
// gridfinity_internal_fillets(count, 5, [0,1,0,1], z_offset=14);
 
// at z_offset=21 (base height + wall height), create a stacking lip.
gridfinity_stacking_lip(count, z_offset=21);
