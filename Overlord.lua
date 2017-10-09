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
	print('message sent ' .. message:type)
	if message.content == '!ping' then
		message.channel:send('Pong!')
	end
end)

client:run('Bot ' .. botToken)
