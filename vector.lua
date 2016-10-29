-- Vector class

local vector = setmetatable({}, {__call = function(_,x, y) return vector.new(x, y) end})
vector.__index = vector

function vector.new(x, y)
    local t = setmetatable({}, vector)
    t.x = x
    t.y = y
    t.mag = 0
    t.dir = 0
    t.f = 0
    t.max = 6
    return t
end

function vector:add(vec)
    local dir1, mag1 = self.dir, self.mag
    local dir2, mag2 = vec.dir, vec.mag
    
    local new_y = math.sin(dir1)*mag1 + math.sin(dir2)*mag2
    local new_x = math.cos(dir1)*mag1 + math.cos(dir2)*mag2
    
    self.dir = math.atan2(new_y, new_x)
    self.mag = math.sqrt(new_x^2 + new_y^2)
    
    if self.mag > self.max then self.mag = self.max end
    
end

function vector:capSpeed()

end

function vector:addFriction()
    if self.mag > .25 then self.mag = self.mag - self.f end
    if self.mag <= .25 then self.mag = 0 end
end

function vector:step(...)
    local args = {...}
    local m = args[1] or self.mag
    self.x = self.x + math.cos(self.dir)*m
    self.y = self.y + math.sin(self.dir)*m

end

function vector:getVecToPoint()
    
end

return vector