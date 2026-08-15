/* Lindy 43202 KVM dock - under-desk end cup, MIRRORED half. Print ONE.

   This is the pair to cup.scad. The two are NOT identical: mirroring across Y
   moves the end wall to the far end while keeping the solid side wall on the
   same long face, which is what the second end of the dock needs. Printing two
   of cup.scad puts the solid wall against the port face at one end.

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

mirror([0, 1, 0])
end_cup(
    device_w = 79.00,
    device_h = 28.70,

    button_from_end  = 26.695,
    button_from_edge = 15.865
);
