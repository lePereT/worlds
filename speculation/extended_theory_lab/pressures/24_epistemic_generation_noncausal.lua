local W=require('worlds')
local Q=require('worlds.query')
local C=require('speculation.extended_theory_lab.common')
local function roles()
  local b=W.builder()
  local m=b:membrane(nil,'roles')
  local ps={}
  for _,n in ipairs{'COUNT','PERMIT','OBS','TAKEN'} do ps[n]=b:point(m,n) end
  b:strand(m,{},'anchor')
  ps._geometry=b:finish()
  return ps
end
return function()
  local R=roles()
  for _,case in ipairs{{n=0,p=0,yes=true},{n=3,p=2,yes=false},{n=3,p=3,yes=true},{n=5,p=5,
      yes=true}} do
    local b=W.builder()
    local m=b:membrane(nil,'world')
    local pts={R.COUNT}
    for i=1,case.n do pts[#pts+1]=b:point(m,'mark'..i) end
    local count=b:strand(m,pts,'count')
    for i=1,case.p do b:strand(m,{R.PERMIT},'permit'..i) end
    local source=b:finish()
    local observed=#W.points(count)-1
    local q=W.builder()
    local qm=q:membrane(nil,'candidate')
    local qpts={R.COUNT}
    for i=1,observed do qpts[#qpts+1]=q:point(qm,'n'..i) end
    local ci=q:strand(qm,qpts,'count.in')
    local obs=q:strand(qm,{R.OBS},'obs')
    local faces={}
    faces[#faces+1]=q:face(qm,{ci},{obs},'observe')
    for i=1,observed do local pi=q:strand(qm,{R.PERMIT},'p'..i)
    local po=q:strand(qm,{R.TAKEN},'t'..i)
    faces[#faces+1]=q:face(qm,{pi},{po},'take'..i) end
    local target=q:finish()
    local k=C.decide(Q.match(source,target,{seeds={{from=count,to=ci}}}))
    assert((k=='yes')==case.yes,'permit judgement mismatch')
    if k=='yes' then
      for i=1,#faces do for j=1,#faces do if i~=j then
        local seen={[faces[i]]=true}
        local queue={faces[i]}
        local qi=1
        local reaches=false
        while qi<=#queue do local f=queue[qi]
        qi=qi+1
        for _,s in ipairs(W.outputs(f)) do local c=target:consumer(s)
        if c and not seen[c] then if c==faces[j] then reaches=true end
        seen[c]=true
        queue[#queue+1]=c end end end
        assert(not reaches,'epistemic fanout leaked causal order')
      end end end
    end
  end
  return 'runtime evidence may determine how much independent Geometry ' ..
      'to form without becoming causal order'
end
