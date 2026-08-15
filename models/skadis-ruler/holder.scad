/* SKADIS holder for a 50 cm ruler. Print one.

   Ruler measured 39.90 mm wide, 4.0 mm thick. It stands vertically in the
   pocket with its flat face against the board, held by gravity.

   Single-slot hook, so board pitch does not matter - fits any SKADIS.
*/

use <../../lib/skadis_holder.scad>

$fn = 48;

skadis_holder(
    item_w = 39.90,
    item_t = 4.0
);
