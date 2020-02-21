Role = {}

function Role:get(server)
    local roles = server.roles
    local allRoles = {}
    for k, v in pairs(roles) do
        table.insert(allRoles,v)
    end

    return allRoles
end

function Role:create(user,server,roleName)
    if roleName ~= nil or roleName ~= "" then
        local newRole = server:createRole(roleName)
        if newRole ~= nil then
            newRole:disableAllPermissions()
             server:getMember(user.id):addRole(newRole.id)
            return newRole
        end
    end
    return nil
end

function Role:addID(user,roleID,server)
    local allRoles = Role:get(server)
    local highestRole = nil
    local targetRole = nil
    for k, v in pairs (allRoles) do
        if v ~= nil then
            if server:getMember(user.id):hasRole(v.id) == true then
                if highestRole == nil then
                    highestRole = v
                elseif highestRole.position < v.position then
                    highestRole = v
                end
            end

            if v.id == roleID then
                targetRole = v
            end
        end
    end
    if targetRole ~= nil then
        if highestRole.position > targetRole.position then
           server:getMember(user.id):addRole(targetRole.id)
            return targetRole
        end
    end
    return nil
end

function Role:add(user, roleName, server)
    local allRoles = Role:get(server)
    local highestRole = nil
    local targetRole = nil
    local lockedRoles = Server_Settings:getRoles(server)
    for k, v in pairs (allRoles) do
        if v ~= nil then
            if server:getMember(user.id):hasRole(v.id) == true then
                if highestRole == nil then
                    highestRole = v
                elseif highestRole.position < v.position then
                    highestRole = v
                end
            end

            if v.name == roleName then
                targetRole = v
            end
        end
    end
    if targetRole ~= nil then
        if highestRole.position > targetRole.position then
            for s, o in pairs(lockedRoles) do
                if o == targetRole.id then
                    return nil
                end
            end
            server:getMember(user.id):addRole(targetRole.id)
            return targetRole
        end
    end
    return nil
end

function Role:server(user, server)
    local memberRole = Server_Data:get_data(server,"MEMBERROLE")
    local serverUser = server:getMember(user.id)
    if memberRole ~= nil then
        local m_role = server:getRole(memberRole)
        if m_role ~= nil then
            if serverUser:hasRole(memberRole) == false then
                serverUser:addRole(memberRole)
            end
        end
    end
end

function Role:remove(user,server,roleName)
    local serverUser = server:getMember(user.id)
    local allRoles = Role:get(server)
    for k, v in pairs(allRoles) do
        if v.name == roleName then
            if serverUser:hasRole(v.id) == true then
                serverUser:removeRole(v.id)
                return true
            end
        end
    end

    return false
end

function Role:secure(server,roleName, bool)
    local allRoles = Role:get(server)
    for k, v in pairs(allRoles) do
        if v.name == roleName then
            Server_Settings:secureRoles(server,v.id,bool)
            return true
        end
    end
    return false
end

function Role:handle(raw_data, message,level)
    local msg = Text:compile_message(raw_data,2)
    local serverUser = message.author
    if msg[1] == "/role" then
        if msg[2] == "join" then
            local addedRole = Role:add(serverUser,msg[3],message.guild)
            if addedRole ~= nil then
                message.channel:send(message.author.mentionString .. ' Role ' .. addedRole.name .. ' added to you')
            end
        end
        if msg[2] == "new" then
            if tonumber(level) >= 2 then
                local newRole = Role:create(serverUser, message.guild, msg[3])
                 if newRole ~= nil then
                    message.channel:send("Role " .. newRole.name .. " was created")
                end
            else 
                message.channel:send('Server lacks command levle to use this command')
            end
        end
        if msg[2] == "server" then
            Role:server(serverUser, message.guild)
            message:delete()
        end
        if msg[2] == "leave" then
            if Role:remove(serverUser,message.guild,msg[3]) == true then
                message.channel:send("Role " .. msg[3] .. ' removed')
            end
        end
        if msg[2] == 'react' then
            local emoji = message.guild:getEmoji(msg[3])
            if emoji ~= nil then
                local serverMessage = message.channel:send('React to gain full access to server')
                serverMessage:addReaction(emoji)
            end
            message:delete()
        end
        if msg[2] == 'locked' then
            local lockedRoles = Server_Settings:getRoles(message.guild)
            local foundRoles = ''
            local i = 1
            for k, v in pairs(lockedRoles) do
                foundRoles = foundRoles..message.guild:getRole(v).name..', '
                i = i + 1
            end
            message.channel:send('('..i..') Locked roles are; '..foundRoles)
        end

        local secMsg = Text:compile_message(raw_data,3)
        local extendMsg = Text:compile_message(raw_data,4)
        local type
        local active
        if secMsg[2] == "secure" then
            if message.guild:getMember(message.author.id):hasPermission(0x10000000) then
                if secMsg[3] == 'add' then
                    active = Role:secure(message.guild,secMsg[4], true)
                    type = true
                elseif secMsg[3] == 'remove' then
                    active = Role:secure(message.guild,secMsg[4], false)
                    type = false
                elseif extendMsg[3] == 'id' then
                    if extendMsg[4] == 'add' then
                        active = Server_Settings:secureRoles(message.guild,extendMsg[5],true)
                        type = true
                    elseif extendMsg[4] == 'remove' then
                        active = Server_Settings:secureRoles(message.guild,extendMsg[5],false)
                        type = false
                    end
                end
                local mrsg = ''
                if active == true then mrsg = 'Success ' else mrsg = 'Failed ' end
                if type == true then mrsg = mrsg..'in adding '..secMsg[4]..' to security' else mrsg = mrsg..'in removing '..secMsg[4]..' to security' end
                message.channel:send(mrsg)
            else
                message.channel:send('You lack the proper permissions to use this command')
            end
        end
    end
end
