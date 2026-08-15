# Working in this repo

Parametric OpenSCAD mounts for a Bambu Lab A1. Read [README.md](README.md) for
what the parts are; this file is about how to work on them.

## Read these before designing anything

- [docs/design-notes.md](docs/design-notes.md) - every rule here was paid for by
  a part that printed and did not fit. Read the library section for whichever
  module you are touching **before** changing it.
- [docs/printer.md](docs/printer.md) - printer operation, MCP setup, and the
  BambuStudio quirks that have wasted time before.

## Secrets

Printer host, serial, MAC and the LAN access code are in `.envrc`, which is
**gitignored**. They must never appear in a tracked file. `docs/printer.md`
uses `<PRINTER_HOST>`, `<BAMBU_SERIAL>`, `<BAMBU_TOKEN>` placeholders; keep it
that way.

## Get dimensions from the device, never from a bin

Both Gridfinity bins in `reference/` turned out to be for **different devices**
than the folder names suggested, and two parts were printed to the wrong size
before that surfaced. Order of preference:

1. Manufacturer spec sheet (Lindy 43202, Apple, Lenovo all publish theirs)
2. The user measures with calipers
3. Nothing else. A downloaded bin is not evidence.

When measuring is needed, ask for named dimensions with a diagram. Ambiguous
single numbers have caused several wrong revisions - "the span", "the width",
"41" all meant something other than what was assumed.

## Verify by measurement, not by looking

A render will not show a silent bounding-box change, an unsupported flange, or a
lean tilting the wrong way. After **every** geometry change:

```bash
bambu-studio --info part.stl                # bbox, manifold, volume
python3 tools/overhangs.py part.stl         # unsupported downward faces
python3 tools/xsect.py part.stl 10 20 30    # internal geometry
```

`bambu-studio --info` drops a `result.json` in the working directory; delete it.

## Asymmetric mounts need a mirrored pair - ship BOTH STLs

If a mount has a wall on only **one** long face, its two halves are **not
identical**. Printing two of the same file puts the solid wall against the port
face at one end, which is the exact thing the design existed to avoid. This was
printed wrong before it was caught.

```
lib/end_cup.scad      asymmetric - wall on one face only  -> mirrored pair
lib/end_bracket.scad  symmetric  - walls on both faces    -> identical pair
lib/saddle.scad       symmetric  - open at both ends      -> identical pair
lib/laptop_foot.scad  symmetric                           -> identical pair
```

**Do not rely on a slicer mirror step.** Ship both halves as separate files, as
`models/lindy-dock/` does with `cup.scad` and `cup-mirrored.scad`. An
instruction in a README is a failure mode; two files cannot be forgotten.

Mirror across **Y** (`mirror([0,1,0])`): it moves the end wall to the far end
while keeping the side wall on the same long face. Rotating 180 degrees instead
swings the wall onto the port face. Verify with `tools/xsect.py` on both halves
and check the end wall swaps ends while the side wall does not.

## Safety

Printer control tools act on real hardware immediately. Check
`get_printer_status` for an active job before any of them, and confirm before
starting, cancelling or heating anything. Read-only tools need no confirmation.

## Conventions

- Geometry lives in `lib/`; per-device files supply dimensions and one call.
- Export binary STL: `openscad --export-format binstl -o out.stl in.scad`.
- Keep per-device comments explaining any parameter overridden from the library
  default, and why.
- No em dashes in anything committed. Plain hyphens.
