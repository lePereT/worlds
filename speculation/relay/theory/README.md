# Relay Theory / Knowledge laboratories

The normative executable Theory model for current Relay research is deliberately thin:

- `knowledge.lua` is the only generic Knowledge host;
- a domain supplies exactly `equal`, `meet`, `reindex`, and `exists`;
- top, bottom, entailment and judgement are host-derived;
- exact identity, quotienting and provenance remain in Worlds;
- Construction transport uses native `Construction:correspondence()` generically;
- domains never receive a Worlds Construction;
- observation, portable encoding and domain-specific query interfaces are outside the domain contract.

`knowledge_contract/` is the executable algebraic specification of that boundary.
`lifecycle_and_correspondence/` contains the native-Worlds lifecycle/correspondence pressures. Its old
no-retraction engine is isolated under `historical/` and is evidence only, not another Theory host.

The computation laboratories under `speculation/relay/computation/` consume this host. Early
symbolic value equality is implemented as a specific domain in
`development_calculus/equality.lua`; recursive/viability finite relations are a laboratory adapter
over the same host. Neither is an alternative Knowledge semantics.

A new generic Theory operation should be treated as a failed design until a pressure shows it cannot
be derived from the four-operation regular-doctrine contract plus kernel-owned Worlds structure.
