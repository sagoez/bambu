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
    lower_t = 26.64
);
