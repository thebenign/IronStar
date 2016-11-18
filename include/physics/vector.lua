-- Vector class

local vector = setmetatable({}, {__call = function(_,x, y, ...) return vector.new(x, y, ...) end})
vector.__index = vector

function vector.new(x, y, ...)
    local init = {...}
    local t = setmetatable({}, vector)
    t.changed = false
    t.x = x or 0
    t.y = y or 0
    t.mag = 0
    t.dir = 0
    t.max = init[1] or 1
    t.f = init[2] or 0
    return t
end

function vector:flag() -- flags the vector as changed, useful for network code
    self.changed = true
end
function vector:unflag()
    self.changed = false
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
    local mag, dir = ...
    mag, dir = (mag or self.mag), (dir or self.dir)
    
    self.x = self.x + math.cos(dir)*mag
    self.y = self.y + math.sin(dir)*mag

end

function vector:magToPoint(x, y)
    return math.sqrt((self.y-y)^2 + (self.x-x)^2)
end

function vector:dirToPoint(x,y)
    return math.atan2(y - self.y, x - self.x)
end

return vector