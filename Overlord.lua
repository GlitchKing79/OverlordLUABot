local discordia = require('discordia')
local client = discordia.Client()

file = io.open('botinfo.info','r')
print('reading file')
idAndToken=file:read()
print(idAndToken)
file:close()

botToken, botId = idAndToken:match("([^,]+),([^,]+)")
client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
	commands = {}
	for word in message.content:gmatch("%S+") do
		print(word)
		table.insert(commands,word)
	end
	if commands[1] == '/ping' then
		message.channel:send('Pong!')
	end
	if commands[1] == '/join' then
	hasARole = false
		for joinIndex, joinRole in pairs(message.guild.roles) do
			if commands[2] == 'server' then
				server = 'Servers/'..message.guild.id
				serverFile = io.open(server,"r")
				serverSettings = {}
				for line in serverFile:lines() do
					table.insert (serverSettings, line);
				end
				print(serverFile:read("*a"))
				serverFile:close()

				for tableIndex, tableResult in pairs(serverSettings) do
					roleTable = {}
					for check in tableResult:gmatch("([^:]*)") do
					print(check)
					table.insert(roleTable,check)
					end
						if roleTable[1] == 'MEMBERROLE' then
							print(roleTable[3]..'is the role')
							if message.guild:getMember(message.author.id):hasRole(roleTable[3]) == false then
								message.guild:getMember(message.author.id):addRole(roleTable[3])
								message.author:send('welcome to '..message.guild.name)
								hasARole = true
							else
								if hasARole == false then
									message.channel:send(message.author.name..' you already have the role')
								end
							end
						end
					end
				else
					if joinRole.name == commands[2] then
						member = message.guild:getMember(message.author.id)
						memberPos = message.guild.roles:get(message.guild.id).position
						print(message.guild.roles:get(message.guild.id).name)
						print(memberPos)
						for rolePos, theRole in pairs(member.roles) do
							print(theRole.name,theRole.position)
							if theRole.position > memberPos then
								memberPos = theRole.position
								print(memberPos)
							end
						end
						if joinRole.position <= memberPos then
						if member:hasRole(joinRole.id) == false then
							member:addRole(joinRole.id)
							hasARole = true
						else
							if hasARole == false then
								message.channel:send(message.author.name..' you already have the role')
							end
						end
						else
							message.channel:send(message.author.name..' you do not meet the requirement for this role')
						end
					end--end sub join
				end--end server
			end--end for
			message:delete()
		end--end join


	if commands[1] == '/setup' then
		server = 'Servers/'..message.guild.id
		serverFile = io.open(server,"r")
		serverSettings = {}
		for line in serverFile:lines() do
			table.insert (serverSettings, line);
		end
		print(serverFile:read("*a"))
		serverFile:close()
		if commands[2] == 'start' then
			serverSettings = {}
			table.insert(serverSettings,'SERVERNAME:'..message.guild.name)
			table.insert(serverSettings,'MEMBERROLE:NIL')
		end
		if commands[2] == 'role' then
			for tableIndex, tableResult in pairs(serverSettings) do
				for check in tableResult:gmatch("([^:]*)") do
				print(check)
					if check == 'MEMBERROLE' then
						serverRolesComplete = '0'
						print(message.guild.roles)
						serverRoles = message.guild.roles
						for serverRoleIndex, serverRoleItem in pairs(serverRoles) do
						print(serverRoleItem.name)
						print(commands[3])
							if serverRoleItem.name == commands[3] then
								serverSettings[tableIndex] = 'MEMBERROLE:'..serverRoleItem.id
								serverRolesComplete = '1'
								message.channel:send('found role setting as default role')
								break
							end
						end
						if serverRolesComplete == '0' then
							message.channel:send('failed to find role')
						end
					end
				end
			end
		end
		endstring = ''
		for index, str in pairs(serverSettings) do print(str) endstring = endstring..str..'\n' end
		newServerFile = io.open(server, "w")
		newServerFile:write(endstring)
		newServerFile:close()


	end
end)

client:run('Bot ' .. botToken)
