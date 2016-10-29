local timer = {}

timer.__index = timer
timer.enum = 0
timer.obj = {}

function timer.new(time, loop) -- time is frames before timer runs out - timer restarts if bool: loop is true
    local self = setmetatable({}, timer)
    self.t = time
    self.dt = 0
    self.loop = loop
    self.run = false
    self.call = function(self) end
    
    timer.enum = timer.enum + 1
    timer.obj[timer.enum] = self
    
    return self
    
    
end

function timer.tick()
    for i = timer.enum, 1, -1 do
        local t = timer.obj[i]
        if t.run then
            t.dt = t.dt + 1

            if t.dt > t.t then
                t.dt = 0
                t.call()
                if t.loop then
                    t.run = true
                end
            end
        end
    end

end

function timer:start()
    self.run = true
end

return timer