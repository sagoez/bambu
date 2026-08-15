# Design notes

Everything learned building the parts in `models/`. The rules here were paid
for: most of them come from a part that was printed and did not fit.

## Tooling

**OpenSCAD** `/usr/bin/openscad` 2021.01 (user installed it, extra/openscad).

Binary STL export is available and preferred (about 3x smaller):

```bash
openscad --export-format binstl -o part.stl part.scad
```

Plain `-o part.stl` writes ASCII. **Format is only a size preference.**
BambuStudio parses both identically - verified with `bambu-studio --info` on
each, same facet count, same volume, `manifold = yes`. Do not chase STL format
when a model fails to appear; check the GUI first (see below).

**Verify a mesh without the GUI:**

```bash
bambu-studio --info part.stl
```

Prints bbox, facet count, `manifold`, `number_of_parts` and volume. Run it after
every geometry change - it catches silent bounding-box growth that a render
does not show. It drops a `result.json` into the working directory; delete it.

`tools/xsect.py` complements this: `--info` gives the bounding box, xsect gives
the internal geometry.

**`tools/overhangs.py`** reports every downward-facing facet with tilt, area and
xy location, so unsupported flange undersides can be found without slicing:

```bash
python3 tools/overhangs.py part.stl
```

Anything marked FLAT OVERHANG on a flange is a real defect. Window ceilings also
show up and are fine, since they are bridges anchored on both sides.

**Loading an STL into the GUI: use Ctrl+I, not Ctrl+O.** File > Open Project
(Ctrl+O) filters for `.3mf` only, so an STL is invisible in the dialog. Meshes
come in through File > Import > Import Geometry (Ctrl+I), which accepts
STL/OBJ/STEP. This was the actual cause of a long "the file will not open"
detour. Two wrong theories were chased first (ASCII STL format, then a Wayland
GTK crash) before the file filter turned out to be it.

The GUI does emit `gtk_window_resize: assertion 'width > 0' failed` and
`WIDGET_REALIZED_FOR_EVENT` assertions on startup under Wayland. They are noisy
but harmless - the GUI runs fine. Do not treat them as a crash.

Launching from a tool call: `nohup ... &` gets reaped when the shell exits. Use
`setsid --fork`. But `pgrep bambu-studio` returning nothing shortly after launch
is not proof of a crash - check with the user before concluding that.

**`tools/xsect.py`** cross-sections an STL at given Z heights and reports closed
loops with bbox and area. This is how internal cavities get measured, since
`get_stl_info` only returns a bounding box:

```bash
python3 tools/xsect.py some.stl 2 10 20 25
```

Handles both ASCII and binary STL. Its loop-joiner is naive and merges touching
outer/inner boundaries into one traversal, so read the reported *area* as a
sanity check rather than trusting loop counts.

Also installed: `ffmpeg` (camera snapshots), BambuStudio `/usr/bin/bambu-studio`.

## NEVER size a part from a Gridfinity bin

**Both bins in this project turned out to be for different devices.** The
cavities were measured accurately; they simply were not the cavities of the
devices being designed for.

```
                bin cavity said    device actually is    error
Lindy 43202     205.91 x 92.90     185 x 79              21 and 14 mm
SPGUARD charger 154.20 x 121.55    unknown, but far smaller
```

The Lindy saddle and the charger saddle were both printed and both failed to
fit. The one dimension that was right in each case was the one the user
measured off the device by hand.

**Get dimensions from the manufacturer's spec page, or have the user measure.**
A downloaded bin tells you the footprint of whatever its author was storing, and
the folder name is not evidence - `models/lindy-dock` was not sized for a
Lindy.

Bins are still useful for confirming a device is Gridfinity-adjacent and for
reading a *shape*, never for a dimension a part is built to.

## Gridfinity decoding

The two source models are Gridfinity. To confirm a model is Gridfinity, check:

- Footprint is `n * 42 - 0.5` mm. 167.5 = 4x42-0.5. 251.5 = 6x42-0.5.
- Geometry below z=0 with depth **4.75 mm** - the standard base sweep
  (0.8 + 1.8 + 2.15). This is the foot, not a modelling error.
- Cross-sectioning below z=0 resolves into 39.5 mm squares on a 42 mm pitch.

## Source models

Both are `body_1.stl` + `body_2.stl` pairs. **`body_1` is the pocket floor
plate, not a colour inlay** - its bounding box equals the cavity footprint
exactly. There is no two-colour intent, so the missing AMS is not a blocker.

