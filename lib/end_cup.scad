/* Reusable under-desk end cup with a single side wall.

   Print TWO, but they are MIRRORED, not identical. Print one, then mirror it
   along Y in the slicer for the second. Rotating instead of mirroring would put
   the side wall on the wrong face.

   Use this instead of lib/end_bracket.scad when a device has ports spread along
   one long face right out to its corners. An end bracket runs side walls in
   from each end along BOTH long faces and would bury them. This has a wall on
   the clear face only, so nothing ever crosses the port face.

   The end wall is deliberately thick (end_wall_d) rather than a 3 mm sheet,
   because with one side wall gone it is the only thing the -X flange has to
   stand on.

   Flanges are asymmetric by necessity: the +X one runs the full cup length over
   its side wall and takes two screws; the -X one exists only over the end wall
   and takes one. Three screws per cup, spread over the footprint rather than
   all on one edge.

   Usage:
       use <../lib/end_cup.scad>
       end_cup(device_w = 79.0, device_h = 28.7);
*/

module end_cup(
    device_w,
    device_h,

    cup_d      = 40.0,
    end_wall_d = 12.0,

    fit_clear = 0.4,
    head_gap  = 0.4,

    wall    = 3.0,
    floor_t = 3.0,
    rim     = 9.0,

    flange_t = 3.0,
    flange_w = 14.0,
    screw_d  = 4.2,

    win_border = 6.0,
    end_win    = 40.0,
    side_win   = 18.0,

    button_from_end  = undef,
    button_from_edge = undef,
    button_relief_d  = 16.0
) {
    pocket_w = device_w + fit_clear;
    wall_h   = device_h + head_gap;
    total_h  = floor_t + wall_h;
    outer_w  = pocket_w + 2 * wall;
    outer_d  = end_wall_d + cup_d;

    x_wall = pocket_w / 2;          // inner face of the side wall
    y0     = -outer_d / 2;          // outer face of the end wall

    eps = 0.01;
    has_button = button_from_end != undef && button_from_edge != undef;

    module floor_slab() {
        translate([-outer_w / 2, y0, 0])
            cube([outer_w, outer_d, floor_t]);
    }

    module end_wall() {
        translate([-outer_w / 2, y0, 0])
            cube([outer_w, end_wall_d, total_h]);
    }

    /* +X only. The -X long face is left completely open for the ports. */
    module side_wall() {
        translate([x_wall, y0, 0])
            cube([outer_w / 2 - x_wall, outer_d, total_h]);
    }

    module end_window() {
        h = wall_h - 2 * win_border;
        translate([0, y0 + end_wall_d / 2, floor_t + wall_h / 2])
            cube([end_win, end_wall_d + 2, h], center = true);
    }

    module side_window() {
        h = wall_h - 2 * win_border;
        translate([outer_w / 2, y0 + end_wall_d + cup_d / 2,
                   floor_t + wall_h / 2])
            cube([2 * wall + 2, side_win, h], center = true);
    }

    module floor_window() {
        w = pocket_w - 2 * rim;
        d = cup_d - 2 * rim;
        translate([0, y0 + end_wall_d + rim + d / 2, floor_t / 2])
            cube([w, d, floor_t + 2], center = true);
    }

    module button_reliefs() {
        y = y0 + end_wall_d + button_from_end;
        for (sx = [-1, 1])
            translate([sx * (device_w / 2 - button_from_edge), y, floor_t / 2])
                cylinder(d = button_relief_d, h = floor_t + 2, center = true);
    }

    /* Full-length flange over the side wall, two screws. */
    module flange_side() {
        translate([outer_w / 2 + flange_w / 2, y0 + outer_d / 2,
                   total_h - flange_t / 2])
            cube([flange_w, outer_d, flange_t], center = true);
    }

    /* Stub flange over the end wall only - there is no side wall under it. */
    module flange_end() {
        translate([-(outer_w / 2 + flange_w / 2), y0 + end_wall_d / 2,
                   total_h - flange_t / 2])
            cube([flange_w, end_wall_d, flange_t], center = true);
    }

    /* Continuous, never discrete. A flange is anchored on one edge only, so
       gaps between gussets are cantilevers rather than bridges. */
    module chamfer(sx, y_centre, length) {
        translate([sx * outer_w / 2, y_centre, total_h - flange_t])
            rotate([90, 0, 0])
                linear_extrude(length, center = true)
                    polygon([[0, 0], [sx * flange_w, 0], [0, -flange_w]]);
    }

    module screws() {
        for (sy = [0.25, 0.75])
            translate([outer_w / 2 + flange_w / 2, y0 + sy * outer_d,
                       total_h / 2])
                cylinder(d = screw_d, h = total_h + 2, center = true);
        translate([-(outer_w / 2 + flange_w / 2), y0 + end_wall_d / 2,
                   total_h / 2])
            cylinder(d = screw_d, h = total_h + 2, center = true);
    }

    difference() {
        union() {
            floor_slab();
            end_wall();
            side_wall();
            flange_side();
            flange_end();
            chamfer(1, y0 + outer_d / 2, outer_d);
            chamfer(-1, y0 + end_wall_d / 2, end_wall_d);
        }
        end_window();
        side_window();
        floor_window();
        if (has_button) button_reliefs();
        screws();
    }
}
