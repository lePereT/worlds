# Worlds 0.6.6 acceptance record

## Release-specific gates

- centre/edge architecture: native Construction provenance remains in the verified join;
  composition/public wrapping remain in `worlds.construction`;
- Lua 5.1 syntax: every shipped Lua file, including Relay research laboratories, is scanned;
- Lua 5.1 representation: persistent sequences are opaque internal values and public Geometry
  sections are ordinary dense arrays, so correctness no longer depends on table `__len` or
  metamethod-backed iteration;
- Construction correspondence: native quotient evidence is differentially pressured against
  staged composition, hidden/annihilated classes and the source-relative between-Worlds groupoid;
- Relay research: `make relay-check` runs the restrictive Theory and package-first
  finite-composition/recurrence/formed-computation/Judgement/authority-viability/concurrency suites.
  The concurrency arena is currently 50/50 pressures. Its recurrence change is also covered by all 32
  recurrence pressures and all 59 Geometry-viability pressures.

The packaging environment provides Lua 5.3 TeXLua but no literal Lua 5.1 or LuaJIT binary.
Compatibility is therefore verified here by the Lua 5.1 syntax gate, by removing the table
metamethod dependency itself, and by the complete semantic/differential suite under TeXLua.
A literal LuaJIT/Lua 5.1 `make full-check` remains a downstream runtime gate.

## Compatibility invariant

The persistent representation remains an internal optimisation. Public Geometry carrier/boundary
arrays retain ordinary dense-table behaviour. Local/indexed advance retains persistent/path-based
updates; the repair does not replace fast evolution with whole-frame fallback.

## Historical 0.6.5 / 0.6.4 gates

## 0.6.5 candidate centre/edge gate

- The verified centre is guarded by a compact-source budget that ignores layout whitespace. The 100-column formatting rule therefore cannot make the semantic centre appear to grow merely by wrapping lines.
- `make full-check`: green after extracting `_fast.lua`.
- Extended-Theory hostile lab: 48/48 green, including 3,222 Construction-image quotient attempts.
- Relay maintained language/pressure suite: 116 files green against this tree.
- Realtime `bench/live.lua 10000`: remains in the same observed performance band as the pre-extraction candidate; disposable acceleration remains enabled.

# Worlds 0.6.4 acceptance record

**Status:** trusted in-process profile plus locality/mechanical performance programme; semantic laws unchanged.  
**Primary clients:** Relay and Fibers.  
**Semantic baseline:** Worlds 0.6.3 laws remain the oracle through differential/reference tests; 0.6.4 changes mechanics, trust profile and release ratchets, not ontology.

## Maintained semantic centre

The carrier ontology and public laws remain:

```text
Membrane / Point / Strand / Face / Geometry
boundary / join / advance
Question / Match / Close
```

No performance feature introduces a second authority model. Query acceleration, boundary indexes, persistent
sections and retained realisations are disposable/mechanical evidence around the same exact judgement.

The trusted in-process contract remains:

```text
new semantic information -> validate once
authentic Worlds values  -> trust thereafter
borrowed finite views     -> read-only by contract
```

## Accepted performance work

The current tree incorporates the following changes, each kept only after semantic/differential testing and
client benchmarks:

- successful Questions retain the exact strict-join realisation they already constructed instead of throwing it
  away and forcing clients to repeat the join;
- mathematically trivial identity joins/constructions avoid quotient work;
- DSU singleton state is lazy;
- Construction images are hybrid: dense for small ordinary joins, sparse identity-by-default where locality makes
  that representation pay;
- the Close engine uses a monotone support filter based on Strand arity and rigid imported Point incidence;
- `W.minter` provides cheap authentic exact Points without abusing quotient composition as an allocator;
- `W.development_builder()` is the trusted target/development Builder. It defers incidence checks to the single
  authoritative `finish()` validation instead of validating the same trusted arrays twice;
- Match may use a prepared live-boundary frame to avoid whole-frame work when the index exists; small unindexed
  sources go directly to the reference join;
- `advance` keeps the specialised single-Face delta and additionally reuses the frame-local quotient for small local multi-Face Developments;
- disposable boundary incidence/order acceleration and persistent boundary sections allow local live evolution to
  reuse unchanged structure rather than reconstruct the entire frontier.

Generic `join` remains the reference composition law. Specialised evolution is continuously checked against
`boundary(join(...))` and the existing differential suites.

## Regression shape

The optimisation programme is accepted because improvements are broad rather than benchmark-specific.
Representative TexLua measurements against the trusted-in-process checkpoint:

```text
live evolution, 10,000 steps       ~1.16 s vs ~1.77 s    (~34% faster)
observed live evolution, 1,000     ~0.115 s vs ~0.183 s  (~37% faster)
full history, 1,000                ~7.23 s vs ~7.51 s    (~4% faster)
50k-frame join stress              ~0.217 s vs ~0.238 s  (~9% faster median)
exact-10P5                         ~3.24 s vs ~3.31 s     slightly faster
rigid-100k                         ~0.00024 s vs ~0.995 s several-thousand-fold faster
```

The hybrid Construction image recovered the small-join regressions seen in an earlier all-sparse experiment:
boundary-chain, ancestor and dense-triangle stress cases are now effectively flat to slightly faster than the
trusted baseline. Two sub-millisecond Close microcases retain roughly 5–7% fixed overhead; Hall-unsatisfiable Close
is flat and the rigid Close case is dramatically faster. This residual is recorded rather than hidden.

## Verification gate

The final source must pass `make LUA=texlua full-check` and `make LUA=texlua speculation-check`. The full-check
includes core/query/closure/construction/presentation/history/trust/adversarial/query-work/mechanical-work tests, centre/shape checks,
10k differential assertions, restricted/partial/nested/branching/closure differential suites, a direct local-advance differential suite, and all historical
algebra files.

The paired Fibers checkpoint additionally exercises the kernel through Channel, Mailbox, custody, Task, host,
Socket and Process workloads.

### Deterministic mechanical ratchets

0.6.4 adds `tests/mechanical-work.lua` beside the existing finite-query work constitution. These are non-timing release
gates. They lock in borrowed zero-copy observation, identity join, single-validation development construction, retained
Question-realisation reuse, and indexed local live advance — including small multi-Face Developments — whose work remains effectively independent of a 100x larger
unrelated frontier. The paired Fibers suite separately counts exact `advance`/`join`/`solve`/development-builder operations
for its hot Channel and Mailbox paths.

## Encapsulation

Weak-key private-state registries remain the chosen representation. Benchmarking against per-object closure
accessors found closures modestly cheaper to construct but about 25–35% slower on hot state reads and roughly 30%
heavier in retained heap under TexLua. The common representation therefore stays weak-key rather than optimising
for stylistic uniformity at measurable runtime cost.
