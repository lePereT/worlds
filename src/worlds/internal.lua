-- Worlds package-internal access to reference-model helpers.
-- Not exported by `worlds.lua`; external consumers should use the hardened Model
-- and Certified Reader surfaces instead.
return require('worlds.harden_core').internal
