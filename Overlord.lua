--require('lfs')
local discordia = require('discordia')
local client = discordia.Client()

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
	if message.content == '!ping' then
		message.channel:send('Pong!')
	end
end)

client:run('Bot MzU5MTM1ODU5NjQ1MjE4ODE3.DLysUQ.6moJNVj4LWrJaOSDGJ55zHs0hm0')
