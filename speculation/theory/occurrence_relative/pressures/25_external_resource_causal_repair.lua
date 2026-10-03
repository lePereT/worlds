local W=require('worlds')
local function reaches(g,a,z)
  local seen={[a]=true};local q={a};local i=1;while i<=#q do local f=q[i];i=i+1;for _,s in ipairs(W.outputs(f)) do local c=g:consumer(s);if c and not seen[c] then if c==z then return true end;seen[c]=true;q[#q+1]=c end end end;return false
end
return function()
  local cap={shared=64,registers=100,slots=2};local A={shared=40,registers=20,slots=1};local B={shared=40,registers=30,slots=1};local C={shared=20,registers=50,slots=1}
  local function fits(x,y) return x.shared+y.shared<=cap.shared and x.registers+y.registers<=cap.registers and x.slots+y.slots<=cap.slots end
  assert(not fits(A,B) and fits(A,C) and fits(B,C))
  local b=W.builder();local m=b:membrane(nil,'machine');local sa=b:strand(m,{},'A.start');local sc=b:strand(m,{},'C.start');local sb=b:strand(m,{},'B.start');local ad=b:strand(m,{},'A.done');local hand=b:strand(m,{},'lease');local fa=b:face(m,{sa},{ad,hand},'A');local cd=b:strand(m,{},'C.done');local fc=b:face(m,{sc},{cd},'C');local bd=b:strand(m,{},'B.done');local fb=b:face(m,{sb,hand},{bd},'B');local g=b:finish()
  assert(reaches(g,fa,fb),'resource repair failed to publish A->B causality')
  assert(not reaches(g,fa,fc) and not reaches(g,fc,fa) and not reaches(g,fb,fc) and not reaches(g,fc,fb),'repair unnecessarily ordered independent C')
  return 'domain-specific capacity reasoning may publish one ordinary causal consequence while Theory remains non-authoritative'
end
