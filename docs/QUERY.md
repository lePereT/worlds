# Finite matching Questions

**Status: normative definition of the finite matching judgement layer.**

This layer is deliberately outside the Worlds operational ontology. A Question
carries no authority, is not transported programme meaning and does not change
Geometry. It parameterises one finite judgement about exact open Geometry.

## Normal form

A Question is:

```text
Q = (A, B, S, T, R, C, E0)
```

with:

```text
A  source/world Geometry
B  target/development Geometry
S  subset of egress(A)
T  subset of ingress(B)
R  subset of T
C  subset of S x T
E0 subset of C
```

`C` is omitted in the API when it is the complete relation `S × T`.

`S`, `T`, `R`, `C` and `E0` are mathematical sets/relations. Presentation order
is not semantic.

The implementation need not materialise a complete set merely to represent it.
When `S`, `T`, `R` or `C` take their defaults, the Question stores that fact
symbolically and materialises defensive arrays only if a public accessor asks
for them. This is an implementation choice and does not alter the normal form.

The roles of `A` and `B` remain distinct when they are the same exact Geometry.
This is required for same-Geometry questions such as internal sibling closure.

## Matching judgement

Write:

```text
A ; B |- E match
```

when the exact equation set `E` is a lawful partial realisation of target ingress
against source egress. The judgement incorporates the intrinsic Worlds matching
laws:

- exact source scarcity;
- at-most-once target closure;
- Strand arity and ordered Point incidence;
- rigid imported Point identity;
- target-local Point/Membrane substitution;
- endpoint locality equality and ancestry constraints; and
- the causal-development condition on `B`.

Matching is not defined as mere successful materialisation by `join`. `join`
answers whether already-chosen open equations produce a lawful quotient Geometry;
matching additionally answers whether those source occurrences lawfully realise
the target development pattern.

## Solutions

`E` is a solution of `Q` exactly when:

```text
A ; B |- E match

E0 subset E
E subset C
domain(E) subset S
codomain(E) subset T
R subset codomain(E)
```

with exact scarcity/target uniqueness supplied by the matching judgement.

An optional target is simply a member of `T \ R`. No `optional_ingress` semantic
operation exists.

A disallowed source/target pair is simply absent from `C`. No `forbid` semantic
operation exists.

## Complete solve

The ordinary Worlds convenience:

```lua
W.solve(A, B, seeds)
```

means:

```text
S = egress(A)
T = ingress(B)
R = T
C = S x T
E0 = seeds
```

and delegates to the Question judgement.

`W.solve` accepts no other policy fields. General questions use
`require('worlds.query')`.

## API

```lua
local Q = require('worlds.query')

local question = Q.new(source, target, {
  sources = selected_source_egress,     -- optional; default all
  targets = selected_target_ingress,    -- optional; default all
  required = required_targets,          -- optional; default targets
  admissible = exact_pairs,             -- optional; default S x T
  seeds = exact_seed_equations,         -- optional
})

local search = Q.solve(question)
```

The Question value is immutable and keeps its private state in lexical closures. Its public accessors return copies of the finite sets/relations. The specification is closed to `sources`, `targets`, `required`, `admissible` and `seeds`; unknown fields are rejected. All finite collections are dense Lua arrays, so sparse tables fail rather than being interpreted through `#`/`ipairs` truncation.

## Epistemic result

The engine returns:

```text
yes(E)   constructive exact solution
no(C)    exhaustive absence for this exact finite Question
more     incomplete calculation
done     enumeration exhausted after one or more yes results
```

`no` carries an immutable `Refutation` tied to the exact finite Question that
was proved empty. The Refutation is positive evidence about that Question; it is
not Geometry, authority or programme state. It currently retains the exact
boundary-normal Question and a diagnostic reason. Minimal dependency support and
incremental invalidation frontiers are deliberately not claimed yet.

## Engine separation

`worlds.query_engine` is replaceable implementation machinery. It currently uses
counted source sections, endpoint-thread quotienting, factor elimination,
provenance support, Hall feasibility and exact allocation.

A retained engine state does not retain `A` itself. It retains only the exact
outgoing source section needed by the Question plus the target development and
its own calculation.

Changing the engine must not change `Solutions(Q)`.
