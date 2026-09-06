-- Public Lua trust boundary for Worlds.
--
-- The implementation lives in `harden_core.lua` so package-internal modules can
-- share the same proxy state without exposing reference helpers on Model handles.
return require('worlds.harden_core').public
