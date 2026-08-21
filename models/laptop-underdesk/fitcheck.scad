/* Interference test. NOT a printable part.

   Builds the real bracket pair at their installed spacing, drops both laptops
   in as solid blocks, and intersects them. Any non-zero volume in the export
   is a collision.

   This exists because dimension-checking is not fit-checking. Every gap and
   tab position measured correct while a locating stop sat squarely in the
   wider laptop's path - the numbers were all right and the part still would
   not have worked.

   Usage:
       openscad -D 'PART="mac"'   -o /tmp/c.stl fitcheck.scad
       openscad -D 'PART="think"' -o /tmp/c.stl fitcheck.scad
       openscad -D 'PART="asm"'   -o /tmp/a.stl fitcheck.scad   // visual

   A collision export has volume > 0. An empty one means clear.
*/

use <../../lib/under_desk_shelf.scad>

PART = "asm";

/* Overridable via -D so the harness itself can be validated: inflate one and
   a collision MUST appear, otherwise the test is lying. */
MAC_T   = 0;
THINK_T = 0;

upper_t = 16.80;   lower_t = 26.64;
upper_w = 355.70;  lower_w = 315.90;
fit_clear = 1.6;   stop_slack = 2.0;
bracket_w = 95.0;  lip_reach = 30.0;
spine_t = 6.0;     lip_t = 3.0;  top_tab_t = 5.0;  stop_h = 8.0;
mid_tab_t = 6.0;   // MUST track models/laptop-underdesk/shelf.scad
bot_tab_t = 6.0;   // MUST track models/laptop-underdesk/shelf.scad

upper_gap = upper_t + fit_clear;
lower_gap = lower_t + fit_clear;
total_h   = top_tab_t + mid_tab_t + bot_tab_t + upper_gap + lower_gap;
z_top_tab = total_h - top_tab_t;
z_mid_tab = z_top_tab - upper_gap - mid_tab_t;
pack      = (upper_w - lower_w) / 2 - stop_slack;

// Clear span between the two spines' inner faces.
span = upper_w + fit_clear;
y_in = spine_t;                 // inner face of bracket A's spine
y_far = y_in + span;            // inner face of bracket B's spine

module pair() {
    under_desk_shelf(upper_t = upper_t, lower_t = lower_t,
                     upper_w = upper_w, lower_w = lower_w,
                     bracket_w = bracket_w, fit_clear = fit_clear,
                     stop_slack = stop_slack, mid_tab_t = mid_tab_t,
                     bot_tab_t = bot_tab_t, spine_t = spine_t);
    translate([0, y_far + spine_t, 0]) mirror([0, 1, 0])
        under_desk_shelf(upper_t = upper_t, lower_t = lower_t,
                         upper_w = upper_w, lower_w = lower_w,
                         bracket_w = bracket_w, fit_clear = fit_clear,
                         stop_slack = stop_slack, mid_tab_t = mid_tab_t,
                     bot_tab_t = bot_tab_t, spine_t = spine_t);
}

/* Laptops run well past the brackets along x, which is the slide direction. */
module mac() {
    translate([-150, y_in + (span - upper_w) / 2, z_mid_tab + mid_tab_t])
        cube([400, upper_w, MAC_T > 0 ? MAC_T : upper_t]);
}

/* Pushed hard against one stop - the worst case for the far side. */
module think() {
    translate([-150, y_in + pack, bot_tab_t])
        cube([400, lower_w, THINK_T > 0 ? THINK_T : lower_t]);
}

if (PART == "pair") pair();
else if (PART == "mac")   intersection() { pair(); mac(); }
else if (PART == "think") intersection() { pair(); think(); }
else { pair(); %mac(); %think(); }
