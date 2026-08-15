/* Reusable under-desk saddle strap.

   Print TWO per device. Each is a U-channel that passes under the device and
   rises up two opposite faces, with a flange on top of each wall screwing into
   the underside of a desk. Unlike lib/end_bracket.scad it has NO end walls, so
   it grips a band across the middle of a device rather than cupping an end.

   Use this when the device has ports or connectors on faces an end bracket
   would cover. The two straps sit inset from the corners, leaving both ends
   fully open and the centre of each long face clear.

   The device is retained by gravity and located by the two walls. Nothing
   clamps it, and it lifts straight out.

   Prints floor-down with no support: the flange undersides are continuous
   45 degree chamfers over the full strap width, so there is no flat overhang.

   Usage:
       use <../lib/saddle.scad>
       saddle(device_w = 121.55, device_h = 40.07);
*/

module saddle(
    device_w,
    device_h,

    saddle_w = 25.0,

    fit_clear = 0.4,
    head_gap  = 0.4,

    wall    = 3.0,
    floor_t = 3.0,
    rim     = 7.0,

    flange_t = 3.0,
    flange_w = 14.0,
    screw_d  = 4.2,

    wall_win   = true,
    win_border = 7.0,
    win_w      = 13.0
) {
    pocket_w = device_w + fit_clear;
    wall_h   = device_h + head_gap;
    total_h  = floor_t + wall_h;
    outer_w  = pocket_w + 2 * wall;
    eps      = 0.01;

    module body() {
        translate([0, 0, total_h / 2])
            cube([outer_w, saddle_w, total_h], center = true);
    }

    /* Open in Y at both ends: this is a strap, not a cup. */
    module pocket() {
        translate([0, 0, floor_t + wall_h / 2 + eps])
            cube([pocket_w, saddle_w + 2, wall_h + 1], center = true);
    }

    module floor_window() {
        translate([0, 0, floor_t / 2])
            cube([pocket_w - 2 * rim, saddle_w - 2 * rim, floor_t + 2],
                 center = true);
    }

    module wall_windows() {
        h = wall_h - 2 * win_border;
        translate([0, 0, floor_t + wall_h / 2])
            cube([outer_w + 2, win_w, h], center = true);
    }

    module flange(sx) {
        translate([sx * (outer_w / 2 + flange_w / 2), 0,
                   total_h - flange_t / 2])
            cube([flange_w, saddle_w, flange_t], center = true);
    }

    /* Continuous over the full strap width. Discrete gussets would leave flat
       overhang between them, and a flange is anchored on one edge only, so
       those gaps are cantilevers rather than bridges. */
    module chamfer(sx) {
        translate([sx * outer_w / 2, 0, total_h - flange_t])
            rotate([90, 0, 0])
                linear_extrude(saddle_w, center = true)
                    polygon([[0, 0], [sx * flange_w, 0], [0, -flange_w]]);
    }

    module screws() {
        for (sx = [-1, 1])
            translate([sx * (outer_w / 2 + flange_w / 2), 0, total_h / 2])
                cylinder(d = screw_d, h = total_h + 2, center = true);
    }

    difference() {
        union() {
            body();
            for (sx = [-1, 1]) {
                flange(sx);
                chamfer(sx);
            }
        }
        pocket();
        floor_window();
        if (wall_win) wall_windows();
        screws();
    }
}
