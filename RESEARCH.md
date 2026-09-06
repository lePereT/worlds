# Open research

`LAWS.md` states the Worlds 0.4.0 kernel. This document records current open
work only.

The working interpretation is that Worlds supplies a free/intensional geometry
of computation:

```text
immutable nested directed 2-complex
+
contextual selection
+
exact attachment substitution
+
fresh gluing
```

Domain Theories add only the semantics which exact geometry cannot honestly
know: admissibility, extensional observation, symbolic domain laws and, where
required, quotient-sensitive composition.

## Formalisation

The executable Lua implementation should be accompanied by a small formal
model. The most useful initial results are:

- preservation of geometry well-formedness under fresh gluing;
- scarcity preservation for Strand authority;
- precise substitution and freshness properties for Points;
- exactness of attachment evidence consumed by gluing;
- conditions under which commuting developments establish higher-dimensional
  independence;
- a clear statement of which derived constructions are invariant under exact
  isomorphism and which require an explicit Theory quotient.

## Theory constitution

Theory is intentionally outside the kernel, but its boundary needs a durable
formal account.

Open questions include:

- what laws an admissibility judgement must satisfy;
- how `unknown` propagates without becoming either permission or refutation;
- when a Theory equality is a congruence for the contexts it exposes;
- when quotient-sensitive attachment `Att^T` is independent of representative
  choice;
- how independently useful Theories compose;
- whether useful classes of Theory can be expressed declaratively rather than
  as arbitrary trusted code;
- which domain facts should be represented symbolically rather than by literal
  geometric expansion.

## Geometric products and open processes

Current experiments support a particularly small account of open-process
products without adding kernel ontology.

The promising construction is:

```text
each(L1,...,Ln)
    symmetric product / juxtaposition of open lane geometries
    without sibling output-to-input cuts

together(L1,...,Ln)
    the same product
    plus compatible internal sibling cuts
```

Under this reading, sibling consumption constrains a complete candidate through
ordinary Strand scarcity, while sibling-produced authority becomes available to
another sibling only when an internal cut is admitted.

This has already survived representative counter and ordered-index resource
examples, including sibling-order symmetry. It should now be characterised as a
proper derived construction rather than remaining an experiment-specific
algorithm.

Open work includes:

- precise symmetric product and internal-cut definitions;
- associativity, symmetry and coherence of nested products;
- whole-candidate Theory observations independent of source lane order;
- cyclic mutual support and the conditions under which a support SCC denotes
  one simultaneous joint Face rather than illegal causal cyclicity;
- proof that source correspondence can recover result ordering without making
  source order semantic;
- interaction with quotient-sensitive process Theories.

## Symbolic resource geometry

Fine geometry is useful for expressing scarcity exactly, but literal expansion
is not always a viable semantic representation. A counter value of four billion
must not require four billion explicit Unit Strands in a compiler.

Work is needed on Theory-supported symbolic presentations which retain the same
resource laws while allowing compact semantic and physical representations.
This is also a useful test of the division between free exact geometry and
domain-specific extensional Theory.

## Responsibility and causal suspension

Relay and Fibers are important pressure tests for whether ordinary geometric
obligations can account for continuing responsibility without introducing
special task/scope/lifetime carriers.

Work remains to recover, from geometry plus Theory where necessary:

- transactional task admission;
- cancellation and cancellation propagation;
- supervision and failure policy;
- body completion versus complete retirement;
- transfer of continuing responsibility;
- failed retirement and recovery authority;
- obligations retained across causal suspension.

## Irreversible effects

Immutable Geometry gives clean provisional semantic development, but it does not
undo physical reality.

A serious client needs a principled boundary between:

```text
provisional semantic development
        -> commit
        -> irreversible physical discharge
```

The relation between effect obligations, commit evidence, failure after commit
and continuing responsibility remains open work above the Worlds kernel.

## Performance

The reference implementation is deliberately small, but production clients need
attachment and Theory reasoning to scale well from the beginning.

Important areas include:

- locality-sensitive candidate indexing;
- retained and incremental attachment search;
- decomposition into independent membrane/incidence components;
- compact immutable representation and structural sharing;
- memoised Theory judgements against stable semantic identities;
- parallel candidate filtering and matching;
- batch operations suitable for SIMD or GPU acceleration where measurements
  justify it;
- stable semantic fingerprints for incremental and separate compilation clients
  such as Relay.

Search-resource limits must remain operational only. Exhausting a budget may
produce `unknown`; it must never become semantic impossibility.

## Physical systems pressure tests

The next broad tests should come from places where abstract ownership calculi
usually meet physical reality:

- memory regions and allocation;
- atomics and weak-memory observation;
- interrupts;
- DMA and device-visible memory;
- MMIO and volatile observation;
- physical locality and coherence;
- distributed or observer-relative interpretations of actuality/locality.

The important question is not whether each domain can be encoded somehow, but
whether it can be expressed while preserving the small Worlds kernel and
placing genuinely domain-specific law in Theory rather than growing new kernel
ontology.

New kernel concepts should be introduced only when a pressure test demonstrates
a law which cannot be expressed cleanly through existing geometry plus an
appropriate Theory.