| | outer | cavity = device W x D | cavity floor | depth |
|---|---|---|---|---|
| models/spguard-charger | 167.5 x 167.5 (4x4) | 154.20 x 121.55 | z=1.415 | 25.0 |
| models/lindy-dock | 125.5 x 251.5 (3x6) | 92.90 x 205.91 | z=1.415 | 25.0 |

Device heights are **not** derivable from these files - the bin only cradles the
bottom 25 mm. Ask. Lindy device height is 28.62 mm; the gray one is unknown.

## Bracket library - lib/end_bracket.scad

**This section is device-independent. Per-device numbers live under Devices.**

Makes one under-desk end bracket. **Print two per device**: they are identical,
not mirrored, and the second installs rotated 180 degrees. Each cups one short
end, the two are screwed to the desk at whatever spacing suits, and the middle
of the device is open on all four sides.

A per-device file is thin:

```openscad
use <../lib/end_bracket.scad>
$fn = 48;
end_bracket(device_w = 92.90, device_h = 28.62,
            button_from_end = 26.695, button_from_edge = 15.865);
```

Only `device_w` and `device_h` are required. Everything else defaults.

`bracket_d` (40) sets how far along the device each bracket reaches. The
unsupported middle span is not a concern for a rigid device; `bracket_d` only
needs to be enough to stop it tipping out.

**The install trade.** Two brackets move fit tolerance off the print and onto
the desk: screw spacing absorbs any error in the device length, so that
dimension stops having to be right. In exchange they must be screwed down
**square to each other** or the device sits crooked. Alignment moved from the
print to the install. A paper template from the STL helps if that matters.

### Design rules, learned the hard way

- **Load path.** The floor carries the device; the desk underside caps it.
  Nothing clamps. Wall tops stand proud of the device by `head_gap` so *they*,
  not the device, bear against the desk.
- **Flange chamfers must be CONTINUOUS, never discrete gussets.** This took
  three attempts to get right. A flange is anchored to the wall on **one edge
  only**, so the gaps between discrete gussets are *cantilevers*, not bridges,
  and they droop. Two gussets per side left 1409 mm2 of flat overhang at the
  flange underside; adding a third diagonal one did not help because the problem
  was never the corner. `gusset_x`/`gusset_y` now run the full length, which
  leaves zero downward-facing flat surface.
- **The corner square needs a solid pyramid, not a fin.** Where the two flange
  legs meet, the square sits diagonally outside the body corner and no
  orthogonal chamfer reaches it. A thin diagonal gusset only covers a strip.
  `gusset_corner()` hulls the whole square down to the body corner, dropping by
  `sqrt(flange_w^2 + wrap_w^2)` so every face of the pyramid is at least
  45 degrees.
- **Verify with `tools/overhangs.py`, do not eyeball it.** It reports every
  downward-facing facet with tilt, area and location. Window ceilings show up
  and are fine (true bridges, anchored both sides); anything on a flange
  underside is not. Reasoning about which overhangs "will bridge fine" was
  wrong twice here.
- **Corner flanges force both short ends closed.** An L-flange needs solid wall
  under both legs, so an open end cannot carry one. Corner flanges and slide-in
  loading are mutually exclusive; picking flanges means the device drops in from
  above before the part goes up.
- **Print floor-down. Do not reorient.** Best bed contact, and it puts load
  across layers rather than along them. Standing a bracket on its end face
  trades an overhang for a tippy tower on a 3 mm wall. If the slicer complains
  about overhangs, fix the geometry.
- **`footprint_clip()` is not decoration.** A diagonal gusset is thick
  perpendicular to its own axis, so its corners escape the flange outline and
  silently grow the bounding box (135.30 x 53.00 became 138.21 x 55.62 the
  moment `gusset_diag` was added). The model is wrapped in `intersection()` with
  it. **Check `bambu-studio --info` size after touching any gusset** - a render
  will not show this.
- **Watch what the flanges add to the bounding box.** `wrap_w` (10) is
  deliberately shallower than `flange_w` (18). Symmetric 18 mm wraps put the
  earlier one-piece cradle at 248.31 mm in Y, back inside the bed-sling margin
  the redesign existed to escape. Two short brackets have far more headroom, but
  the rule stands: after changing `flange_w` or `wrap_w`, check the result
  against the 256 mm bed, and prefer the long axis on X since the A1 slings Y.
- **`fit_clear` (0.4) is not optional.** Gridfinity cavities are modelled with
  zero clearance, which works for dropping a part in from above and fails for
  anything that slides. Do not "restore" the original pocket size.
