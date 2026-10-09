-- Compatibility only: lets the old 48 pressures prove that their explicit
-- retract lists have no semantic effect. New code should use positive_theory directly.
local Strict=require('speculation.relay.theory.lifecycle_and_correspondence.historical.positive_theory')
local A={}
for k,v in pairs(Strict) do A[k]=v end
function A.rule(g,spec)
  spec=spec or {}
  return Strict.rule(g,{requires=spec.requires,asserts=spec.asserts,schemas=spec.schemas})
end
return A
