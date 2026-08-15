"""Report downward-facing facets in an STL, grouped by Z.

Flat facets whose normal points down are overhangs. Anything above z=0 that is
not backed by material below will droop or be flagged by the slicer. Steep but
non-horizontal faces are reported separately so 45 degree gussets (fine) can be
told apart from true 90 degree overhangs (not fine).

    python3 tools/overhangs.py part.stl [max_angle_ok]
"""
import math
import sys
from collections import defaultdict

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from xsect import load


def normal(a, b, c):
    u = (b[0] - a[0], b[1] - a[1], b[2] - a[2])
    v = (c[0] - a[0], c[1] - a[1], c[2] - a[2])
    n = (u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0])
    m = math.sqrt(sum(x * x for x in n))
    return None if m == 0 else tuple(x / m for x in n)


def area(a, b, c):
    u = (b[0] - a[0], b[1] - a[1], b[2] - a[2])
    v = (c[0] - a[0], c[1] - a[1], c[2] - a[2])
    n = (u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0])
    return math.sqrt(sum(x * x for x in n)) / 2


def main(path, ok_deg=50.0):
    tris = load(path)
    groups = defaultdict(list)
    for t in tris:
        n = normal(*t)
        if n is None or n[2] >= -0.001:
            continue
        # angle of the face from horizontal: 90 = vertical wall, 0 = flat down
        tilt = math.degrees(math.asin(min(1.0, -n[2])))
        zs = [v[2] for v in t]
        if max(zs) < 0.05:
            continue
        groups[round(min(zs), 3)].append((tilt, area(*t), t))

    print(f"{path}\n")
    print(f"{'z':>8} {'tilt':>7} {'area':>9}   x-range            y-range")
    print("-" * 66)
    flagged = []
    for z in sorted(groups):
        for tilt, a, t in sorted(groups[z], key=lambda r: -r[1]):
            if a < 1.0:
                continue
            xs = [v[0] for v in t]
            ys = [v[1] for v in t]
            mark = "  <-- FLAT OVERHANG" if tilt > ok_deg else ""
            if mark:
                flagged.append((z, a, min(xs), max(xs), min(ys), max(ys)))
            print(f"{z:8.2f} {tilt:6.1f}d {a:9.1f}   "
                  f"[{min(xs):7.2f},{max(xs):7.2f}]  [{min(ys):7.2f},{max(ys):7.2f}]{mark}")
    print()
    if flagged:
        print(f"{len(flagged)} flat-ish downward facets above the bed:")
        for z, a, x0, x1, y0, y1 in flagged:
            print(f"   z={z:6.2f}  area={a:8.1f}  x[{x0:7.2f},{x1:7.2f}] y[{y0:7.2f},{y1:7.2f}]")
    else:
        print("No flat downward-facing facets above the bed.")


if __name__ == "__main__":
    main(sys.argv[1], float(sys.argv[2]) if len(sys.argv) > 2 else 50.0)
