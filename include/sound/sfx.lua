local sfx = {}

sfx.engine = love.audio.newSource("assets/sfx/engine_2.wav", "static")
sfx.engine:setLooping(true)
sfx.engine:setVolume(0)
sfx.engine:play()

sfx.bullet = love.audio.newSource("assets/sfx/Laser_Shoot_2.wav", "static")
sfx.bullet:setVolume(1)

return sfx