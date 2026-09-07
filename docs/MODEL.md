# Model

**Status: maintained explanatory model; `LAWS.md` is authoritative on conflict.**

## 1. Open Geometry

A finite Geometry is a nested open 2-complex.  Ingress is exactly the Strands
without producers; egress is exactly the Strands without consumers.

Names are correspondence data only.  Exact carrier identity is object identity
in this reference implementation.

## 2. Tensor

`P ⊗ Q` is juxtaposition.  It introduces no interaction and no scheduling order.

## 3. Cut

A Cut is an exact proof/search relation between open ingress and an explicitly
supplied finite set of exact offered Strands.  It is injective in Strand
authority and solves Point equality plus membrane-topology equations induced by
that wiring.  A closure link always relates two distinct exact Strand
occurrences.  An occurrence which is simultaneously ingress and egress cannot
be "closed to itself"; any future trace/feedback operation would require its
own law rather than a no-op self-identification.

Cut creates nothing and executes nothing.

## 4. Close

`close(parts, links)` simultaneously internalises exact terminal-to-ingress
wiring and materialises the resulting open Geometry.

Mutual causal support is simultaneity, not an arbitrary serialisation.  Each
closed support SCC contracts to one joint Face.  Its semantic locality is the
least common enclosing membrane of its member occurrences after cut-induced
membrane equations.

## 5. Boundary-relative Point roles

Point behaviour is derived from the boundary being composed:

- an imported Point is rigid exact identity;
- a local Point occurring on ingress is a variable supplied by the environment;
- a local Point introduced only downstream is a fresh existential of that
  complete development.

No Point tag records these roles.

## 6. Causal authority

Structural Cut compatibility is weaker than executable authority.

Existing locality may change only when consumed exact ingress authority
causally supports that locality.  Merely knowing a Point or Membrane, or merely
forwarding a Strand, is not modification authority.

## 7. State and execution

For exact history `H`, operational state is `∂⁺H`.

The semantic execution equation is:

```text
       close
H ---------------> H'
|                   |
egress              egress
|                   |
v                   v
B -------step------> B'
```

`Operational` implements the bottom path directly.  It stores only a set of
exact live egress Strands and does not retain the closed causal interior.

## 8. Theory

Worlds provides exact/intensional structure.  Domain equality, admissibility and
quotients belong to Theory outside the kernel.  A Theory with authority over
future execution must be boundary-sufficient: if historical fact matters later,
its relevant consequence must remain represented on the open boundary.
