/* SPGUARD multi-port GaN desktop charger - under-desk saddle. Print two.

   Ports are on three faces: PD/C1-C2 on one short end, P1-P4 across the front,
   PD/C3-C4 on the other short end. Only the back carries just the power cable.
   No pair of opposite faces is free, so an end bracket (lib/end_bracket.scad)
   cannot be used here - it would cover C1-C4 whichever way it was turned.

   A saddle strap solves it: both short ends stay completely open, and because
   the straps sit near the ends the middle of the front face stays clear of
   P1-P4.

   Placement, measured along the 154.20 mm length from each corner:
       0  -> 16 mm    keep clear, plugged cables need the room
       16 -> 41 mm    the strap sits here (25 mm band)

   So saddle_w is 25 and each strap is inset 16 mm from its end. That leaves
   72.2 mm of open span between the two straps.

   Heat: this is a high-wattage GaN charger and the underside is the likely
   vent face. Two 25 mm straps under a 154.20 mm device leave about 68% of the
   underside open to air, and the floor is further cut back to a rim.
*/

use <../../lib/saddle.scad>

$fn = 48;

/* device_h is 41.0, the height INCLUDING the rubber feet, not the 40.07 bare
   body. The charger rests on its feet, so that is the real dimension the pocket
   has to clear. Size to the bare body and the device stands proud of the walls
   and bears against the desk itself, which is what head_gap exists to prevent.

   rim is widened from the 7.0 default to 8.5, narrowing the floor slot to 8 mm
   so a rubber foot cannot drop into it and rock the charger. Airflow does not
   suffer: the two straps already leave ~68% of the underside open. */

saddle(
    device_w = 90.00,
    device_h = 41.00,
    saddle_w = 25.0,
    rim      = 8.5
);
