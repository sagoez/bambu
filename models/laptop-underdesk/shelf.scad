/* Under-desk double shelf for a MacBook Pro 16" and a ThinkPad P14s 14".
   Print two, identical. Three if you want mid-span support.

       upper shelf   MacBook Pro 16"   16.8 mm thick, 355.7 wide
       lower shelf   ThinkPad P14s     26.64 mm over its rear bar, 315.9 wide

   MacBook on top simply because it is the thinner of the two, so the stack
   sits tighter to the desk. Swap upper_t and lower_t to reverse it.

   The ThinkPad number is the MEASURED 26.64, not Lenovo's published 16.13.
   The machine has a raised bar across its underside; laid flat that bar sets
   the shelf gap.

   SPACING: set the brackets to the MacBook's 355.7 mm plus a couple of mm and
   slide each laptop in from the front. lip_reach is 35 mm so the narrower
   ThinkPad still lands ~14 mm onto each lip.

   EXPORTED ALREADY ROTATED into its print orientation, lying on its spine with
   every tab rising vertically. Verified zero downward-facing facets. Do not
   re-orient it; standing upright the three tabs become horizontal cantilevers.
*/

use <../../lib/under_desk_shelf.scad>

$fn = 48;

rotate([90, 0, 0])
under_desk_shelf(
    upper_t = 16.80,
    lower_t = 26.64,

    /* Wider than the 70 mm default: more contact along the laptop's edge, and
       it pushes the two screws from 38 mm apart to 63 mm, which resists the
       bracket twisting on its own fixings. */
    bracket_w = 95.0,

    /* Tighter than the 1.4 mm default so the laptops sit rather than rattle.
       0.4 mm per side is snug but still slides. Do not go below this - a laptop
       is not a precision part and the slot has to clear stickers and feet. */
    fit_clear = 1.0
);
