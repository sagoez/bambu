/* Lindy 43202 KVM dock - under-desk end cup. Print TWO, MIRRORED.

   Print one, then mirror it along Y in the slicer for the second. Rotating
   would put the side wall on the port face.

   Dock is 185 x 79 x 28.7 mm (Lindy 43202 official spec). All ports run along
   one long face, out to both corners - DC 20V at one end, PD at the other - so
   an end bracket with side walls on both long faces would bury them. This has a
   wall on the clear long face only.

   Mounts UPSIDE DOWN so the POWER/SWITCH button faces the floor. Button is
   11.41 mm across, 20.99 mm from the short end and 10.16 mm from the long edge
   to its near side, hence centre 26.695 / 15.865. Without the relief it lands
   on the floor and the dock rests on it, holding it pressed.
*/

use <../../lib/end_cup.scad>

$fn = 48;

end_cup(
    device_w = 79.00,
    device_h = 28.70,

    button_from_end  = 26.695,
    button_from_edge = 15.865
);
