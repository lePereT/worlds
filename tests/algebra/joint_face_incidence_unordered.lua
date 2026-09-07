local W=require('worlds'); local T=require('support')

-- Rigid vocabulary: the external ports are semantically distinct Points.
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v')
local AI=vb:point(vm,'AI'); local AO=vb:point(vm,'AO')
local BI=vb:point(vm,'BI'); local BO=vb:point(vm,'BO')
local X =vb:point(vm,'X');  local Y =vb:point(vm,'Y')
vb:finish()

local function part(name, ext_in, ext_out, support_in, support_out)
  local b=W.Geometry.builder(); local m=b:membrane(nil,name)
  local ei=b:strand(m,{ext_in},name..'.in')
  local si=b:strand(m,{support_in},name..'.support.in')
  local so=b:strand(m,{support_out},name..'.support.out')
  local eo=b:strand(m,{ext_out},name..'.out')
  local f=b:face(m,{ei,si},{so,eo},name)
  return b:finish(),ei,si,so,eo,f
end

local A,ai,ays,ax,ao,af=part('A',AI,AO,Y,X)
local B,bi,bxs,by,bo,bf=part('B',BI,BO,X,Y)

local function roles_of(set)
  local r={}
  for _,s in ipairs(set) do local pts=W.Geometry.points(s); T.eq(#pts,1); r[pts[1]]=true end
  return r
end
local function assert_joint(g, expected_ins, expected_outs)
  T.eq(#g:faces(),1,'mutual support must normalise to one joint Face')
  local f=g:faces()[1]
  local ins=roles_of(W.Geometry.inputs(f)); local outs=roles_of(W.Geometry.outputs(f))
  for _,p in ipairs(expected_ins) do T.ok(ins[p],'missing joint ingress role') end
  for _,p in ipairs(expected_outs) do T.ok(outs[p],'missing joint egress role') end
  local ni,no=0,0; for _ in pairs(ins) do ni=ni+1 end; for _ in pairs(outs) do no=no+1 end
  T.eq(ni,#expected_ins); T.eq(no,#expected_outs)
end

local g1=W.Algebra.close({A,B},{{ax,bxs},{by,ays}})
local g2=W.Algebra.close({B,A},{{by,ays},{ax,bxs}})
assert_joint(g1,{AI,BI},{AO,BO})
assert_joint(g2,{AI,BI},{AO,BO})

-- Ordinary Face incidence has the same set semantics: constructor order is not
-- observable through the public carrier API.
local function ordinary(reverse)
  local b=W.Geometry.builder(); local m=b:membrane(nil,'ordinary')
  local x=b:strand(m,{AI}); local y=b:strand(m,{BI}); local z=b:strand(m,{AO}); local w=b:strand(m,{BO})
  local inputs=reverse and {y,x} or {x,y}; local outputs=reverse and {w,z} or {z,w}; local f=b:face(m,inputs,outputs); local g=b:finish()
  local xs=W.Geometry.inputs(f); local ins={}; for _,s in ipairs(xs) do ins[s]=true end; T.ok(ins[x]); T.ok(ins[y]); T.eq(#xs,2)
  local ys=W.Geometry.outputs(f); local outs={}; for _,s in ipairs(ys) do outs[s]=true end; T.ok(outs[z]); T.ok(outs[w]); T.eq(#ys,2)
  return g
end
ordinary(false); ordinary(true)

return T.count()
