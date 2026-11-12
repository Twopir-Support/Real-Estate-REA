// Parse the "## 12. Sources" table of a research markdown file.
module.exports = function parseSources(md) {
  const i = md.search(/^## 12\. Sources/m); if (i < 0) return [];
  const out = [];
  for (const line of md.slice(i).split("\n")) {
    if (!line.startsWith("|") || /^\|\s*:?-/.test(line) || /^\|\s*id\s*\|/i.test(line)) continue;
    const c = line.split("|").slice(1, -1).map((x) => x.trim());
    if (c.length < 4) continue;
    const url = (c[2].match(/https?:\/\/[^\s;)<>]+/) || [c[2]])[0];
    out.push({ id: c[0].replace(/\*/g, ""), title: c[1].replace(/\*/g, "").slice(0, 110), url, urlRaw: c[2], type: c[3], accessed: c[4] });
  }
  return out;
};
