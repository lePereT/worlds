package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common'); local BR=require('speculation.modern.dimensional_lab.reduct')
local ok,eq,count=D.counter()

-- Ordinary Worlds is interpreted one rank up for this control: state Points denote
-- exact W2 histories, Strands are scarce higher-state occurrences, and Faces are
-- higher rewrites.  A cyclic family should cast one ordinary causal shadow after
-- SCC normalisation, exactly as the dimensional hypothesis predicts.
local function cell(label,with_in,with_out)
  local b=W.builder(); local m=b:membrane(nil,label); local a=b:point(m,label..'.from'); local z=b:point(m,label..'.to')
  local cin=b:strand(m,{a},label..'.cycle.in'); local cout=b:strand(m,{z},label..'.cycle.out')
  local ins={cin}; local outs={cout}; local extin,extout
  if with_in then local p=b:point(m,'external-in'); extin=b:strand(m,{p},label..'.external.in'); ins[#ins+1]=extin end
  if with_out then local p=b:point(m,'external-out'); extout=b:strand(m,{p},label..'.external.out'); outs[#outs+1]=extout end
  local f=b:face(m,ins,outs,label); return {g=b:finish(),cin=cin,cout=cout,extin=extin,extout=extout,f=f}
end

print('1. cyclic higher rewrites contract to one lower causal event')
for n=2,6 do
  local parts,meta,eqs={},{},{}
  for i=1,n do meta[i]=cell('H'..n..'.'..i,i==1,i==n); parts[i]=meta[i].g end
  for i=1,n do local j=i%n+1; eqs[#eqs+1]={from=meta[i].cout,to=meta[j].cin} end
  local g=W.join(parts,eqs)
  eq(#g:faces(),1,'higher SCC becomes one joint event')
  eq(#g:ingress(),1,'external higher source survives'); eq(#g:egress(),1,'external higher target survives')
  local red=BR.reduce_full(g)
  eq(#red.world:faces(),0,'one further descent is structural')
    ok(next(red.face_point)~=nil,'joint higher event has one lower face coordinate')
end

print('2. the shadow law depends on higher causal incidence, not on domain labels')
local a=cell('quantum-like',true,false); local b=cell('chemistry-like',false,false); local c=cell('logic-like',false,true)
local mixed=W.join({a.g,b.g,c.g},{{from=a.cout,to=b.cin},{from=b.cout,to=c.cin},{from=c.cout,to=a.cin}})
eq(#mixed:faces(),1); eq(#mixed:ingress(),1); eq(#mixed:egress(),1)
print('PASS domain-neutral higher SCC shadow',count(),'assertions')
