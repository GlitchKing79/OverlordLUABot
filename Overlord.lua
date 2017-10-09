local discordia = require('discordia')
local client = discordia.Client()

file = io.open('botinfo.info','r')
idAndToken=io.read()
io.close()
botToken, botId = idAndToken.split(',')
client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
	print('message sent ' .. message.type)
	if message.content == '!ping' then
		message.channel:send('Pong!')
	end
end)

client:run('Bot ' .. botToken)
