#!/usr/bin/env python3
"""Static site builder for the Salesforce AppExchange From Zero course.

Usage:  python3 build.py
Reads  content/<slug>.html  fragments and wraps them in the shared template,
writing <slug>.html at the project root.

Authoring helpers available inside content fragments:

  [[code bash]] ... [[/code]]     -> escaped code block with copy button
  [[diagram]]   ... [[/diagram]]  -> escaped ASCII diagram block (no copy button)

Everything else is passed through as raw HTML.
"""
import html
import re
from pathlib import Path

ROOT = Path(__file__).parent
CONTENT = ROOT / "content"

# slug, nav label, page title, kicker (matches the numbered nav)
PAGES = [
    ("index",            "Start here",              "Salesforce AppExchange From Zero", "Course home &amp; Stage 0"),
    ("01-big-picture",   "1 &middot; Big picture",       "The Salesforce ISV Ecosystem",     "Part 1"),
    ("02-orgs",          "2 &middot; Org architecture",  "How Many Orgs Do I Actually Need?","Part 2"),
    ("03-prereqs",       "3 &middot; Prerequisites",     "Prerequisites Checklist",          "Part 3"),
    ("04-the-app",       "4 &middot; The app",          "Build the Application First",      "Part 4"),
    ("05-1gp",           "5 &middot; 1GP concepts",     "1GP From Absolute Zero",           "Part 5"),
    ("06-1gp-lifecycle", "6 &middot; 1GP lifecycle",    "Build &amp; Release the 1GP",          "Part 6"),
    ("07-2gp",           "7 &middot; 2GP concepts",     "2GP From Absolute Zero",           "Part 7"),
    ("08-2gp-build",     "8 &middot; 2GP build",        "Build the Same App as a 2GP",      "Part 8"),
    ("09-scratch-orgs",  "9 &middot; Scratch orgs",     "Scratch Org Strategy",             "Part 9"),
    ("10-compare",       "10 &middot; 1GP vs 2GP",      "Deep Comparison",                  "Part 10"),
    ("11-dependencies",  "11 &middot; Dependencies",    "Building Package Dependencies",    "Part 11"),
    ("12-install",       "12 &middot; Install &amp; upgrade", "Customer Install and Upgrades", "Part 12"),
    ("13-security",      "13 &middot; Security Review", "Security Review Readiness",        "Part 13"),
    ("14-cicd",          "14 &middot; CI/CD",           "Pipelines for ISV Packaging",      "Part 14"),
    ("15-appexchange",   "15 &middot; AppExchange",     "Listing and Distribution",         "Part 15"),
    ("16-day-plan",      "16 &middot; Day-by-day plan", "The 14-Day Build Plan",            "Part 16"),
    ("17-debugging",     "17 &middot; Debug drills",    "Break It On Purpose",              "Part 17"),
    ("17b-error-index",  "17b &middot; Error index",    "The Error Field Guide",            "Part 17b"),
    ("18-backend",       "18 &middot; Behind the scenes","What Salesforce Does Internally",  "Part 18"),
    ("19-commands",      "19 &middot; Command cheat sheet","Every Command You Need",        "Part 19"),
    ("20-quiz",          "20 &middot; Knowledge test",  "Architect-Level Interview",        "Part 20"),
]

TEMPLATE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<link rel="stylesheet" href="assets/site.css">
</head>
<body>
<a class="skip" href="#main">Skip to content</a>
<button class="navtoggle" aria-label="Toggle navigation">&#9776; Contents</button>
<div class="shell">
<nav class="sidenav" id="sidenav">
  <div class="brand">
    <span class="brand-mark">SF</span>
    <span class="brand-text">AppExchange<br><b>From Zero</b></span>
  </div>
  <ol class="navlist">
{nav}
  </ol>
  <div class="navfoot">
    <p>Local course site.<br>Regenerate with <code>python3 build.py</code></p>
  </div>
</nav>
<main id="main">
  <header class="pagehead">
    <p class="kicker">{kicker}</p>
    <h1>{h1}</h1>
  </header>
  {body}
  <nav class="pager">{pager}</nav>
  <footer class="sitefoot">
    <p>Built as a personal learning course. Salesforce behaviour changes between releases &mdash;
    always confirm against <a href="https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/">Salesforce DX Developer Guide</a>
    and the <a href="https://developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/">ISVforce / Packaging guides</a>
    before you rely on a detail in production.</p>
  </footer>
</main>
</div>
<script src="assets/site.js"></script>
</body>
</html>
"""


def code_block(match):
    lang = (match.group(1) or "text").strip()
    body = match.group(2).strip("\n")
    wrap = "codewrap err" if lang in ("error", "failure") else "codewrap"
    return ('<div class="%s"><div class="codebar"><span>%s</span>'
            '<button class="copy" type="button">Copy</button></div>'
            '<pre class="code"><code>%s</code></pre></div>'
            % (wrap, html.escape(lang), html.escape(body)))


def diagram_block(match):
    body = match.group(1).strip("\n")
    return '<pre class="diagram">%s</pre>' % html.escape(body)


def include_file(match):
    parts = match.group(1).split()
    rel = parts[0]
    lang = parts[1] if len(parts) > 1 else "text"
    path = ROOT / rel
    if not path.exists():
        return ('<div class="stop"><p>MISSING INCLUDE: <code>%s</code></p></div>' % html.escape(rel))
    return ('<div class="codewrap"><div class="codebar"><span>%s</span>'
            '<button class="copy" type="button">Copy</button></div>'
            '<pre class="code"><code>%s</code></pre></div>'
            % (html.escape(rel), html.escape(path.read_text().rstrip("\n"))))


def render(fragment):
    out = re.sub(r"\[\[file ([^\]]+)\]\]", include_file, fragment)
    out = re.sub(r"\[\[code([^\]]*)\]\](.*?)\[\[/code\]\]", code_block, out, flags=re.S)
    out = re.sub(r"\[\[diagram\]\](.*?)\[\[/diagram\]\]", diagram_block, out, flags=re.S)
    return out


def build():
    written = []
    for i, (slug, label, title, kicker) in enumerate(PAGES):
        frag_path = CONTENT / f"{slug}.html"
        if not frag_path.exists():
            print(f"  skip (no content): {slug}")
            continue
        nav_items = []
        for s, lbl, _t, _k in PAGES:
            cls = ' class="here"' if s == slug else ""
            nav_items.append(f'    <li{cls}><a href="{s}.html">{lbl}</a></li>')
        prev_link = ""
        next_link = ""
        if i > 0:
            p = PAGES[i - 1]
            prev_link = f'<a class="prev" href="{p[0]}.html"><span>Previous</span>{p[1]}</a>'
        if i < len(PAGES) - 1:
            n = PAGES[i + 1]
            next_link = f'<a class="next" href="{n[0]}.html"><span>Next</span>{n[1]}</a>'
        doc_title = title if "AppExchange From Zero" in title else (
            title + " &middot; AppExchange From Zero"
        )
        page = TEMPLATE.format(
            title=doc_title,
            h1=title,
            kicker=kicker,
            nav="\n".join(nav_items),
            body=render(frag_path.read_text()),
            pager=prev_link + next_link,
        )
        (ROOT / f"{slug}.html").write_text(page)
        written.append(slug)
    print(f"built {len(written)} pages: {', '.join(written)}")


if __name__ == "__main__":
    build()
