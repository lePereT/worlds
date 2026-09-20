# Quantum atlas experiments against Worlds 0.6.2

Non-authoritative research experiments. They modify neither Worlds nor Relay and
use no external mathematical packages.

Run with the repository speculation corpus:

```sh
make speculation-check
```

The experiments deliberately attack quantum structure through incidences already
present in Worlds rather than by adding a quantum carrier or quantising the
kernel.

## Experiments

- `contextuality_scope.lua` — Mermin-Peres contextuality as a face-free cover of
  six overlapping Point-Strand scopes over nine exact observable Points. Every
  context is locally satisfiable; all six have no global +/-1 section; deleting
  any one context restores exactly 16 sections. This uses arbitrary overlap in
  Point-Strand incidence and requires no non-laminar membrane extension.
- `permutation_fibres.lua` — three exact Strands in one structural row generate
  the six exact allocations of S3. Summing the trivial character gives 6 while
  the sign character cancels to 0, a Pauli-style repeated-state exclusion toy.
  Exact causal individuality is retained: consuming one fibre member does not
  consume its siblings.
- `interference_boundary.lua` — two exact alternative causal constructions reach
  one structural boundary row. Amplitudes combine within that observational
  class. Exact which-path Points refine the class and remove interference;
  causal erasure returns the paths to one class and makes interference available
  again. The amplitudes remain external Theory data.
- `phase_holonomy.lua` — local U(1)-like phase weights on exact causal histories
  transform under internal basis rephasings, but internal gauge factors cancel
  along each route. Relative phase and interference probability are invariant.
  This tests phase as structure on histories/transport rather than payload on a
  carrier.
- `classicality_copy.lua` — the same explicit two-system geometric correlation
  operation copies computational-basis classical information but maps |+>|0> to
  a Bell state rather than cloning |+>. This treats classicality as a Theory-
  certified copyable substructure over explicit scarce authority.
- `monoidal_semantics.lua` — a first process-semantic attack: sequential Worlds
  composition corresponds to matrix multiplication, disjoint juxtaposition to
  tensor product, and the elementary interchange law agrees. This supports
  treating quantum mechanics as a compositional semantics of Worlds processes.
- `locality_joint_state.lua` — hostile test. A scarce joint state-factor Strand
  over Alice and Bob must be consumed at joint/root support to be updated, even
  when Bob authority is untouched. An Alice-only Face stays Alice-local if the
  joint state is updated externally in Theory. This warns against making an
  extensional global state description itself into causal authority merely to
  expose its scope.

## Current synthesis

The experiments suggest that different quantum phenomena attach naturally to
different existing Worlds structures:

```text
contextuality          overlapping Point-Strand scopes
identical particles    exact occurrence fibres + permutation representations
interference           exact alternative histories + observational boundary class
phase                  gauge-like weights/holonomy over histories
classicality           Theory-certified copyability of explicit processes
process semantics      join / juxtaposition interpreted by composition / tensor
locality/no-signalling local scarce authority, with global extensional state in Theory
```

The strongest revision to the earlier two-layer toy is that amplitude/state
*factors* should not automatically be promoted to scarce Strands. Point-Strand
incidence is excellent for exact scope/factorisation when an occurrence really is
a resource. For global quantum state, the locality test suggests a more careful
split: Worlds carries subsystem identity, causal authority, history and the
structural scopes on which propositions are stated; Theory may carry the
extensional state and its update under local Faces without manufacturing global
causal permission.

The radical research possibility is therefore not a single missing quantum axis.
It is that quantum phenomena may be semantics on several already-independent
incidences of Worlds, with their compatibility providing the useful structure.
