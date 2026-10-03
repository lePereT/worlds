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

Worlds also assumes trusted in-process clients. Authentic finite arrays are
borrowed read-only views rather than defensively copied at every accessor or
module boundary. Validation is paid for newly introduced semantic claims, not
for repeated observation of already-authentic values. See `TRUST.md`.

In particular:

- the world side is pre-counted structural egress incidence with exact fibres;
- rigid Point coordinates use postings rather than scanning unrelated rows;
- development locality is compressed by the endpoint-thread quotient;
- private structural variables are projected away;
- structural solutions are retained as factor/provenance support rather than a
  second evaluator;
- exact allocation is delayed until structural solving is complete;
- Hall feasibility rejects impossible scarce lifts before enumeration;
- Match and Close share one Geometry-free finite relation solver rather than maintaining
  separate injection/subset search;
- required target and required source coverage are handled symmetrically by that solver,
  with Hall feasibility before exact enumeration;
- optional-ingress Match queries prove singleton base feasibility before subset search,
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
rejection stays linear, cached ancestry work is independent of raw depth, query
compilation survives repeated `W.solve` calls, canonicalising two or more complete
seed equations does not rebuild a source-position map over unrelated egress, and
Close Hall deficiency / required-source optional-target search remain polynomial in
the finite support relation rather than reverting to factorial/subset enumeration.

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


## Current 0.6.4 real-time implementation profile

The performance constitution is now exercised by Relay/Fibers-shaped local developments. The maintained mechanical
rule is: **prove a candidate once, materialise it once, and let cost follow ambiguity + incoming development +
changed live boundary rather than historical programme size or repeated validation of certified state.**

The current implementation therefore retains Question realisations, uses lazy DSU state and hybrid images, provides
a trusted development Builder, and gives `advance` locality-aware representations/indexes while preserving generic
`join` as the reference oracle. Persistent boundary data and compiled/indexed structures are acceleration only;
they are neither programme authority nor additional semantic state.

Performance changes are accepted only with the full differential/historical gate and paired Fibers benchmarks.
See the top-level `CHECKS.md` for the current measured regression shape.

## 0.6.4 mechanical work ratchets

0.6.4 makes the non-timing part of the performance contract executable at two
levels.

`tests/work.lua` measures finite Question/search work in the engine's own fuel
quanta, with relative VM-instruction checks only where construction happens
before the fuelled coroutine exists.

`tests/mechanical-work.lua` protects the mechanics below the query engine. Its
ratchets require that:

- borrowed `egress` and Strand-incidence observations do not copy or scale with
  section width;
- `join({G}, {})` remains identity work independent of `G` size;
- `development_builder():strand(...)` does not eagerly rescan trusted incidence;
- committing a retained successful Question does not rematerialise the frame;
- indexed local live advance over a 10,000-Strand frontier stays in the same
  work class as the 100-Strand case for both the single-Face delta and small
  multi-Face causal Developments; and
- the disposable boundary index transfers to the successor so the next local
  advance stays local.

These are release correctness gates. Wall-clock benchmark snapshots remain
non-portable development evidence and are not pass/fail thresholds.
