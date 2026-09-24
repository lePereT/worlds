-- Ordered non-authoritative presentation of exact open Strand occurrences.
--
-- A Presentation owns no Geometry and carries no programme authority.  Its rows,
-- row order, coordinate order and coordinate multiplicity are descriptive
-- structure relative to one exact ambient Geometry.

local W=require('worlds')
local Construction=require('worlds.construction')
local DENSE=require('worlds._array')

local Presentation={}
local MT={}; MT.__index=MT
local MARK_KEY,STATE_KEY,MARK={},{},{}

local function immutable() error('Worlds values are immutable',2) end

local function state(x)
  if type(x)~='table' then return nil end
  local ok,m=pcall(function() return x[MARK_KEY] end)
  if not ok or m~=MARK then return nil end
  local ok2,st=pcall(function() return x[STATE_KEY] end)
  return ok2 and st or nil
end

local function copy_row(row)
  local out={}
  for i=1,#row do out[i]=row[i] end
  return out
end

local function copy_rows(rows)
  local out={}
  for i=1,#rows do out[i]=copy_row(rows[i]) end
  return out
end

local function is_open(g,s)
  return g:producer(s)==nil or g:consumer(s)==nil
end

local function normal_rows(g,rows)
  DENSE.length(rows,'Presentation rows')
  local out={}
  for i,row in ipairs(rows) do
    local xs=DENSE.copy(row,'Presentation row')
    for _,s in ipairs(xs) do
      assert(W.kind(s)=='strand' and g:owns_strand(s),'Presentation coordinate must be an exact Strand of the ambient Geometry')
      assert(is_open(g,s),'Presentation coordinate must be open in the ambient Geometry')
    end
    out[i]=xs
  end
  return out
end

local function value(st)
  return setmetatable({}, {
    __newindex=immutable,
    __metatable='Worlds Presentation',
    __index=function(_,k)
      if k==MARK_KEY then return MARK end
      if k==STATE_KEY then return st end
      return MT[k]
    end,
  })
end

function Presentation.new(geometry,rows)
  assert(W.is_geometry(geometry),'Presentation ambient must be Worlds Geometry')
  return value{ambient=geometry,rows=normal_rows(geometry,rows)}
end

function Presentation.is_presentation(x)
  return state(x)~=nil
end

function MT:ambient()
  return assert(state(self),'Worlds Presentation required').ambient
end

function MT:rows()
  return copy_rows(assert(state(self),'Worlds Presentation required').rows)
end

function MT:row(i)
  local st=assert(state(self),'Worlds Presentation required')
  assert(type(i)=='number' and i>=1 and i%1==0 and i<=#st.rows,'Presentation row index out of range')
  return copy_row(st.rows[i])
end

function MT:transport(construction)
  local st=assert(state(self),'Worlds Presentation required')
  assert(Construction.is_construction(construction),'Presentation transport requires Worlds Construction')

  local authorised=false
  for _,g in ipairs(construction:parts()) do
    if g==st.ambient then authorised=true; break end
  end
  assert(authorised,'Presentation ambient must be an exact part of the Construction')

  local target=construction:result()
  local rows={}
  for i,row in ipairs(st.rows) do
    local out={}
    for _,s in ipairs(row) do
      local mapped=construction:image(s)
      if mapped and W.kind(mapped)=='strand' and target:owns_strand(mapped) and is_open(target,mapped) then
        out[#out+1]=mapped
      end
    end
    rows[i]=out
  end
  return value{ambient=target,rows=rows}
end

return Presentation
