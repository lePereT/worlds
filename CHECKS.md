# Worlds 0.6.3 release acceptance record

Worlds 0.6.3 is an additive semantic-edge release. The verified Geometry centre
and main `require('worlds')` facade are unchanged from the 0.6.2 between-Worlds
baseline. Two optional edge modules are added:

```text
worlds.construction
worlds.presentation
```

No carrier kind, Geometry law, `boundary`, `join`, `advance`, Question or query
engine semantics changed.

## Source-identity gate

The exact baseline and release hashes agree for the two critical centre files:

```text
src/worlds/_kernel.lua
  e8147b5e56f8fad44dce629f5e5cdef84a0483da076bc749c96aeba99353606d

src/worlds.lua
  20cba8a8badbde15321c97d335e0743f5e3f5c9bb9b241af8515f03d97505a85
```

A recursive comparison against the packaged 0.6.2 between-Worlds tree shows no
modification to any existing file under `src/`; only these files are new:

```text
src/worlds/construction.lua
src/worlds/presentation.lua
```

The shape guard additionally checks that:

- the main facade does not import or re-export either module;
- Construction delegates to ordinary public `W.join` and contains no duplicate
  quotient implementation or direct `_kernel` dependency;
- Presentation neither calls `join` nor Builder and transports only through an
  actual Construction image; and
- both new immutable values use closure-owned hidden state rather than weak
  registries or protected-metatable labels as identity.

## Maintained semantic gate

`make full-check` completed successfully with TexLua on the release tree:

```text
PASS 0.6.3                         5110 assertions
PASS query                           78 assertions
PASS closure query                   51 assertions
PASS construction                    57 assertions
PASS presentation                    49 assertions
PASS optional history               165 assertions
PASS 0.6.3 adversarial               36 assertions
PASS work constitution                57 assertions
PASS verified centre without acceleration
PASS shape 0.6.3 centre/edge split
PASS differential10k              10000 assertions
PASS restricted differential       5000 cases
PASS partial differential        104510 assertions
PASS nested differential            3000 cases
PASS branching differential         3000 cases
PASS closure differential           2000 cases
PASS historical algebra               15 files
```

The new Construction tests cover immutable copied inputs, normalised equations,
frame/template asymmetry, exact image access, SCC many-to-one Face transport,
cyclic Strand annihilation, staged surviving transport and public dense-array
validation.

The new Presentation tests cover exact ambient membership, open-Strand
validation, empty rows, omitted authority, repeated coordinates, exact same-row
fibres with different positional order, pointwise identification without
multiplicity collapse, residual removal of internalised or SCC-annihilated
coordinates, zero-result non-causality, staged transport and exact-part
authorisation.

In particular, if distinct presented coordinates `s1` and `s2` are identified by
construction and both map to one surviving open Strand `t`, transport preserves
presentation multiplicity as `[t,t]` rather than deduplicating to `[t]`.

## Speculation gate

`make speculation-check` completed successfully on the exact release tree. It
executed all 81 Lua chunks under `speculation/`, including 41 Lua chunks in the
cross-domain dimensional laboratory and its shadow/fibre/between-Worlds work.

The retained non-authoritative programme includes:

- intrinsic face-free/configurational structures;
- fixed-shadow filling and causal-polarisation fibres;
- Membrane support and causal-spine experiments;
- high-dimensional realisation-fibre topology probes;
- exact construction-history fibres;
- source-relative construction groupoids through ordinary and SCC joins;
- provenance/symmetry and inter-World structural-versus-causal move pressures.

Python homology/fundamental-group research scripts are preserved under the same
speculation tree but remain outside `make speculation-check`; they are not
release semantics or release gates.

## Production boundary

The release deliberately stops at two promoted distinctions:

```text
Construction
    immutable witness of one exact ordinary join materialisation

Presentation
    immutable ordered non-authoritative view of selected exact open Strands
```

`Presentation:transport(construction)` maps coordinates pointwise through the
exact construction image and retains only mapped Strands which remain open in
the result, preserving row order and multiplicity. It creates no carrier,
authority, sequencing or completion.

No W1/W2/W3 API, rank, higher cell, cut, canonical dimensional reduction or
arbitrary inter-World adjacency is part of Worlds 0.6.3.
