/* SKADIS holder for a 50 cm ruler. Print one.

   Ruler measured 39.90 mm wide, 4.0 mm thick. It stands vertically in the
   pocket with its flat face against the board, held by gravity.

   Single-slot hook, so board pitch does not matter - fits any SKADIS.

   PRINT WITH SUPPORT ON, "support on build plate only".

   The hook cantilevers 7.7 mm off the back plate and 58 mm2 of it is
   unsupported. This cannot be fixed by orientation: supporting it geometrically
   needs material either where the pegboard sits or past the 5 mm slot width.
   Unsupported it sags in the print-Z direction, which here is the hook's WIDTH
   - the dimension that has to pass a 5 mm slot with 0.4 mm of clearance, so sag
   can stop it fitting.

   "On build plate only" is correct: below the hook is open air all the way to
   the bed, so support grows from the plate and does not touch anything else.
   The scarred face is the hook underside, which rests on the slot's lower edge
   in use - cosmetic, not functional.

   EXPORTED ALREADY ROTATED into its print orientation, lying on its side.
   Upright, the hook's rear lip spans z 58-71 while the tongue joining it to the
   back plate only starts at z 66, so between 58 and 66 the lip is a floating
   island and the slicer refuses it. On its side there is no Z-overhang in the
   hook at all, and the only downward face left is the pocket ceiling - a 5 mm
   span anchored both sides, which bridges. Do not "fix" the orientation.
*/

use <../../lib/skadis_holder.scad>

$fn = 48;

item_w    = 39.90;
item_t    = 4.0;
fit_clear = 1.0;
wall      = 3.0;

/* Half the outer width, which becomes the drop height once rotated, so the
   part sits on z=0 rather than relying on the slicer to drop it. */
translate([0, 0, (item_w + fit_clear + 2 * wall) / 2])
rotate([0, 90, 0])
skadis_holder(
    item_w    = item_w,
    item_t    = item_t,
    fit_clear = fit_clear,
    wall      = wall
);
