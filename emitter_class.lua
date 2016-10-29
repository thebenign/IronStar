local emitter = {}
emitter.__index = emitter
emitter.part_img = love.graphics.newImage("/img/part4.tga")
emitter.part_img:setFilter("linear", "linear")
--emitter.part_batch = love.graphics.newSpriteBatch(emitter.part_img,15000,"static")

function emitter.new(...)
    local args = {...}
    local x, y = args[1] or 0, args[2] or 0
    local self = setmetatable({}, emitter)
    
    self.part_batch = love.graphics.newSpriteBatch(emitter.part_img,15000,"static")
    self.obj = {}
    self.enum = 0    -- Enumerator
    self.emit_dt = 0    --delta time
    self.emit_t = 1    -- timer
    self.part_t = 30    -- life timer
    self.pps = 1    -- particles per step
    self.a = 0    -- angle in radians
    self.spread = 0    -- angle variation in radians
    self.s = 0    -- pixels per step movement
    self.acc_a = 0    -- acceleration angle in radians
    self.acc_s = 0    -- acceleration speed
    self.tang_d = 0    -- tangental angle delta?
    self.tang_s = 0
    self.tang_a = 0
    self.color = {255,255,255,255}
    self.h = 0
    self.scale = 1    -- scale multiplier
    self.min_s = 0    -- minimum speed
    self.fric = 0    -- friction
    
    self.run = true
    self.shrink = true
    
    self.x, self.y = x, y
    return self
end

function emitter:update()
    rand = math.random
    cos, sin = math.cos, math.sin
    local cx, cy = camera.x or 0, camera.y or 0
    
    
    self.emit_dt = self.emit_dt + 1

    if self.emit_dt > self.emit_t and self.run then
        for i = 1, self.pps do
            self.enum = self.enum + 1
            self.emit_dt = 0
            self.obj[self.enum] = {}
            self.obj[self.enum].x = self.x
            self.obj[self.enum].y = self.y
            self.obj[self.enum].a = self.a + rand()*self.spread-(self.spread*.5)
            self.obj[self.enum].min_s = self.min_s
            self.obj[self.enum].s = self.min_s + rand()*(self.s-self.min_s)
            self.obj[self.enum].xd = cos(self.obj[self.enum].a)*self.obj[self.enum].s
            self.obj[self.enum].yd = sin(self.obj[self.enum].a)*self.obj[self.enum].s
            self.obj[self.enum].acc_a = self.acc_a
            self.obj[self.enum].acc_s = self.acc_s
            self.obj[self.enum].dt = 0
            self.obj[self.enum].t = self.part_t
            self.obj[self.enum].diam = self.diam
            self.obj[self.enum].scale = self.scale
            self.obj[self.enum].tang_d = self.tang_d
            self.obj[self.enum].tang_s = self.tang_s
            self.obj[self.enum].tang_a = self.tang_a
            self.obj[self.enum].color = self.color
            self.obj[self.enum].fric = self.fric

        end
    end

    local x, y
    local c, cf
    local delta_normal
    local scale = self.scale
    self.part_batch:clear()

    for k = self.enum, 1, -1 do

        self.obj[k].a = self.obj[k].a + self.obj[k].tang_a--self.obj[k].tang_d
        
        self.obj[k].xd = cos(self.obj[k].a)*self.obj[k].s
        self.obj[k].yd = sin(self.obj[k].a)*self.obj[k].s
        
        self.obj[k].xd = self.obj[k].xd + cos(self.obj[k].acc_a)*self.obj[k].acc_s
        self.obj[k].yd = self.obj[k].yd + sin(self.obj[k].acc_a)*self.obj[k].acc_s

        self.obj[k].x = self.obj[k].x + self.obj[k].xd
        self.obj[k].y = self.obj[k].y + self.obj[k].yd

        if self.obj[k].fric > 0 then emitter.addFriction(self.obj[k]) end
        


        self.obj[k].dt = self.obj[k].dt + 1

        if self.obj[k].dt > self.obj[k].t then
            self.obj[k] = self.obj[self.enum]
            self.enum = self.enum - 1
        else
            delta_normal = self.obj[k].dt/self.obj[k].t
            if self.shrink then scale = (1-delta_normal)*self.obj[k].scale end
            c = self.obj[k].color
            cf = {c[1],c[2],c[3], (1 - delta_normal) * c[4]}
            self.part_batch:setColor(cf)
            self.obj[k].id = self.part_batch:add(self.obj[k].x-cx, self.obj[k].y-cy, delta_normal*3.14*2, scale, scale,32,32)
        end

    end
    return self
end

function emitter.addFriction(obj)
    local mag = math.sqrt(obj.xd^2 + obj.yd^2)
    local a = math.atan2(obj.yd,obj.xd)
    if mag > .005 then
        obj.xd = obj.xd - math.cos(a) * obj.fric
        obj.yd = obj.yd - math.sin(a) * obj.fric
    else
        obj.xd = 0
        obj.yd = 0
    end
end

function emitter:draw()
    local rr,rg,rb,ra = love.graphics.getColor()  -- grab the current brush color
    love.graphics.setBlendMode("add")
    love.graphics.draw(self.part_batch, 0, 0)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(rr,rg,rb,ra)
end





function emitter:burst()

end

function emitter:move(x,y)
    self.x = x
    self.y = y
end

function emitter:setRate(v)
    self.pps = v
end
function emitter:setEmitterDelta(v)
    self.emit_t = v
    self.emit_dt = v
end

function emitter:setLifeTime(v)
    self.part_t = v
end
function emitter:setAngle(v)
    self.a = v
end
function emitter:setSpread(v)
    self.spread = math.pi/180*v
end
function emitter:setMaxSpeed(v)
    self.s = v
end
function emitter:setMinSpeed(v)
    self.min_s = v
end
function emitter:setAccelAngle(v)
    self.acc_a = v
end
function emitter:setAccelSpeed(v)
    self.acc_s = v
end
function emitter:setFric(v)
    self.fric = v
end
function emitter:setColor(r,g,b,a)
    self.color = {r,g,b,a}
end
function emitter:setScale(v)
    self.scale = v
end
function emitter:noAdd()
    self.add = nil
end
return emitter