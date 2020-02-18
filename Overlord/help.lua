Help = {}

Help.index = {
    optional = "|text| = optional",
    required = "[text] = required",
    another = "(text 1/ text 2) = required but different options"
}

Help.channels = {}
Help.channels.voice = {
    room = "/room |room name| = creates a tempory voice room and gives the user full permisions over it"
}
Help.channels.text = {
    clean = "/clean |amount| = removes an amount of messages from the channel"
}

Help.server = {}

Help.server.role = {
    join = "/role join [role name] = gives you the target role if the role is below your highest one",
    new = "/role new [role name] = creates a new role",
    server = "/role server = gives you the initial server role allowing you to use other commands or have access to the server",
    leave = "/role leave [role name] = removes the target role from you",
    locked = "/role locked = displays roles you cannot use 'join' on",
    secure = "/role secure (add,remove) [Role Name] = target role becomes locked from 'join'",
    secureID = "/role secure id (add,remove) [Role ID] = target role becomes locked from 'join'",
    react = "/role react [Emoji ID] = creates a message that if people click on the reaction it triggers '/role server'"
}

Help.server.settings = {
    member = "/settings member = creates a new role that is used for '/role server'",
    voice = "/settings voice = creates a category for the tempory voice rooms",
    level = "/settings level [number] = changes the command level of the server allowing users to use certain commands",
    watch = "/settings watch image = makes ovewrlord watch the channel for anyone to post an image, and when they do it add a role to them",
    edit = "/settings edit member [Role ID] = changes the target role for member"
}

Help.other = 'if you type "get_emoji" and then add a reaction to it, the bot will print its Emoji ID'

function Help:handle(raw_message, message,level,bot)
    if raw_message[1] == "/help" then
        Help:embed(1,message.author,nil,bot)
    end
end

function Help:embed(i,author,oldMessage,bot)
    if author == nil then return end
    if oldMessage ~= nil then
        oldMessage:delete()
    end
    local voiceCat = ''
    local textCat = ''
    local roleCat = ''
    local settingsCat = ''

    local i = 1
    for k, v in pairs(Help.channels.voice) do
        voiceCat = voiceCat..i..': '..v..'\n\n'
        i = i + 1
    end
    i = 1
    for k, v in pairs(Help.channels.text) do
        textCat = textCat..i..': '..v..'\n\n'
        i = i + 1
    end
    i = 1
    for k, v in pairs(Help.server.role) do
        roleCat = roleCat..i..': '..v..'\n\n'
        i = i + 1
    end
    i = 1
    for k, v in pairs(Help.server.settings) do
        settingsCat = settingsCat..i..': '..v..'\n\n'
        i = i + 1
    end
    
        author:send{
            embed = {
                title = "Bot Commands",
                url = '',
                author = {
                    name = bot.username,
                    icon_url = bot.avatarURL
                },
                fields = { -- array of fields
                    {
                        name = "Voice",
                        value = voiceCat,
                        inline = false
                    },
                    {
                        name = "Text",
                        value = textCat,
                        inline = false
                    },
                    {
                        name = "Role",
                        value = roleCat,
                        inline = false
                    },
                    {
                        name = "Settings",
                        value = settingsCat,
                        inline = false
                    },
                    {
                        name = "Other",
                        value = Help.other,
                        inline = false
                    },
                },
                footer = {
                    text = "Bot made by Lmon#1465"
                },
                color = 0x8000ff -- hex color code
            }
        }
end