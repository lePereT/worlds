local S=require('tests.support')
local G,A=S.G,S.A

-- One open transition can use its own terminal boundary as the next source,
-- yielding fresh finite causal history rather than a graph cycle.
local p=G.builder(); local D=p:membrane(nil,'place','loop'); local X=p:point(D,'X'); local i=p:strand(D,'R',{X},'in'); local o=p:strand(D,'R',{X},'out'); p:face(D,'step',{i},{o}); local step=p:finish()

local g=step
for n=1,60 do
  local w=A.one(g,{D},step)
  S.ok(w,'self-unfolding failed at '..n)
  g=A.glue(w)
end
S.eq(#g:faces(),61)
-- Exactly one R authority occurrence remains terminal after the chain.
local offers=g:offers({D}); local count=0
for _,s in ipairs(offers) do if g:cell(s).sort=='R' then count=count+1 end end
S.eq(count,1)

print('ok 23_recursive_unfolding')
