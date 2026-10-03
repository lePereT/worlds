# Worlds 0.6.5 acceptance record

**Status:** small verified geometric centre, disposable accelerated edge, trusted in-process profile.  
**Primary clients:** Relay, Fibers, and realtime Worlds users.  
**Semantic baseline:** the four-carrier Geometry laws remain the oracle; 0.6.5 changes mechanics, evidence plumbing and implementation shape, not the authority ontology.

## Maintained geometric centre

The centre is `src/worlds/_centre.lua` and owns only:

```text
Membrane / Point / Strand / Face / Geometry
boundary / join / Construction image
```

`join` is the sole Geometry-changing law. `advance` remains the derived equation

```text
boundary(join({boundary(world), development}, equations))
```

implemented at the edge with exact refinements. The centre imports no cache, persistent sequence, fast local join, live delta or query engine.

0.6.5 also makes two construction obligations explicit in mechanics:

- the Membrane quotient induced by equations must remain a finite parent forest;
- Construction images commute with surviving Membrane parenthood, Point placement and ordered Strand incidence, rematerialising affected frame carriers where literal reuse would make the image stale.

## Disposable accelerated edge

The realtime work from 0.6.4 is retained, but factored behind narrow internal contracts:

- `_fast.lua` — local-frame quotient and single-Face/live refinements;
- `_index.lua` — one rebuildable incidence/order index shared by query and live mechanics;
- `_persistent.lua` — persistent finite sequence/set mechanics for local boundary edits.

A fast path returns an exact result or `fallback`. Deleting these modules changes performance, not Geometry meaning.

Additional trusted mechanics remain:

- borrowed read-only finite arrays for authentic in-process values;
- one-validation `development_builder()`;
- exact Point `minter()`;
- retained successful Question materialisation;
- dense/sparse Construction images selected by join shape.

## Exact materialisation evidence

Direct composition and successful finite Questions now use the same exact `Construction` witness:

```text
parts + equations -> result Geometry + carrier image
```

`Realisation` remains compatibility terminology only; it is not a second value kind.

## Finite judgement

Questions remain outside programme state. Search may use factorisation, counted incidence, Hall feasibility and other disposable algorithms, but every constructive answer is validated by strict `join` before publication.

## Deterministic performance gates

Wall-clock benchmarks are development evidence. Release performance is guarded primarily by deterministic work ratchets:

- `tests/work.lua` constrains finite Question/search work;
- `tests/mechanical-work.lua` constrains copying/materialisation/local evolution work;
- differential `advance` checks every accelerated live result against the defining reference equation.

The centre/edge refactor retains the 0.6.4 realtime fast paths rather than trading runtime cost for source-code minimalism.

## Verification gate

A release tree must pass:

```sh
make LUA=texlua full-check
make LUA=texlua speculation-check
sha256sum -c SHA256SUMS
```

`full-check` includes semantic/query/construction/trust/adversarial/work/shape gates, 10k general differential assertions, restricted/partial/nested/branching/closure suites, 2,000 local-advance cases with hundreds of thousands of assertions, and all historical algebra files.

`speculation-check` includes the occurrence-relative Theory hostile programme under `speculation/theory/occurrence_relative/`; speculation remains non-authoritative but must be internally green at release.

## Encapsulation and trust

Weak-key private-state registries remain the common encapsulation representation. Authentic Worlds objects are immutable by trusted in-process contract; zero-copy borrowed views are therefore compatible with semantic immutability without imposing defensive-copy cost on hot paths.
