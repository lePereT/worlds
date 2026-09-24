# Worlds test strategy

**Status: maintained test architecture and executable-evidence guide.**

The semantic laws live in `../docs/LAWS.md`. Tests are executable evidence, not
a second prose specification.

## Gate

`make full-check` runs:

```text
tests/run.lua
    native 0.6 semantics

tests/construction.lua
    immutable exact join-materialisation witness and image transport

tests/presentation.lua
    ordered non-authoritative open-boundary views and residual transport

tests/history.lua
    optional observer/history independence

tests/adversarial.lua
    targeted boundary/scarcity/locality regressions

tests/work.lua
    deterministic complexity/work-budget regression gates

tools/check-shape.lua
    architectural/source-shape guard

tests/differential.lua
    10,000 flat cases against independent brute force

tests/nested-differential.lua
    3,000 nested-locality cases

tests/branching-differential.lua
    3,000 branching-locality cases

tests/historical/*.lua
    15 retained algebra cases through compat/worlds.lua
```

The differential suites are important because they compare the optimised
boundary/factor solver with deliberately simpler independent enumerations rather
than merely asserting examples against itself.

## Historical compatibility evidence

`tests/historical/` and `compat/worlds.lua` preserve selected 0.5 algebra laws as
regression evidence. They do not define the 0.6 public API and should not be used
by new clients.

## Speculation

`make speculation-check` runs the deliberately non-authoritative experiments in
`../speculation/`. These are excluded from `full-check`: passing them means only
that their toy assertions remain executable against the released kernel.

## Benchmarks

`make bench`, `make stress` and `make live` are development/performance probes.
They are not wall-clock correctness gates. Captured release results are recorded
in `../CHECKS.md` and `../bench/`.

## Work constitution

`work.lua` is a deterministic performance-regression gate.  It does not use
wall-clock thresholds.  Solver paths are measured in the kernel's own
`step(fuel)` work units; complete-Question construction is measured in Lua VM
instruction quanta because it occurs before the fuelled coroutine exists.

The guarded properties are: indexed rigid lookup independent of unrelated
source size; symbolic complete-Question construction; persistent query/ancestry
caches; cached depth work independent of raw membrane depth; and linear early
scarcity rejection.  The budgets are deliberately loose enough to permit local
implementation changes while failing changes in asymptotic work.


## Centre/edge architecture

`centre.lua` loads `worlds._kernel` directly and exercises Geometry, `boundary`
and `join` while asserting that neither disposable acceleration nor the matching
engine has been loaded. This guards the one-way dependency from edge to centre.
