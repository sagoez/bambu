# bambu

3d blueprints for my home office.

Parametric OpenSCAD parts for a Bambu Lab A1, plus the mesh-inspection tools
used to verify them before printing.

Everything here is a functional mount for a specific object that was measured,
not a decorative model. Each part is a thin per-device file supplying
dimensions to a reusable library module.

## Parts

| Part | Holds | Qty | Volume |
|---|---|---|---|
| [`models/lindy-dock`](models/lindy-dock) | Lindy 43202 KVM dock, under a desk | 2, **mirrored** | 41.1 cm3 ea |
| [`models/spguard-charger`](models/spguard-charger) | SPGUARD GaN charger, under a desk | 2 | 15.2 cm3 ea |
| [`models/laptop-stand`](models/laptop-stand) | MacBook Pro 16" + ThinkPad P14s, on edge | 2 | 269.5 cm3 ea |
| [`models/skadis-ruler`](models/skadis-ruler) | 50 cm ruler, on an IKEA SKADIS pegboard | 1 | 21.8 cm3 |

## Libraries

Three mount types, and which one a device needs is decided by **where its ports
are**, not by its size:

| Free faces | Module | Shape |
|---|---|---|
| A clear opposing pair | [`lib/end_bracket.scad`](lib/end_bracket.scad) | Cups both short ends |
| Ports on three faces | [`lib/saddle.scad`](lib/saddle.scad) | Straps across the middle, ends fully open |
| Ports along one whole long face | [`lib/end_cup.scad`](lib/end_cup.scad) | Wall on the clear face only |

Plus [`lib/laptop_foot.scad`](lib/laptop_foot.scad) (twin-slot leaning foot) and
[`lib/skadis_holder.scad`](lib/skadis_holder.scad) (single-slot pegboard pocket).

## Building

Requires OpenSCAD. Always export **binary** STL:

```bash
openscad --export-format binstl -o models/lindy-dock/cup.stl \
                                  models/lindy-dock/cup.scad
```

A per-device file is thin - dimensions and one call:

```openscad
use <../../lib/end_cup.scad>
$fn = 48;
end_cup(device_w = 79.00, device_h = 28.70,
        button_from_end = 26.695, button_from_edge = 15.865);
```

## Verifying

Renders hide the failures that matter. Three checks, in order:

```bash
bambu-studio --info part.stl        # bbox, manifold, volume, part count
python3 tools/overhangs.py part.stl # unsupported downward faces
python3 tools/xsect.py part.stl 10 20 30   # internal geometry at Z heights
```

`--info` catches silent bounding-box growth after a geometry change.
`overhangs.py` distinguishes a genuine flange cantilever from a window ceiling,
which is a bridge and fine. `xsect.py` is the only way to measure an internal
cavity or confirm which way a leaning slot actually leans.

## The rules that cost the most

Full detail in [`docs/design-notes.md`](docs/design-notes.md).

- **Never size a part from a Gridfinity bin.** Both bins here were for other
  devices. Use the manufacturer's spec sheet, or measure.
- **Flange chamfers must be continuous, never discrete gussets.** A flange is
  anchored on one edge only, so gaps between gussets are cantilevers, not
  bridges, and they droop.
- **Check which way a lean actually goes.** `rotate([lean,0,0])` tilts toward
  -Y, not +Y. A 12 degree lean looks identical either way in a render.
- **Take the over-feet height.** A device rests on its feet, so that is the
  dimension a pocket has to clear.
- **A button or port on a contact face is structural**, not merely an access
  problem. The device will rest on it.

## Layout

```
lib/        reusable parametric modules
models/     per-device files and their STLs
tools/      mesh inspection
docs/       design notes and printer setup
reference/  third-party Gridfinity bins, not redistributed (gitignored)
```

## Licence

Parts and tools here are original work. `reference/` holds third-party models
downloaded elsewhere; they are excluded from the repo and carry their own
licences.
