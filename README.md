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

## Quickstart Instructions

Some familiarity with OpenSCAD is required. But it's fairly simple; much, much simpler than Fusion360. First, download all the .scad files into the same folder.

Edit one of the sample files (simple\_box.scad, box\_with\_inserts.scad, etc) and
make changes to the values as required. Then render and save your .stl file.

## Involved Instructions

Tip: If you have git on your computer, try cloning this project rather than downloading. You can keep up-to-date simply by using 'git pull'.

By examining the example .scad files, you can see the gridfinity_* calls
that need to be executed to create the desired features. Documentation
on the expected-to-be-called SCAD modules follows.

There are serveral possible modules to call, specified below with their "signatures":

* `gridfinity_module_base(count, holes=0, hole_width, hole_height, hole_offset=0.2)`
* `gridfinity_wall(count, height, z_offset=module_unit_height)`
* `gridfinity_internal_mass(count, height, z_offset=module_unit_height)`
* `gridfinity_square_bores(count, size, z_offset, repeat=[1,1], top_radius=0, bottom_radius=0, top_sides=[1,1,1,1], bottom_sides=[1,1,1,1])`
* `gridfinity_internal_fillets(count, radius, sides=[1,1,1,1], z_offset=module_unit_height)`
* `gridfinity_stacking_lip(count, z_offset)`

One doesn't need to call them all; just the ones to get the feature you want. Generally, the first two will be called, with the others being optional.

### Common parameters

All dimensions except *count* are in mm.

* *count* -- Specified as a tuple `[x,y]`. The number of gridfinity spaces for the box in each dimension.
* *height* -- The height of the feature. This is in mm, and usually a multiple of the *gridfinity_unit_height* of **7**.
* *z_offset* -- The base height of the feature. Most features begin at the top of the module base, so this is the default. Internal fillets
and the stacking lip will usually appear higher.

### gridfinity_module_base
Creates the container base, including the X x Y inserts and a overall base layer. Always 7mm high. The origin of this and other features
is the bottom-center of the *first* insert.
* *holes* -- Selects to put holes in the bottom of the module, as per spec. 0-No holes. 1-Holes in corners only. 2-Holes everywhere. 3-Slide-in holes in corners
* *hole_width* -- The width of a slide in hole. Typically very slightly smaller than the magnet to allow it to be wedged in. (Only if holes==3)
* *hole_height* -- The height of a slide in hole. Typically this is slightly larger than the magnet to account for variability. (Only if holes==3)
* *hole_offset* -- The vertical offset of the hole from the bottom. Typically just one or two layer's worth to keep the magnet close to the base magnets. (Only if holes==3. Defaults to 0.2)

### gridfinity_wall
Creates the wall around the outside of the box.

### gridfinity_internal_mass
Within the walls, creates a solid mass. Most useful as the positive part
of a combination with the square_bores below.

### gridfinity_square_bores
Creates a repeating set of "bores" to subtract from the internal_mass created above.
* *size* -- The [x,y,depth] of the bores to create.
* *z_offset* -- The z-offset of the _top_ of the bore. this is typically level with the top of the internal mass.
* *repeat* -- The number of separate bores to create in the X and Y direction.
* *top_radius* -- If non-0, the radius of the curve at the top of the bore.
* *bottom_radius* -- If non-0, the radius of the curve at the bottom of the bore.
* *top_sides*, *bottom_sides* -- Which sides of the bore, at the top and bottom,
that have a curved side. Each value is a 4-tuple of true/false values, where
_true_ creates a curve on that side. The order is "[right, back, left, front]". The default is "all sides".

### gridfinity_internal_fillets
Creates rounded fillets, either at the top of the base, or the top of the internal mass.
* *radius* -- The radius of curvature of the fillets.
* *sides* -- A 4-tuple boolean values indicating which side the fillet is to appear on. A "true" or "non-zero" value indicates to put a fillet there.
The order is "[right, back, left, front]". I.e., the value `[0,1,0,1]` will create fillets at the back and front. The default is "all sides".

### gridfinity_stacking_lip
Create a fixed-height lip on the box to allow other gridfinity modules to stack atop this.
