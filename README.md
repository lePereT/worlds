# Worlds 0.6.5 — small centre, fast disposable edge

Worlds is a small operational geometry in which exact identity, scarce authority,
causal transformation and locality arise from incidence and open boundary.

0.6.5 keeps the real-time engineering earned in 0.6.4, but makes the
implementation shape match the calculus again.

## Geometric centre

`src/worlds/_centre.lua` owns only the exact carriers, Geometry validation,
`boundary`, `join`, and Construction images.

```text
Membrane  Point  Strand  Face
             ↓
          Geometry

boundary   join
```

`join(parts,equations)` is the sole Geometry-changing law. `boundary` removes
closed causal history while preserving exact future-relevant authority and its
locality support.

`advance` is deliberately derived at the public edge:

```text
boundary(join({boundary(world), development}, equations))
```

## Disposable acceleration

The centre imports no cache, persistent sequence, local join, live delta or
query engine.

The edge contains three small mechanical modules:

- `_fast.lua` — exact local-frame and single-Face refinements;
- `_index.lua` — one rebuildable cache shared by query compilation and live boundaries;
- `_persistent.lua` — persistent sequence/set mechanics for local boundary edits.

A fast path either returns an exact result or `fallback`; the reference centre
remains the specification. All acceleration can be discarded and rebuilt from
Geometry.

## Finite judgement

Questions remain outside programme state. Matching/search may use counted
incidence, factorisation, Hall feasibility and other disposable algorithms, but
every constructive answer is checked by strict `join` before publication.

A direct materialisation and a successful Question now retain the same exact
`Construction` witness. `Realisation` remains only as compatibility API
terminology, not as another value kind.

## Trusted in-process performance

Authentic Worlds values are certified immutable in-process objects. Borrowed
arrays are read-only by contract rather than defensively copied. Short-lived
developments may use `development_builder()`, and exact client tokens may be
minted without quotient construction.

These are implementation policies, not new semantic concepts.

## Optional edge utilities

`worlds.presentation` and `worlds.history` remain optional descriptive and
observational libraries. Neither owns Geometry or authority.

## Verification

```sh
make full-check
```

runs the semantic, adversarial, work-ratchet and differential gates. The
Extended-Theory hostile lab in `speculation/theory/occurrence_relative` adds 48
cross-domain pressures, including generated Construction-image incidence checks.

See `docs/SHAPE.md`, `docs/LAWS.md`, `docs/PERFORMANCE.md`, and `docs/TRUST.md`.
