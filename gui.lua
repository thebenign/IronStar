-- Draw the GUIs an shit
suit = require 'suit'

local gui = {}

gui.server = suit.new()

gui.go_button_color = {
        normal   = {bg = { 50,100, 50,150}, fg = {255,255,255}},
        hovered  = {bg = { 50,170, 50,150}, fg = {255,255,255}},
        active   = {bg = {220,220,220,150}, fg = {225,225,225}}
    }
gui.stop_button_color = {
        normal   = {bg = {100, 50, 50,150}, fg = {255,255,255}},
        hovered  = {bg = {170, 50, 50,150}, fg = {255,255,255}},
        active   = {bg = {220,220,220,150}, fg = {225,225,225}}
    }
gui.status_color = {
        normal   = {bg = {150,150,150,80}, fg = {255,255,255}},
        hovered  = {bg = {150,150,150,80}, fg = {255,255,255}},
        active   = {bg = {150,150,150,80}, fg = {225,225,225}}
    }    
    suit.theme.color = {
        normal   = {bg = { 66, 66, 66, 80}, fg = {188,188,188}},
        hovered  = {bg = {150,153,150, 80}, fg = {255,255,255}},
        active   = {bg = {220,220,220,150}, fg = {225,225,225}}
    }
    
    
function gui.play_menu()
    local inputbox
    suit.layout:reset(32,32, 4)
    suit.layout:push(32,32)
    suit.Label("IP",{font=world.small_font, align="left"}, suit.layout:row(140, 16))

    suit.Label("Port",{font=world.small_font, align="left", color = {active={bg = {150,150,150,80}, fg = {225,225,225}}}}, suit.layout:col(50, 16))
    suit.layout:pop()
    suit.layout:push(suit.layout:row())
    suit.Input(world.ip_input,{font=world.small_font}, suit.layout:col(140,30))
    suit.Input(world.port_input, {font=world.small_font}, suit.layout:col(50, 30))
    
    if suit.Button("Go",{font=world.small_font, color = gui.go_button_color}, suit.layout:col(30, 30)).hit then
        net.client.start(world.ip_input.text, world.port_input.text)
    end
    suit.layout:pop()

    local host
    if net.client.host then host = net.client.host:getState() end
    
    suit.Button("Status: "..tostring(host),{font=world.small_font,color=gui.status_color}, suit.layout:row(140, 30))
    
    if suit.Button("Disconnect", {font=world.small_font, color=gui.stop_button_color}, suit.layout:col(84, 30)).hit then
        if net.client.live then
            net.client.stop()
        end
        
    end
    
    
    ---------
    
    --local server = suit.new()
    local server_text
    if net.server.live then
        server_text = "Stop Server"
    else
        server_text = "Start server"
    end
    
    gui.server.layout:reset(love.graphics.getWidth()-232,32, 4)
    if gui.server:Button(server_text, {font=world.small_font}, gui.server.layout:row(200, 30)).hit then
        if net.server.live then
            net.server.stop()
        else
            net.server.start()
        end
        
    end
    if net.server.live then
        
        gui.server:Button("\n Server Status", {font=world.small_font, align="left",valign="top"}, gui.server.layout:row(200, 200))
        
        if net.server.info then
            gui.server.layout:push(gui.server.layout._x,gui.server.layout._y+32)
            for k, v in pairs(net.server.info) do
                gui.server:Label(k..v, {font=world.small_font, align="left"}, gui.server.layout:row(200, 16))
            end
            gui.server.layout:pop()
        end
        
        
        --[[
        if net.server.info then
            gui.server.layout:push(gui.server.layout._x,gui.server.layout._y+32)
            gui.server:Label(" Connected clients: "..net.server.info[1],{font=world.small_font, align="left"}, gui.server.layout:row(200, 16))
            gui.server:Label(" Data sent: "..net.server.info[2],{font=world.small_font, align="left"}, gui.server.layout:row(200, 16))
            gui.server:Label(" Data received: "..net.server.info[3],{font=world.small_font, align="left"}, gui.server.layout:row(200, 16))
            gui.server:Label(" KB received: "..net.server.info[4]/1024,{font=world.small_font, align="left"}, gui.server.layout:row(200, 16))
            for i, v in ipairs(net.server.peer) do
                if v.location and v.location.vec then
                    gui.server:Label(" Client location: "..v.location.vec.x..", "..v.location.vec.y, {font=world.small_font, align="left"}, gui.server.layout:row(200, 16))
                end
                
            end
            
            gui.server.layout:pop()
        end]]

    end
    
    
end

return gui