- **Gussets are for printability, not strength.** Flanges are 90 degree
  overhangs off a vertical wall; the 45 degree gussets are what let the part
  print without support.
- **Windows must land clear of gussets** so every gusset sits on solid wall.
  Changing `side_win` or `end_win` can break this silently.
- **Buttons and ports on the face that ends up against a bracket are a
  structural problem, not just an access one.** If a button lands on the floor
  rim, the device rests on it and holds it pressed. Measure before printing;
  `button_from_end` / `button_from_edge` cut a through-hole so the button
  protrudes and can be pressed directly. The relief is cut on both long edges so
  the bracket stays one identical part either way round.

### Slicing

Import with **Ctrl+I**. 0.2 mm layers, 4 perimeters, 25-30% infill, no support,
as-oriented. PLA works but creeps under sustained load when warm; PETG is the
reprint if anything ever sags.

## Symmetry: which mounts need a mirrored pair

A mount with a wall on only **one** long face has two halves that are **not
identical**. Two identical prints put the solid wall against the port face at
one end.

| module | symmetry | pair |
|---|---|---|
| `end_cup` | wall on one face only | **mirrored**, two files |
| `end_bracket` | walls on both faces | identical |
| `saddle` | open at both ends | identical |
| `laptop_foot` | symmetric | identical |

Mirror across **Y** (`mirror([0,1,0])`) - it moves the end wall to the far end
while keeping the side wall on the same long face. Rotating 180 degrees swings
the wall onto the port face instead.

Ship both halves as separate STLs rather than telling someone to mirror in the
slicer. `models/lindy-dock` does this with `cup.scad` and `cup-mirrored.scad`.
The instruction-in-a-README version was tried first and produced two wrong
parts.

Verify by cross-sectioning both halves at the same Z: the end wall should swap
ends, the side wall should not move.

## Saddle library - lib/saddle.scad

**Also device-independent.** Use this instead of `end_bracket` when the device
has ports or connectors on faces an end bracket would cover.

A saddle is a U-channel strap that passes under the device and up two opposite
faces, with a flange on top of each wall. **No end walls**, so it grips a band
across the middle rather than cupping an end. Print two.

```openscad
use <../lib/saddle.scad>
saddle(device_w = 121.55, device_h = 40.07, saddle_w = 25.0);
```

`device_w` is the span between the two walls; `saddle_w` is the strap width.

### Choosing between the two

| | end_bracket | saddle |
|---|---|---|
| Grips | the two short ends | a band across the middle |
| Needs | two opposite faces free | one opposing *pair* free |
| Leaves open | both long faces | both ends, and the middle of both long faces |
| Retention | end walls stop lengthwise slide | gravity and the two walls only |

If a device has ports on three faces, `end_bracket` cannot work whichever way it
is turned - there is no free opposing pair for the end walls. That is what
forced the saddle into existence.

The saddle is much lighter: 15.60 cm3 versus 35.90 for an end bracket, because
it has no end walls, no corner squares and therefore none of the L-flange
gusset machinery. It is also **weaker in retention** - nothing stops the device
sliding out along the strap axis except gravity and friction. Fine hanging under
a desk, wrong for anything that gets pushed or pulled.

The continuous-chamfer rule carries over unchanged, and so does everything under
"Design rules, learned the hard way" that is not specific to corner flanges.

## Laptop foot library - lib/laptop_foot.scad

**Device-independent.** Twin-slot foot for two laptops stood on edge, closed.
Print two; they are identical and sit under the two ends.

```openscad
use <../lib/laptop_foot.scad>
laptop_foot(front_t = 16.13, back_t = 16.80);
```

### Design rules

- **Check which way the lean actually goes. `rotate([lean,0,0])` tilts the slot
  toward -Y, not +Y.** Rotating about X by a positive angle maps
  `y' = y*cos - z*sin`, so as the slot rises it moves toward the *front*. The
  code uses `rotate([-lean,0,0])` to lean back into the tail. This was wrong for
  four revisions; every stability figure computed before the fix was against
  geometry that did not exist, and **the renders looked correct the whole time** -
  a 12 degree lean reads the same either way at a glance. Verify with
  `tools/xsect.py` at two heights and watch which way the rib moves.
- **Leaning throws the centre of mass off the base.** A 16" laptop leaning 12
  degrees puts its CoM ~26 mm behind its slot. Without `back_margin` and the
  tail, a compact base tips over backwards with the big laptop alone. Always
  recompute the single-heaviest-laptop case, not just both-loaded - removing the
  lighter machine is the worst case, not the best.
