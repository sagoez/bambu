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

    fit_clear = 1.4,

    bracket_w = 70.0,
    lip_reach = 35.0,
    spine_t   = 4.0,
    lip_t     = 3.0,

    screw_d      = 4.2,
    screw_ins    = 9.0,
    screw_head_d = 8.4,
    screw_cs     = 2.6,
    top_tab_t    = 5.0,
    driver_d     = 10.0,

    win_w = 30.0,
    win_h = 8.0
) {
    upper_gap = upper_t + fit_clear;
    lower_gap = lower_t + fit_clear;
    total_h   = top_tab_t + 2 * lip_t + upper_gap + lower_gap;

    eps = 0.01;

    /* z measured from the bottom of the part. The desk face is at total_h. */
    z_top_tab = total_h - top_tab_t;
    z_mid_tab = z_top_tab - upper_gap - lip_t;
    z_bot_tab = 0;

    module spine() {
        cube([bracket_w, spine_t, total_h]);
    }

    module tab(z, t = undef) {
        translate([0, spine_t - eps, z])
            cube([bracket_w, lip_reach + eps, t == undef ? lip_t : t]);
    }

    /* Lightening cutouts in the spine. Kept clear of the tab roots so every
       tab still meets full-thickness spine. */
    module spine_windows() {
        for (z = [z_bot_tab + lip_t + lower_gap / 2,
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
            tab(z_mid_tab);
            tab(z_bot_tab);
        }
        spine_windows();
        driver_access();
        screws();
    }
}
