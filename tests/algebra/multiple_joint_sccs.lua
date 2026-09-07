local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local Ctl=vb:point(vm,'Ctl'); local A=vb:point(vm,'A'); local B=vb:point(vm,'B'); local Mid=vb:point(vm,'Mid'); local C=vb:point(vm,'C'); local D=vb:point(vm,'D'); local Done=vb:point(vm,'Done'); vb:finish()
local function part(name,inputs,outputs)
  local b=W.Geometry.builder(); local m=b:membrane(nil,name); local ins={}; for i,r in ipairs(inputs) do ins[i]=b:strand(m,{r}) end; local outs={}; for i,r in ipairs(outputs) do outs[i]=b:strand(m,{r}) end; local f=b:face(m,ins,outs,name); return b:finish(),ins,outs,f
end
local ga,ai,ao,af=part('A',{B,Ctl},{A})
local gb,bi,bo,bf=part('B',{A},{B,Mid})
local gc,ci,co,cf=part('C',{D,Mid},{C})
local gd,di,do_,df=part('D',{C},{D,Done})
local g,img=W.Algebra.close({ga,gb,gc,gd},{
  {ao[1],bi[1]}, {bo[1],ai[1]}, -- first SCC
  {bo[2],ci[2]},                 -- acyclic bridge
  {co[1],di[1]}, {do_[1],ci[1]}, -- second SCC
})
T.eq(#g:faces(),2,'two cyclic support components become two joint Faces'); T.eq(img[1].faces[af],img[2].faces[bf]); T.eq(img[3].faces[cf],img[4].faces[df]); T.ok(img[1].faces[af]~=img[3].faces[cf])
local ctl=img[1].strands[ai[2]]; local mid=img[2].strands[bo[2]]; local done=img[4].strands[do_[2]]
T.ok(ctl and g:is_input(ctl)); T.ok(mid and not g:is_input(mid) and not g:is_terminal(mid),'bridge remains ordinary causal Strand'); T.ok(done and g:is_terminal(done)); T.ok(g:grounded())
return T.count()
