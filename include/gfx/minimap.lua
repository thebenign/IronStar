--minimap

local minimap = {}

function minimap.draw()
    lg.setColor(150,150,150,50)
    lg.rectangle("fill", window.w-216, window.h-216, 200, 200)
    lg.setColor(200,200,200,100)
    lg.setLineWidth(1)
    lg.rectangle("line", window.w-216, window.h-216, 200, 200)
    lg.setColor(255,0,0,200)
    lg.setPointSize(5)
    lg.points(ship.vec.x/2600*200+window.w-216, ship.vec.y/2600*200+window.h-216)
    lg.setPointSize(1)
end

return minimap