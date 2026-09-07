local T=require('support'); local H=require('theory_whole_support'); local W,G=H.W,H.G
local R=H.vocab{'Left','Right','Send','Recv','Done'}

-- 0.4/46: an extensional quotient that forgets sharing is not a congruence for all exact contexts.
local function pair(shared)
  local b=G.builder(); local m=b:membrane(nil,'term'); local p=b:point(m,'p'); local q=shared and p or b:point(m,'q'); local l=b:strand(m,{R.Left,p}); local r=b:strand(m,{R.Right,q}); return b:finish(),{[p]=42,[q]=42},l,r
end
local shared,sv,sl,sr=pair(true); local split,dv,dl,dr=pair(false); T.eq(tostring(sv[G.points(sl)[2]])..','..tostring(sv[G.points(sr)[2]]),tostring(dv[G.points(dl)[2]])..','..tostring(dv[G.points(dr)[2]]))
local ip=G.builder(); local im=ip:membrane(nil,'probe'); local z=ip:point(im,'z'); ip:strand(im,{R.Left,z}); ip:strand(im,{R.Right,z}); local probe=ip:finish(); T.eq(#H.structural(shared,probe),1); T.eq(#H.structural(split,probe),0)

-- 0.4/47: structural congruence may be needed before exact Cut, not merely as a post-filter.
local function scoped()
  local b=G.builder(); local root=b:membrane(nil,'proc'); local inner=b:membrane(root,'transparent'); local c=b:point(root,'c'); b:strand(inner,{R.Send,c}); b:strand(root,{R.Recv,c}); return b:finish()
end
local function flat()
  local b=G.builder(); local root=b:membrane(nil,'proc'); local c=b:point(root,'c'); b:strand(root,{R.Send,c}); b:strand(root,{R.Recv,c}); return b:finish()
end
local rp=G.builder(); local rm=rp:membrane(nil,'p'); local c=rp:point(rm,'c'); local s=rp:strand(rm,{R.Send,c}); local r=rp:strand(rm,{R.Recv,c}); local o=rp:strand(rm,{R.Done,c}); rp:face(rm,{s,r},{o}); local pat=rp:finish()
local gs,gf=scoped(),flat(); T.eq(#H.structural(gs,pat),0); T.eq(#H.structural(gf,pat),1)

-- 0.4/48: derived Theory attachment may search a congruence class of exact representatives.
local function att_T(reps,pattern)
  local out={}; for _,rep in ipairs(reps) do for _,cut in ipairs(H.structural(rep,pattern)) do out[#out+1]={representative=rep,cut=cut} end end; return out
end
local xs=att_T({gs,gf},pat); T.eq(#xs,1); T.eq(xs[1].representative,gf)
-- The selected representative composes using ordinary exact Worlds algebra.
local composite=W.Algebra.apply(gf,pat,xs[1].cut); T.ok(composite)
return T.count()
