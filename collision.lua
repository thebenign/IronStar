--collision

local collision = {}

function collision.circleRect(circle, rect)
    local circleDistance = {}
    local cornerDistance_sq
    circleDistance.x = math.abs(circle.x - (rect.x+rect.w/2))
    circleDistance.y = math.abs(circle.y - (rect.y+rect.h/2))

    if circleDistance.x > rect.w/2 + circle.r then return false end
    if circleDistance.y > rect.h/2 + circle.r then return false end

    if circleDistance.x <= rect.w/2 then return true end
    if circleDistance.y <= rect.h/2 then return true end

    cornerDistance_sq = (circleDistance.x - rect.w/2)^2 + (circleDistance.y - rect.h/2)^2

    return (cornerDistance_sq <= (circle.r^2))
end

function collision.circleRect2(circle, rect)
    --intersectPoint: (point) ->
    local dir = math.atan2(circle.y-(rect.y+rect.h/2), circle.x-(rect.x+rect.w/2))
    point = {x=circle.x-math.cos(dir)*circle.r, y=circle.y-math.sin(dir)*circle.r}
    local dx = point.x - (rect.x + rect.w/2)
    local px = (rect.w/2) - math.abs(dx)
    if px <=0 then
        return false
    end

    local dy = point.y - (rect.y + rect.h/2)
    local py = (rect.h/2) - math.abs(dy)
    if py <= 0 then
        return false
    end

    local hit = {}
    hit.point = point
    hit.delta = {}
    hit.normal = {}
    hit.pos = {}

    if px < py then
        local sx = collision.sign(dx)
        hit.delta.x = px * sx
        hit.normal.x = sx
        hit.pos.x = rect.x + ((rect.w/2) * sx)
        hit.pos.y = point.y
    else
        local sy = collision.sign(dy)
        hit.delta.y = py * sy
        hit.normal.y = sy
        hit.pos.x = circle.x
        hit.pos.y = point.y + ((rect.w/2) * sy)
    end
    return hit
end


function collision.resolveCircleRect(circle, rect)
    local transRect = {x=rect.x,y=rect.y}
    local dist
    transRect.w = rect.w+circle.r
    transRect.h = rect.h+circle.r
    --dist = 
end

function collision.sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function collision.mapCheck(map, circle)
    local h_tiles, v_tiles = map.width, map.height
    local hit
    local rect
    for y = 0, v_tiles do
        for x = 0, h_tiles do
            if map.data[y*map.width+x+1] and map.data[y*map.width+x+1] > 0 then
                rect = {x=x*map.tile_width,y=y*map.tile_height,w=map.tile_width,h=map.tile_height}

                hit = collision.circleRect2(circle, rect)
                if hit then
                    if hit.delta.x then
                        ship.vec.x = ship.vec.x + hit.delta.x
                        local norm = math.rad(hit.normal.x * 180)
                        ship.vec.dir = 2 * norm - math.pi - ship.vec.dir
                    end
                    if hit.delta.y then
                        ship.vec.y = ship.vec.y + hit.delta.y
                        local norm = math.rad(hit.normal.y * 90)
                        ship.vec.dir = 2 * norm - math.pi - ship.vec.dir
                    end
                    ship.colliding = {255,0,0,255}
                    ship.vec.mag = ship.vec.mag*.75
                else
                    ship.colliding = {255,255,255,255}
                end
                
            end
        end
    end
end

return collision