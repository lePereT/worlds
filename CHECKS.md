# Worlds 0.6.2 research-release acceptance record

Worlds 0.6.2 changes documentation and the non-authoritative research/speculation
programme only. The `src/` and `compat/` trees are byte-for-byte identical to
0.6.1, the public API is unchanged, and the normative law text differs only in
the release-number status line.

The unchanged implementation was checked with TexLua using the complete 0.6.1
semantic/performance corpus. Several test banners therefore still print `0.6.1`;
that is deliberate evidence that the executable corpus itself was not rewritten
for this documentation-only release.

## Semantic/compatibility gate

```text
PASS 0.6.1                         5110 assertions
PASS query                           78 assertions
PASS closure query                   51 assertions
PASS optional history               165 assertions
PASS 0.6.1 adversarial               36 assertions
PASS work constitution                57 assertions
PASS verified centre without acceleration
PASS shape 0.6.1 centre/edge split
PASS differential10k              10000 assertions
PASS restricted differential       5000 cases
PASS partial differential        104510 assertions
PASS nested differential            3000 cases
PASS branching differential         3000 cases
PASS closure differential           2000 cases
PASS historical algebra               15 files
```

`tests/query.lua` covers directional Match sections, symmetric required-source/target coverage, admissibility, seed immutability/injectivity, exact Refutation evidence and the counterexample showing that matching is not merely `join`-definedness. `tests/closure-query.lua` covers direct multi-part and same-Geometry Close judgements, including the invariant that every constructive witness is accepted by strict `join`.

The restricted and partial differentials independently brute-force the public Match features against the ordinary matching laws. `tests/closure-differential.lua` independently compares Close against direct exhaustive finite relation enumeration plus strict `join`. The historical algebra suite continues to load the public facade through its
compatibility adapter; the authoritative centre/edge separation is checked
independently by `tests/centre.lua` and `tools/check-shape.lua`.

## Performance restoration snapshot

One same-host TexLua comparison using the unchanged `bench/run.lua` workloads:

```text
case                       original       split checkpoint    revised
broad-1000 first           0.039659 s     0.057408 s          0.044682 s
broad-1000 cached          0.003543 s     0.052107 s          0.003664 s
shared-unsat-5000          0.022426 s     0.087675 s          0.028406 s
odd-C7-K5,5                0.007689 s     0.009292 s          0.008115 s
rigid-100k                 0.018541 s     1.788114 s          0.020411 s
boundary-depth3000 first   0.015138 s     0.041510 s          0.016255 s
boundary-depth3000 cached  0.001884 s     0.038117 s          0.002349 s
```

A public `Query.complete` rigid-100k probe measured Question construction at
about 0.401 s in the split checkpoint and below 0.001 s in the revised tree;
construct-plus-solve fell from about 1.543 s to about 0.033 s.

These are development observations, not timing guarantees. The release
invariants are the restored complexity shapes: complete defaults remain
symbolic, rigid lookup does not scan unrelated egress during Question
construction, repeated complete solves reuse compilation state, and transient
join output does not eagerly allocate query-only indexes.

## Architectural shape

The verified Geometry centre is `src/worlds/_kernel.lua`. It has no dependency
on `worlds._compiled` or the query implementation. `src/worlds.lua` is the
public edge: it wraps Builder completion with disposable index preparation and
adds the complete `solve` convenience. Query acceleration remains in
`src/worlds/_compiled.lua`; the finite Question judgement remains in
`src/worlds/query_factory.lua`; Match factorisation remains in `src/worlds/query_engine.lua`; finite Hall/injective relation search shared by Match and Close lives in `src/worlds/query_relation.lua`. `src/worlds/_query.lua` supplies one shared
disposable matching instance to both `W.solve` and `worlds.query`.

The shape guard rejects finite-Question/search/acceleration policy from the
verified centre, checks that the public edge owns eager preparation, and checks
that complete source/target sections remain symbolic. `tests/centre.lua` also
loads and exercises Geometry directly while asserting that acceleration and the
query engine were never loaded.

## Deterministic work constitution

`make work` runs `tests/work.lua`.  It guards the restored performance profile
using solver fuel and Lua instruction quanta, not wall-clock timings.  `make
check` and therefore `make full-check` include this gate.

