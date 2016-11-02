require "slam"
sock = require "sock"

DEVMODE = false

function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    
    
    local x, y = love.window.getDesktopDimensions()
    
    love.window.setMode(x, y, {resizable=true})
    love.window.maximize()
        -- GLOBALS
    lg = love.graphics
    
    -- Set up the screen environment
    love.window.setTitle("Shootin' Poopies - v0.1.0")
    love.graphics.setBackgroundColor(10, 10, 10)
    love.keyboard.setKeyRepeat(true)
    
    -- required modules
    gfx = require "gfx"
    gui = require "gui"
    geometry = require "geometry"
    collision = require "collision"
    map = require "map"
    minimap = require "minimap"
    
    font = require "font"
    timer = require "timer"
    sfx = require "sfx"
    enet = require "enet"
    particle = require "emitter_class"
    vector = require "vector"
    bullet = require "bullet"
    music = require "music"

    ship = require "ship"
    keyhandle = require "keyhandle"
    star = require "star"
    camera = require "camera"

    net = require "network2"
    
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
        world.ip_input = {text = "localhost"}
        world.port_input = {text = "22122"}
    
    step_timer = {
        val = {},
        i = 0,
        max = 60,
        result = 0
    }
    
    
    window = {}
        window.w = 800
        window.h = 700
        
    star.pop()
    
    gfx.gen_bg(50,50,2600,2600)
    
    camera.follow(ship)
end

function love.update(dt)
    world.timer.dt = world.timer.dt + dt
    gui.play_menu()
    net.clientUpdate(dt)
    net.serverUpdate(dt)

    if world.timer.dt > world.timer.t then

        -- game logic
            local step_timer_start = love.timer.getTime()
        keyhandle()
        collision.mapCheck(main_map, ship.circle)
        
        
        ship.update()
        
        bullet.update()
        
        timer.tick()
        
        ship.part:update()
        
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
        
        --[[ This code is dumb
        if math.sqrt((ship.vec.x-world.r)^2 + (ship.vec.y-world.r)^2) > world.r then
            --ship.vec:step(
            local dir = math.atan2(ship.vec.y-world.r, ship.vec.x-world.r)
            ship.vec.x = ship.vec.x + cos(dir-math.pi)*(math.sqrt((ship.vec.x-world.r)^2 + (ship.vec.y-world.r)^2)-world.r)
            ship.vec.y = ship.vec.y + sin(dir-math.pi)*(math.sqrt((ship.vec.x-world.r)^2 + (ship.vec.y-world.r)^2)-world.r)
            --ship.vec.mag = 0
            
        end]]
        
        world.timer.dt = world.timer.dt - world.timer.t
    end
    
end

function love.keypressed(key, scan, isrepeat)
    if key == "escape" and not isrepeat then
        love.event.quit()
    end
    suit.keypressed(key)
end

function love.textinput(t)
    suit.textinput(t)
end

function love.draw()
    lg.setColor(255,255,255,255)
    --star.draw()
    lg.draw(gfx.img_bg, -(ship.vec.x/world.w)*1280, -(ship.vec.y/world.h)*720)
    --lg.draw(gfx.bg, -camera.x, -camera.y)
    main_map:draw()
    lg.setLineWidth(6)
    lg.setColor(80,255,130)
    lg.rectangle("line", 0-camera.x, 0-camera.y, world.w, world.h)
    lg.setColor(255,255,255)
    
    if net.server.state then
        net.serverDrawOthers()
    end
    if net.client.state then
        net.clientDrawOthers()
    end
    
    
    ship.part:draw()
    bullet.draw()
    ship.draw()
    
    --Player tag
    lg.setColor(128,128,128,80)
    lg.rectangle("fill",ship.vec.x-camera.x-font.main:getWidth(world.name)/2-4, ship.vec.y-camera.y-78, font.main:getWidth(world.name)+8, 30, 4,4)
    lg.setColor(180,180,180,255)
    lg.print(world.name, ship.vec.x-camera.x-font.main:getWidth(world.name)/2, ship.vec.y-camera.y-78)
    
    minimap.draw()
    
    suit.draw()
    gui.server:draw()
    lg.setColor(255,255,255,255)
    love.graphics.print(love.timer.getFPS(), 0,0)
    if step_timer.result*1000 > 16.66 then love.graphics.setColor(255,20,20) end
    love.graphics.print("Logic step ms: "..string.format("%.4f",(step_timer.result or 0)*1000), 0, love.graphics.getHeight()-32)
    camera.draw()
end

function love.resize(w, h)
    local x, y = love.graphics.getDimensions()
    print(x, y)
    love.window.setMode(x,y,{x=0,y=0,vsync=true})
    
    window.w, window.h = x, y
    
end

function HSL(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h, s, l = h/256*6, s/255, l/255
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

