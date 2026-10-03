local W=require('worlds')
local Construction=require('worlds.construction')
local T=require('speculation.theory.occurrence_relative.theory')
local C=require('speculation.theory.occurrence_relative.common')
local F=require('speculation.theory.occurrence_relative.multi_recursive_fixtures')
local function depths(st)
  local out={};for _,f in ipairs(st:select('event')) do out[#out+1]=C.depth(W.membrane(f.args[1])) end;table.sort(out);return table.concat(out,',')
end
return function()
  local R=F.roles('staged');local S=F.component({{'a','x'},{'b','y'}},{'chain2','chain3'},R,'staged');local facts={};for _,f in ipairs(S.geometry:faces()) do facts[#facts+1]=T.fact('event',f,'work') end;local th=T.state(S.geometry,facts)
  local direct=Construction.join({S.geometry},{{from=S.loop_out[1],to=S.loop_in[2]},{from=S.loop_out[2],to=S.loop_in[1]}});local td=T.rebase(th,direct)
  local c1=Construction.join({S.geometry},{{from=S.loop_out[1],to=S.loop_in[2]}});local t1=T.rebase(th,c1);local c2=Construction.join({c1:result()},{{from=assert(c1:image(S.loop_out[2])),to=assert(c1:image(S.loop_in[1]))}});local ts=T.rebase(t1,c2)
  assert(#direct:result():faces()==#c2:result():faces(),'staged closure changed final Face count')
  assert(td:count('event')==ts:count('event') and depths(td)==depths(ts),'Theory retained recursive construction history')
  return 'one-shot and staged recursive closure yield the same observable Face-relative Theory profile; closed linking history is forgotten'
end
