# Authoring one application chapter (brief for helpers)

Build dir: C:/Users/kunal/AppData/Local/Temp/claude/94fcd26b2af6da85/fc795adb-c400-4306-a381-c92d83377662/scratchpad/build
Research dir: ../research (one <key>.md per app, template-structured, every claim labelled with source ids).

Goal: write `apps/<key>.js`, a data module that `slides.js` turns into ~12–15 editable PowerPoint slides in the style of the existing chapters. **Read `apps/ascendixre.js` and `apps/propertybase.js` first. They are the exemplars: match their shape, density, tone and evidence discipline exactly.** `apps/realproperties.js` shows how to treat a product with thin public material ("inferred reference architecture" tags, `statusWarn`, `Proposed:` names, type `proposed` ERD nodes).

## Rules
- Content comes only from the research md. Evidence letter on every item: V (Verified, incl. search-snippet), O (Observed), I (Inferred), U (Unknown). Never invent API names, class names, Flow names; unknown API names → `null` in objects table (renders "Unknown") or `"Proposed: TC_..."`; in the ERD omit `api` (renders "API name unknown") or use `Proposed:` with type `proposed`.
- Source ids in `src` arrays must be ids from the md's Sources table.
- If the product is no longer sold / renamed / not on Salesforce, say it in `statusWarn` and in facts.
- Writing style: plain, short, specific. No marketing words. Sentences end without fluff. Use the exemplars' length: block titles ≤ ~45 chars, `text` ≤ ~90 chars, chip items ≤ ~38 chars, overview answers ≤ ~170 chars, callout `d` ≤ ~200 chars.
- 2–4 processes (`processes`), each 3–4 sections (lanes) with tones beige → blue → orange (→ navy). Show start point (kind `start`), numbered steps (`num`), automation (kind `auto`), status lists (kind `status` with `items`, one `{t, hl:true}` highlight), decisions (kind `gate`), notes (kind `note`, `noLink: true`), end (`end`). Add `links` between lanes ([fromId, toId]). If a process leaves the lower half empty, add `notes` (3–4 callouts: who acts / alternate paths / exceptions / unknowns).
- Module slide: 3 lanes, blocks with `title` + `text`, no ids needed.
- ERD: grid `cols` × `rows` (typically 5×3 or 4×3), each node `{id,label,api?,type,c,r,fields,ev}`; types std|custom|junction|config|external|proposed. Edges `{from,to,kind:md|lookup|junction|ref,label:"1:N"}`. Place nodes so edges are short: same row/col neighbours are best. Optional offsets for diagonal edges: `aox`/`box` (shift exit/entry x from centre, inches, ±0.4–0.9) and `ymo` (shift the mid horizontal run) to stop edges overlapping each other. **No edge may pass through a node.** Drop an edge rather than let it cross a box; mention the relation in node fields instead.
- Integrations: 6–8 items `{sys, dir: "→" into SF | "←" out of SF | "↔", purpose, data, ev}`.

## Build and check (mandatory)
1. `node chapter-test.js <key>` — prints fit warnings (text estimated not to fit). Fix all of them by shortening text or moving content.
2. Render with PowerPoint (real render). Use your own output dir:
   `powershell -NoProfile -ExecutionPolicy Bypass -File render.ps1 -deck "<abs windows path to ch-<key>.pptx>" -outDir "<abs windows path to png-<key>>"`
   (in Git Bash: `"$(cygpath -w $PWD/ch-<key>.pptx)"`). If PowerPoint is busy because another helper is rendering, wait ~20 s and retry.
3. Open every PNG with the Read tool and check: text overflowing or clipped, overlapping shapes, ERD edges crossing nodes or labels, arrows that make no sense, large empty areas (fill with notes), titles wrapping to 2 lines (shorten). Fix in `apps/<key>.js` only, rebuild, re-render, re-check until clean.
4. **Do not edit lib.js, slides.js, render.ps1, chapter-test.js or other apps' files.** If a renderer bug blocks you, describe it in your final report.

Final report (≤ 15 lines): slide count, what the chapter claims about status, anything you could not fix, any renderer issue.
