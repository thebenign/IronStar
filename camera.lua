local camera = {}
    camera.x = 0
    camera.y = 0
    
function camera.follow(obj) -- object with vector
    camera.obj = obj
end

function camera.update()
    camera.x = math.floor(camera.obj.vec.x - window.w/2)
    camera.y = math.floor(camera.obj.vec.y - window.h/2)
end

return camera