-- map
local map = {}
map.__index = map

function map.new(file)
    local m = setmetatable({}, map)
    local f = "maps."..file
    local file_table = require(f)

    m.data = file_table.layers[1].data
    m.tileset = {}
    m.tileset.file_name = file_table.tilesets[1].image
    m.tileset.img = love.graphics.newImage("/assets/maps/"..m.tileset.file_name)
    m.tileset.img_width = file_table.tilesets[1].imagewidth
    m.tileset.img_height = file_table.tilesets[1].imageheight
    m.tileset.h_tiles = math.floor(file_table.tilesets[1].imagewidth/file_table.tilesets[1].tilewidth)
    m.tileset.v_tiles = math.floor(file_table.tilesets[1].imageheight/file_table.tilesets[1].tileheight)
    m.tileset.tile = {}
    local h_tiles = math.floor(file_table.tilesets[1].imagewidth/file_table.tilesets[1].tilewidth)
    local v_tiles = math.floor(file_table.tilesets[1].imageheight/file_table.tilesets[1].tileheight)
    for y = 0, v_tiles do
        for x = 0, h_tiles do
        m.tileset.tile[y*h_tiles+x+1] = love.graphics.newQuad(x*file_table.tilesets[1].tilewidth, y*file_table.tilesets[1].tileheight, file_table.tilesets[1].tilewidth, file_table.tilesets[1].tileheight, m.tileset.img:getDimensions())
        end
    end
    
    m.width = file_table.width
    m.height = file_table.height
    m.tile_width = file_table.tilewidth
    m.tile_height = file_table.tileheight

    return m
end

function map:draw()
    local h_tiles, v_tiles = self.width, self.height
    for y = 0, v_tiles do
        for x = 0, h_tiles-1 do
            if self.data[y*self.width+x+1] and self.data[y*self.width+x+1] > 0 then
                
                love.graphics.draw(self.tileset.img, self.tileset.tile[self.data[y*self.width+(x+1)]], x*self.tile_width-camera.x, y*self.tile_height-camera.y)
                --love.graphics.rectangle("line",x*self.tile_width-camera.x, y*self.tile_height-camera.y,50,50)
            end
            
        end
    end
end


return map