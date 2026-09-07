local W=require('worlds'); local T=require('support')
local vb=W.Geometry.builder(); local vm=vb:membrane(nil,'v'); local roles={}; for i=1,3 do roles[i]=vb:point(vm,'S'..i) end; vb:finish()
local procs={}
for i=1,3 do local j=i%3+1; local b=W.Geometry.builder(); local m=b:membrane(nil,'p'); local si=b:strand(m,{roles[i]}); local so=b:strand(m,{roles[j]}); b:face(m,{si},{so}); procs[i]={g=b:finish(),input=si,output=so,next=j} end
local hb=W.Geometry.builder(); local hm=hb:membrane(nil,'root'); local hs=hb:strand(hm,{roles[1]}); local history=hb:finish(); local boundary=W.Operational.from_geometry(history); local os=hs; local state=1
for step=1,500 do
  local p=procs[state]
  local w=W.Operational.one(boundary,p.g,{strands={[p.input]=os}}); T.ok(w); local _,oi=W.Operational.commit(w); os=oi.strands[p.output]
  local h2,hi=W.Algebra.close({history,p.g},{{hs,p.input}}); history=h2; hs=hi[2].strands[p.output]
  state=p.next
  T.eq(W.Geometry.points(os)[1],roles[state]); T.eq(W.Geometry.points(hs)[1],roles[state]); T.eq(boundary:size(),1); T.eq(#history:egress(),1)
end
return T.count()
