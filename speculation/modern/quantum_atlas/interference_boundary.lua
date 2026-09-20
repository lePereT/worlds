-- Radical atlas-derived attack: interference as coherent summation over distinct exact
-- constructions which land in one structural boundary class. Which-path structure
-- refines the boundary class; coherent erasure coarsens it again.
package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')

local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end
local EPS=1e-12
local function approx(a,b) return math.abs(a-b)<EPS end

local wb=W.builder(); local wm=wb:membrane(nil,'interferometer')
local q=wb:point(wm,'q'); local input=wb:strand(wm,{q},'input'); local initial=wb:finish()

local function route(name,marker)
  local b=W.builder(); local m=b:membrane(nil,name); local Q=b:point(m,'Q')
  local i=b:strand(m,{Q},name..'.in')
  local pts={Q}
  local M
  if marker then M=b:point(m,marker); pts={Q,M} end
  local o=b:strand(m,pts,name..'.out')
  b:face(m,{i},{o},name)
  return {g=b:finish(),i=i,o=o,marker=M}
end
local L=route('left',nil); local R=route('right',nil)
local function run(dev)
  local s=W.solve(initial,dev.g,{{from=input,to=dev.i}}); local tag,es=s:step(math.huge); eq(tag,'yes')
  local live,img=W.advance(initial,dev.g,es); return live,img[dev.o]
end
local lworld,lo=run(L); local rworld,ro=run(R)
ok(lo~=ro,'alternative realisations retain distinct exact output occurrences')
eq(W.points(lo)[1],q); eq(W.points(ro)[1],q)
eq(W.membrane(lo),wm); eq(W.membrane(ro),wm)

local function row_key(s)
  local pts=W.points(s); local t={tostring(W.membrane(s))}
  for i,p in ipairs(pts) do t[#t+1]=tostring(p) end
  return table.concat(t,'|')
end
eq(row_key(lo),row_key(ro),'distinct exact histories share one structural boundary row')

-- Each route contributes splitter*recombiner amplitude 1/2 to one detector.
local function probability_by_class(items)
  local sums={}
  for _,it in ipairs(items) do sums[it.key]=(sums[it.key] or 0)+it.amp end
  local p=0; for _,a in pairs(sums) do p=p+a*a end
  return p
end
ok(approx(probability_by_class{{key=row_key(lo),amp=0.5},{key=row_key(ro),amp=0.5}},1),'constructive paths interfere to unit probability')
ok(approx(probability_by_class{{key=row_key(lo),amp=0.5},{key=row_key(ro),amp=-0.5}},0),'opposite phase cancels in shared boundary class')

-- Add exact which-path Points. The two route boundaries are now structurally distinct,
-- so amplitudes are not combined at this observational resolution.
local LM=route('left-marked','L-record'); local RM=route('right-marked','R-record')
local _,lmo=run(LM); local _,rmo=run(RM)
ok(row_key(lmo)~=row_key(rmo),'which-path records refine structural boundary class')
ok(approx(probability_by_class{{key=row_key(lmo),amp=0.5},{key=row_key(rmo),amp=-0.5}},0.5),'distinguishable paths add probabilities, not amplitudes')

-- Coherent erasure: consume a marked occurrence and reissue only q. This is a causal
-- operation in Geometry; whether it preserves phase coherently is Theory.
local function erase(marked_world,marked)
  local b=W.builder(); local m=b:membrane(nil,'erase'); local Q=b:point(m,'Q'); local M=b:point(m,'M')
  local i=b:strand(m,{Q,M},'marked'); local o=b:strand(m,{Q},'unmarked'); b:face(m,{i},{o},'erase record'); local d=b:finish()
  local s=W.solve(marked_world,d,{{from=marked,to=i}}); local tag,es=s:step(math.huge); eq(tag,'yes')
  local live,img=W.advance(marked_world,d,es); return live,img[o]
end
local lmworld,lmout=run(LM); local rmworld,rmout=run(RM)
local _,le=erase(lmworld,lmout); local _,re=erase(rmworld,rmout)
eq(row_key(le),row_key(re),'coherent erasure returns alternatives to one structural boundary class')
ok(approx(probability_by_class{{key=row_key(le),amp=0.5},{key=row_key(re),amp=-0.5}},0),'phase-sensitive cancellation is structurally available again')

print('interference boundary classes: '..n..' assertions passed')
print('  exact histories remain distinct while structural boundary classes control where amplitudes may combine')
