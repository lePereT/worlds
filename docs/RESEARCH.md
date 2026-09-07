# Research

**Status: non-authoritative research ledger.**

## Why this clean implementation exists

Research-7 established the whole-model hypothesis through successive
simplifications.  This tree asks whether the model can be rederived cleanly from
its laws without carrying the mechanism of discovery.

The main result so far is positive: the same semantic gate passes with a small
implementation and a simpler operational representation.

## Compile-time / runtime continuum

Open geometry can be closed whenever the required information becomes known:

```text
source -> module compilation -> linking -> whole-program distillation
       -> startup -> runtime event arrival
```

The semantics does not change with the time of resolution.  Realise may erase a
fully resolved relationship, residualise it to a specialised state machine, or
retain genuinely dynamic Cut search at runtime.

## Expressive adequacy of the four-carrier geometry

The central long-term question is not whether individual language constructs can
be encoded, but what class of resource-sensitive computation is faithfully
presentable using only Membrane, Point, Strand and Face together with Cut,
closure, causal authority and Theory.

A useful formal result would characterise the expressive boundary rather than
merely accumulate examples.  Possible targets include a representation theorem
for a well-defined finite process class, together with counterexamples showing
which additional assumptions belong in Theory or require genuinely new
structure.

This question should remain falsifiable.  If an important systems phenomenon
cannot be represented without smuggling hidden ontology through imported Points,
Theory or operational state, that is evidence against the current model rather
than a reason to rename the hidden mechanism.

## Correspondence with established process models

Worlds has clear neighbours in Petri/occurrence nets, event structures, graph
rewriting, bigraph-like locality, linear/resource logics and higher-dimensional
models of concurrency.  The research goal is not to identify Worlds loosely with
one of them, but to establish precise translations where useful.

Questions include:

- Which fragments translate faithfully in each direction?
- What does exact Point identity correspond to?
- How does scarce Strand authority compare with token/condition semantics?
- When does Cut/close correspond to pushout-like or net composition?
- Which commuting cubes correspond to standard independence notions?
- What extra structure is contributed by membranes and rigid imported Points?

Such correspondences could provide existing theorems, counterexamples and
terminology without making another formalism part of the kernel implementation.

## Trace and feedback

Same-occurrence self-Cut is deliberately rejected: identifying an open Strand
with itself does not close a boundary and provides no coherent authority or
causal account.

If feedback/trace is needed, it should therefore be derived as a distinct law.
A valid proposal must answer at least:

- which distinct boundary occurrences are hidden or connected;
- how scarce authority moves;
- whether new Face incidence is created;
- how causal acyclicity is preserved or deliberately generalised;
- what remains observable at the external boundary;
- how operational execution represents the feedback without retaining hidden
  closed history.

It is possible that useful feedback belongs in a higher Theory rather than the
base algebra.  Experiments should establish that rather than assume a traced
structure because it is mathematically attractive.

## Distributed and observer-relative execution

The current operational model has one exact live boundary for one executing
semantic world.  Distributed systems pressure the assumption that one observer
has immediate authoritative knowledge of the whole relevant boundary.

Research questions include whether several agents can maintain partial/local
boundaries and reconcile them using ordinary exact geometry, and which facts
must become explicitly observer-relative rather than being forced into a global
actuality/state notion.

Relevant hostile cases include network partitions, delayed observation,
distributed ownership transfer, replicated read authority and remote failure.
The preferred outcome is to preserve the small carrier model and express
knowledge/observation in Theory or explicit open geometry; adding a hidden global
history or omniscient scheduler would undermine the operational result.

## Infinite and probabilistic computation

The current kernel is deliberately finitary: a Geometry and a concrete Cut
query are finite objects.  Long-running execution is represented by unbounded
fresh finite development while operational state may remain bounded by the live
boundary.

Two possible extensions should be investigated without changing this base
prematurely:

- coinductive/infinite semantic observations over an unbounded sequence of
  finite developments;
- probabilistic or weighted Theory over alternative admissible developments.

The questions are whether these can live entirely as interpretations over the
finitary kernel, what notion of equivalence is appropriate, and whether
`Hit`/`Retry`/`Unknown` requires extension when the question being asked is about
measure or limit behaviour rather than finite existence.

## Stronger concurrency and non-interference theorems

The current theorem programme covers frame preservation, commuting history and
boundary, Cut-family coherence, tensor symmetry, Boolean cubes, mutual support
and boundary-sufficient Theory.  A longer-term goal is a more general account of
when local developments commute, conflict or remain observationally
independent.

Possible results include:

- a concurrency theorem relating sequential closures to a simultaneous
  composite closure;
- residual/non-interference criteria derived solely from exact boundary
  authority;
- higher-dimensional coherence beyond the finite cube tests;
- sufficient conditions under which independent operational updates may execute
  in parallel without coordination;
- compatibility of these results with Theory quotienting.

These theorems matter directly to Relay because they could justify parallel
compiler/runtime execution without introducing a scheduler order into semantics.

## Formal adequacy of translations

As Relay and other experiments use Worlds, it will become useful to prove that a
translation preserves and reflects the intended observations rather than merely
passing tests.

Candidate adequacy results include:

- a small Relay core -> Worlds translation;
- Worlds -> a simpler reference transition/process semantics;
- selected established calculi -> Worlds and back;
- operational boundary execution -> full-history semantics.

The goal is not to formalise every language feature.  A few small, independent
translations with preservation/reflection theorems would provide a valuable
check that the executable kernel is not the only authority describing its own
meaning.

## Current open questions

1. Prove or falsify the history/boundary commuting square.
2. Prove coherence of simultaneous closure and SCC normalisation.
3. Characterise the exact algebraic structure of tensor/partial Cut/closure.
4. Formalise boundary-sufficient Theory and quotient-sensitive attachment.
5. Pressure-test irreversible external effects, weak memory, atomics, DMA and
   interrupts without granting closed history hidden authority.
6. Establish a durable separately compiled artefact representation without
   requiring global graph canonicalisation.
7. Determine whether trace/feedback belongs in the kernel algebra, a higher
   Theory, or is unnecessary for the intended systems domain.
8. Characterise the expressive adequacy boundary of the four-carrier model.
9. Establish precise correspondences with at least one established concurrency
   or rewriting model.
10. Determine whether distributed/observer-relative execution and probabilistic
    or infinite observations can remain interpretations over the finitary core.

## Face incidence

Face input/output incidence is semantically set-valued.  The implementation may
use compact arrays as unordered enumerations; presentation order is not semantic.
This removes the tensor-order leak in joint-Face SCC contraction without adding
a canonical semantic ordering.
