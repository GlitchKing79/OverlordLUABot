Server_Data = {}

function Server_Data:get(server)
    local server_file = io.open('Servers/'.. server.id,"r")
    ServerGuildSettings = {}
		if server_file ~= nil then
            for line in server_file:lines() do
				table.insert (ServerGuildSettings, line);
			end
			server_file:close()
			return ServerGuildSettings
        else
            server_file = io.open('Servers/'..server.id,"w")
            server_file:close()
			return {}
		end
end

function Server_Data:get_raw(server)
    local serverData = Server_Data:get(server)
    local compiledData = {}
    for k, v in pairs(serverData) do
        local splitData = {}
        for data in v:gmatch("([^:]+)") do
            table.insert(splitData,data)
        end
        table.insert(compiledData,splitData)
    end

    return compiledData
end

function Server_Data:edit(server,dataName, dataResult)
    local serverData = Server_Data:get_raw(server)
    local endString = ""
    local value = nil
    for index, currentData in pairs(serverData) do
        if currentData[1] == dataName then
            currentData[2] = dataResult
            value = dataResult
        end
        endString = endString .. currentData[1] .. ':' .. currentData[2] .. '\n'
    end
    server_file = io.open('Servers/'..server.id,"w")
    server_file:write(endString)
    server_file:close()

    return value
end

function Server_Data:get_data(server,dataName)
    local serverData = Server_Data:get_raw(server)

    for k, v in pairs(serverData) do
        if v[1] == dataName then
            if v[2] ~= "NIL" then
                return v[2]
            end
        end
    end

    return nil
end

function Server_Data:add(server,name,value)
    local serverData = Server_Data:get_raw(server)
    table.insert(serverData,{name,value})
    server_file = io.open('Servers/'..server.id,"w")
    local endString = ""
    for index, currentData in pairs(serverData) do
        endString = endString .. '' .. currentData[1] .. ':' .. currentData[2] .. '\n'
    end
    server_file:write(endString)
    server_file:close()

    return value
end