Text = {}

function Text:handle_message(message)
    local final = {}
	for word in message.content:gmatch("%S+") do
		table.insert(final,word)
	end

	return final
end

function Text:compile_message(t,start)
    local str = ""
	local final = {}
	if t == nil then return final end
    for k, v in pairs(t) do
		if k > start then
			if k == start + 1 then
				str = v
			else 
				str = str .. " " .. v
			end
        else 
            table.insert(final,v)
        end
	end
	
	table.insert(final,str)

    return final
end

function Text:clean_channel(channel,amount)
	if amount ~= nil then
		if amount <= 100 then
			local mg = channel:getMessages(amount)
			channel:bulkDelete(mg)
		else
			local tmsg = amount/100
			local endingMsg = tmsg % 1
			local totalMsg = tmsg - endingMsg
			for i=1, totalMsg do
				mg = channel:getMessages(100)
				channel:bulkDelete(mg)
			end
			mg = channel:getMessages(100 * endingMsg)
			channel:bulkDelete(mg)
		end
	else
		local mg = channel:getMessages(100)
        channel:bulkDelete(mg)
    end
end

function Text:handle(raw_message, message,level)
	if raw_message[1] == '/clean' then
		local server_user = message.guild:getMember(message.author.id)

		if server_user:hasPermission(message.channel,0x00002000) then
        	if raw_message[2] ~= nil then
        	    local numb = tonumber(raw_message[2])
        	    Text:clean_channel(message.channel,numb)
        	else 
        	    Text:clean_channel(message.channel)
			end
		else 
			message.channel:send(message.author.mentionString .. ' lacking permisions to use this command')
		end
	end

    target = nil
end