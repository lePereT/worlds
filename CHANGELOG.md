# Changelog

## 0.1.0 — first external-consumer release

The first version intended to be pinned by an external compiler, with Relay as the first consumer.

### Kernel

- opaque World/Point/Strand/Face handles and opaque Model state;
- actuality derived from World reachability, with no latency or World-state bit;
- transactional construction and Point-equivalence rollback;
- explicit `admit`, `copy` and `discard` structural operations;
- certification of actual geometry and detached stages;
- immutable Certified View/Reader observation;
- Point-equivalent structural matching;
- local `develop` with incoming demand and outgoing egress frontiers;
- prospective use-site checking: non-linear late aliasing is rejected before grafting;
- World retirement judgement without lifecycle metadata.

### Separate compilation

- portable `worlds.unit/1` geometry with derived demand/egress frontier;
- pure `Separate.validate_unit` before installation;
- atomic unit import;
- private identity correlation preserved without private names.

### Frontier abstraction

- `worlds.frontier-artifact/1`;
- variadic abstract Point rows outside the kernel;
- equivalence-shape extraction;
- complete source-less `specialise` into ordinary `worlds.unit/1` geometry;
- empty rows and multiple independent variables;
- no FrontierVar may cross into the kernel.

### Verification checkpoint

```text
118 directed tests
10,500 generated stress/differential cases
```

Formal mechanisation remains a documented next step; no theorem-prover dependency is included in 0.1.0.
