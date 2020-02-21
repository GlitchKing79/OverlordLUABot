Voice = {}

function Voice:room(user,server, roomName)
    local tempCat = Server_Data:get_data(server,"TEMPCATEGORY")
    local tempCategory = server:getChannel(tempCat)
    if tempCategory ~= nil then
        local room = tempCategory:createVoiceChannel(roomName)
		if room == nil then room = tempCategory:createVoiceChannel(user.name .. "'s Room") end
        room:getPermissionOverwriteFor(server:getMember(user.id)):allowAllPermissions()

        if room ~= nil then return room end
    end
    return nil
end

function Voice:connect(user,server)
    local channel = server:getChannel(server:getMember(user.id).voiceChannel)
    return channel:join()
end

function Voice:play(server,channel,audio)
    print("starting stream")
    coroutine.wrap(function()
        channel:playFFmpeg(audio)
        print('done streaming!')
    end)()
end

function Voice:handle(raw_data,message, level)
    local msg = Text:compile_message(raw_data,1)
    local channel = message.guild.connection
    
    if msg[1] == "/room" then
        local room = Voice:room(message.author,message.guild,msg[2])
        if room ~= nil then
            message.channel:send(message.author.mentionString .. ' Room ' .. room.name .. ' Was Created')
        end 
    end

    if msg[1] == "/summon" then
        Voice:connect(message.author,message.guild)
    end

    if msg[1] == "/music" then
        if channel ~= nil then
            Voice:play(message.guild,channel,msg[2])
        end
    end

    if msg[1] == "/stop" then
        if channel ~= nil then
            channel:close()
        end
    end
end