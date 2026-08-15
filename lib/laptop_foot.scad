/* Leaning twin-slot laptop foot.

   Print TWO. They are identical and sit under the two ends of a pair of
   laptops stood on edge, closed. A 16" laptop is ~355 mm long, well past the
   A1's 256 mm bed, so a single full-length stand is not printable; two feet
   are, and they also let you set the spacing to suit.

   Slots lean back by `lean` degrees. That is not styling: a vertical slot lets
   a laptop rock within the slot clearance, whereas a leaning one makes it
   settle firmly against one slot face. It is what stops the wobble.

   The cost of leaning is that it throws the centre of mass BACKWARD, off the
   base. A 16" laptop leaning 12 degrees puts its CoM ~26 mm behind its slot,
   which will tip a compact base straight over. `back_margin` and the tail
   exist to catch that - see the stability note in CLAUDE.md before shrinking
   either.

   Profile is a fin: rises from the front, peaks just behind the rear slot,
   then sweeps down to a low tail. The tail provides the anti-tip footprint
   without the visual bulk of a block. Built as a hull of spheres, which
   radiuses every edge in one operation.

   Usage:
       use <../lib/laptop_foot.scad>
       laptop_foot(front_t = 16.13, back_t = 16.80);
*/

module laptop_foot(
    front_t,
    back_t,

    slot_clear  = 1.3,
    front_clear = undef,
    back_clear  = undef,
    slot_floor = 9.0,
    slot_gap   = 15.0,

    lean = 12.0,

    foot_w       = 58.0,
    front_margin = 12.0,
    back_margin  = 42.0,

    h_front = 30.0,
    h_peak  = 56.0,
    h_tail  = 14.0,

    edge_r = 5.0,

    pad_inset = 11.0,
    pad_d     = 2.4,
    pad_dia   = 12.0
) {
    /* Per-slot clearance so one laptop can be a tight fit without dragging the
       other tighter with it. Fall back to slot_clear when not given. */
    fc = front_clear == undef ? slot_clear : front_clear;
    bc = back_clear  == undef ? slot_clear : back_clear;

    fs = front_t + fc;
    bs = back_t + bc;

    foot_d = front_margin + fs + slot_gap + bs + back_margin;

    front_y = -foot_d / 2 + front_margin + fs / 2;
    back_y  = front_y + fs / 2 + slot_gap + bs / 2;
    peak_y  = back_y + bs / 2 + 5;

    eps = 0.01;

    module body() {
        r = edge_r;
        hull() for (sx = [-1, 1]) {
            x = sx * (foot_w / 2 - r);
            translate([x, -(foot_d / 2 - r), r]) sphere(r);
            translate([x, foot_d / 2 - r, r]) sphere(r);
            translate([x, -(foot_d / 2 - r), h_front - r]) sphere(r);
            translate([x, peak_y, h_peak - r]) sphere(r);
            translate([x, foot_d / 2 - r, h_tail - r]) sphere(r);
        }
    }

    /* Cut in the leaning frame so the slot walls stay parallel to the laptop
       rather than pinching it at the mouth.

       Keyed to slot_floor, an absolute height, NOT a depth below the top
       surface. The top is a slope, so a fixed depth leaves the front slot far
       shallower than the rear one - on a first attempt that gave 10 mm, not
       enough to hold a laptop upright. */
    module slot(yc, t) {
        rotate([-lean, 0, 0])
            translate([0, yc, slot_floor + 100])
                cube([foot_w + 20, t, 200], center = true);
    }

    /* Recesses for stick-on rubber pads. A smooth radiused base slides on a
       desk otherwise, and the pads also keep the print off the finish. */
    module pads() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (foot_w / 2 - pad_inset),
                       sy * (foot_d / 2 - pad_inset), -eps])
                cylinder(d = pad_dia, h = pad_d);
    }

    difference() {
        body();
        slot(front_y, fs);
        slot(back_y, bs);
        pads();
    }
}
