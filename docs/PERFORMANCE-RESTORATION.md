# Performance restoration after the finite-Question split

**Status: implementation note for the revised 0.6.0 tree.**

The finite Question API remains unchanged. The restoration is an implementation
change: verified Geometry, finite Question semantics and query acceleration stay
separate, but the query engine no longer reconstructs verified Geometry through
copying public accessors on every solve.

## Internal layering

```text
verified exact Geometry centre (`worlds._kernel`)
        |
        | private read-only observation
        v
public edge (`worlds`) / rebuildable acceleration (`worlds._compiled`)
        |  outgoing structural fibres
        |  open-boundary positions, lazily where needed
        v
finite Question judgement (`worlds.query_factory`)
        |
        v
replaceable search engine (`worlds.query_engine`)
```

`worlds._compiled` is not public API and contributes no Geometry identity,
authority or matching policy. Its contents can be discarded and reconstructed
from verified Geometry.

## Restored properties

- `W.solve` retains one injected Question/engine instance per exact kernel
  instance, so ingress and ancestry caches survive repeated solves.
- Complete Question defaults are represented symbolically. `S = egress(A)`,
  `T = ingress(B)`, `R = T` and `C = S x T` do not cause copies or membership
  maps merely because they are complete.
- The public Builder edge precompiles the outgoing structural section after the
  verified centre has produced a Geometry. The centre has no dependency on that
  preparation. Boundary projection reuses acceleration naturally when exact
  egress is preserved.
- Transient `join` output does not eagerly allocate query-only position maps or
  source indexes which `boundary()` is about to discard.
- The engine consumes a private read-only view of already verified incidence,
  producer/consumer and developability data. Public Geometry accessors continue
  to return defensive copies.
- `W.solve` has a complete-coverage constructor which enters the same query
  machine directly. It does not introduce a second matcher.

## Comparative observation

TexLua observations on the same host, from unchanged `bench/run.lua` workloads:

| case | original clean boundary | API-split checkpoint | revised |
| --- | ---: | ---: | ---: |
| broad-1000 first | 0.0418 s | 0.0575 s | 0.0444 s |
| broad-1000 cached | 0.00359 s | 0.0385 s | 0.00372 s |
| shared-unsat-5000 | 0.0234 s | 0.0934 s | 0.0277 s |
| odd-C7-K5,5 | 0.00745 s | 0.00916 s | 0.00771 s |
| rigid-100k | 0.0197 s | 1.7666 s | 0.0205 s |
| depth-3000 first | 0.0169 s | 0.0382 s | 0.0174 s |
| depth-3000 cached | 0.00211 s | 0.0346 s | 0.00288 s |

The exact-enumeration case remains output-sensitive and is within ordinary run
variance of the original implementation.

A direct public-Question rigid-100k probe measured:

```text
API-split checkpoint: Question construction 0.401 s; total 1.543 s
revised:              Question construction 0.00004 s; total 0.0325 s
```

These figures are development observations, not portable timing guarantees. The
important restored shape is that complete rigid lookup does not acquire an
O(|egress|) Question-construction scan, and repeated complete solves reuse their
compiled target/ancestry state.
