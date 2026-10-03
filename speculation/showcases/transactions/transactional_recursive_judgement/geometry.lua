-- Geometry adapter for restrictive occurrence-relative Theory.
-- Reuses the finite calculus symbolic Geometry, but retains exact Point
-- correspondence needed to transport knowledge during composition.
local W=require('worlds')
local Construction=require('worlds.construction')
local Base=require('speculation.showcases.transactions.transactional_development_calculus.geometry')
local M={}
for k,v in pairs(Base) do M[k]=v end

local function class_key(row)
  table.sort(row)
  return table.concat(row,'|')
end

function M.compose(parts,equations)
  local exact,maps={},{}
  for i,p in ipairs(parts) do exact[i],maps[i]=Base.instantiate(p) end
  local eqs={}
  for i,e in ipairs(equations or {}) do
    eqs[i]={from=assert(maps[e.from.part].strands[e.from.strand]),
      to=assert(maps[e.to.part].strands[e.to.strand])}
  end
  local c=Construction.join(exact,eqs)
  local result,index=Base.symbolize_construction(c,maps)
  local corr=c:correspondence()

  local images,classes={},{}
  local class_rows={}
  for pi,p in ipairs(parts) do
    local row={strands={},points={}}
 images[pi]=row
 classes[pi]={}
    for si=1,#p.strands do local y=c:image(maps[pi].strands[si])
 row.strands[si]=y and index.strands[y] or nil end
    for qi=1,#p.points do
      local x=maps[pi].points[qi]
 local y=c:image(x)
 row.points[qi]=y and index.points[y] or nil
      local cl=assert(corr:source_class(x),'Construction correspondence omitted source Point')
      local bucket=class_rows[cl] or {}
 class_rows[cl]=bucket
      bucket[#bucket+1]=string.format('%09d:%09d',pi,qi)
    end
  end
  local class_id={}
  local rows={}
  for cl,bucket in pairs(class_rows) do rows[#rows+1]={cl=cl,key=class_key(bucket)} end
  table.sort(rows,function(a,b) return a.key<b.key end)
  for i,r in ipairs(rows) do class_id[r.cl]='c'..i end
  local target={}
  for _,p in ipairs(c:result():points()) do
    local cl=assert(corr:target_class(p),'Construction correspondence omitted target Point')
    local id=assert(class_id[cl],'target Point lacks marked source class')
    target[id]=assert(index.points[p])
  end
  for pi,p in ipairs(parts) do
    for qi=1,#p.points do
      local cl=assert(corr:source_class(maps[pi].points[qi]))
      classes[pi][qi]=assert(class_id[cl])
    end
  end
  return result,images,c,{sources=classes,target=target}
end

return M
