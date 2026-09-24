# Laws

**Status: normative semantic laws for Worlds 0.6.3.**

## Carrier and Geometry

1. The semantic carrier kinds are Membrane, Point, Strand and Face; Geometry is
   the sole composite value carrying programme authority and causal structure.
2. Carrier identity is exact object identity. Names are correspondence/debugging
   data only.
3. Membranes form a finite parent forest. A Point, Strand or Face inhabits one
   exact Membrane.
4. Strand Point incidence is ordered. Face input/output incidence is a finite
   collection of distinct Strand occurrences; presentation order is not
   semantic.
5. A Strand has at most one producer and at most one consumer in valid Geometry.
6. Builder-produced Geometry is causally acyclic.
7. Every executable Face is reachable from open ingress.
8. Existing local Point/Membrane structure used downstream must be causally
   available through input incidence. Fresh Point/locality structure must be
   generated beneath causally available or freshly generated locality.

## Open boundary

9. Ingress is exactly the Strands with no producer.
10. Egress is exactly the Strands with no consumer.
11. `boundary(G)` contains exactly the exact egress Strands, owned Points
    incident on them, and owned Membrane ancestry required to interpret them.
    It contains no Faces or consumed Strands.
12. Boundary projection preserves every surviving carrier literally.
13. Boundary projection is idempotent: `boundary(boundary(G)) = boundary(G)`.
14. The operational ontology contains no finite-question policy. Matching is a
    judgement over exact source and target Geometry; Questions parameterise that
    judgement without becoming Geometry or authority.

## Matching and finite Questions

15. A matching judgement `A ; B |- E match` relates exact source egress in `A`
    to exact target ingress in `B`. It respects Strand arity, ordered Point
    incidence, rigid imported Point identity, target-local Point/Membrane
    substitution and endpoint-locality equalities.
16. Exact source Strand authority is scarce: one exact source occurrence cannot
    satisfy two target requirements in one solution. A target ingress closes at
    most once.
17. Matching is not defined by `join` alone. The target must satisfy the causal
    development constraints of the matching judgement, and every constructive
    `yes(E)` must denote equations whose strict `join` quotient is lawful Geometry.
18. Finite Questions have two exact forms: `Match(A,B,S,T,D,R,C,E0)` and
    `Close(P,S,T,D,R,C,E0)`. `D` requires source-domain coverage and `R`
    target-codomain coverage; `C` is finite admissibility and `E0` exact seeds.
19. Match solutions satisfy the directional matching judgement and the finite
    domain/range constraints. Close solutions are exactly finite equation sets
    satisfying those constraints for which strict `join(P,E)` is lawful Geometry.
20. Question sets/relations are exact and unordered. Their presentation order
    cannot create priority. The ordered part list of Close is exact because it is
    the list subsequently supplied to `join`.
21. `W.solve(A,B,seeds)` is only the complete Match Question: all source egress
    selected, all target ingress selected/required, no required sources and
    unrestricted admissibility. It accepts no other query policy.
22. `yes` is constructive exact evidence for one Question solution. `no` is
    exhaustive emptiness of that exact finite Question.
23. `more` is epistemic only: supplied fuel was insufficient to decide or
    continue enumerating the Question. It is never semantic refutation.
24. After one or more `yes` results, `done` means the exact finite Question has
    been exhausted.
25. Search representations, factor graphs, counted surfaces, endpoint quotients,
    Hall structures and provenance DAGs are implementation accelerations. They
    carry no authority and may be replaced without changing the Question
    solution relation.

## join

26. `join(parts, equations)` is the sole geometry-changing primitive. Parts are
    disjoint Geometry values; equations identify distinct open egress/ingress
    Strand occurrences.
27. A source egress may occur in at most one supplied equation and a target
    ingress may close at most once.
28. Strand equations induce typed equality closure over Strand, Point and
    Membrane structure. Imported/external exact identity is rigid.
29. The first joined part is the frame. Unaffected frame carriers survive
    literally; non-frame structure is instantiated as required by the quotient.
30. Causal cycles induced by joining are not serialised arbitrarily. Each causal
    SCC is normalised to one joint Face.
31. A joint Face inhabits the least common enclosing Membrane of the member
    Faces after the induced Membrane quotient.
32. Open incidence not internalised by equations remains open.
33. `join` returns an image from input carriers to their resulting carriers;
    cyclic member Faces map to the resulting joint Face.

## Live evolution and history

34. `advance(world, development, equations)` is definitionally
    `boundary(join({boundary(world), development}, equations))` plus the join
    image. It is not a second composition semantics.
35. Live execution may therefore remain permanently at the boundary fixed
    point. Closed causal interior has no hidden authority over later `solve`.
36. `worlds.history` is optional observation. It may record developments,
    equations and carrier images, but the kernel never consults it when deciding
    future development.

## Scope of the laws

37. Scarcity is exclusivity of exact open occurrences, not a conservation law:
    an explicit Face may consume one Strand and produce many fresh Strands.
38. Exact Point or Membrane identity is not itself causal authority.
39. Domain equality, rates, amplitudes, logical admissibility and other
    extensional interpretation are outside the kernel unless explicitly
    represented by Geometry.
40. Raw exact Geometry is not claimed to be a minimal observational quotient.
    Any stronger extensional/full-abstraction claim requires an explicitly
    stated observation/Theory equivalence.

## Construction witnesses and presentations

41. `Construction.join(parts,E)` performs exactly the existing `join(parts,E)`
    materialisation and records its exact construction data. Construction is not
    another Geometry-changing primitive.
42. A Construction carrier image is exact and construction-relative. Exact
    carrier identities from different materialisation paths need not coincide.
43. A Presentation is a finite ordered family of rows of exact open Strand
    occurrences relative to one exact ambient Geometry. It is not Geometry and
    carries no programme authority.
44. Presentation row order, coordinate order and multiplicity are presentation
    semantics only. They impose no causal order or scarcity law on the ambient
    Geometry.
45. Any number of Presentations may describe one exact Geometry. Inclusion,
    omission or repetition of a Strand in a Presentation neither grants,
    consumes nor removes authority.
46. Transport through a Construction maps Presentation coordinates pointwise
    through the exact construction image, retaining in order and with
    multiplicity precisely those mapped Strands which remain open in the result.
    Transport creates no carrier or causal authority.
