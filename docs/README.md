# Worlds documentation

**Status: maintained documentation authority map.**

Worlds deliberately keeps a small documentation set. Prose has different levels
of authority and must not acquire semantic force merely by being present in the
repository.

The maintained documents are:

- `LAWS.md` — **normative semantic laws** for the released kernel;
- `MODEL.md` — maintained explanatory model; if prose conflicts with `LAWS.md`,
  the laws win;
- `API.md` — maintained public Lua API for this release;
- `THEOREMS.md` — theorem targets and executable evidence, not proofs;
- `PERFORMANCE.md` — maintained performance constitution and work-shape goals;
- `RESEARCH.md` — explicitly non-authoritative future directions.

Other prose has a local home:

- `../tests/README.md` describes executable test/torture strategy;
- `../formal/README.md` describes the formalisation programme;
- `../archaeology/` records historical implementations and migration evidence;
- `../external/*/README.md` belongs to independent external clients.

Only the repository entry point `../README.md` remains as top-level Markdown.
The exact Markdown set is enforced by `../tests/docs.lua`.
