# Verification target

Formalisation should preserve the architectural split rather than proving the
current search implementation as though it were the ontology.

The intended layers are:

```text
Geometry kernel
    exact open causal incidence

partial matching judgement
    A ; B |- E match

finite Question relation
    Q = (A,B,S,T,R,C,E0)

query engine
    executable proof/search machinery
```

## Geometry obligations

1. producer/consumer uniqueness and exact ingress/egress;
2. causal acyclicity before quotient;
3. causal authority/locality construction law;
4. boundary carrier preservation and idempotence;
5. typed equality closure of `join`;
6. SCC mutual-support normalisation and least common locality;
7. literal preservation of unaffected frame carriers.

## Matching-judgement obligations

1. exact source scarcity and target at-most-once closure;
2. ordered incidence and rigid imported Point identity;
3. target-local Point/Membrane substitution;
4. endpoint-locality/ancestry equalities;
5. target causal-development admissibility;
6. distinction from mere `join` definedness.

## Question obligations

For `Q=(A,B,S,T,R,C,E0)`, prove that `Solutions(Q)` is exactly the lawful matching
equation sets satisfying the finite source/target/required/admissible/seed
conditions. Presentation order must not affect this set.

`W.solve(A,B,seeds)` should then be a theorem-level abbreviation for the complete
Question.

## Engine obligations

Prove the current executable engine sound and complete for `Solutions(Q)`:

- endpoint-thread quotient correctness;
- factor join/projection preservation;
- provenance reconstruction correctness;
- Hall/fibre negative evidence soundness;
- finite scarce-relation completeness;
- `more` never implying `no`;
- retained search not retaining closed source history.

The package includes flat, selected-section, optional/admissibility, nested and
branching brute-force differential suites as executable evidence for these
obligations.
