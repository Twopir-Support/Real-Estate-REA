# Reverse engineering: eight real-estate applications on Salesforce

Research date: 12 November 2026. Public sources only. No product was installed, and no vendor code was viewed.

## Deliverables

| File | What it is |
|---|---|
| [Real_Estate_Applications_Reverse_Engineering.pptx](Real_Estate_Applications_Reverse_Engineering.pptx) | Main deck, 152 slides, built in the style of the "Proposed Architecture" reference deck. All diagrams are editable PowerPoint shapes. |
| [Application_Functional_Comparison.xlsx](Application_Functional_Comparison.xlsx) | Landscape, ratings (supplied vs verified), feature matrix, technical, object map, process steps, integrations, modules, automation |
| [Salesforce_Object_Architecture.xlsx](Salesforce_Object_Architecture.xlsx) | Object inventory, relationships, published API names and ERD fields, each with a confidence label |
| [Application_Process_Flows.md](Application_Process_Flows.md) | Six-stage business processes for each product, with alternate paths |
| [Research_Sources_and_References.md](Research_Sources_and_References.md) | Every source, with its URL, type and access date |
| [Proposed_Salesforce_Architecture.md](Proposed_Salesforce_Architecture.md) | Recommended architecture and roadmap, extending the TC app in this repo |
| [research/](research/) | Full research notes for each product, in a fixed template. Every claim carries a label and a source id |

## Deck structure

1. **Executive overview:** objective, method, landscape, ratings, key findings.
2. **Individual analysis:** one chapter per product, each covering identity, overview, architecture, modules, objects, ERD, two to four process flows, automation, integrations, UI flow, and reporting and limitations.
3. **Cross-application comparison:** features, architecture, objects, processes, integrations, market position.
4. **Proposed architecture:** what is common and what is unique, ERD, layers, modules, end-to-end process, LWC, Apex, Flow vs Apex, integrations.
5. **Roadmap:** phases, priorities and dependencies, risks, sequence.
6. **Sources:** key sources per product, and research limitations.

## Evidence labels

| Label | Meaning |
|---|---|
| V | Verified: the vendor states it, including search-engine snippets of vendor pages that blocked direct fetches |
| O | Observed: seen in an official walkthrough (used for Left Main only) |
| I | Inferred: reasoned, not confirmed |
| U | Unknown: no reliable public information |
| P | Proposed: our own design |

## Rebuilding

The generator lives in `scripts/reverse-engineering/`. It uses Node and pptxgenjs, with each product's content held in its own `apps/<key>.js` file.

```bash
cd scripts/reverse-engineering && node build.js ../../docs/reverse-engineering/Real_Estate_Applications_Reverse_Engineering.pptx
```

```bash
cd scripts/reverse-engineering && node gen-docs.js ../../docs/reverse-engineering
```

`render.ps1` exports slide PNGs through a local PowerPoint install, for visual QA.
