# Worlds 0.6.4 — real-time performance and work-ratchet release

Worlds is a small operational geometry in which exact identity, scarce authority, causal transformation and
locality arise from incidence and open boundary.

This release keeps the 0.6.3 ontology and judgement laws while locking in the performance programme
needed by Relay and real-time Fibers. The implementation now treats authentic Worlds values as certified immutable
in-process objects, retains exact judgement evidence instead of recomputing it, and makes common live evolution
proportional to the changed region where practical.

The public centre remains:

```lua
local W = require('worlds')

-- ontology: Membrane / Point / Strand / Face / Geometry
-- operations: boundary / join / advance
```

`join(parts, equations)` is still the reference Geometry composition law. `advance` is semantically
`boundary(join(...))`; specialised paths are implementation accelerations checked against that definition.

## Trusted in-process contract

Worlds validates new semantic claims, not immutable facts that it has already certified. Arrays exchanged with
cooperating clients are borrowed read-only views rather than defensive copies. Callers must not mutate borrowed
state while Worlds retains it. Private object state uses weak-key registries.

See `docs/TRUST.md`.

## Performance shape

The implementation now avoids several forms of repeated mechanical work:

- successful Questions retain their strict-join realisation for later Construction/commit use;
- identity constructions are identity work;
- DSU state is allocated only for carriers that need it;
- Construction images use dense or sparse representation according to the shape where each is cheaper;
- short-lived trusted developments use `W.development_builder()` and are validated once at `finish()`;
- exact client tokens can be minted without performing a quotient join;
- prepared live boundaries support frame-aware matching and local `advance`;
- persistent boundary sections/disposable indexes preserve unchanged live structure across local evolution;
- Close search rejects structurally impossible support pairs monotonically before deeper search.

None of these structures is programme authority. They may be discarded and reconstructed from the exact Geometry.

## Deterministic work ratchets

Performance acceptance is based on work done, not elapsed time. `tests/work.lua` protects finite Question/search
complexity in solver fuel quanta; `tests/mechanical-work.lua` protects allocation/materialisation/locality mechanics.
The latter includes constant-work borrowed observations and identity joins, retained-realisation reuse, one-pass trusted
development validation, and local indexed advance over a 10,000-Strand live frontier. Wall-clock files under `bench/`
remain development evidence only.

## Construction and Presentation

```lua
local Construction = require('worlds.construction')
local Presentation = require('worlds.presentation')
```

Construction is exact transport evidence for one materialisation; Presentation is ordered, non-authoritative ABI
structure over selected exact open Strand occurrences. They remain deliberately outside the ontology.

## Validation

`make LUA=texlua full-check` is the release semantic/differential/work gate. `make LUA=texlua speculation-check` runs
the broader experimental corpus. `CHECKS.md` records the current performance and regression shape.

The current paired Fibers checkpoint reaches historical V1-class small Channel performance while retaining
Worlds-based transactional laws, providing an application-shaped validation of this kernel profile.
