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

    /* Widths drive the stepped lower lip. Brackets space to the 16 inch, so the
       14 inch sits (355.7-315.9)/2 = 19.9 mm inboard on each side; the lower
       lip reaches that much further in and stops it there. */
    upper_w = 355.70,
    lower_w = 315.90,

    /* Wider than the 70 mm default: more contact along the laptop's edge, and
       it pushes the two screws from 38 mm apart to 63 mm, which resists the
       bracket twisting on its own fixings. */
    bracket_w = 95.0,

    /* Deliberately generous. A slot 1 mm short means the laptop does not fit
       and the part is scrap; 1 mm proud means it sits loose and foam tape fixes
       it. Both figures these derive from came off spec sheets, and Lenovo's
       thickness was 10 mm out. */
    fit_clear  = 1.6,
    stop_slack = 2.0,

    /* The middle tab is the most loaded part in the bracket: it carries the
       MacBook on a 48 mm cantilever and separates the two machines. Doubled
       from the 3 mm the other lips use. Costs 3 mm of drop, and there is
       height to spare. */
    mid_tab_t = 6.0,

    /* The 3 mm bottom lip visibly bent in the first print. Stiffness goes as
       thickness cubed, so 3 -> 6 mm is 8x stiffer, not 2x. Costs 3 mm of drop.
       My earlier deflection figures were optimistic: they assumed solid PLA at
       E = 3000 MPa, and a sparsely filled print is nearer 1800. */
    bot_tab_t = 6.0
);
