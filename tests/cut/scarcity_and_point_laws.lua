local W=require('worlds'); local T=require('support')
local b=W.Geometry.builder(); local m=b:membrane(nil,'root'); local p=b:point(m,'p'); local s=b:strand(m,{p,p},'one'); local live=W.Operational.from_geometry(b:finish())
-- Repeated Point variable requires exact repeated identity.
local q=W.Geometry.builder(); local qm=q:membrane(nil,'q'); local x=q:point(qm,'x'); local i=q:strand(qm,{x,x}); local pat=q:finish(); T.ok(W.Operational.one(live,pat,{strands={[i]=s}}))
-- Distinct pattern Points may both map to the same exact Point.
local r=W.Geometry.builder(); local rm=r:membrane(nil,'r'); local a=r:point(rm,'a'); local c=r:point(rm,'c'); local ri=r:strand(rm,{a,c}); local rpat=r:finish(); local w=W.Operational.one(live,rpat,{strands={[ri]=s}}); T.ok(w); T.eq(w:point(a),p); T.eq(w:point(c),p)
-- Scarcity remains injective: two demands cannot consume one live occurrence.
local z=W.Geometry.builder(); local zm=z:membrane(nil,'z'); local z1=z:point(zm,'x'); local z2=z:point(zm,'y'); local a1=z:strand(zm,{z1,z1}); local a2=z:strand(zm,{z2,z2}); local out=z:strand(zm,{z1}); z:face(zm,{a1,a2},{out}); local zpat=z:finish(); T.eq(W.Operational.one(live,zpat,{strands={[a1]=s,[a2]=s}}),nil)
return T.count()
