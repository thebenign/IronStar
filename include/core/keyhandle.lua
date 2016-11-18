
local keyhandle = function()
    
    if love.keyboard.isDown("up") then
        ship.vec:add({dir = math.rad(ship.dir), mag = ship.speed})
        sfx.engine:setVolume(.7)
        ship.thrust = true
    else

        sfx.engine:setVolume(0)
        ship.thrust = false
    end
    
    if love.keyboard.isDown("left") then
        ship.dir = ship.dir - ship.rot_speed
    end
    if love.keyboard.isDown("right") then
        ship.dir = ship.dir + ship.rot_speed
    end
    
    if love.keyboard.isDown("a") then
        ship.bullet_timer:start()
        if ship.can_shoot then
            bullet.new(ship.vec, math.rad(ship.dir))
            
            local pew = sfx.bullet:play()
            pew:setPitch(.8 + math.random()*.4)
            
            
            ship.can_shoot = false
        end
        
    end
    
end

return keyhandle