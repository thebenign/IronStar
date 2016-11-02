

local server = {
    host = nil,         -- Sock server object
    live = false,       -- whether the server is running
    try_close = false,  -- server close flag
    clients = {},       -- table of local_data sent from clients currently connected
    local_data = {}     -- Our local_data
    }


function server.startServer(port)
    port = port or 22122
    
    server.host = sock.newServer("*", port)
    
    if server.handle then
        server.live = true
        print("Started server")
    end
    
    -- Got Player Data
    server.host:on("playerData", function(data, client)
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