- **The lean also tapers the fins.** The slot face is furthest forward at the
  bottom, so whichever fin the slot leans away from is thinnest at its base -
  exactly where a cantilever is most loaded. Read `front_margin` as thickness at
  the top and subtract roughly `slot_depth * tan(lean)` for the base. At
  `front_margin = 12` the base measured ~6 mm.
- **Keep the lean anyway.** A vertical slot lets the laptop rock through the
  slot clearance; the lean makes it settle against one face and stay there. It
  is what stops the wobble, and the tail is the price.
- **Profile is a fin, not a wedge**: rises from the front, peaks just behind the
  rear slot, sweeps down to a low tail. The tail buys anti-tip footprint without
  the visual mass of a block.
- **Do not "hollow" a bulky part to save filament.** At 15% infill the slicer
  already leaves the interior mostly air; modelling a cavity adds perimeter
  walls around it and can use *more* filament. Lower the infill or shrink the
  part instead.

## Devices

### models/lindy-dock - cup.scad

Uses `lib/end_cup.scad`, not `lib/end_bracket.scad`. An end bracket runs side
walls in from each end along **both** long faces, and the Lindy's ports run the
full length of one long face with the DC 20V jack and the PD port right at the
corners - they would be buried. The cup has a wall on the clear long face only.

Earlier attempts (`cage.scad`, `end_bracket.scad`) have been deleted.

**Print two, MIRRORED.** BambuStudio: duplicate, then Mirror along **Y**.
Rotating 180 degrees instead puts the side wall on the port face.

Cup: 113.40 x 52.00 x 32.10 mm, 41.11 cm3 each, 82.2 cm3 the pair. Three screws
per cup - two on the full-length side flange, one on the end-wall stub.

**Rule this generalises to:** before choosing a mount type, work out which
faces are actually free. Ports on three faces forced the saddle for the charger;
ports along one whole long face forced the cup here. Only a device with a clear
opposing pair suits `end_bracket`.

### models/lindy-dock - device data

Lindy 2-port Type-C KVM docking station. `end_bracket.scad` -> `end_bracket.stl`.

| | |
|---|---|
| Device | **185 x 79 x 28.7**, 0.926 kg (Lindy 43202, official spec) |
| Bracket | 113.40 x 53.00 x 32.10, 33.87 cm3 |
| Pair | 67.75 cm3, ~46 g PLA |

Dimensions are from Lindy's own product page for model **43202**, not from the
Gridfinity bin. The first version was built to the bin's 205.91 x 92.90 and was
oversized by 21 and 14 mm. Height 28.7 matches the 28.62 measured by hand,
which is how the discrepancy was eventually caught.
| Vents | none on either large face (confirmed) |

**Mounts upside down** so the POWER/SWITCH button faces the floor and stays
reachable. Button is 11.41 mm diameter, 20.99 mm from the short end and 10.16 mm
from the long edge to its near side, so centre 26.695 / 15.865. It overhung the
plain floor rim by 2.4 mm lengthwise and cleared the side rim by 0.36 mm, so
both axes needed the relief. 16 mm hole gives 2.29 mm all round.

### models/spguard-charger - done

**SPGUARD multi-port GaN desktop charger.** `saddle.scad` -> `saddle.stl`.

| | |
|---|---|
| Device | 154.20 x 121.55 x **41.0** (incl. rubber feet; 40.07 bare body) |
| Saddle | 155.95 x 25.00 x 44.40, 16.54 cm3 |
| Pair | 33.09 cm3, ~23 g PLA |

**Use the height INCLUDING the feet.** The charger rests on its feet, so 41.0 is
the real dimension the pocket must clear. Sizing to the 40.07 bare body would
leave the device standing proud of the wall tops, bearing against the desk
itself - exactly what `head_gap` exists to prevent. When a device has feet,
always take the over-feet height.

`rim` is raised from the 7.0 default to 8.5, narrowing the floor slot to 8 mm so
a rubber foot cannot drop into it and rock the charger. Airflow is unaffected;
the straps already leave ~68% of the underside open.

**Ports on three faces**: PD/C1-C2 on one short end, P1-P4 across the front,
PD/C3-C4 on the other short end. Only the back is clear, and it carries the
power cable. There is **no free opposing pair**, which is why `end_bracket` is
unusable here and `lib/saddle.scad` exists.

Strap placement, measured along the 154.20 length from each corner:

```
0  -> 16 mm    keep clear, plugged cables need the room
16 -> 41 mm    the strap sits here
```

