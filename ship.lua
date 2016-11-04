local ship = {}

ship.img = lg.newImage("/img/esmhPKd.png")

ship.vec = vector(500, 500)
ship.vec:flag()

ship.vec.f = .1
ship.vec.max = 9
ship.dir = 0
ship.rot_speed = 6
ship.speed = .5
ship.can_shoot = true
ship.thrust = 0


ship.colliding = false
ship.circle = geometry.newCircle(ship.vec.x, ship.vec.y, 28)--collision circle

ship.bullet_timer = timer.new(7, false)

ship.bullet_timer.call = function(self)
    ship.can_shoot = true
    ship.bullet_timer.run = false
end



ship.part = particle.new(ship.vec.x, ship.vec.y)
    ship.part:setScale(.75)
    ship.part.h = 140
    ship.part.sat = 255
    ship.part.l = 180
    ship.part:setColor(HSL(ship.part.h,ship.part.sat,ship.part.l,250))
    ship.part:setMaxSpeed(1)
    ship.part:setMinSpeed(0)
    ship.part:setSpread(0)
    ship.part:setLifeTime(20)
    ship.part:setEmitterDelta(0)
    ship.part:setRate(6)
    ship.part:setAccelSpeed(0)
    ship.part.fric = 3
    
    ship.part.run = false
    
ship.part2 = particle.new(ship.vec.x, ship.vec.y)
    ship.part2:setScale(.75)
    ship.part2.h = 140
    ship.part2.sat = 255
    ship.part2.l = 180
    ship.part2:setColor(HSL(ship.part.h,ship.part.sat,ship.part2.l,250))
    ship.part2:setMaxSpeed(1)
    ship.part2:setMinSpeed(0)
    ship.part2:setSpread(0)
    ship.part2:setLifeTime(20)
    ship.part2:setEmitterDelta(0)
    ship.part2:setRate(6)
    ship.part2:setAccelSpeed(0)
    ship.part2.fric = 3
    
    ship.part2.run = false
    
function ship.update()
        if not love.keyboard.isDown("up") then ship.vec:addFriction() end
        local vec = {x = ship.vec.x, y = ship.vec.y, dir = ship.part.a+math.rad(42), mag = 44}
        local vec2 = {x = ship.vec.x, y = ship.vec.y, dir = ship.part.a-math.rad(42), mag = 44}
        vector.step(vec)
        vector.step(vec2)
        
        if ship.vec.mag ~= 0 then
            ship.vec:flag()
        else
            ship.vec:unflag()
        end
        
        ship.vec:step()
        
        ship.part.x = vec.x
        ship.part.y = vec.y
        ship.part2.x = vec2.x
        ship.part2.y = vec2.y
        ship.part.a = math.rad(ship.dir)-math.pi
        ship.part2.a = math.rad(ship.dir)-math.pi

        ship.circle.x = ship.vec.x
        ship.circle.y = ship.vec.y
end

function ship.draw()
    lg.draw(ship.img, ship.vec.x-camera.x, ship.vec.y-camera.y, math.rad(ship.dir), .3, .3, 145, 163)
    local x = ship.vec.x + math.cos(math.rad(ship.dir))*100
    local y = ship.vec.y + math.sin(math.rad(ship.dir))*100
    lg.setLineWidth(1)
    lg.setColor(255,255,255,100)
    lg.setBlendMode("add")
    lg.circle("line", x-camera.x, y-camera.y, 8,5)
    lg.setBlendMode("alpha")
end
    
return ship
