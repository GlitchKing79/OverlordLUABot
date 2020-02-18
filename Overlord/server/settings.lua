Server_Settings = {}

function Server_Settings:member_role(server, author)
    local memberRole = Server_Data:get_data(server,"MEMBERROLE")
    if memberRole == nil then
        local role = server:createRole("New Member Role")
        memberRole = Server_Data:add(server,"MEMBERROLE",role.id)
    else
        if server:getRole(memberRole) == nil then
            author:send("Could not find old Member Role, creating a new one")
            local role = server:createRole("New Member Role")
            memberRole = Server_Data:edit(server,"MEMBERROLE",role.id)
        elseif author ~= nil then
            author:send("Member Role already exists")
        end
    end

    return memberRole
end

function Server_Settings:watched_channel_image(server, channel)
    local splitData = Server_Data:get_data(server,"WATCHEDCHANNEL_IMAGE")
    local wtcChannel
    local wtcRole
    if splitData == nil then
        wtcChannel = channel
        wtcRole = server:createRole("Image Watcher")
        wtcRole:disableAllPermissions()
        Server_Data:add(server,"WATCHEDCHANNEL_IMAGE",channel.id..','..wtcRole.id)
        splitData = channel.id..','..wtcRole.id
    end
    local compChannel, compRole = splitData:match("([^,]+),([^,]+)")
    wtcChannel = server:getChannel(compChannel)
    wtcRole = server:getRole(compRole)
    if watchedChannel == nil or wtcRole == nil then
        if wtcChannel == nil then
            channel:send("failed to find channel")
            wtcChannel = channel
        else
            channel:send("found channel")
        end
        if wtcRole == nil then
            channel:send("failed to find role")
            wtcRole = server:createRole("Image Watcher")
        else
            channel:send("found role")
        end
    end
    Server_Data:edit(server,"WATCHEDCHANNEL_IMAGE",wtcChannel.id..','..wtcRole.id)
    return watchedChannel, wtcRole
end

function Server_Settings:tempory_voice(server,author)
    local tempCategory = Server_Data:get_data(server,"TEMPCATEGORY")
    if tempCategory == nil then
        local category = server:createCategory("Tempory Voice Channels")
        tempCategory = Server_Data:add(server,"TEMPCATEGORY",category.id)
    else
        if server:getChannel(tempCategory) == nil then
            if author ~= nil then author:send("Could not find old Temporary Voice Channel Category, creating new one") end
            local category = server:createCategory("Temporary Voice Channels")
            tempCategory = Server_Data:edit(server,"TEMPCATEGORY",category.id)
        elseif author ~= nil then
            author:send("Temporary Voice Category already exists")
        end
    end

    return tempCategory
end

function Server_Settings:name(server)
    local serverName = Server_Data:get_data(server,"SERVERNAME")
    if serverName == nil then
        serverName = Server_Data:add(server,"SERVERNAME",server.name)
    elseif serverName ~= server.name then
        serverName = Server_Data:edit(server,"SERVERNAME",server.name)
    end

    return serverName
end

function Server_Settings:commands(server,author,v)
    local commands = Server_Data:get_data(server,"COMMANDS")
    if commands == nil then
        if v == nil then
            v = 1
        end
        if v ~= nil then
            if type(v) ~= "number" then
                v = 1
            end
        end
        commands = Server_Data:add(server,"COMMANDS",v)
        if author ~= nil then author:send("Changed server commands level to "..commands) end
    else 
        if v ~= nil then
            v = v + 0
            if type(v) == "number" then
                commands = Server_Data:edit(server,"COMMANDS",v)
                if author ~= nil then author:send("Changed server commands level to "..commands) end
            end
        end
    end
    return commands
end

function Server_Settings:getRoles(server)
    local roles = Server_Data:get_data(server,"SECUREROLES")
    if roles == nil then
        return nil
    end
    local test = roles:gmatch("([^,]+),([^,]+)")
    if test ~= nil then

        local foundRoles = {}
        local targetRoles = {}
        for id in roles:gmatch("[^,]+") do
            table.insert(foundRoles,id)
        end
        for k, v in pairs(foundRoles) do
            local gettingRole = server:getRole(v)
            if gettingRole ~= nil then
                table.insert(targetRoles,v)
            end
        end

        return targetRoles
    end

    return nil
end

function Server_Settings:secureRoles(server,role,add)
    local secureTest = false
    local roles = Server_Data:get_data(server,"SECUREROLES")
    local rl = server:getRole(role) 
    if roles == nil then
        Server_Data:add(server,"SECUREROLES",'0,')
        roles = '0,'
    end
    local foundRoles = {} 
    for id in roles:gmatch("[^,]+") do
        table.insert(foundRoles,id)
    end
    if foundRoles ~= nil then
        local targetRoles = {}
        for k, v in pairs(foundRoles) do
            local gettingRole = server:getRole(v)
            if gettingRole ~= nil then
                local check = false
                for n, f in pairs(targetRoles) do
                    if f == v then 
                        check = true
                        break
                    end
                end
                if check == false then table.insert(targetRoles,v) end
            end
        end

        local str = ""
        local skip = false
        for s, o in pairs(targetRoles) do
            if add == true then 
                if o == role then skip = true end
                str = str..o..','
            else
                if o == role then
                    secureTest = true
                else
                    str = str..o..','
                end
            end
        end
        if rl ~= nil and skip == false then
            if add == true then
                str = str..role..','
                secureTest = true
            end
        end
        Server_Data:edit(server,"SECUREROLES",str)
    else
        if add == true then
            if rl ~= nil then
                Server_Data:edit(server,"SECUREROLES",role..',')
                secureTest = true
            end
        end
        return secureTest
    end
end

function Server_Settings:handle(raw_data, message)
    local msg = Text:compile_message(raw_data,3)

    if msg[1] == "/settings" then
        if message.guild:getMember(message.author.id):hasPermission(0x00000020) or message.guild.owner.id == message.author.id then
            Server_Settings:name(message.guild)
            if msg[2] == "member" then
                Server_Settings:member_role(message.guild, message.author)
            end
            if msg[2] == "voice" then
                Server_Settings:tempory_voice(message.guild,message.author)
            end
            if msg[2] == "level" then
                Server_Settings:commands(message.guild,message.author,msg[3])
            end
            if msg[2] == "watch" then
                if msg[3] == "image" then
                    Server_Settings:watched_channel_image(message.guild,message.channel)
                end
            end
            if raw_data[2] == 'edit' then
                if raw_data[3] == 'member' then
                    local data = Server_Data:get_data(message.guild,"MEMBERROLE")
                    local role = message.guild:getRole(raw_data[4])
                    if role == nil then
                        message.channel:send('Failed to find target role')
                    end
                    if data ~= nil then
                        if role ~= nil then
                            Server_Data:edit(message.guild,"MEMBERROLE",role.id)
                            message.channel:send('Updated member role to '..role.name)
                        end
                    else
                        Server_Data:add(message.guild,"MEMBERROLE",role.id)
                        message.channel:send('Couldnt locate member role in settings, adding target to '..role.name)
                    end
                end
            end
        else 
            message:send("You require admin to access this command")
        end
    end
end
