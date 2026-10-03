# Construction-image kernel finding

The expanded hostile suite uncovered one foundational issue which is independent
of the extended-Theory hypothesis.

## Required law

Occurrence-relative Theory rebases an exact carrier reference only through the
actual Worlds Construction image.  Therefore, for surviving carriers, that image
must be compatible with the structural incidence which gives the carrier its
meaning:

- a Membrane image's parent must be the image of the old parent, modulo parent
  contraction;
- a Point image must inhabit the image of its old Membrane;
- a surviving Strand image must inhabit the image of its old Membrane and carry
  the ordered images of its old Points.

X44 checks this over **3,222 generated quotient attempts**.

## Stock Worlds 0.6.4 result

The ordinary Worlds full-check passes, but X44 finds a counterexample:

```text
Point placement did not commute with image
```

The cause is frame reuse after an induced Membrane quotient.  An affected frame
child/Point can be reused literally even when its parent/support class has been
mapped to a different result Membrane.  The returned result remains a Geometry,
but the Construction image no longer represents one coherent quotient of the
input incidence.

## A second issue exposed while repairing reuse

The earlier proof-lab patch rematerialised affected frame Membranes and Points.
That made X44 green, but a generated census found **30** cases where the patch
recursed until stack overflow.

All 30 have the same structural character: the boundary equations identify a
Membrane with a strict descendant (possibly through several equations), making
the induced quotient-parent relation cyclic.  Stock 0.6.4 reports those joins as
successful only because stale frame incidence masks the cycle.

The refined candidate therefore adds two mechanics rules:

1. reject an equation set when the induced Membrane-class parent relation is
   cyclic (`inconsistent boundary equation`);
2. reuse a frame Membrane/Point only when its literal parent/placement already
   agrees with the materialised quotient incidence; otherwise rematerialise it.

The 3,222-case comparison changes exactly **30** stock `OK` results to
`inconsistent boundary equation`; no other lawfulness result changes.

## Candidate verification

With the refined mechanics candidate:

- X44: 3,222/3,222 generated attempts satisfy image-incidence compatibility when
  lawful;
- extended-Theory hostile suite: **48/48 pass**;
- Worlds `full-check`: PASS, including all differential suites;
- native `tests/construction.lua` includes both the reparent/rematerialisation
  regression and explicit descendant/ancestor quotient-cycle rejection.

This is a candidate Worlds mechanics correction, not part of the Theory model
and not claimed here as an official 0.6.4 change.
