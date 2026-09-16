# Worlds documentation

**Status: maintained documentation authority map.**

Worlds keeps a deliberately small documentation surface. Prose has different
levels of authority and must not acquire semantic force merely by being present
in the repository.

The maintained documents are:

- `LAWS.md` — **normative semantic laws** for Worlds 0.6.1;
- `MODEL.md` — maintained explanatory model; if prose conflicts with `LAWS.md`,
  the laws win;
- `API.md` — maintained public Lua API for 0.6.1;
- `QUERY.md` — normative finite matching Question and partial matching judgement;
- `SHAPE.md` — implementation/representation shape of the clean-boundary kernel;
- `LIVE.md` — the boundary-only execution result;
- `COMPLEXITY.md` — structural complexity notes;
- `THEOREMS.md` — theorem targets and executable evidence, not proofs;
- `PERFORMANCE.md` — maintained performance constitution;
- `VERIFICATION.md` — formal verification obligations;
- `RESEARCH.md` — explicitly non-authoritative future directions.

Other prose has a local home:

- `../tests/README.md` describes executable test/differential strategy;
- `../CHECKS.md` is the acceptance record captured for this release;
- `../speculation/README.md` indexes deliberately non-authoritative experiments.

`../compat/` and `../tests/historical/` preserve compatibility/equivalence
evidence for older algebra tests; they do not enlarge the 0.6 public semantic
surface.

