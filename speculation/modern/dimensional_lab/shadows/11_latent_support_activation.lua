package.path='./src/?.lua;./src/?/init.lua;./?.lua;'..package.path
local W=require('worlds')
local n=0; local function ok(x,m) n=n+1; assert(x,m or 'assertion failed') end; local function eq(a,b,m) n=n+1; assert(a==b,(m or 'neq')..': '..tostring(a)..' ~= '..tostring(b)) end

local specs={
 {name='x0',v={'000','001','011','010'}}, {name='y0',v={'000','001','101','100'}},
 {name='z0',v={'000','010','110','100'}}, {name='y1',v={'010','011','111','110'}},
 {name='z1',v={'001','011','111','101'}}, {name='x1',v={'100','101','111','110'}},
}
local ord={x0=1,y0=2,z0=3,y1=4,z1=5,x1=6}; local function key(a,b) if a>b then a,b=b,a end return a..'-'..b end
local function cube(omit,shared_child,edges_in_child)
  local b=W.builder(); local root=b:membrane(nil,'root'); local child=shared_child and b:membrane(root,'shared higher support') or root; local ep=edges_in_child and child or root
  local p={}; for _,v in ipairs{'000','001','010','011','100','101','110','111'} do p[v]=b:point(ep,v) end
  local edge,fe,owners={},{},{}
  for fi,f in ipairs(specs) do fe[fi]={}; for i=1,4 do local a,c=f.v[i],f.v[i%4+1]; local k=key(a,c); if not edge[k] then edge[k]=b:strand(ep,{p[a],p[c]},k) end; local s=edge[k]; fe[fi][#fe[fi]+1]=s; owners[s]=owners[s] or {}; owners[s][#owners[s]+1]=fi end end
  for fi,f in ipairs(specs) do if f.name~=omit then local ins,outs={},{}; for _,s in ipairs(fe[fi]) do local os=owners[s]; local other=os[1]==fi and os[2] or os[1]; if ord[f.name]<ord[specs[other].name] then outs[#outs+1]=s else ins[#ins+1]=s end end; b:face(child,ins,outs,f.name) end end
  return b:finish()
end

print('1. a closed unreachable higher surface tolerates latent shared support')
local closed=cube(nil,true,false); ok(not closed:is_developable()); eq(#closed:faces(),6); eq(#closed:ingress(),0)

print('2. source puncture activates causal locality law and rejects that same support reuse')
local good,err=pcall(function() return cube('x0',true,false) end); ok(not good,'activated faces must not reuse known child locality without causal incidence'); ok(tostring(err):find('existing locality used without causal input incidence',1,true)~=nil)

print('3. carrying the shared locality on the causal edge incidence repairs the activated disk')
local repaired=cube('x0',true,true); ok(repaired:is_developable()); eq(#repaired:ingress(),4); eq(#repaired:faces(),5)

print('4. root-hosting also repairs execution without changing the cellular topology')
local root=cube('x0',false,false); ok(root:is_developable()); eq(#root:points(),#repaired:points()); eq(#root:strands(),#repaired:strands()); eq(#root:faces(),#repaired:faces())
print('PASS latent support activation',n,'assertions')
