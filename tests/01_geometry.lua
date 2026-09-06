local S=require('tests.support')
local G=S.G

local b=G.builder()
local W=b:membrane(nil,'scope','W')
local P=b:point(W,'X','x')
local s0=b:strand(W,'cell',{P},'before')
local s1=b:strand(W,'cell',{P},'after')
local f=b:face(W,'write',{s0},{s1},'write')
local g=b:finish()

S.eq(g:producer(s0),nil)
S.eq(g:consumer(s0),f)
S.eq(g:producer(s1),f)
S.eq(g:consumer(s1),nil)
S.ok(g:is_input(s0))
S.ok(g:is_terminal(s1))
S.eq(g:find('point','x'),P)

S.raises(function() g.foo=1 end,'immutable')

-- Scarcity is geometry: one Strand cannot have two consumers.
S.raises(function()
  local x=G.builder(); local m=x:membrane(); local p=x:point(m,'X')
  local a=x:strand(m,'R',{p}); local z1=x:strand(m,'R',{p}); local z2=x:strand(m,'R',{p})
  x:face(m,'a',{a},{z1}); x:face(m,'b',{a},{z2}); x:finish()
end,'at most one consumer')

-- Causal cycles are impossible even though membrane topology is independent.
S.raises(function()
  local x=G.builder(); local m=x:membrane(); local p=x:point(m,'X')
  local a=x:strand(m,'R',{p}); local b1=x:strand(m,'R',{p})
  x:face(m,'a',{a},{b1}); x:face(m,'b',{b1},{a}); x:finish()
end,'acyclic')

print('ok 01_geometry')
