local W=require('worlds')
local Q=require('worlds.query')
local C=require('speculation.theory.occurrence_relative.common')
local R=C.roles({'START','MSG','EXTERNAL','PDONE','CDONE'},'transactional')
return function()
  local p=W.builder();local pm=p:membrane(nil,'producer');local start=p:strand(pm,{R.START},'start');local msg=p:strand(pm,{R.MSG},'msg');local pd=p:strand(pm,{R.PDONE},'pdone');p:face(pm,{start},{msg,pd},'produce');local pg=p:finish()
  local q=W.builder();local qm=q:membrane(nil,'consumer');local need=q:strand(qm,{R.MSG},'need');local ext=q:strand(qm,{R.EXTERNAL},'external');local cd=q:strand(qm,{R.CDONE},'cdone');q:face(qm,{need,ext},{cd},'consume');local qg=q:finish()
  local close=Q.close({pg,qg},{sources={msg},targets={need},required_sources={msg},required_targets={need},admissible={{from=msg,to=need}}});local k,eqs=C.decide(close);assert(k=='yes');local action=W.join({pg,qg},eqs)
  local function world(with_ext)
    local b=W.builder();local m=b:membrane(nil,'world');b:strand(m,{R.START},'start');if with_ext then b:strand(m,{R.EXTERNAL},'external') end;return b:finish()
  end
  assert(C.decide(Q.match(world(false),action))=='no','internal communication committed despite missing later external requirement')
  assert(C.decide(Q.match(world(false),pg))=='yes','failed composite admission reserved producer authority')
  assert(C.decide(Q.match(world(true),action))=='yes','complete transactional action should become admissible')
  return 'internal closure remains transactional with unrelated external requirements; failed admission consumes no authority'
end