Hence `saddle_w = 25`, each strap inset 16 mm, leaving a 72.2 mm open span
between them.

Heat matters on this one: high-wattage GaN, underside is the likely vent face.
Two 25 mm straps under a 154.20 mm device leave ~68% of the underside open, and
the floor is cut back to a rim on top of that. Do not widen the straps without
thinking about that.

**Identify the device before designing.** The bin gives a footprint and nothing
else - no port cutouts, no orientation clue. Guessing the layout from a stock
photo would have produced a bracket that covered four ports.

### laptop-stand - done

MacBook Pro 16" M4 + ThinkPad P14s Gen 6 AMD, stood on edge side by side.
`foot.scad` -> `foot.stl`. **Print two.**

| | width | depth | thickness |
|---|---|---|---|
| MacBook Pro 16" M4 | 355.7 | 248.1 | 16.8 uniform |
| ThinkPad P14s Gen 6 AMD | 315.9 | 223.7 | 16.13 rear, 10.9 front |

Foot: 78.0 x 117.5 x 52.1 mm, 269.5 cm3 each. This is by far the biggest print
in the project - roughly 100 g and several hours per foot.

**The ThinkPad is a wedge.** The taper runs along its 223.7 mm depth and the
slot engages only ~30 mm of it, so thickness varies ~0.65 mm inside the slot.
Sized for the REAR edge: **stand it hinge-down**. Front-edge-down would leave
~5 mm of rattle. MacBook goes at the back, being taller on edge.

Neither laptop has a case, so slots are sized bare: 17.43 and 18.10 mm.

`foot_w` (78) and `h_tail` (24) are well above library defaults by choice - the
defaults read as thin for something carrying a 16" machine. `front_margin` (22)
and `slot_gap` (18) are raised for the taper reason in the library notes.

**Placement: 200-250 mm centre to centre.** Both machines must sit in both feet
and the ThinkPad is the shorter at 315.9 mm, so wider spacing leaves it unable
to reach both.

A single-piece stand IS printable - it need only be ~200 mm, not the full
355.7 mm laptop length - but costs ~30% more filament since you print the gap
too, and one failure loses the lot. Two feet chosen deliberately.

### skadis-ruler - done

SKADIS pegboard holder for a 50 cm ruler, measured 39.90 x 4.0 mm.
`holder.scad` -> `holder.stl`. **Print one.** 46.9 x 18.7 x 82.0 mm, 21.8 cm3.

Ruler stands vertically in an open-topped pocket, flat face against the board,
retained by gravity. Lift straight out. Mount it low on the board: a 50 cm rule
is ~530 mm and a standard SKADIS is 560 mm tall.

**Print rotated 90 degrees about Y, on its side.** Upright leaves the hook
underside as a 4.6 x 5.2 mm flat cantilever, and droop there could stop it
passing through the 5 mm slot. On its side the only downward face is the pocket
ceiling, a 5 mm bridge anchored both sides.

## SKADIS geometry

```
slot     5 mm wide x 15 mm tall, vertical oval
board    5.0 - 5.2 mm thick
pitch    DISPUTED - sources say 20 mm and 40 mm
```

`lib/skadis_holder.scad` engages **one slot only**, deliberately, so the pitch
does not matter and it fits any board. Cost: it can pivot about that point, so
the back plate is oversized to bear on the board and damp it. If a two-slot
version is ever needed, measure the actual board first - do not trust either
published figure.

Hook fits by tilting the holder up, pushing the tongue through the slot, then
lowering. The slot is 15 mm against a 5 mm tongue, giving 10 mm of drop for the
rear lip to land behind the board.

## Known quirks

- `get_printer_status` returns `status: "UNKNOWN"` with empty `modules` and zero
  temperatures on a short-lived connection. The A1 pushes full state on an
  interval. `connected: true` is the real signal that auth succeeded. A
  long-lived session returns full data.
- The server reports `model: "A1M"` for this printer even though it is an A1,
  not an A1 mini. Do not use that field to tell them apart.
- `get_printer_filaments` returns `trays: []` on this printer because it walks
  AMS slots only. With no AMS the spool data is in
  `get_printer_status` -> `raw.vt_tray`. Read that for filament matching, or
  AMS mapping will be silently wrong.
- `raw.chamber_temper` reports a constant (~5) and is meaningless. The A1 is
  open-frame with no chamber sensor.
- BambuStudio CLI export flags take the filename attached to the flag, not via
  `-o`: `--export-3mf out.3mf in.stl`. Passing `-o out.3mf` makes it treat the
  output name as a missing input and fail with `return -3`.
