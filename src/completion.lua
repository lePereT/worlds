-- completion.lua
--
-- World completion/lifecycle experiment for the topology kernel.
--
-- There is deliberately no World.closed bit.  Instead, completion is a
-- geometric predicate checked at the moment an enclosing construct attempts
-- to retire a World subtree.
--
-- Key distinction:
--   * while a World remains attached to actuality, unspent authority may be
--     intentional live state;
--   * when retirement is requested, every authority occurrence resident in
--     that subtree must already have been consumed or transferred out.
--
-- Thus "live state" and "leak" are intentionally indistinguishable before an
-- exit/retirement attempt.  The attempt is the observation that makes the
-- distinction meaningful; no persistent lifecycle metadata is stored.

local C={}

local function descendants(m,w)
  local set={}
  for _,x in ipairs(m.worlds) do
    if m:is_realised(x) and m:_descends(x,w) then set[x]=true end
  end
  return set
end

local function resident_strands(m,wset)
  local xs={}
  for _,o in ipairs(m.objects) do
    if o.dim==1 and m:is_realised(o) and wset[o.world] then xs[#xs+1]=o end
  end
  return xs
end

-- Faces in the retiring subtree may export authority by producing a Strand
-- whose own World lies outside the subtree.  Such an occurrence is not a
-- resident residue; it has already crossed the membrane geometrically.
function C.egress(m,w)
  local ws=descendants(m,w); local out={}
  for _,f in ipairs(m.objects) do
    if f.dim==2 and m:is_realised(f) and ws[f.world] then
      for _,s in ipairs(f.outputs or {}) do
        if m:is_realised(s) and not ws[s.world] then out[#out+1]={face=f,strand=s} end
      end
    end
  end
  return out
end

function C.residual_authority(m,w)
  local ws=descendants(m,w); local out={}
  for _,s in ipairs(resident_strands(m,ws)) do
    if m:_realised_uses(s)==0 then out[#out+1]=s end
  end
  table.sort(out,function(a,b)return a.serial<b.serial end)
  return out
end

-- A subtree is geometrically retirable exactly when no unspent authority
-- remains resident anywhere in it.  Points/Faces are history/identity and do
-- not prevent retirement.  Child Worlds are retired together with the subtree.
function C.can_retire(m,w)
  if not (w and w.dim==-1 and m:is_realised(w)) then return false,'retirement requires an actual World' end
  if w==m.actuality then return false,'the distinguished actuality root is not retired by this predicate' end
  local residual=C.residual_authority(m,w)
  if #residual>0 then
    local names={}; for _,s in ipairs(residual) do names[#names+1]=s.id end
    return false,'resident authority remains: '..table.concat(names,', '),residual
  end
  return true,nil,{}
end

-- Retire is an assertion/check, not a state transition.  A compiler/runtime may
-- archive/delete the subtree after this succeeds, but the semantic kernel does
-- not add a closed/retired state to World.
function C.require_retirable(m,w)
  local ok,why,res=C.can_retire(m,w)
  if not ok then error('World not retirable: '..tostring(why),2) end
  return true
end

-- Useful diagnostic only: a World with residual authority is *not* thereby a
-- leak.  It becomes a leak only relative to an attempted retirement boundary.
function C.status(m,w)
  local residual=C.residual_authority(m,w)
  if #residual==0 then return 'quiescent',residual end
  return 'live-or-residual',residual
end

return C
