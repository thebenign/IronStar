
local client = setmetatable({
        live = false,
        host = nil,
        try_disconnect = false,
        disconnecting = false,
        clients = {},
        local_data = {}
    
    }, net
)



function client.start(ip, port) --IP, Port
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
    client.host = sock.newClient(ip, port)
    client.host:connect()
    client.live = true
    
    client.host:on("connect", function(data)
            print("Established connection to server")
            client.index = client.host:getIndex()
            
            -- One time send to server to establish client data
            local player_data = {
                vec = ship.vec,
                dir = ship.dir,
                thrust = ship.thrust,
                tc = socket.gettime()
            }
            client.host:emit("player_data", player_data)
        end
    )
    
    client.host:on("player_data", function(data)
            
            for i, client_table in ipairs(data) do
                client.clients[client_table.id] = client.clients[client_table.id] or {}
                
                for k, v in pairs(client_table) do
                    client.clients[client_table.id][k] = v
                end
            end
        end
    )
    
    client.host:on("disconnect", function(data)
            print(os.date("%r").." - Disconnected from server")
            client.live = false
        end
    )
    
    client.host:on("serverclose", function(data)
            print("Server is closing...")
            client.try_disconnect = true
        end
    )
    
end

function client.stop()
    client.try_disconnect = true
end


function client.update(dt)
    if client.try_disconnect then
        client.host:disconnectLater()
        client.try_disconnect = false
    end
    
    if client.live then

        net.metric.dt = net.metric.dt + dt

        if net.metric.dt > net.metric.t then
            
            if not client.disconnecting then

                local data = client:buildPlayerPacket()
                -- If there's anything in the data packet, send it.
                if next(data) ~= nil then client.host:emit("player_data", data) end
                
            end

            client.host:update()
            
            if client.host:getState() == "disconnected" then
                client.live = false
                net.metric.dt = 0
            end
            
            net.metric.dt = net.metric.dt - net.metric.t
        end
    end
end

function client.drawOthers()
    local other
    
    for i, v in pairs(client.clients) do
        other = v
        love.graphics.draw(ship.img, other.vec.x-camera.x, other.vec.y-camera.y, math.rad(other.dir), .3, .3, 145, 163)
    end
end

return client