local function partTable(w, h, dist, off, n, prop)
    local pt = {w = w, h = h, dist = dist, off = off, canvas = love.graphics.newCanvas(w, h)}

    for i = 1, n do
        local part = particle.new()
        for k, v in pairs(prop) do
            part[k] = v
        end
        table.insert(pt, part)
    end
    return pt
end


local ship = {
    img = lg.newImage("/assets/img/newshipmid1.png"),
    vec       = vector(500,500,9,.125),
    
    dir       = 0,
    rot_speed = 6,
    speed     = .4,
    can_shoot = true,
    thrust    = false,
    
    colliding = false,
    circle = geometry.newCircle(500, 500, 36),--collision circle,
    
    bullet_timer = timer.new(9, false),
    wave_delta = 0,
    
    part = partTable(475, 475, 44, 85, 2, 
        {
            scale = .75,
            clr_hsl = {160, 255, 180, 180},
            clr_rgb = {hsl(120,220,190,255)},
            a = 0,
            spread = math.rad(6),
            s = 1,
            min_s = .5,
            part_t = 20,
            pps = 7,
            run = true,
            camera = false,
        }
    )
}

ship.bullet_timer.call = function(self)
    ship.can_shoot = true
    --ship.wave_delta = (ship.wave_delta + 1) % 6
    --if ship.wave_delta > 2 then ship.can_shoot = false end
end

function ship.runParticles()
    
    love.graphics.setCanvas(ship.part.canvas)
    love.graphics.clear()
    ship.part.a = math.rad(ship.dir)-math.pi
    for i, v in ipairs(ship.part) do
        if ship.thrust then
            v.s = 6
            v.min_s = 5
        else
            v.s = .5
            v.min_s = 0
        end
        local rgb = v.color
        --v.color = HSL()
        v.a = math.rad(ship.dir)-math.pi
        v.x = ship.part.w/2+math.cos(v.a + math.rad(ship.part.off/(#ship.part-1)*(i-1))-math.rad(ship.part.off/2))*ship.part.dist
        v.y = ship.part.h/2+math.sin(v.a + math.rad(ship.part.off/(#ship.part-1)*(i-1))-math.rad(ship.part.off/2))*ship.part.dist
        v:update()
        v.part_batch:flush()
        v:draw()
        
    end
    love.graphics.setCanvas()
end

function ship.update()
        if not love.keyboard.isDown("up") then ship.vec:addFriction() end
--[[        local vec = {x = ship.vec.x, y = ship.vec.y, dir = ship.part.a+math.rad(42), mag = 44}
        local vec2 = {x = ship.vec.x, y = ship.vec.y, dir = ship.part.a-math.rad(42), mag = 44}
        vector.step(vec)
        vector.step(vec2)]]
        
        if ship.vec.mag ~= 0 then
            ship.vec:flag()
        else
            ship.vec:unflag()
        end
        
        ship.vec:step()
        
        ship.runParticles()
        ship.circle.x = ship.vec.x
        ship.circle.y = ship.vec.y
        
end

function ship.draw()
    lg.draw(ship.img, ship.vec.x-camera.x, ship.vec.y-camera.y, math.rad(ship.dir), .3, .3, 145, 163)
    lg.setBlendMode("alpha", "premultiplied")
    lg.draw(ship.part.canvas, ship.vec.x-camera.x, ship.vec.y-camera.y, 0, 1, 1, ship.part.w/2,ship.part.h/2)
    lg.setBlendMode("alpha")
    local x = ship.vec.x + math.cos(math.rad(ship.dir))*100
    local y = ship.vec.y + math.sin(math.rad(ship.dir))*100
    lg.setLineWidth(1)
    lg.setColor(255,255,255,100)
    lg.circle("line", x-camera.x, y-camera.y, 8,7)
end
    
return ship
