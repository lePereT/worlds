local W=require('worlds')
local Q=require('worlds.query')
local C=require('speculation.theory.occurrence_relative.common')
local function shape(child)
  local b=W.builder();local r=b:membrane(nil,'root');local m=child and b:membrane(r,'hidden') or r;local s=b:strand(m,{},'public');return b:finish(),s
end
return function()
  local gr,sr=shape(false);local gc,sc=shape(true);local pr,ir=shape(false);local pc,ic=shape(true)
  local function yes(a,s,p,i)
    local k=C.decide(Q.match(a,p,{seeds={{from=s,to=i}}}));return k=='yes'
  end
  assert(yes(gr,sr,pr,ir));assert(not yes(gr,sr,pc,ic));assert(yes(gc,sc,pr,ir));assert(yes(gc,sc,pc,ic))
  return 'hidden support ancestry remains ordinary Geometry; extended Theory needs no Region/support signature'
end
