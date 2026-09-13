-- Optional exact execution history for Worlds.
--
-- History observes transitions; it is never consulted by solve.  Live state is
-- always the boundary-normal Geometry returned by advance().

local W=require('worlds')
local H={}
local MT={}; MT.__index=MT

local function copy_equations(es)
  local out={}
  for i,e in ipairs(es or {}) do out[i]={from=e.from or e[1],to=e.to or e[2]} end
  return out
end
local function face_image(development,image)
  local out={}
  for _,f in ipairs(development:faces()) do out[f]=image[f] end
  return out
end

function H.new()
  return setmetatable({records={}},MT)
end

function MT:append(development,equations,image)
  local records=self.records
  records[#records+1]={development=development,equations=copy_equations(equations),faces=face_image(development,image)}
  return records[#records]
end

function MT:advance(world,development,equations)
  local live,image=W.advance(world,development,equations)
  self:append(development,equations,image)
  return live,image
end

function MT:count()
  return #self.records
end

function MT:events()
  local out={}; for i,r in ipairs(self.records) do out[i]=r end; return out
end

return H
