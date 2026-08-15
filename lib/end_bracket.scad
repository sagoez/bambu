/* Reusable under-desk end bracket.

   Print TWO per device. They are identical, not mirrored; the second installs
   rotated 180 degrees. Each cups one short end of the device, the two are
   screwed to the underside of a desk at whatever spacing suits, and the middle
   of the device is left open on all four sides.

   Each bracket carries two L-shaped corner flanges: a plate down the long face
   holding the screw, and a wrap onto the short face. Both are horizontal
   overhangs, so both are gusseted at 45 degrees and the part prints floor-down
   with no support.

   Per-device files supply device_w, device_h and any button relief; everything
   else has a working default. See CLAUDE.md for the reasoning behind the
   non-obvious ones.

   Usage:
       use <../lib/end_bracket.scad>
       end_bracket(device_w = 92.90, device_h = 28.62);
*/

module end_bracket(
    device_w,
    device_h,

    bracket_d = 40.0,

    fit_clear = 0.4,
    head_gap  = 0.4,

    wall    = 3.0,
    floor_t = 3.0,
    rim     = 10.0,

    flange_t = 3.0,
    flange_w = 14.0,
    wrap_w   = 10.0,
    leg_x    = 24.0,
    gusset_t = 6.0,
    screw_d  = 4.2,

    win_border = 6.0,
    side_win   = 22.0,
    end_win    = 40.0,

    // Centre of the device's button, measured from the short end and the long
    // edge. Leave undef for a device with no button on that face.
    button_from_end  = undef,
    button_from_edge = undef,
    button_relief_d  = 16.0
) {
    pocket_w = device_w + fit_clear;
    wall_h   = device_h + head_gap;
    total_h  = floor_t + wall_h;
    outer_w  = pocket_w + 2 * wall;
    outer_d  = bracket_d + wall;
    eps      = 0.01;

    has_button = button_from_end != undef && button_from_edge != undef;

    /* Outer end is -Y. The +Y face is open, that is where the device
       continues into the gap between the two brackets. */
    module body() {
        translate([0, 0, total_h / 2])
            cube([outer_w, outer_d, total_h], center = true);
    }

    module pocket() {
        translate([0, wall / 2 + 0.5, floor_t + wall_h / 2 + eps])
            cube([pocket_w, bracket_d + 1, wall_h + 1], center = true);
    }

    module windows() {
        h = wall_h - 2 * win_border;
        translate([0, wall / 2, floor_t + wall_h / 2])
            cube([outer_w + 2, side_win, h], center = true);
        translate([0, 0, floor_t + wall_h / 2])
            cube([end_win, outer_d + 2, h], center = true);
        translate([0, wall / 2, floor_t / 2])
            cube([pocket_w - 2 * rim, bracket_d - 2 * rim, floor_t + 2],
                 center = true);
    }

    /* Through-hole, so the button protrudes and can be pressed directly rather
       than the device resting on it. Cut on both long edges so the bracket
       stays one identical part whichever way round it is installed. */
    module button_reliefs() {
        y = -outer_d / 2 + wall + button_from_end;
        for (sx = [-1, 1])
            translate([sx * (device_w / 2 - button_from_edge), y, floor_t / 2])
                cylinder(d = button_relief_d, h = floor_t + 2, center = true);
    }

    module corner_flange(sx) {
        x0 = sx * outer_w / 2;
        y0 = -outer_d / 2;
        z  = total_h - flange_t / 2;

        translate([x0 + sx * flange_w / 2, 0, z])
            cube([flange_w, outer_d, flange_t], center = true);

        translate([x0 - sx * leg_x / 2, y0 - wrap_w / 2, z])
            cube([leg_x, wrap_w, flange_t], center = true);

        translate([x0 + sx * flange_w / 2, y0 - wrap_w / 2, z])
            cube([flange_w, wrap_w, flange_t], center = true);
    }

    /* Continuous, not discrete. Discrete gussets always leave flat overhang
       between them, and a flange is anchored on one edge only, so those gaps
       are cantilevers rather than bridges. Running the chamfer the full length
       leaves no downward-facing flat surface at all. */
    module gusset_x(sx) {
        translate([sx * outer_w / 2, 0, total_h - flange_t])
            rotate([90, 0, 0])
                linear_extrude(outer_d, center = true)
                    polygon([[0, 0], [sx * flange_w, 0], [0, -flange_w]]);
    }

    module gusset_y(sx) {
        translate([sx * (outer_w / 2 - leg_x / 2), -outer_d / 2,
                   total_h - flange_t])
            rotate([0, 0, 90])
                rotate([90, 0, 0])
                    linear_extrude(leg_x, center = true)
                        polygon([[0, 0], [-wrap_w, 0], [0, -wrap_w]]);
    }

    /* The corner square where the two legs meet sits diagonally outside the
       body corner, so neither orthogonal chamfer reaches it. A thin diagonal
       fin is not enough either - it only covers a strip. This hulls the whole
       square down to the body corner, dropping by the diagonal length so every
       face of the resulting pyramid is at least 45 degrees. */
    module gusset_corner(sx) {
        len = sqrt(flange_w * flange_w + wrap_w * wrap_w);
        x0  = sx * outer_w / 2;
        y0  = -outer_d / 2;
        hull() {
            translate([x0 + sx * flange_w / 2, y0 - wrap_w / 2,
                       total_h - flange_t - eps / 2])
                cube([flange_w, wrap_w, eps], center = true);
            translate([x0, y0, total_h - flange_t - len])
                cube(eps, center = true);
        }
    }

    module screws() {
        for (sx = [-1, 1])
            translate([sx * (outer_w / 2 + flange_w / 2), 0, total_h / 2])
                cylinder(d = screw_d, h = total_h + 2, center = true);
    }

    /* A diagonal gusset is thick perpendicular to its own axis, so its corners
       escape the flange outline and silently grow the bounding box. */
    module footprint_clip() {
        y_back  = outer_d / 2 + wrap_w;
        y_front = outer_d / 2;
        translate([0, (y_front - y_back) / 2, total_h / 2])
            cube([2 * (outer_w / 2 + flange_w), y_back + y_front, total_h + 2],
                 center = true);
    }

    intersection() {
        footprint_clip();
        difference() {
            union() {
                body();
                for (sx = [-1, 1]) {
                    corner_flange(sx);
                    gusset_x(sx);
                    gusset_y(sx);
                    gusset_corner(sx);
                }
            }
            pocket();
            windows();
            if (has_button) button_reliefs();
            screws();
        }
    }
}
