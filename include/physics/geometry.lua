--geometry

local geometry = {}

function geometry.newCircle(x, y, r)
    return {x=x, y=y, r=r}
end

function geometry.newRect(x, y, w, h)
    return {x=x, y=y, w=w, h=h}
end

return geometry