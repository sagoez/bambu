/* Reusable IKEA SKADIS pocket holder.

   A back plate that lies flat on the pegboard, a single-slot hook, and an
   open-topped pocket. The held item stands vertically in the pocket and is
   retained by gravity, not friction - lift it straight out.

   SKADIS geometry used:
       slot        5 mm wide x 15 mm tall, vertical oval
       board       5.0 - 5.2 mm thick

   Deliberately engages ONE slot. Sources disagree on whether the pitch is 20
   or 40 mm, and a single-slot hook does not care - it fits any SKADIS board.
   The cost is that the holder could pivot about that one point; the back plate
   is sized tall and wide enough to bear on the board and damp it.

   Hook fits by tilting the holder up, pushing the tongue through the slot, then
   lowering. The slot is 15 mm tall against a 5 mm tongue, so there is 10 mm of
   drop, and the rear lip lands behind the board.

   Usage:
       use <../lib/skadis_holder.scad>
       skadis_holder(item_w = 39.90, item_t = 4.0);
*/

module skadis_holder(
    item_w,
    item_t,

    fit_clear = 1.0,
    pocket_h  = 55.0,

    wall     = 3.0,
    plate_t  = 3.0,
    plate_h  = 82.0,

    board_t   = 5.2,
    tongue_w  = 4.6,
    tongue_h  = 5.0,
    tongue_ex = 2.5,
    lip_t     = 2.5,
    lip_drop  = 8.0,

    lead_in = 1.5
) {
    pw = item_w + fit_clear;
    pd = item_t + fit_clear;

    outer_w  = pw + 2 * wall;
    pocket_y = plate_t;
    front_y  = pocket_y + pd + wall;

    hook_z = plate_h - 16;
    eps    = 0.01;

    /* Board face sits at y = 0. The holder lives at +y, the hook reaches
       to -y through the slot. */
    module plate() {
        translate([-outer_w / 2, 0, 0])
            cube([outer_w, plate_t, plate_h]);
    }

    module pocket_block() {
        translate([-outer_w / 2, 0, 0])
            cube([outer_w, front_y, pocket_h]);
    }

    module pocket_void() {
        translate([-pw / 2, pocket_y, wall])
            cube([pw, pd, pocket_h + 1]);
    }

    /* Flares the pocket mouth so the item drops in without hunting for it. */
    module mouth() {
        translate([0, pocket_y + pd / 2, pocket_h])
            hull() {
                translate([0, 0, -eps])
                    cube([pw, pd, eps], center = true);
                translate([0, 0, lead_in])
                    cube([pw + 2 * lead_in, pd + 2 * lead_in, eps],
                         center = true);
            }
    }

    module hook() {
        translate([-tongue_w / 2, -(board_t + tongue_ex), hook_z])
            cube([tongue_w, board_t + tongue_ex + eps, tongue_h]);
        translate([-tongue_w / 2, -(board_t + tongue_ex),
                   hook_z - lip_drop])
            cube([tongue_w, lip_t, lip_drop + tongue_h]);
    }

    difference() {
        union() {
            plate();
            pocket_block();
            hook();
        }
        pocket_void();
        mouth();
    }
}
