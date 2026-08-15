/* Twin laptop stand foot - MacBook Pro 16" M4 + ThinkPad P14s Gen 6 AMD.
   Print two.

   Official thicknesses:
       MacBook Pro 16" M4        16.8 mm, uniform slab
       ThinkPad P14s Gen 6 AMD   16.13 mm rear, tapering to 10.9 mm front

   The ThinkPad is a wedge, but the taper runs along its 223.7 mm depth and the
   slot only engages ~28 mm of that, so thickness varies by ~0.65 mm inside the
   slot. Sized for the REAR edge: stand it hinge-down. Front-edge-down would
   leave ~5 mm of rattle.

   MacBook goes at the back. On edge it is 248.1 mm tall against the ThinkPad's
   223.7 mm, so the taller machine behind reads better, and the heavier one sits
   over the deeper part of the base.
*/

use <../../lib/laptop_foot.scad>

$fn = 64;

/* foot_w and h_tail are overridden well above the library defaults on purpose.
   The default 58 mm wide foot with a 14 mm tail read as thin and insubstantial
   for something carrying a 16" machine. Wider also genuinely helps: it resists
   the laptops twisting about the vertical axis, and it puts more sole on the
   desk. Neither change affects fore-aft tipping, and the heavier tail adds mass
   exactly where it counters it.

   No cases or sleeves on either laptop, so slot widths are sized bare. */

laptop_foot(
    front_t = 16.13,   // ThinkPad P14s Gen 6 AMD, hinge edge
    back_t  = 16.80,   // MacBook Pro 16" M4

    foot_w = 78.0,
    h_tail = 24.0,

    /* front_margin is well above what the nominal wall needs because the 12
       degree lean tapers the front fin: the slot face sits furthest forward at
       the bottom, so the fin is thinnest at its base, which is exactly where a
       cantilever is most loaded. At 12 it measured ~6 mm at the floor. Read
       front_margin as "fin thickness at the top", and subtract roughly
       slot_depth * tan(lean) to get the thickness at the base. */
    front_margin = 22.0,
    slot_gap     = 18.0
);
