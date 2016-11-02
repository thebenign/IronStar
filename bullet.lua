local bullet = setmetatable({}, {__call = function(_,x, y) return bullet.new(x, y) end})

bullet.__index = bullet

bullet.enum = 0
bullet.obj = {}


    
function bullet.new(vec, dir)
    local b = setmetatable({}, bullet)
    b.vec = vector(vec.x, vec.y)
    b.vec.dir = dir--+math.rad(math.random()*80-40)
    b.vec.mag = 8+vec.mag/2
    b.vec:step(20)
    
    b.part = particle.new(0, 0)
    b.part:setScale(.75)
    b.part.h = 120
    b.part.sat = 255
    b.part.l = 180
    
    b.part:setSpread(10)
    b.part:setLifeTime(10)
    b.part:setEmitterDelta(0)
    b.part:setRate(3)
    b.part:setAccelSpeed(0)
    b.part:setMaxSpeed(1)
    
    b.part.run = true
    b.part:setAngle(dir)
    
    b.part:setColor(HSL(b.part.h,b.part.sat,b.part.l,255))
    b.kill = false
    
    b.timer = timer.new(200, false)
    b.timer:start()
    b.timer.call = function(self)
        b.kill = true
    end
    
    bullet.enum = bullet.enum + 1
    bullet.obj[bullet.enum] = b
    return b
end

function bullet.update()

    for i = bullet.enum, 1, -1 do
        local b = bullet.obj[i]
        b.vec:step()
        
        b.part.x = b.vec.x
        b.part.y = b.vec.y
        --b.part.a = b.vec.dir
            b.part:update()

        if b.kill then
            b.part = nil
            bullet.obj[i] = bullet.obj[bullet.enum]
            bullet.obj[bullet.enum] = nil
            bullet.enum = bullet.enum - 1

        end
    end
    
end

function bullet.draw()
    for i = 1, bullet.enum do
        bullet.obj[i].part:draw()
    end
end

return bullet