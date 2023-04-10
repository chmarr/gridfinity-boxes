# gridfinity-boxes
## A Gridfinity Box Generator

This is the first stage of, I hope, an extensive gridfinity generator to cover a large proportion of uses out there. 
Right now this covers the simple container case, with new features being added progressively, such as:

* Deep holes to store square or rounded objects
* Flanges at the rear wall to allow labeling.
* Inserts for screws or magnets at the base of the box
* More as I and others think of them.

Of note, the Gridfinity spec sheet does not specify several dimensions, such as radii of stacking lips, etc. 
Some interpolation has been made. The result is that boxes generated with this tool fit so well that a 3x2 
can lift up an unloaded “standard” base plate, even through stacking.

The project is being shared at github, at https://github.com/chmarr/gridfinity-boxes .
Please send all bug reports and feature requests there, after searching for existing issues, of course, :)
I will still read comments here, and would love to see people's makes.

I'd like to acknowledge an existing OpenSCAD generator here: https://www.printables.com/model/174346-gridfinity-openscad-model .
This project is not a remix of that, but rather a “clean-room” implementation.

The base-plate that was used for testing dimensions is this one: https://www.printables.com/model/417152-gridfinity-specification/files .

## Instructions

Some familiarity with OpenSCAD is required. But it's fairly simple; much, much simpler than Fusion360.

Tip: If you have git on your computer, try cloning this project rather than downloading. You can keep up-to-date simply
by using 'git pull'.

Either modify the last lines in the `gridfinity_boxes.scad` file, or better, create a new file based on `example1.scad`. Edit to create the
box features you want. Documentation for each of the expected-to-be-called modules is in the scad file, but here's a quick run down. 
There are five possible modules to call, specified below with their "signatures":

* `gridfinity_module_base(count, holes=0)`
* `gridfinity_wall(count, height, z_offset=module_unit_height)`
* `gridfinity_internal_mass(count, height, z_offset=module_unit_height)`
* `gridfinity_internal_fillets(count, radius, sides=[1,1,1,1], z_offset=module_unit_height)`
* `gridfinity_stacking_lip(count, z_offset)`

One doesn't need to call them all; just the ones to get the feature you want. In almost all cases the first two will be called.

### Common parameters

All dimensions except *count* are in mm.

* *count* -- Specified as a tuple `[x,y]`. The number of gridfinity spaces for the box in each dimension.
* *height* -- The height of the feature. This is in mm, and usually a multiple of the *gridfinity_unit_height* of **7**.
* *z_offset* -- The base height of the feature. Most features begin at the top of the module base, so this is the default. Internal fillets
and the stacking lip will usually appear higher.

### gridfinity_module_base
Creates the container base, including the X x Y inserts and a overall base layer. Always 7mm high. The origin of this and other features
is the bottom-center of the *first* insert.
* *holes* -- Selects to put holes in the bottom of the module, as per spec. 0-No holes. 1-Holes in corners only. 2-Holes everywhere.

### gridfinity_wall
Creates the wall around the outside of the box.

### gridfinity_internal_mass
Within the walls, creates a solid mass. This is not especially useful at this time, but will be once additional features become available.

### gridfinity_internal_fillets
Creates rounded fillets, either at the top of the base, or the top of the internal mass.
* *radius* -- The radius of curvature of the fillets.
* *sides* -- A 4-tuple boolean values indicating which side the fillet is to appear on. A "true" or "non-zero" value indicates to put a fillet there.
The order is "[right, back, left, front]". I.e., the value `[0,1,0,1]` will create fillets at the back and front. The default is "all sides".

### gridfinity_stacking_lip
Create a fixed-height lip on the box to allow other gridfinity modules to stack atop this.
