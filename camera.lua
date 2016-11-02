local camera = {
    x = 0,
    y = 0,
    rolloff = .6,
    follow_distance = 0,
    
    vec = vector()
    }
    
function camera.follow(obj) -- object with vector
    camera.obj = obj
end

function camera.update()
    local dist = camera.vec:magToPoint(camera.obj.vec.x-window.w/2, camera.obj.vec.y-window.h/2)
    dist = (dist > .25) and dist or 0
    if dist > camera.follow_distance then
        camera.vec:step((dist-camera.follow_distance)^camera.rolloff, camera.vec:dirToPoint(camera.obj.vec.x-window.w/2, camera.obj.vec.y-window.h/2))
    end
    
    camera.x = math.floor(camera.vec.x)
    camera.y = math.floor(camera.vec.y)
end

function camera.draw()

end

return camera