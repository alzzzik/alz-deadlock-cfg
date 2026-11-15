#!/usr/bin/env python3
"""Lint a Deadlock gameinfo.gi against Valve's stock file and the convar dump.

Usage:  python3 tools/lint.py <gameinfo.gi> [--catalog catalog.json] [--video video.txt]

Reports every ConVars line that cannot do what it says: removed from the game, blocked
(gameinfo_cannot_override), server-replicated, outside min/max, equal to the default,
set twice, archive-flagged (a saved value wins) or owned by video.txt. Also lists every
edit outside ConVars, marking the sections Valve's matchmaking message names.

The catalog is Deadlock Mod Manager's perf catalog (convar dump + stock gameinfo history).
Without --catalog it is downloaded from GitHub.
"""
import collections, json, sys, urllib.request

CATALOG_URL = ("https://raw.githubusercontent.com/deadlock-mod-manager/deadlock-mod-manager/"
               "main/packages/perf-catalog/data/catalog.json")


def tokenize(t):
    i, n = 0, len(t)
    while i < n:
        ch = t[i]
        if ch.isspace():
            i += 1
        elif t.startswith("//", i):
            j = t.find("\n", i)
            i = n if j < 0 else j
        elif ch in "{}":
            yield ch
            i += 1
        elif ch == '"':
            j = t.index('"', i + 1)
            yield ("s", t[i + 1:j])
            i = j + 1
        else:
            j = i
            while j < n and not t[j].isspace() and t[j] not in '{}"' and not t.startswith("//", j):
                j += 1
            yield ("s", t[i:j])
            i = j


def parse(t):
    toks, pos = list(tokenize(t)), 0

    def block():
        nonlocal pos
        out = []
        while pos < len(toks):
            tk = toks[pos]
            if tk == "}":
                pos += 1
                return out
            if tk == "{":
                raise SyntaxError("unexpected {")
            key = tk[1]
            pos += 1
            if pos >= len(toks):
                raise SyntaxError(f"key {key!r} has no value")
            nx = toks[pos]
            pos += 1
            if nx == "{":
                out.append((key, block()))
            elif nx == "}":
                raise SyntaxError(f"key {key!r} has no value")
            else:
                out.append((key, nx[1]))
        return out

    tree = block()
    if t.count("{") != t.count("}"):
        raise SyntaxError("unbalanced braces")
    return tree


def flat(tree, pre=()):
    for k, v in tree:
        if isinstance(v, list):
            yield from flat(v, pre + (k,))
        else:
            yield pre + (k,), v


def norm(v):
    v = str(v).strip().lower()
    if v in ("true", "false"):
        return "1" if v == "true" else "0"
    try:
        return repr(float(v))
    except ValueError:
        return v


def main(argv):
    if len(argv) < 2:
        sys.exit(__doc__)
    path, cat_path, video_path = argv[1], None, None
    for flag, target in (("--catalog", "c"), ("--video", "v")):
        if flag in argv:
            val = argv[argv.index(flag) + 1]
            if target == "c":
                cat_path = val
            else:
                video_path = val
    if cat_path:
        cat = json.load(open(cat_path, encoding="utf-8"))
    else:
        with urllib.request.urlopen(CATALOG_URL, timeout=60) as r:
            cat = json.load(r)
    cv = {x["name"]: x for x in cat["convars"]}
    stock = max(cat["stock"], key=lambda s: s["build"])
    stock_map = collections.defaultdict(list)
    for e in stock["entries"]:
        stock_map[tuple(e["path"])].append(e["value"])
    guarded = set(cat["rules"]["guardedSections"])
    excluded = set(cat["rules"]["excludedSections"])

    tree = parse(open(path, encoding="utf-8", errors="replace").read())
    root = tree[0][1]
    mine = collections.defaultdict(list)
    for p, v in flat(root):
        mine[p].append(v)

    video = {}
    if video_path:
        for p, v in flat(parse(open(video_path, encoding="utf-8").read())):
            if p[-1].startswith("setting."):
                video[p[-1][8:]] = v

    print(f"catalog {cat['version']}  convar build {cat['convarBuild']}  stock build {stock['build']}")
    print(f"\n== edits outside ConVars (vs stock build {stock['build']}) ==")
    n_guard = 0
    for p in sorted(set(mine) | set(stock_map)):
        if p[0] in ("ConVars", "FileSystem") or "/".join(p[:-1]) in excluded:
            continue
        if mine.get(p) != stock_map.get(p):
            g = p[0] in guarded
            n_guard += g
            print(f"  {'[guarded] ' if g else '          '}{'/'.join(p)}: stock {stock_map.get(p)} -> {mine.get(p)}")
    print(f"  guarded-section edits: {n_guard}")

    groups = collections.defaultdict(list)
    for p, vals in mine.items():
        if p[0] != "ConVars" or len(p) != 2:
            continue
        name, v = p[1], vals[-1]
        if p in stock_map and set(vals) == set(stock_map[p]):
            continue  # Valve's own line, untouched
        x = cv.get(name)
        if len(vals) > 1:
            groups["DUPLICATE (last one wins)"].append(f"{name} {vals}")
        if x is None:
            groups["UNKNOWN (not in dump)"].append(f"{name} {v}")
            continue
        if x.get("status"):
            groups[f"DEAD: {x['status']}"].append(f"{name} {v}")
            continue
        flags = x.get("flags", [])
        d = stock_map[p][-1] if p in stock_map else x.get("default")
        if "replicated" in flags:
            groups["SERVER-OWNED (replicated; bot matches only)"].append(f"{name} {v}")
            continue
        try:
            fv = float(norm(v))
            if ("min" in x and fv < x["min"]) or ("max" in x and fv > x["max"]):
                groups["CLAMPED (outside min/max)"].append(f"{name} {v}  range {x.get('min')}..{x.get('max')}")
                continue
        except ValueError:
            pass
        if d is not None and norm(d) == norm(v):
            groups["NO-OP (equals default)"].append(f"{name} {v}")
            continue
        if name in video:
            groups["VIDEO.TXT WINS"].append(f"{name} {v}  (video.txt: {video[name]})")
        if "archive" in flags:
            groups["ARCHIVE (default only; saved value wins)"].append(f"{name} {v}  default {d}")
        note = x.get("sideEffects")
        if note:
            groups["SIDE EFFECTS (your call)"].append(f"{name} {v}: {note}")
        groups["active"].append(f"{name} {v}  (default {d}; {','.join(flags)})")

    order = sorted(groups, key=lambda g: (g == "active", g))
    for g in order:
        print(f"\n== {g}: {len(groups[g])} ==")
        if g != "active" or "-v" in argv:
            for it in groups[g]:
                print("  ", it)
    bad = sum(len(v) for g, v in groups.items()
              if g.split(":")[0].split(" ")[0] in ("DUPLICATE", "UNKNOWN", "DEAD", "SERVER-OWNED", "CLAMPED", "NO-OP"))
    print(f"\n{len(groups['active'])} active lines, {bad} dead-weight lines")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
