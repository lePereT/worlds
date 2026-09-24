package.path='./src/?.lua;./src/?/init.lua;./speculation/modern/dimensional_lab/?.lua;'..package.path
local W=require('worlds'); local D=require('common'); local R=require('speculation.modern.dimensional_lab.reduct')
local ok,eq,count=D.counter()

local function mechanism(label,intermediate)
  local b=W.builder(); local m=b:membrane(nil,label)
  local A1=b:point(m,'A'); local A2=b:point(m,'A'); local B=b:point(m,'B'); local X=b:point(m,intermediate); local E=b:point(m,'E')
  local a1=b:strand(m,{A1},'A.1'); local a2=b:strand(m,{A2},'A.2'); local bs=b:strand(m,{B},'B')
  local x=b:strand(m,{X},intermediate); local e=b:strand(m,{E},'E')
  b:face(m,{a1,a2,bs},{x},'form '..intermediate); b:face(m,{x},{e},'finish E')
  return D.surface(label,b:finish(),{kind='mechanism',intermediate=intermediate})
end
local function net(label)
  local b=W.builder(); local m=b:membrane(nil,label)
  local A1=b:point(m,'A'); local A2=b:point(m,'A'); local B=b:point(m,'B'); local E=b:point(m,'E')
  local a1=b:strand(m,{A1},'A.1'); local a2=b:strand(m,{A2},'A.2'); local bs=b:strand(m,{B},'B'); local e=b:strand(m,{E},'E')
  b:face(m,{a1,a2,bs},{e},'net 2A+B->E')
  return D.surface(label,b:finish(),{kind='net'})
end
local function stoich(g)
  local i,o=D.boundary_multiset(g); return i,o
end

print('1. distinct reaction mechanisms share one net W1 stoichiometric boundary')
local C=mechanism('via-C','C'); local Dm=mechanism('via-D','D'); local N=net('net')
local ci,co=stoich(C.g); local di,do_=stoich(Dm.g); local ni,no=stoich(N.g)
ok(D.same_multiset(ci,di) and D.same_multiset(di,ni),'all inputs are 2A+B')
ok(D.same_multiset(co,do_) and D.same_multiset(do_,no),'all outputs are E')
eq(ci.A,2); eq(ci.B,1); eq(co.E,1)
ok(C.g~=Dm.g and Dm.g~=N.g,'mechanisms and net reaction remain exact-distinct')
eq(#C.g:faces(),2); eq(#Dm.g:faces(),2); eq(#N.g:faces(),1)

print('2. exact boundary reduct retains occurrence multiplicity beyond stoichiometric vector')
local cr=R.reduce(C.g)
eq(#C.g:ingress(),3); for _,s in ipairs(C.g:ingress()) do ok(cr.port_point[s]~=nil,'each reactant occurrence has its own reduced coordinate') end
local aports=0; for _,s in ipairs(C.g:ingress()) do if W.name(W.points(s)[1])=='A' then aports=aports+1 end end
eq(aports,2,'stoichiometric coefficient is multiplicity of exact occurrences, not one weighted carrier')

print('3. mechanism/refinement incidence lives above W2 without erasing mechanisms')
local atlas=D.deformation_atlas({C,Dm,N},{{C,Dm},{C,N},{Dm,N}},'mechanism space')
eq(#atlas.world:faces(),0); eq(#atlas.world:points(),3); eq(#atlas.world:strands(),3)
ok(atlas.point[C]~=atlas.point[Dm] and atlas.point[Dm]~=atlas.point[N])

print('4. direct and staged mechanism refinements may share a higher boundary while retaining exact history')
local cd=D.higher_rewrite(C,Dm,'change intermediate')
local dn=D.higher_rewrite(Dm,N,'coarse-grain D mechanism')
local cn=D.higher_rewrite(C,N,'coarse-grain C mechanism')
local staged=D.path_rewrites({cd,dn}); local direct=cn.world
eq(D.boundary_signature(staged),D.boundary_signature(direct),'higher refinement paths have same source/target mechanism kinds')
eq(#staged:faces(),2); eq(#direct:faces(),1); ok(staged~=direct)

print('PASS chemistry dimensional mechanisms',count(),'assertions')
