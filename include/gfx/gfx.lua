--[[Graphics module:
    Load graphics at run-time and build
    some procedural shit.]]

local gfx = {}
print(love.filesystem.getWorkingDirectory())
gfx.img_bg = love.graphics.newImage("assets/img/procgen2.png")
function gfx.gen_bg(ix, iy, bx, by) -- Generate background batch
    
    local data = love.image.newImageData(ix, iy)
    local chroma_var
    for y = 0, iy-1 do
        for x = 0, ix-1 do
            data:setPixel(x,y,255,255,255,255)
        end
    end
    
    local bg_img = love.graphics.newImage(data)
    gfx.bg = love.graphics.newSpriteBatch(bg_img, math.floor(bx/ix) * math.floor(by/iy), "static")
    local c
    for y = 0, math.floor(by/iy)-1 do
        for x = 0, math.floor(bx/ix)-1 do
            c = math.floor(math.random()*10+10)
            gfx.bg:setColor(c,c,c+20,127)
            gfx.bg:add(x*ix, y*iy)
        end
    end
    
end

return gfx