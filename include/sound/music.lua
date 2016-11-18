local music = {}

music.track = {}

--[[music.track[1] = love.audio.newSource("/music/679456_ColBreakz---Gameboy.mp3", "stream")
music.dev = love.audio.newSource("/music/678911_Stellar-Lull.mp3", "stream")
music.track[1]:setVolume(.8)
music.track[1]:setLooping(true)
music.dev:setVolume(.45)
music.dev:setLooping(true)
if DEVMODE then
    music.dev:play()
else
    --music.track[1]:play()
end
]]

return music