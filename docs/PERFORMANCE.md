# Performance constitution

**Status: maintained performance constitution.**

The intended complexity parameter is:

```text
relevant live boundary
+ incoming open development
+ genuine structural ambiguity
+ number of exact witnesses actually requested
```

not elapsed history or unrelated programme size.

## Semantic refinement before caching

Optimisation should first ask whether the kernel is posing the smallest correct
geometric/query problem. 0.6 deliberately avoids installing a second semantic
model beside the kernel.

The revised implementation separates the verified centre from disposable
acceleration. `worlds._kernel` owns exact Geometry and exposes an internal
read-only observation capability; it does not import, register or call
`worlds._compiled`. The public `worlds` edge may eagerly prepare rebuildable
outgoing indexes after Builder completion so first-query work remains bounded.
Those indexes contain no Question policy and contribute nothing to Geometry
identity.

Complete Question defaults remain symbolic internally. In particular, asking
for all source egress does not first copy and re-index the complete source
boundary; rigid postings can therefore retain their dependence on the relevant
posting rather than unrelated egress size.

In particular:

- the world side is pre-counted structural egress incidence with exact fibres;
- rigid Point coordinates use postings rather than scanning unrelated rows;
- development locality is compressed by the endpoint-thread quotient;
- private structural variables are projected away;
- structural solutions are retained as factor/provenance support rather than a
  second evaluator;
- exact allocation is delayed until structural solving is complete;
- Hall feasibility rejects impossible scarce lifts before enumeration;
- optional-ingress queries prove singleton base feasibility before subset search,
  so unrelated external demands do not create artificial binary dimensions.

## Live state

`advance` always returns to boundary normal form. Long-running persistent state
therefore follows frontier size, not accumulated closed history. Optional
history is an observer and pays explicitly for retained records.

## Exact enumeration is output-sensitive

Worlds does not make the general exact query problem polynomial. If a query has
`n!` exact scarce lifts and the caller asks for all of them, the implementation
must emit `n!` results. Symmetry/quotient-aware domain semantics belong outside
the release kernel unless made explicit as a future extension.

## Fuel and stack discipline

All solve work, including structural preparation, factor traversal, Hall
feasibility and exact enumeration, passes through one retained coroutine fuel
gate. Semantic backtracking is kept in explicit heap/query state rather than
requiring recursive Lua call depth proportional to the demand count.

`more` is therefore a progress result, not a timing judgement.

## Deterministic work regression gates

`../tests/work.lua` makes the main complexity promises executable.  Search is
measured in the engine's own `step(fuel)` work units rather than elapsed time.
It checks that rigid lookup is independent of unrelated source size, scarcity
rejection stays linear, cached ancestry work is independent of raw depth, and
query compilation survives repeated `W.solve` calls, and canonicalising two or more complete seed equations does not rebuild a source-position map over unrelated egress.

Complete Question construction precedes the fuelled solve coroutine, so that
path is guarded separately with Lua VM instruction quanta.  The test compares
small and much larger complete sections and permits a generous fixed-factor
slack; it is intended to detect an accidental return to O(boundary)
materialisation, not to freeze individual bytecode instructions.

## Benchmarks

Wall-clock probes in `../bench/` are development evidence, not correctness or
portable performance promises. `../CHECKS.md` records the captured release
snapshot. Release correctness now includes semantic, differential, shape and
deterministic work-budget tests; elapsed-time thresholds remain deliberately
outside the acceptance suite.
