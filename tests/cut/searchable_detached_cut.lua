local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local C=vb:point(vm,'C'); local X=vb:point(vm,'X'); local D=vb:point(vm,'D'); vb:finish()
local a=W.Geometry.builder(); local am=a:membrane(nil,'A'); local ci=a:strand(am,{C}); local p=a:point(am,'p'); local q=a:point(am,'q'); local o1=a:strand(am,{X,p}); local o2=a:strand(am,{X,q}); a:face(am,{ci},{o1,o2}); local A=a:finish()
local b=W.Geometry.builder(); local bm=b:membrane(nil,'B'); local y=b:point(bm,'y'); local bi=b:strand(bm,{X,y}); local bo=b:strand(bm,{D,y}); b:face(bm,{bi},{bo}); local B=b:finish()
local query=W.Algebra.query(A,B,{close={bi},offers={o1,o2}}); local seen={}
while true do local k,c=query:step(100); if k=='Retry' then break end; T.eq(k,'Hit'); local source=c:strand(bi); seen[source]=true end
T.ok(seen[o1]); T.ok(seen[o2])
local g,img=W.Algebra.one(A,B,{close={bi},offers={o1,o2}}); T.ok(g); T.eq(#g:faces(),2); T.ok(g:is_terminal(img.right.strands[bo]))
return T.count()
