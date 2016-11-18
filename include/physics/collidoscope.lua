--== collidoscope ==--

--[[Collidoscope is a full collision detection system.
As such, it does not resolve collisions, just reports when they occur.
Collidoscope uses a simple spatial hash table to break the world into a grid.
Every object gets indexed based on its coordinates.

When I programmed this, only god and I knew what I was doing.
Now only god does.
]]

local collider = {}
collider.__index = collider

collider.count = 0
collider.list = {}
collider.cell_size = 128

collider.range = {}

function collider.new()
  assert(world and world.w and world.h,"Collidoscope depends on a global table called 'world' that contains the width and height of the world.\nTo use collidoscope, simply create a table called world and ensure world.w and world.h reflect the expected width and height of the world.")
  local self = setmetatable({},collider)
  self.count = 0
  self.cell_size = collider.cell_size
  self.w = math.ceil(world.w/collider.cell_size)
  
  --collider.count = collider.count + 1
  --collider.list[collider.count] = self
  return self
end
function collider:remove(obj)
  for i = 1, obj.cell_count do
    self[obj.cells[i]][obj.cell_ind[i]] = self[obj.cells[i]][#self[obj.cells[i]]]
    self[obj.cells[i]].count = self[obj.cells[i]].count - 1
  end
end

function collider:add(obj)
  local cells = self:getCellsFor(obj)
  
  for i = 1, #cells do
    if not self[cells[i]] then
      self[cells[i]] = {}
      self[cells[i]].count = 0
    end
    self[cells[i]].count = self[cells[i]].count + 1
    self[cells[i]][self[cells[i]].count] = obj
    obj.cell_ind[i] = self[cells[i]].count
  end
end

function collider:getCellsFor(obj)
  local cells = {}
  local temp = {}
  local c = 0
  local range = collider.range
  range[1] = {x = obj.x, y = obj.y}
  range[2] = {x = obj.x+obj.w, y = obj.y}
  range[3] = {x = obj.x, y = obj.y+obj.h}
  range[4] = {x = obj.x+obj.w, y = obj.y+obj.h}
  for i = 1, 4 do
    c = self:calculateCell(range[i].x,range[i].y)
    if not temp[c] then
      temp[c] = 1
      cells[#cells+1] = c
    end
  end
  obj.cell_count = i
  obj.cells = cells
  return cells
end

function collider:calculateCell(x,y)
  y = y/self.cell_size
  x = x/self.cell_size
  y = (y-y%1)*self.w
  x = 1+x-x%1
  return y + x
end

function collider:clear()
  return collider.new()
end

return collider