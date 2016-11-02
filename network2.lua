--network rewrite with sock

local net = {}

net.__index = net

net.client = setmetatable({}, net)
    net.client.state = nil
    net.client.rtt = 0
    net.client.try_disconnect = false
    net.client.disconnecting = false
    
    net.client.player_data = {}
    
    net.client.otherClient = {}
    
net.server = setmetatable({}, net)
    net.server.state = nil
    net.server.try_close = false
    
    net.server.peer = {}
    net.server.player_data = {}
    
    
net.metric = {}
    -- Set our data transmission rate in packets per second.
    net.metric.t = 1/30
    net.metric.dt = 0

function net.startServer(...)
    local arg = {...}
    local ip = arg[1] or "*"
    local port = arg[2] or 22122
    net.server.handle = sock.newServer(ip, port)
    if net.server.handle then
        net.server.state = true
        print("Started server")
    end
    
    -- Got Player Data
    net.server.handle:on("playerData", function(data, client)
            local player_data = net.server.peer[client:getIndex()].player_data
            player_data = player_data and player_data or {}
            for k, v in pairs(data) do
                player_data[k] = v
            end
            net.server.peer[client:getIndex()].player_data = player_data
        end
    )
    
    -- Client connected
    net.server.handle:on("connect", function(data, client)
            net.server.peer[client:getIndex()] = {connected = true}
            local player_data = {
                vec = ship.vec,
                dir = ship.dir,
                thrust = ship.thrust
            }
            local peer = net.server.handle.peers[client:getIndex()]
            net.server.handle:sendToPeer(peer,"playerData",{player_data})
        end
    )
    
    -- Client disconnected
    net.server.handle:on("disconnect", function(data, client)
            print("client disconnected")
            net.server.peer[client:getIndex()].connected = false
            if net.server.try_close then
            end
        end
    )
    
    -- Got acknowledgement from client
    net.server.handle:on("ack", function(data, client)
            print("Got ack")
        end
    )
    
    
    
end

function net.stopServer()
    net.server.handle:emitToAll("serverclose", 1) -- reason code 0, server is closing.
    net.server.try_close = true
end

    

function net.startClient(ip, port) --IP, Port
    
    if not net.isIP(ip) then
        ip = "localhost"
        print("Not a valid IP, falling back to localhost")
    end
    port = tonumber(port)
    if not port then
        port = 22122
        print("Can't use that port, using 22122 instead")
    end
    print ("Connecting to "..ip.." on port "..port)
    net.client.handle = sock.newClient(ip, port)
    net.client.handle:connect()
    net.client.state = true
    
    net.client.handle:on("connect", function(data)
            print("Established connection to server")
            net.client.index = net.client.handle:getIndex()
            -- One time send to server to establish client data
            local player_data = {
                vec = ship.vec,
                dir = ship.dir,
                thrust = ship.thrust
            }
            net.client.handle:emit("playerData", player_data)
        end
    )
    net.client.handle:on("playerData", function(data)
            local player_data
            for i, v in ipairs(data) do
                player_data = net.client.otherClient[i] or {}
                for k, v2 in pairs(v) do
                    player_data[k] = v2
                end
                net.client.otherClient[i] = player_data
            end
        end
    )
    
    net.client.handle:on("disconnect", function(data)
            print(os.date("%r").." - Disconnected from server")
            if data == 0 then
                print("No disconnect code recieved. Most likely I never found the server.")
            elseif data == 1 then
                print("Server closed, forced disconnect")
            end
            
        end
    )
    net.client.handle:on("serverclose", function(data)
            net.client.try_disconnect = true
        end
    )
    
end

function net.clientClose()
    net.client.try_disconnect = true
end


function net.clientUpdate(dt)
    if net.client.try_disconnect then
            net.client.handle:disconnectLater()
            net.client.try_disconnect = false
    end
    
    if net.client.state then

        net.metric.dt = net.metric.dt + dt

        if net.metric.dt > net.metric.t then
            if not net.client.disconnecting then

                local data = net.client:buildPlayerPacket()
                -- If there's anything in the data packet, send it.
                if next(data) ~= nil then net.client.handle:emit("playerData", data) end
                
            end

            net.client.handle:update()
            if net.client.handle:getState() == "disconnected" then
                net.client.state = false
                net.metric.dt = 0
            end
            
            net.metric.dt = net.metric.dt - net.metric.t
        end
    end
end

function net.serverDrawOthers()
    local client
    for i, v in ipairs(net.server.peer) do
        client = v.player_data
        if client and v.connected then
            love.graphics.draw(ship.img, client.vec.x-camera.x, client.vec.y-camera.y, math.rad(client.dir), 1, 1, 32, 31)
        end
    end
end



function net.clientDrawOthers()
    local client
    for i, v in ipairs(net.client.otherClient) do
        client = v
        if client then
            love.graphics.draw(ship.img, client.vec.x-camera.x, client.vec.y-camera.y, math.rad(client.dir), 1, 1, 32, 31)
        end
    end
end


function net.serverUpdate(dt)
    if net.server.try_close then
        local can_close = true
        for i, v in ipairs(net.server.peer) do
            if not v.ack then
                can_close = false
            end
        end
        if can_close then
            net.server.state = false
            net.server.handle = nil
            net.server.try_close = false
            net.server.info = nil
            net.metric.dt = 0
        end
    end
    
    if net.server.state then
        net.metric.dt = net.metric.dt + dt
        if net.metric.dt > net.metric.t then

            local data
            
            for i, v in ipairs(net.server.handle.peers) do
                data = {net.server:buildPlayerPacket()}
                 
                for i2, v2 in ipairs(net.server.peer) do
                    if i2 ~= i then
                        --table.insert(data, v2)
                    end
                end
                
                if next(data) ~= nil then net.server.handle:sendToPeer(v, "playerData", data) end
            end
            
            net.server.handle:update()
            
            net.server.info = {#net.server.handle.peers, net.server.handle:getTotalSentPackets(),net.server.handle:getTotalReceivedPackets(),net.server.handle:getTotalReceivedData()}
            
            net.metric.dt = net.metric.dt - net.metric.t
        end
    end

end

-- HELPERS
function net:buildPlayerPacket()
    -- Build a data packet to send out. Compare real data to a client copy to see if it needs to be sent to the server.
    -- Tables are a special case and must contain a ".changed" indice with a boolean value. Flip this when data should be sent.
    local data = {}
    local vec = net.compareData(ship.vec, nil) -- This is a table, it doesn't compare to a client copy.
    local dir = net.compareData(ship.dir, self.player_data.dir)
    local thrust = net.compareData(ship.thrust, self.player_data.thrust)

    if vec then
        data.vec = vec
    end

    if dir then
        data.dir = dir
        self.player_data.dir = dir
    end
    if thrust then
        data.thrust = thrust
        self.player_data.thrust = thrust
    end
    return data
end

function net.buildClientPacket()
    local data = {}
    
end

function net.compareData(d1, d2)
    if type(d1) == "table" then
        return d1.changed and d1 or false
    end
    
    return (d1 ~= d2) and d1
end


function net.isIP(ip)
    if not ip or type(ip) ~= "string" then return false end
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

function net.isPort(port)
    if port < 49152 or port > 65535 then
        print("Port "..port.." is out of range (49152-65536)\nWill not bind host. Try a different port number.")
        return false
    end
    return true
end

return net