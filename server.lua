

local server = setmetatable({
        host = nil,         -- Sock server object
        live = false,       -- whether the server is running
        try_close = false,  -- server close flag
        clients = {},       -- table of client data sent from clients currently connected
        local_data = {},     -- Our local_data
        
    
    }, net
)

function server.start(port)
    port = port or 22122
    
    server.host = sock.newServer("*", port)
    
    if server.host then
        server.live = true
        print("Started server")
    else
        print("Failed to start server")
    end
    
    -- Client connected
    server.host:on("connect", function(data, client)
            local index = client:getIndex()
            
            server.clients[index] = {
                connected = true,
                player_data = {id=index+1}
            }
        local init_data = {
            {
                vec = ship.vec,
                dir = ship.dir,
                thrust = ship.thrust,
                connected = true,
                ts = socket.gettime(),
                id = 1
            }
        }
            for i, v in ipairs(server.clients) do
                if i ~= index and v.connected then
                        table.insert(init_data, v.player_data)
                    end
                end
            -- Get the enet peer
            local peer = server.host.peers[index]
            -- And send an initial server state to that player
            server.host:sendToPeer(peer,"player_data",init_data)
            print(string.format("Client connected.\n Sending %i packets\n skipping packet %i\n", #server.clients, index))
        end
    )
    
    -- Got Player Data
    server.host:on("player_data", function(data, client)
            local index = client:getIndex()
            
            for k, v in pairs(data) do
                server.clients[index].player_data[k] = v
            end
        end
    )
    

    -- Client disconnected
    server.host:on("disconnect", function(data, client)
            print("client disconnected")
            server.clients[client:getIndex()].connected = false
        end
    )
    
    -- Got acknowledgement from client
    server.host:on("ack", function(data, client)
            print("Got ack")
        end
    )
    
    
    
end

function server.stop(code)
    server.host:emitToAll("serverclose", code) -- Send a request to all clients to diconnect with a reason code.
    server.try_close = true
    print("Stopping server...")
end

function server.update(dt)
    
    if server.try_close then
        local can_close = true
        for i, v in ipairs(server.clients) do
            if v.connected then
                can_close = false
            end
        end
        if can_close then
            server.live = false
            server.host = nil
            server.try_close = false
            server.info = nil
            net.metric.dt = 0
        end
    end
    
    if server.live then
        net.metric.dt = net.metric.dt + dt
        if net.metric.dt > net.metric.t then


            local packet = server:buildPlayerPacket()
            
            for pi, peer in ipairs(server.host.peers) do
                local data = {}
                if next(packet) then
                    data[1] = packet 
                    data[1].connected = true
                    data[1].id = 1
                end
                
                 
                for ci, c_data in ipairs(server.clients) do
                    if ci ~= pi and c_data.connected then
                        local player_data = c_data.player_data
                        player_data.id = ci+1
                        print(player_data.id)
                        table.insert(data, player_data)
                    end
                    print("__")
                end
                
                if next(data) ~= nil then server.host:sendToPeer(peer, "player_data", data) end
            end
            
            server.host:update()
            
            server.info = {
                ["Number of Players: "] = #server.host.peers,
                ["Total Packets Sent: "] = server.host:getTotalSentPackets(),
                ["Total Packets Received: "] = server.host:getTotalReceivedPackets(),
                ["Total KB Sent: "] = math.floor((10^2)*server.host:getTotalSentData()/1024)/10^2,
                ["Total KB Received: "] = math.floor((10^2)*server.host:getTotalReceivedData()/1024)/10^2
                }
            
            net.metric.dt = net.metric.dt - net.metric.t
        end
    end

end


function server.drawOthers()
    local pdata
    for i, client in ipairs(server.clients) do
        pdata = client.player_data
        if client.connected then
            love.graphics.draw(ship.img, pdata.vec.x-camera.x, pdata.vec.y-camera.y, math.rad(pdata.dir), 1, 1, 32, 31)
        end
    end
end

return server