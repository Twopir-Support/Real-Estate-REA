const L = require("./lib");
const S = require("./slides");
const key = process.argv[2];
const app = require(`./apps/${key}`);
const pres = L.createDeck();
S.chapter(pres, app, 1);
pres.writeFile({ fileName: `ch-${key}.pptx` }).then(() => { console.log(L.warnings.join("\n") || "no warnings"); });
