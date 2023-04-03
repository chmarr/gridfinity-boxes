// Gridfinity Module Generator
// Copyright 2023 Chris Cogdon
// Licence: CC-BY-SA-3.0
// https://www.github.com/chmarr/gridfinity-boxes

$fn=40;
epsilon = 0.001; // a small value to make difference() look nice.

// Constants derived from spec sheet
module_side=41.5;
module_radius_1=3.75;  // because using diameters for fillets is non-standard.
module_radius_2=1.6;
module_radius_3=0.8;
module_base_height=5;
module_spacing=42;
module_unit_height=7;
module_internal_square = module_side - 2*module_radius_1;
internals_radius = module_radius_3;
internals_side=module_side - 2*(1.9 + 0.7);

function coalesce(a, b) = a == undef ? b : a;
function module_dim(count) = [module_side+(count.x-1)*module_spacing, module_side + (count.y-1) * module_spacing];
function internals_dim(count) = [internals_side+(count.x-1)*module_spacing, internals_side+(count.y-1)*module_spacing];
function module_internal_dim(count) = [module_internal_square+(count.x-1)*module_spacing, module_internal_square+(count.y-1)*module_spacing];
function add_point_and_number(dim, addition) = [dim.x+addition, dim.y+addition];

module rounded_wedge(size, radius1, radius2, external=false){
    radius2_ = radius2 == undef ? radius1 : radius2;
    x = external ? size.x : size.x - radius1;
    y = external ? size.y : size.y - radius1;
    minkowski(){
        cube([x, y, epsilon]);
        cylinder(r1=radius1, r2=radius2_, h=size.z);
    }  
}

module isolated_fillet(radius, length) {
    difference() {
        cube([radius, radius, length]);
        translate([radius, radius, -epsilon])
            cylinder(r=radius, h=length + 2*epsilon);
    }
}

module gridfinity_insert () {
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

module gridfinity_module_outline(count) {
    translate([-module_side/2 + module_radius_1, -module_side/2 + module_radius_1])
        offset(r=module_radius_1)
        square([module_side + (count.x-1) * module_spacing - 2*module_radius_1,
            module_side + (count.y-1) * module_spacing - 2*module_radius_1]);
}

module gridfinity_module_mass(count, height, z_offset=module_unit_height) {
    // Height and z_offset should typically be a multiple of 7.
    translate([0,0, z_offset])
        linear_extrude(height=height)
        gridfinity_module_outline(count);
}

module gridfinity_internals_outline(count){
    translate([-internals_side/2 + internals_radius, -internals_side/2 + internals_radius])
        offset(r=internals_radius)
        square(add_point_and_number(internals_dim(count), -2*internals_radius));
}

module gridfinity_internals_mass(count, height, z_offset=module_unit_height, radius=0) {
    translate([0, 0, z_offset])
        linear_extrude(height=height)
            gridfinity_internals_outline(count);
    internals = internals_dim(count);
    if ( radius > 0 ) {
        // x=0 side
        translate([-internals_side/2, internals.y - internals_side/2, height + z_offset])
            rotate([90, 0, 0])
            isolated_fillet(radius, internals.y);
        // x=N side
        translate([internals.x - internals_side/2, -internals_side/2, height + z_offset])
            rotate([90,0,180])
            isolated_fillet(radius, internals.y);
        // y=0 side
        translate([-internals_side/2, -internals_side/2, height + z_offset])
            rotate([90,0,90])
            isolated_fillet(radius, internals.x);
        // y=N side
        translate([internals.x - internals_side/2, internals.y - internals_side/2, height + z_offset])
            rotate([90,0,-90])
            isolated_fillet(radius, internals.x);
    }
}

module gridfinity_wall_outline(count) {
    difference(){
        gridfinity_module_outline(count);
        gridfinity_internals_outline(count);
    }
}

module gridfinity_wall(count, height, z_offset=module_unit_height) {
    // Height and z_offset should be multiple of 7.
    translate([0, 0, z_offset])
        linear_extrude(height=height)
        gridfinity_wall_outline(count);
}

module gridfinity_module_base(count) {
    plane_height = module_unit_height - module_base_height;
    for(x=[0:count.x-1]) {
        for(y=[0:count.y-1]) {
            translate([x * module_spacing, y*module_spacing])
                gridfinity_insert();
        }
    }
    gridfinity_module_mass(count, plane_height, module_base_height);
}

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


count=[1,1];
gridfinity_module_base(count);
gridfinity_wall(count, 7);
gridfinity_internals_mass(count,0, radius=5);
gridfinity_stacking_lip(count,14);
