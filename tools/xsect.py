"""Cross-section a binary STL at given Z heights and report closed loops.

Outer loop = outer wall; inner loops = cavities. Reports bbox and signed area
so we can tell the device pocket from the wall.
"""
import struct
import sys
from collections import defaultdict


def load(path):
    with open(path, "rb") as f:
        head = f.read(5)
        f.seek(0)
        if head == b"solid":
            tris, cur = [], []
            for line in f:
                p = line.split()
                if p and p[0] == b"vertex":
                    cur.append(tuple(float(v) for v in p[1:4]))
                    if len(cur) == 3:
                        tris.append(tuple(cur))
                        cur = []
            if tris:
                return tris
            f.seek(0)
        f.read(80)
        (n,) = struct.unpack("<I", f.read(4))
        tris = []
        for _ in range(n):
            d = struct.unpack("<12fH", f.read(50))
            tris.append(((d[3], d[4], d[5]), (d[6], d[7], d[8]), (d[9], d[10], d[11])))
    return tris


def section(tris, z):
    """Return list of (p0, p1) segments where triangles cross plane z."""
    segs = []
    for tri in tris:
        below = [v for v in tri if v[2] < z]
        above = [v for v in tri if v[2] > z]
        if not below or not above:
            continue
        pts = []
        for i in range(3):
            a, b = tri[i], tri[(i + 1) % 3]
            if (a[2] - z) * (b[2] - z) < 0:
                t = (z - a[2]) / (b[2] - a[2])
                pts.append((a[0] + t * (b[0] - a[0]), a[1] + t * (b[1] - a[1])))
        if len(pts) == 2:
            segs.append(tuple(pts))
    return segs


def build_loops(segs, tol=1e-4):
    q = 1.0 / tol
    key = lambda p: (round(p[0] * q), round(p[1] * q))
    adj = defaultdict(list)
    for a, b in segs:
        adj[key(a)].append((key(b), b))
        adj[key(b)].append((key(a), a))
    coord = {}
    for a, b in segs:
        coord[key(a)] = a
        coord[key(b)] = b

    seen = set()
    loops = []
    for start in list(adj):
        if start in seen:
            continue
        loop, cur, prev = [], start, None
        while cur is not None and cur not in seen:
            seen.add(cur)
            loop.append(coord[cur])
            nxt = None
            for k, _ in adj[cur]:
                if k != prev and k not in seen:
                    nxt = k
                    break
            prev, cur = cur, nxt
        if len(loop) >= 3:
            loops.append(loop)
    return loops


def area(loop):
    s = 0.0
    for i in range(len(loop)):
        x0, y0 = loop[i]
        x1, y1 = loop[(i + 1) % len(loop)]
        s += x0 * y1 - x1 * y0
    return s / 2.0


def report(path, zs):
    tris = load(path)
    zmin = min(v[2] for t in tris for v in t)
    zmax = max(v[2] for t in tris for v in t)
    print(f"\n=== {path.split('/')[-2]}/{path.split('/')[-1]}  (z {zmin:.2f} .. {zmax:.2f}) ===")
    for z in zs:
        if not (zmin < z < zmax):
            continue
        loops = build_loops(section(tris, z))
        loops = [l for l in loops if abs(area(l)) > 5.0]
        loops.sort(key=lambda l: -abs(area(l)))
        print(f"\n  z = {z:6.2f}   ({len(loops)} loops)")
        for l in loops[:6]:
            xs = [p[0] for p in l]
            ys = [p[1] for p in l]
            w, d = max(xs) - min(xs), max(ys) - min(ys)
            print(f"     {w:7.2f} x {d:7.2f} mm   area {abs(area(l)):9.1f}   "
                  f"x[{min(xs):7.2f},{max(xs):7.2f}] y[{min(ys):7.2f},{max(ys):7.2f}]")


if __name__ == "__main__":
    zs = [float(a) for a in sys.argv[2:]]
    report(sys.argv[1], zs)
