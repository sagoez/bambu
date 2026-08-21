/* Reusable under-desk double shelf bracket.

   Screws to the underside of a desk and holds TWO laptops flat, one above the
   other. Print two or three and space them along the laptops' edge; the
   spacing is set when you drill, not by the print.

   Section is a comb: a vertical spine with three tabs, all pointing the same
   way. The top tab takes the screw, the middle and bottom tabs are the two
   shelves. Laptops slide in from the open side and rest on the tabs.

   The top tab points INWARD, over the laptop, rather than outward as most
   commercial versions do. That is deliberate: with every tab on the same side,
   the part lies on its spine and prints with all tabs rising vertically, so
   there is not a single overhang anywhere. An outward flange would need a
   chamfer under it. The cost is that the upper laptop sits lip_t lower, which
   is accounted for.

   Fit the brackets first, then slide the laptops in - the screws are above the
   upper laptop and unreachable once it is loaded.

   lip_reach is sized for the NARROWER laptop, not the wider one. Brackets get
   spaced for the widest machine, so a narrower one loses half the width
   difference in overlap on each side. With a 16" and a 14" that is 19.9 mm per
   side, and a short lip would let the 14" drop between the brackets.

   Usage:
       use <../../lib/under_desk_shelf.scad>
       under_desk_shelf(upper_t = 16.8, lower_t = 26.64);
*/

module under_desk_shelf(
    upper_t,
    lower_t,

    fit_clear  = 1.6,
    stop_slack = 2.0,

    upper_w = undef,
    lower_w = undef,

    bracket_w = 70.0,
    lip_reach = 30.0,
    stop_h    = 8.0,
    stop_t    = 3.0,
    spine_t   = 4.0,
    lip_t     = 3.0,
    mid_tab_t = undef,
    bot_tab_t = undef,

    screw_d      = 4.2,
    screw_ins    = 9.0,
    screw_head_d = 8.4,
    screw_cs     = 2.6,
    top_tab_t    = 5.0,
    driver_d     = 10.0,

    win_w = 30.0,
    win_h = 8.0
) {
    /* Brackets get spaced for the WIDER laptop, so the narrower one sits inset
       by half the width difference on each side. Rather than packing the slot
       out, the lower lip simply reaches that much further in and carries a stop
       where the narrower laptop's edge lands. Each floor is sized to its own
       machine.

       stop_slack pulls the stops outward from the exact figure. The failures
       are not symmetric: a slot or gap too SMALL means the laptop does not go
       in at all, while too LARGE means it sits a little loose and a strip of
       foam tape fixes it. Margin therefore goes on the generous side of every
       dimension, and the published widths these are derived from have already
       been wrong once. */
    pack = (upper_w == undef || lower_w == undef)
             ? 0
             : (upper_w - lower_w) / 2 - stop_slack;

    mt = mid_tab_t == undef ? lip_t : mid_tab_t;
    bt = bot_tab_t == undef ? lip_t : bot_tab_t;

    upper_gap = upper_t + fit_clear;
    lower_gap = lower_t + fit_clear;
    total_h   = top_tab_t + mt + bt + upper_gap + lower_gap;

    eps = 0.01;

    /* z measured from the bottom of the part. The desk face is at total_h. */
    z_top_tab = total_h - top_tab_t;
    z_mid_tab = z_top_tab - upper_gap - mt;
    z_bot_tab = 0;

    module spine() {
        cube([bracket_w, spine_t, total_h]);
    }

    module tab(z, t = undef, reach = undef) {
        translate([0, spine_t - eps, z])
            cube([bracket_w,
                  (reach == undef ? lip_reach : reach) + eps,
                  t == undef ? lip_t : t]);
    }

    /* Upstand the narrower laptop's edge butts against, so it cannot wander
       across the slack left by the wider one's spacing.

       A 45 degree ramp, not a block. The vertical face is on the inboard side
       where the laptop actually touches; the outboard side slopes away to the
       lip. As a block it printed as a horizontal cantilever off the lip -
       380 mm2 each - because in the print orientation the lips stand vertical
       and anything projecting from them overhangs. The ramp self-supports. */
    module stop(z) {
        translate([0, spine_t + pack, z])
            rotate([0, 0, 90])
                rotate([90, 0, 0])
                    linear_extrude(bracket_w)
                        polygon([[0, 0], [-stop_h, 0], [0, stop_h]]);
    }

    /* Lightening cutouts in the spine. Kept clear of the tab roots so every
       tab still meets full-thickness spine. */
    module spine_windows() {
        for (z = [z_bot_tab + bt + lower_gap / 2,
                  z_mid_tab + lip_t + upper_gap / 2])
            translate([bracket_w / 2, spine_t / 2, z])
                cube([win_w, spine_t + 2, win_h], center = true);
    }

    /* Countersunk, opening DOWNWARD. The screws go up into the desk, so the
       head sits on the underside of the top tab - inside the upper laptop's
       slot. A proud head would foul the laptop, which has only fit_clear of
       room. top_tab_t is thickened so there is solid material left under the
       cone. */
    /* Clearance holes through the lower tabs, directly under each screw, so a
       driver reaches the head in a straight line from below. Without these the
       screws are unreachable: they sit inside the upper slot with the middle
       tab right beneath them, and no driver fits an 18 mm gap. */
    module driver_access() {
        for (sx = [-1, 1])
            translate([bracket_w / 2 + sx * (bracket_w / 2 - 16),
                       spine_t + screw_ins, -1])
                cylinder(d = driver_d, h = total_h, $fn = 32);
    }

    module screws() {
        for (sx = [-1, 1])
            translate([bracket_w / 2 + sx * (bracket_w / 2 - 16),
                       spine_t + screw_ins, 0]) {
                translate([0, 0, z_top_tab - 1])
                    cylinder(d = screw_d, h = top_tab_t + 2, $fn = 32);
                translate([0, 0, z_top_tab - eps])
                    cylinder(d1 = screw_head_d, d2 = screw_d,
                             h = screw_cs, $fn = 32);
            }
    }

    difference() {
        union() {
            spine();
            tab(z_top_tab, top_tab_t);
            tab(z_mid_tab, mt, pack + lip_reach);
            tab(z_bot_tab, bt, pack + lip_reach);
            /* ONE stop, on the bottom tab only. The middle tab's TOP face is
               the floor of the upper slot, so a stop there sits directly in
               the wider laptop's path and blocks it. The narrower laptop rests
               on the bottom tab; the middle tab is merely its ceiling. */
            if (pack > 0) stop(z_bot_tab + bt);
        }
        spine_windows();
        driver_access();
        screws();
    }
}
