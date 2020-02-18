local discordia = require('discordia')
local client = discordia.Client()
local logger = discordia.Logger(0, '%F %T')

require('overlord.server.data')
require('overlord.server.role')
require('overlord.server.settings')

require('overlord.channels.text')
require('overlord.channels.voice')

require('overlord.help')

local file = io.open('botinfo.info','r')
idAndToken=file:read()
file:close()

botToken, botId = idAndToken:match("([^,]+),([^,]+)")

server_level = 0

function Role:reactionHandle(reaction)
    print('internal print',reaction)
    if reaction == nil then
        print('failed to get reaction',reaction)
        return false
    end
    print(reaction)
    
    return true
end

client:on('ready', function()
	print('Logged in as '.. client.user.username)
	client:setGame('overseeing all actions')
end)

client:on('voiceChannelLeave',function(member,channel)
	local tempCat = Server_Data:get_data(channel.guild,"TEMPCATEGORY")
	if channel.category.id == tempCat then
		local usercount = 0
		for k,v in pairs(channel.connectedMembers) do
			usercount = usercount + 1
		end
		if usercount == 0 then
			channel:delete()
		end
	end
end)

client:on('memberJoin', function(member)
    local memberRole = Server_Data:get_data(member.guild,"MEMBERROLE")
	if memberRole ~= nil then
		member:send('you have joined a server i have influence over\nfor you to have access to this server you will need to run a command, read the rules to know what that command is')
	end
end)

client:on('messageCreate', function(message)
    if message.author.bot == true then
		return nil
	end
	if message.guild == nil then return end

    server_level = Server_Settings:commands(message.guild,message.author,nil)
    local raw_message = Text:handle_message(message)

	Server_Settings:handle(raw_message, message)

	if raw_message[1] == '/restart' then
		if message.author.id == '102956993060274176' then
			client:stop()
			message:delete()
		end
	end

	if raw_message[1] == '/getID' then
		message.channel:send(message.author.id)
	end

	Role:handle(raw_message,message,server_level)
	Voice:handle(raw_message,message,server_level)
	Text:handle(raw_message,message,server_level)
	Help:handle(raw_message,message,server_level,client.user)

	local watchedChannels = Server_Data:get_data(message.guild,"WATCHEDCHANNEL_IMAGE")
	if watchedChannels ~= nil then
		local wtcChannel, wtcRole = watchedChannels:match("([^,]+),([^,]+)")
		if message.channel.id == wtcChannel then
			 if message.attachment ~= nil then
				Role:addID(message.author,wtcRole,message.guild)
				message.author:send('You have gained the role '..message.guild:getRole(wtcRole).name)
			 end
		end
	end
end)

client:on('reactionAdd',function(reaction,userID)
	if reaction.emojiId == nil then
		return
	end
	local sentMessage = reaction.message
	local channel = sentMessage.channel
	if sentMessage.content == "get_emoji" then
		channel:send(reaction.emojiId)
	end
	if sentMessage.content == "React to gain full access to server" then
		local targetServer = reaction.message.channel.guild
		if reaction.count > 1 then
			local targetUser = reaction:getUsers()
			for k, v in pairs(targetUser) do
				if v.bot == false then
					Role:server(v,targetServer)
				end
			end
			sentMessage:clearReactions()
			sentMessage:addReaction(client:getEmoji(reaction.emojiId))
        end
        --sentMessage:delete()
    end
end)

client:on('reactionAddUncached',function(channel,messageID,hash,userID)
	local sentMessage = channel:getMessage(messageID)
	local reaction = 0
	local rect = sentMessage.reactions
	for k, v in pairs(rect) do 
		if v ~= nil then
			reaction = v
			break
		end
	end

	--reaction handler
	if reaction.emojiId == nil then
		return
	end
	local sentMessage = reaction.message
	if sentMessage.content == "get_emoji" then
		channel:send(reaction.emojiId)
	end
	if sentMessage.content == "React to gain full access to server" then
		local targetServer = reaction.message.channel.guild
		if reaction.count > 1 then
			local targetUser = reaction:getUsers()
			for k, v in pairs(targetUser) do
				if v.bot == false then
					Role:server(v,targetServer)
				end
			end
			sentMessage:clearReactions()
			sentMessage:addReaction(client:getEmoji(reaction.emojiId))
        end
        --sentMessage:delete()
    end
end)

client:on('guildUpdate', function(guild)
    Server_Settings:name(guild)
end)

client:run('Bot ' .. botToken)