Current deterministic observations are deliberately expressed as budgets rather
than release promises: rigid lookup consumes 7 fuel quanta at 100, 1,000 and
10,000 unrelated rows; cached deep solves consume 47 quanta at depths 50 and
2,000; scarcity rejection consumes no more than `4n + 20`; and complete-Question
construction stays within a fixed-factor instruction budget when source size is increased by two orders of magnitude. The same source-size-independence gate now covers complete Questions with two seeded equations, preventing seed canonicalisation from rebuilding complete source-position maps.  The earlier API-split checkpoint fails
this gate at the construction test before reaching the solver-work checks.


## Pre-tag encapsulation and input hardening

Builder, Question, Refutation and retained solve state use ordinary lexical closures. Weak tables remain where they are deliberate shared caches (compiled surfaces, ingress analysis and ancestry acceleration); the high-volume exact carrier/Geometry store keeps its existing compact representation. Public finite-array inputs are checked for density, Question specifications reject unknown fields, and Question/Refutation predicates no longer trust protected metatable labels.

## Centre/edge decoupling check

The pre-tag dependency reversal was benchmarked against the immediately preceding
closure-cleanup build using three runs of the unchanged `bench/run.lua`; figures
below are medians on the same TexLua host.

| case | preceding build | centre/edge split | ratio |
| --- | ---: | ---: | ---: |
| broad-1000 first | 0.043535 s | 0.043304 s | 1.00x |
| broad-1000 cached | 0.003833 s | 0.003830 s | 1.00x |
| shared-unsat-5000 | 0.028688 s | 0.029262 s | 1.02x |
| odd-C7-K5,5 | 0.007939 s | 0.008190 s | 1.03x |
| exact-10P5 | 0.172230 s | 0.180792 s | 1.05x |
| rigid-100k | 0.017810 s | 0.017846 s | 1.00x |
| depth-3000 first | 0.017002 s | 0.016778 s | 0.99x |
| depth-3000 cached | 0.002181 s | 0.002249 s | 1.03x |

A separate three-run 10,000-step live probe measured 1.437608 s median before
and 1.467338 s after (1.02x). These timings are observations rather than release
thresholds; `tests/work.lua` remains the deterministic performance gate.

## Speculation corpus check

`make speculation-check` executes every Lua file under `speculation/`, including
`speculation/support.lua` and the helper module used by the quantum/classical
experiments. The revised 0.6.2 tree contains 40 executable Lua chunks. The
complete historical corpus still passes, including the older quantum pressure
tests and adversarial experiments.

The modern incidence programme now contributes 679 explicit assertions:

```text
factor incidence                         90
latent structures                       106
join structures                         132
membrane cross-axis                       8
quantum two-layer                        10
theory algebras                          34
quantum atlas                            86
quantum/classical correspondence        213
                                      -----
                                        679
```

The seven `speculation/modern/quantum_atlas/` attacks cover contextual overlap,
permutation symmetry over exact occurrence fibres, interference over exact
histories and observational boundary classes, phase/transport, copyability,
monoidal process semantics and the hostile locality case which warns against
reifying global quantum state as scarce authority.

The ten `speculation/modern/quantum_classical/` experiments cover
boundary/partial-trace decoherence, stochastic fixed sectors, copyable classical
structure, environment-selected pointer bases, membrane-separated redundant
records, local classical contextual islands, decoherent-history probability,
Hong-Ou-Mandel distinguishability, deterministic path-sum emergence and a finite
stationary-phase least-action toy. Their synthesis and falsifiers are recorded in
`docs/QUANTUM-CLASSICAL-CORRESPONDENCE.md`.

All modern experiments are dependency-free Lua/TeX Lua. They have no Python,
SymPy, CAS or external numerical dependency. Where a non-trivial expected
algebraic relation is required, the script compares against an explicit
pre-determined relation or computes only small local arithmetic inside the test.

The speculation corpus remains non-authoritative: this gate checks API
compatibility and the experiments' own assertions only. The quantum/classical
experiments do not promote `boundary` to physical decoherence, derive the Born
rule, solve measurement or establish a derivation of classical mechanics.

## Source-identity gate

A recursive file comparison against the packaged 0.6.1 source confirms that
`src/` and `compat/` are unchanged. `docs/API.md` and `docs/LAWS.md` differ from
0.6.1 only in their release-number status lines. The 0.6.2 Makefile now selects
an available Lua interpreter in the order LuaJIT, generic Lua, versioned Lua,
then TexLua, while retaining explicit `make LUA=...` override support. The main
test runner reads its displayed release number from `VERSION` rather than
hard-coding it.
