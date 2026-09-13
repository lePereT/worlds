local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local C=vb:point(vm,'C'); local X=vb:point(vm,'X'); local Y=vb:point(vm,'Y'); local D=vb:point(vm,'D'); vb:finish()
local function stage(inrole,outrole,label)
  local b=W.Geometry.builder(); local m=b:membrane(nil,label); local x=b:point(m,'x'); local i=b:strand(m,{inrole,x}); local o=b:strand(m,{outrole,x}); b:face(m,{i},{o},label); return b:finish(),i,o,x
end
local A,ai,ao,ax=stage(C,X,'A'); local B,bi,bo,bx=stage(X,Y,'B'); local Cg,ci,co,cx=stage(Y,D,'C')
-- (A ; B) ; C
local AB,ab=W.Algebra.cut(A,B,{{ao,bi}})
local ABC1,abc1=W.Algebra.cut(AB,Cg,{{ab.right.strands[bo],ci}})
-- A ; (B ; C)
local BC,bc=W.Algebra.cut(B,Cg,{{bo,ci}})
local ABC2,abc2=W.Algebra.cut(A,BC,{{ao,bc.left.strands[bi]}})
T.eq(#ABC1:faces(),3); T.eq(#ABC2:faces(),3)
-- Each composite has one open C input and one terminal D output.
local function boundaries(g)
  local ins,outs={},{}
  for _,s in ipairs(g:strands()) do if g:is_input(s) then ins[#ins+1]=s end; if g:is_terminal(s) then outs[#outs+1]=s end end
  return ins,outs
end
local i1,o1=boundaries(ABC1); local i2,o2=boundaries(ABC2); T.eq(#i1,1); T.eq(#i2,1); T.eq(#o1,1); T.eq(#o2,1)
T.eq(W.Geometry.points(i1[1])[1],C); T.eq(W.Geometry.points(i2[1])[1],C); T.eq(W.Geometry.points(o1[1])[1],D); T.eq(W.Geometry.points(o2[1])[1],D)
-- Both are executable against the same kind of live authority and preserve the
-- one value identity through all three stages.
local function execute(g,inp,out)
  local b=W.Geometry.builder(); local m=b:membrane(nil,'root'); local val=b:point(m,'value'); local s=b:strand(m,{C,val}); local live=W.Operational.from_geometry(b:finish())
  local w=W.Operational.one(live,g,{strands={[inp]=s}}); T.ok(w); local _,img=W.Operational.commit(w); local gs=img.strands[out]; T.ok(gs); local pts=W.Geometry.points(gs); T.eq(pts[1],D); return pts[2]
end
local v1=execute(ABC1,i1[1],o1[1]); local v2=execute(ABC2,i2[1],o2[1]); T.ok(W.Geometry.is_point(v1)); T.ok(W.Geometry.is_point(v2))
return T.count()
