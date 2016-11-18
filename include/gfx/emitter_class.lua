local emitter = {}
emitter.__index = emitter
emitter.part_img = love.graphics.newImage("/assets/particle/part4.tga")
emitter.part_img:setFilter("linear", "linear")

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
    self.clr_rgb = {128,128,128,128}
    self.clr_hsl = {255,255,128,128}
    self.scale = 1    -- scale multiplier
    self.min_s = 0    -- minimum speed
    self.fric = 0    -- friction
    self.camera = true
    
    self.run = true
    self.shrink = true
    
    self.x, self.y = x, y
    return self
end

function emitter:update()
    rand = math.random
    local cos, sin = math.cos, math.sin
    local cx, cy = 0, 0
    if self.camera then
        cx, cy = camera.x or 0, camera.y or 0
    end
    
    
    
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
            self.obj[self.enum].clr_rgb = self.clr_rgb
            self.obj[self.enum].clr_hsl = self.clr_hsl
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
            c = self.obj[k].clr_rgb
            cf = {c[1],c[2],c[3], (1 - delta_normal) * c[4]}
            self.part_batch:setColor(cf)
            self.obj[k].id = self.part_batch:add(self.obj[k].x-cx, self.obj[k].y-cy, delta_normal*3.14*2, scale, scale,32,32)
        end
    end
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
    love.graphics.setBlendMode("add")
    love.graphics.draw(self.part_batch, 0, 0)
    love.graphics.setBlendMode("alpha")
end

function emitter.hsl2rgb()
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
        elseif h < 2 then r,g,b = x,c,0
        elseif h < 3 then r,g,b = 0,c,x
        elseif h < 4 then r,g,b = 0,x,c
        elseif h < 5 then r,g,b = x,0,c
        else              r,g,b = c,0,x
    end
return (r+m)*255,(g+m)*255,(b+m)*255,a
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
    self.clr_rgb = {r,g,b,a}
end
function emitter:setScale(v)
    self.scale = v
end
function emitter:noAdd()
    self.add = nil
end
return emitter