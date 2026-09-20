local HERE='./speculation/modern/quantum_classical'; package.path='./src/?.lua;./src/?/init.lua;'..HERE..'/?.lua;'..package.path
local W=require('worlds'); local T=require('common'); T.reset()
local ok,eq,approx=T.ok,T.eq,T.approx

-- Exact particles, input modes, and output-mode apparatus all exist in ordinary
-- Worlds structure. We run alternative exact two-particle scattering histories
-- from the same initial authority.
local b=W.builder(); local m=b:membrane(nil,'beam-splitter')
local A=b:point(m,'particle-A'); local B=b:point(m,'particle-B'); local L=b:point(m,'input-L'); local R=b:point(m,'input-R'); local U=b:point(m,'output-U'); local D=b:point(m,'output-D')
local pa=b:strand(m,{A,L},'A@L'); local pb=b:strand(m,{B,R},'B@R'); local apparatus=b:strand(m,{U,D},'output-modes')
local initial=b:finish()

local function history(name,a_mode,b_mode,retain_labels)
  local d=W.builder(); local dm=d:membrane(nil,name)
  local a=d:point(dm,'A'); local bb=d:point(dm,'B'); local l=d:point(dm,'L'); local r=d:point(dm,'R'); local u=d:point(dm,'U'); local dd=d:point(dm,'D')
  local ia=d:strand(dm,{a,l},'A.in'); local ib=d:strand(dm,{bb,r},'B.in'); local im=d:strand(dm,{u,dd},'modes.in')
  local amap=(a_mode=='U') and u or dd; local bmap=(b_mode=='U') and u or dd
  local oa=d:strand(dm,retain_labels and {a,amap} or {amap},'A.out')
  local ob=d:strand(dm,retain_labels and {bb,bmap} or {bmap},'B.out')
  local om=d:strand(dm,{u,dd},'modes.out')
  d:face(dm,{ia,ib,im},{oa,ob,om},name)
  return {g=d:finish(),ia=ia,ib=ib,im=im,oa=oa,ob=ob}
end
local function run(h)
  local s=W.solve(initial,h.g,{{from=pa,to=h.ia},{from=pb,to=h.ib},{from=apparatus,to=h.im}}); local tag,es=s:step(math.huge); eq(tag,'yes')
  local live,img=W.advance(initial,h.g,es); return live,img[h.oa],img[h.ob]
end
local function output_class(x,y)
  local keys={T.row_key(W,x),T.row_key(W,y)}; table.sort(keys); return keys[1]..'||'..keys[2]
end

-- The two coincidence histories of a balanced beam splitter. Quantum amplitudes
-- are +1/2 and -1/2 under a conventional phase choice.
local h1=history('coincidence-TT','U','D',false); local h2=history('coincidence-RR','D','U',false)
local _,h1a,h1b=run(h1); local _,h2a,h2b=run(h2)
eq(output_class(h1a,h1b),output_class(h2a,h2b),'without particle labels the exact exchange histories have one observable coincidence class')
ok(h1a~=h2b and h1b~=h2a,'causal occurrences remain exact despite observational identification')
local amp1,amp2=0.5,-0.5
approx((amp1+amp2)^2,0,'indistinguishable exchange amplitudes cancel: Hong-Ou-Mandel coincidence suppression')

-- Preserve which-particle identity in the open boundary. The histories become
-- distinct structural observations, so ordinary probabilities add instead.
local d1=history('distinguishable-TT','U','D',true); local d2=history('distinguishable-RR','D','U',true)
local _,d1a,d1b=run(d1); local _,d2a,d2b=run(d2)
ok(output_class(d1a,d1b)~=output_class(d2a,d2b),'which-particle records distinguish the two exchange histories')
approx(amp1^2+amp2^2,0.5,'distinguishable particles recover the classical 50% coincidence probability')

-- The exact particle identities A and B were always present upstream. The
-- classicalisation transition is therefore not creation of individuality but
-- making that exact distinction observable at the boundary.
eq(W.points(d1a)[1],A); eq(W.points(d1b)[1],B)

print('HOM distinguishability/classicalisation: '..T.count()..' assertions passed')
print('  classical distinguishable-particle statistics appear when exact exchange alternatives stop sharing one observational boundary class')
