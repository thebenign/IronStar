local ship = {}

ship.img = lg.newImage("/img/g5613.png")

ship.vec = vector(500, 500)

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
    ship.part:setScale(.5)
    ship.part.h = 140
    ship.part.sat = 255
    ship.part.l = 180
    ship.part:setColor(HSL(ship.part.h,ship.part.sat,ship.part.l,200))
    ship.part:setMaxSpeed(1)
    ship.part:setMinSpeed(0)
    ship.part:setSpread(0)
    ship.part:setLifeTime(60)
    ship.part:setEmitterDelta(0)
    ship.part:setRate(6)
    ship.part:setAccelSpeed(0)
    ship.part.fric = 3
    
    ship.part.run = false
    

function ship.update()
        if not love.keyboard.isDown("up") then ship.vec:addFriction() end
        local vec = {x = ship.vec.x, y = ship.vec.y, dir = ship.part.a, mag = 22}
        vector.step(vec)
        
        ship.part.x = vec.x
        ship.part.y = vec.y
        ship.part.a = math.rad(ship.dir)-math.pi

        ship.circle.x = ship.vec.x
        ship.circle.y = ship.vec.y
        camera.update()
end

function ship.draw()
    lg.draw(ship.img, ship.vec.x-camera.x, ship.vec.y-camera.y, math.rad(ship.dir), 1, 1, 32, 31)
end
    
return ship
