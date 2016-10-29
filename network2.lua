--network rewrite with sock

local net = {}
net.client = {}
    net.client.state = nil
    net.client.rtt = 0
    net.client.try_disconnect = false
    net.client.disconnecting = false
    
    net.client.data = {}
    
net.server = {}
    net.server.state = nil
    net.server.try_close = false
    net.server.location = {}
    net.server.peer = {}
    
    
net.metric = {}
    net.metric.t = 1/5
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
    net.server.handle:on("location", function(data, client)
            net.server.peer[client:getIndex()].location = data
            
        end
    )
    net.server.handle:on("connect", function(data, client)
            net.server.peer[client:getIndex()] = {connected = true}
            
        end
    )
    net.server.handle:on("disconnect", function(data, client)
            print("client disconnected")
            if net.server.try_close then
                net.server.peer[client:getIndex()].connected = false
            end
        end
    )
    net.server.handle:on("ack", function(data, client)
            print("Got ack")
        end
    )
    
    
    
end

function net.stopServer()
    net.server.handle:emitToAll("serverclose", 0) -- reason code 0, server is closing.
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
            
        end
    )
    net.client.handle:on("disconnect", function(data)
            print(os.date("%r").." - Disconnected from server")
            if data == 0 then
                print("No disconnect code recieved. Most likely I never found the server.")
            end
            
        end
    )
    net.client.handle:on("serverclose", function(data)
            print(os.date("%r").." - Got server_close message. Closing connection")
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
                local data = {}
                local vec = net.compareData(ship.vec, net.client.data.vec)
                local dir = net.compareData(ship.dir, net.client.data.dir)
                local thrust = net.compareData(ship.thrust, net.client.data.thrust)
                
                if vec then
                    data.vec = vec
                    net.client.data.vec = vec
                end
                if dir then
                    data.dir = dir
                    net.client.data.dir = dir
                end
                if thrust then
                    data.thrust = thrust
                    net.client.data.thrust = thrust
                end
                
                if next(data) ~= nil then net.client.handle:emit("location", data) end
                
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

function net.clientDrawOthers()
    
    
    
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
            net.server.handle:update()
            
            
            
            net.server.info = {#net.server.handle.peers, net.server.handle:getTotalSentPackets(),net.server.handle:getTotalReceivedPackets(),net.server.handle:getTotalReceivedData()}
            
            net.metric.dt = net.metric.dt - net.metric.t
        end
    end

end

-- HELPERS
function net.compareData(d1, d2)
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