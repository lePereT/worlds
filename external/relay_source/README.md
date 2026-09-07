# External Relay source experiment port

This is deliberately outside the Worlds kernel and uses only its public API.  It
reuses the original tiny Relay source syntax and examples while rebuilding the
compiler against the whole-model algebra rather than through a 0.4 compatibility
layer.

The external compiler exercises:

- generic function syntax with no lower `Generic` carrier;
- interface-provider alternatives as exact open process branches;
- higher-order `via` provider requirements;
- nested source handlers;
- `choice`, `or_else`, `and_then`, `each` and `together`;
- cyclic provider requirements remaining `Unknown`;
- task lifetime as ordinary terminal Strand obligation;
- transactional failure by discarding provisional immutable developments.

Resource operations are ordinary open state-transition Geometry. `each` uses
tensor. `together` closes compatible sibling state boundaries before exact
composition with current state.  The experiment is not the new Relay compiler;
it is an external falsification client for Worlds 0.5.
