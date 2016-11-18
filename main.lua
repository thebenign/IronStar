-- GLOBALS
lg = love.graphics
DEVMODE = false

-- Require modules
package.path = package.path .. ";./include/?.lua;./assets/?.lua;"

sock   = require ("network.sock")
net    = require ("network.network2")
socket = require ("socket")

gfx      = require ("gfx.gfx")
hsl      = require ("gfx.hsl")
font     = require ("gfx.font")
minimap  = require ("gfx.minimap")
particle = require ("gfx.emitter_class")
map      = require ("gfx.map")

        require ("sound.slam")
sfx   = require ("sound.sfx")
music = require ("sound.music")

geometry  = require ("physics.geometry")
collision = require ("physics.collision")
vector    = require ("physics.vector")

timer     = require ("core.timer")
bullet    = require ("core.bullet")
ship      = require ("core.ship")
keyhandle = require ("core.keyhandle")
camera    = require ("core.camera")

debug = {
    frame = 0
}

function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end

    
    -- Set up the screen environment
    local x, y = love.window.getDesktopDimensions()
    love.window.setMode(900, 720, {resizable=true, vsync=true})
    love.window.setTitle("Shootin' Poopies - v0.1.0")
    love.graphics.setBackgroundColor(10, 10, 10)
    love.keyboard.setKeyRepeat(true)
    
    

    
    MAIN_MENU = 1
    HOST = 2
    CONNECT = 3
    PLAY = 4
    PAUSE = 5
    GAME_MENU = 6
    
    
    
    game = {}
        game.state = MAIN_MENU
    
    love.graphics.setFont(font.main)
    main_map = map.new("01")
    
    
    world = {}
        world.timer = {}
        world.timer.t = 1/60
        world.timer.dt = 0
        world.w = 2600
        world.h = 2600
        world.r = (world.w/2)
        world.name = "Scout"
        world.small_font = love.graphics.newFont(12)
        world.ip_input = {text = "70.117.86.47"}
        world.port_input = {text = "22122"}
    
    step_timer = {
        val = {},
        i = 0,
        max = 60,
        result = 0
    }
    
    
    window = {}
        window.w, window.h = love.window.getMode()
    
    gfx.gen_bg(50,50,2600,2600)
    
    camera.follow(ship)
end

function love.update(dt)

    
    world.timer.dt = world.timer.dt + dt
    --gui.play_menu()
    
    net.client.update(dt)
    net.server.update(dt)

    if world.timer.dt > world.timer.t then
        -- game logic
        
        local step_timer_start = love.timer.getTime()
        keyhandle()
        
        collision.mapCheck(main_map, ship.circle)
        ship.update()
        camera.update()
        
        
        bullet.update()
        
        timer.tick()
        
        local step_timer_end = love.timer.getTime() - step_timer_start
        step_timer.i = step_timer.i + 1
        if step_timer.i < step_timer.max then
            table.insert(step_timer.val, step_timer_end)
        else
            step_timer.i = 0
            local add = 0
            for i, v in ipairs(step_timer.val) do
                add = add + v
            end
            
            step_timer.result = add / #step_timer.val
            step_timer.val = {}
        end
        
        
        world.timer.dt = world.timer.dt - world.timer.t
    end
    
end

function love.keypressed(key, scan, isrepeat)
    if key == "escape" and not isrepeat then
        love.event.quit()
    end
end

function love.textinput(t)
    
end

function love.draw()
    lg.setColor(255,255,255,255)
    
    lg.draw(gfx.img_bg, -((camera.x+window.w*.5)/(2520+1600))*window.w, -(ship.vec.y/(world.h+window.h))*window.h)
    --lg.draw(gfx.bg, -camera.x, -camera.y)
    main_map:draw()
    lg.setLineWidth(6)
    lg.setColor(80,255,130)
    lg.rectangle("line", 0-camera.x, 0-camera.y, world.w, world.h)
    lg.setColor(255,255,255)
    
    if net.server.live then
        net.server.drawOthers()
    end
    if net.client.live then
        net.client.drawOthers()
    end
    
    
    
    bullet.draw()
    ship.draw()

    --Player tag
    lg.setColor(128,128,128,80)
    lg.rectangle("fill",ship.vec.x-camera.x-font.main:getWidth(world.name)/2-4, ship.vec.y-camera.y-78, font.main:getWidth(world.name)+8, 30, 4,4)
    lg.setColor(180,180,180,255)
    lg.print(world.name, ship.vec.x-camera.x-font.main:getWidth(world.name)/2, ship.vec.y-camera.y-78)
    
    minimap.draw()
    
    lg.setColor(255,255,255,255)
    love.graphics.print(love.timer.getFPS(), 0,0)
    love.graphics.print(camera.x, 0,200)
    if step_timer.result*1000 > 16.66 then --[[love.graphics.setColor(255,20,20)]] end
    love.graphics.print("Logic step ms: "..string.format("%.4f",(step_timer.result or 0)*1000), 0, love.graphics.getHeight()-32)
    camera.draw()
end

function love.resize(w, h)
    
    local x, y = love.graphics.getDimensions()
    if not initial_resize then
        love.window.setMode(x,y,{x=0,y=0,vsync=false,resizable=true})
    end
    
    
    window.w, window.h = x, y
    initial_resize = true
end

