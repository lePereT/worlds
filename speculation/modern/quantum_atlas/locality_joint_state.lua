-- Hostile quantum attack: does representing an entangled/global state factor as a
-- scarce Strand force a local intervention to acquire non-local causal support?
package.path='./src/?.lua;./src/?/init.lua;'..package.path
local W=require('worlds')
local n=0
local function ok(x,msg) n=n+1; assert(x,msg or 'assertion failed') end
local function eq(a,b,msg) n=n+1; assert(a==b,(msg or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local wb=W.builder(); local root=wb:membrane(nil,'joint'); local A=wb:membrane(root,'Alice'); local B=wb:membrane(root,'Bob')
local qA=wb:point(A,'qA'); local qB=wb:point(B,'qB')
local aa=wb:strand(A,{qA},'Alice authority'); local ba=wb:strand(B,{qB},'Bob authority')
local jf=wb:strand(root,{qA,qB},'joint state factor')
local world=wb:finish()

-- A process that explicitly updates both Alice authority and the joint factor.
-- Its natural support is the LCA/root, not Alice's local membrane.
local d=W.builder(); local dr=d:membrane(nil,'joint-op'); local dA=d:membrane(dr,'Alice')
local QA=d:point(dA,'QA')
-- qB is imported rigidly: the process may refer to Bob's identity without owning Bob authority.
local ia=d:strand(dA,{QA},'Alice in'); local ij=d:strand(dr,{QA,qB},'joint in')
local oa=d:strand(dA,{QA},'Alice out'); local oj=d:strand(dr,{QA,qB},'joint out')
local f=d:face(dr,{ia,ij},{oa,oj},'Alice operation + state update')
local dev=d:finish()
local solver=W.solve(world,dev,{{from=aa,to=ia},{from=jf,to=ij}})
local tag,es=solver:step(math.huge)
eq(tag,'yes','root-supported state-update process is matchable')
local joined,img=W.join({world,dev},es)
eq(W.membrane(img[f]),root,'joint-state-consuming Face is forced to joint support')
eq(W.points(img[oj])[1],qA); eq(W.points(img[oj])[2],qB)

-- Bob authority is not consumed, but the update Face is nevertheless globally supported.
ok(joined:owns_strand(ba),'Bob causal authority survives untouched')

-- A truly Alice-local process can act using only Alice authority while Theory updates
-- the extensional joint state externally. It does not need a global factor Strand input.
local l=W.builder(); local lr=l:membrane(nil,'local-op'); local lA=l:membrane(lr,'Alice'); local X=l:point(lA,'X')
local li=l:strand(lA,{X},'in'); local lo=l:strand(lA,{X},'out'); local lf=l:face(lA,{li},{lo},'Alice-local operation'); local localdev=l:finish()
local ls=W.solve(world,localdev,{{from=aa,to=li}}); local ltag,les=ls:step(math.huge)
eq(ltag,'yes','Alice-only geometry is independently executable')
local lj,limg=W.join({world,localdev},les)
eq(W.membrane(limg[lf]),A,'Alice-only Face remains Alice-local')
ok(lj:owns_strand(jf),'joint extensional-scope Strand remains untouched if treated as descriptive scope')

print('locality vs joint state factor: '..n..' assertions passed')
print('  consuming a joint factor geometrises global state-update support; local causal action itself does not require it')
print('  warning: quantum state scope may belong in Theory over Points rather than as a scarce state Strand')
