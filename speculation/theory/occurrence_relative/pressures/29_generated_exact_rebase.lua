local W=require('worlds')
local Construction=require('worlds.construction')
local T=require('speculation.theory.occurrence_relative.theory')
local function parent_arrays(n)
  local out,row={},{};local function go(i) if i>n then local x={};for k=1,n do x[k]=row[k] end;out[#out+1]=x;return end;for p=0,i-1 do row[i]=p;go(i+1) end end;go(1);return out
end
local function patterns()
  local out={};for mask=0,63 do local es,fs,ts={}, {}, {};local ok=true;local bit=0;for i=1,3 do for j=1,3 do if i~=j then if math.floor(mask/2^bit)%2==1 then if fs[i] or ts[j] then ok=false else fs[i]=true;ts[j]=true;es[#es+1]={from=i,to=j} end end;bit=bit+1 end end end;if ok then out[#out+1]=es end end;return out
end
return function()
  local checks=0
  for n=1,3 do for _,parents in ipairs(parent_arrays(n)) do for a=1,n do for b=1,n do for c=1,n do
    local wb=W.builder();local ms={};for i=1,n do ms[i]=wb:membrane(parents[i]==0 and nil or ms[parents[i]]) end;local ps,ss={},{};local wh={a,b,c};for i=1,3 do ps[i]=wb:point(ms[wh[i]]);ss[i]=wb:strand(ms[wh[i]],{ps[i]}) end;local g=wb:finish();local facts={}
    for i=1,#ms do facts[#facts+1]=T.fact('m',ms[i],'m'..i) end;for i=1,3 do facts[#facts+1]=T.fact('p',ps[i],'p'..i);facts[#facts+1]=T.fact('s',ss[i],'s'..i) end;local th=T.state(g,facts)
    for _,pat in ipairs(patterns()) do local es={};for _,e in ipairs(pat) do es[#es+1]={from=ss[e.from],to=ss[e.to]} end;local ok,cons=pcall(Construction.join,{g},es);if ok then checks=checks+1;local rebased=T.rebase(th,cons);for _,f in ipairs(facts) do local x=f.args[1];local im=cons:image(x);if im then local found=false;for _,rf in ipairs(rebased:select(f.pred)) do if rf.args[1]==im and rf.args[2]==f.args[2] then found=true end end;assert(found,'Theory fact failed exact image rebase') end end end end
  end end end end end
  assert(checks>1000,'generated rebase census unexpectedly small')
  return tostring(checks)..' lawful quotient constructions rebase Membrane/Point/Strand Theory references through exact Construction images'
end
