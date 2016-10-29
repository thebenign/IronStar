local star = {}

function star.pop()    
    for i = 0, 500 do
        star[i] = {}
        star[i].x = math.random()*world.w*2
        star[i].y = math.random()*world.h*2
        star[i].r = math.random()*2+1
    end
end

function star.draw()
    for i = 0, 500 do
        --love.graphics.setColor(255,255,255,((star[i].r-1)/3)*255)
        lg.circle("fill", star[i].x-ship.vec.x*(star[i].r/12), star[i].y-ship.vec.y*(star[i].r/12), star[i].r)
    end
    love.graphics.setColor(255,255,255,255)
end

return star