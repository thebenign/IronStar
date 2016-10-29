connect_type = "server"

local network = {}
network.status = 0

network.peer = {}

network.ship = {}
    network.ship.stage = 1
    network.ship.live = false
    network.ship.x = 0
    network.ship.y = 0
    network.ship.r = 0
    network.ship.thrust = 0
    
    network.ship.name = nil

local p = particle.new(network.ship.x, network.ship.y)
    p:setScale(1)
    p.h = 26
    p.sat = 255
    p.l = 180
    p:setColor(HSL(p.h,p.sat,p.l,200))
    p:setMaxSpeed(5)
    p:setMinSpeed(2)
    p:setSpread(15)
    p:setLifeTime(30)
    p:setEmitterDelta(0)
    p:setRate(6)
    p:setAccelSpeed(0)
    p.fric = 0
    
    p.run = true

network.ship.part = p

function network.drawShip()
    network.ship.part:draw()
    lg.draw(ship.img, network.ship.x-camera.x, network.ship.y-camera.y, math.rad(network.ship.r), 1, 1, 28, 28)
    
    lg.setColor(128,128,128,80)
    lg.rectangle("fill",network.ship.x-camera.x-font.main:getWidth(network.ship.name)/2-4, network.ship.y-camera.y-78, font.main:getWidth(network.ship.name)+8, 30, 4,4)
    love.graphics.setColor(180,180,255,255)
    lg.print(network.ship.name, network.ship.x-camera.x-font.main:getWidth(network.ship.name)/2, network.ship.y-camera.y-78)
    love.graphics.setColor(255,255,255)
end

function network.service()
    
    local event = network.host:service()
    if not event then
        return false
    end
        
    if event.type == "receive" then

        if network.ship.stage > 1 then
            network.ship.live = true
            local data = {}
            local j = 0
            for i in string.gmatch(event.data, "[%-]?%d+") do
                j = j + 1
                data[j] = tonumber(i)
            end
            network.ship.x = data[1]
            network.ship.y = data[2]
            network.ship.r = data[3]
            network.ship.thrust = data[4]
        else
            network.ship.name = event.data
            network.ship.stage = 2
        end
     
        --print(tostring(event.data))
    elseif event.type == "connect" then
        print(tostring(event.peer) .. " connected.")
        network.peer[1] = event.peer
    elseif event.type == "disconnect" then
        print(tostring(event.peer) .. " disconnected.")
        network.ship.live = false
    end

    
    
    local packet = tostring(math.floor(ship.vec.x))..","..tostring(math.floor(ship.vec.y))..","..tostring(ship.dir)..","..tostring(ship.thrust)
    if network.ship.stage == 1 then
        packet = world.name
    end
    
    event.peer:send(packet, 0, "unsequenced")
    network.host:service()
end


function network.serverStart(...)
    local arg = {...}
    local port
    if arg[1] then
        port = tonumber(arg[1])
    else
        port = 53399
    end
    if not port then
        print("That's uh... not a number.")
        return false
    end
    if port >= 49152 and port <= 65535 then
        network.host = enet.host_create("*:"..port)
        if network.host then
            print("Server started on port "..port)
            network.status = 1
            return true
        else
            print("Failed to create host on that port.\nEither the server is already running or the port cannot be used.")
            return false
        end
    else
        print("Port "..port.." is out of range (49152-65536)\nWill not bind host. Try a different port number.")
        return false
    end
    
end

function network.clientStart()
    network.host = enet.host_create()
    if network.host then
        print("Client started")

        return true
    else
        print ("Could not start client")
        return false
    end
end

function network.clientDisconnect()
    local peer = network.host:get_peer(1)
    peer:disconnect()
    network.host:flush()
    network.host = nil
    network.status = 0
    network.ship.live = false
    network.ship.stage = 1
    collectgarbage()
end


function network.clientConnect(ip, ...)
    local arg = {...}
    local port
    if arg[2] then
        port = tonumber(arg[2])
    else
        port = 53399
    end
    if not network.isIP(ip) then
        print("Not a valid IP address")
        return false
    end
    if not network.isPort(port) then
        print("Not a valid port")
        return false
    end
    
    network.server = network.host:connect(ip..":"..port)
    if not network.server then
        print("Could not connect to server. Check that your IP address and port numbers are correct.")
        return false
    end
    print("Successfully connected to server at: "..ip..":"..port)
    network.status = 2
    return true
end

function network.isIP(ip)
    if not ip then return false end
    local a,b,c,d=ip:match("^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$")
    a=tonumber(a)
    b=tonumber(b)
    c=tonumber(c)
    d=tonumber(d)
    if not a or not b or not c or not d then return false end
    if a<0 or 255<a then return false end
    if b<0 or 255<b then return false end
    if c<0 or 255<c then return false end
    if d<0 or 255<d then return false end
    return true
end

function network.isPort(port)
    if port <= 49152 and port >= 65535 then
        print("Port "..port.." is out of range (49152-65536)\nWill not bind host. Try a different port number.")
        return false
    end
    return true
end

return network