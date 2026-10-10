-- Settings, event dispatch and slash commands.
-- Automation lives in Quests.lua, Vendor.lua, Mail.lua and Social.lua; visuals in UI.lua.
local ADDON, ns = ...
local L = ns.L

-- Rows of the menu, in display order. icon: Interface\Icons\<name>,
-- or a full path for the quest "!" / "?" glyphs.
ns.toggles = {
    { key = "autoLoot",      label = L.AUTO_LOOT,      icon = "INV_Misc_Bag_10" },
    { key = "autoQuest",     label = L.AUTO_ACCEPT,    icon = "Interface\\GossipFrame\\AvailableQuestIcon" },
    { key = "autoTurnIn",    label = L.AUTO_TURN_IN,   icon = "Interface\\GossipFrame\\ActiveQuestIcon" },
    { key = "bestReward",    label = L.BEST_REWARD,    icon = "INV_Misc_Gift_01" },
    { key = "sellJunk",      label = L.SELL_JUNK,      icon = "INV_Misc_Coin_01" },
    { key = "autoRepair",    label = L.AUTO_REPAIR,    icon = "Trade_BlackSmithing" },
    { key = "mailTakeAll",   label = L.MAIL_TAKE_ALL,  icon = "INV_Letter_15" },
    { key = "acceptInvites", label = L.ACCEPT_INVITES, icon = "Spell_Holy_PrayerOfFortitude" },
    { key = "declineDuels",  label = L.DECLINE_DUELS,  icon = "INV_Sword_04" },
    { key = "declineGuild",  label = L.DECLINE_GUILD,  icon = "INV_Shirt_GuildTabard_01" },
    { key = "declineTrades", label = L.DECLINE_TRADES, icon = "INV_Scroll_03" },
}

ns.defaultPosition = { point = "CENTER", relPoint = "CENTER", x = 0, y = 200 }

local defaults = {
    hidden = {}, -- [toggle key] = true: not listed in the menu
    locked = false,
    shown = true,
    tooltip = true,
    size = 20,   -- icon size in px
    alpha = 100, -- icon opacity in percent
    point = ns.defaultPosition.point,
    relPoint = ns.defaultPosition.relPoint,
    x = ns.defaultPosition.x,
    y = ns.defaultPosition.y,
}
for _, t in ipairs(ns.toggles) do
    defaults[t.key] = false
end
-- the options panel needs them for its "Defaults" button
ns.defaults = defaults

function ns.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100" .. L.TITLE .. "|r: " .. msg)
end

-- "1g 2s 3c" in coin colors; GetCoinTextureString is missing in Forever
function ns.Money(copper)
    local g = math.floor(copper / 10000)
    local s = math.floor(copper / 100) % 100
    local c = copper % 100
    local parts = {}
    if g > 0 then parts[#parts + 1] = "|cffffd700" .. g .. "g|r" end
    if s > 0 then parts[#parts + 1] = "|cffc7c7cf" .. s .. "s|r" end
    if c > 0 or #parts == 0 then parts[#parts + 1] = "|cffeda55f" .. c .. "c|r" end
    return table.concat(parts, " ")
end

-- C_Item in the modern API; the global as a fallback
ns.GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo

function ns.Toggle(key)
    ns.db[key] = not ns.db[key]
    ns.RefreshUI()
end

function ns.AnyEnabled()
    for _, t in ipairs(ns.toggles) do
        if ns.db[t.key] then return true end
    end
    return false
end

function ns.IsInMenu(toggle)
    return not ns.db.hidden[toggle.key]
end

-- A hidden feature is also switched off, so nothing runs that the menu
-- doesn't show.
function ns.SetHidden(key, hidden)
    ns.db.hidden[key] = hidden or nil
    if hidden then ns.db[key] = false end
    ns.RefreshUI()
end

-- The Fast bind row is not a feature, so hiding it switches nothing off.
-- It shares db.hidden with the toggles under its own key.
function ns.IsFastBindShown()
    return not ns.db.hidden.fastBind
end

function ns.SetFastBindShown(shown)
    ns.db.hidden.fastBind = not shown or nil
    ns.RefreshUI()
end

-- ---------------------------------------------------------------- key bindings

-- Bindings.xml lists one binding per toggle:
-- Esc > Options > Keybindings > AddOns > QuickToggle.
BINDING_HEADER_QUICKTOGGLE = L.TITLE
for _, t in ipairs(ns.toggles) do
    _G["BINDING_NAME_QUICKTOGGLE_" .. string.upper(t.key)] = L.BINDING_PREFIX .. t.label
end

function QuickToggle_ToggleFeature(key)
    if not ns.db then return end
    -- a feature switched on by key goes back into the menu, so it can be
    -- seen and switched off there too
    if ns.db.hidden[key] then ns.SetHidden(key, false) end
    ns.Toggle(key)
    for _, t in ipairs(ns.toggles) do
        if t.key == key then
            ns.Print(string.format("%s: %s", t.label, ns.db[key] and L.ON or L.OFF))
        end
    end
end

-- Holding Shift skips automation you trigger yourself (loot, NPCs, vendors).
function ns.Skip()
    return IsShiftKeyDown()
end

local function InitDB()
    QuickToggleDB = QuickToggleDB or {}
    local db = QuickToggleDB
    for k, v in pairs(defaults) do
        if db[k] == nil then
            -- table defaults are empty; each save gets its own table
            if type(v) == "table" then v = {} end
            db[k] = v
        end
    end
    -- drop settings left over from older versions
    for k in pairs(db) do
        if defaults[k] == nil then db[k] = nil end
    end
    ns.db = db
end

-- ---------------------------------------------------------------- events

-- Modules subscribe with ns.On(event, fn). Handlers only run once settings
-- are loaded, so they can use ns.db freely.
local handlers = {}
local events = CreateFrame("Frame")

function ns.On(event, fn)
    if not handlers[event] then
        handlers[event] = {}
        events:RegisterEvent(event)
    end
    table.insert(handlers[event], fn)
end

events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= ADDON then return end
        InitDB()
        ns.InitUI()
        ns.InitOptions()
        self:UnregisterEvent("ADDON_LOADED")
        return
    end
    if not ns.db then return end
    for _, fn in ipairs(handlers[event]) do
        fn(...)
    end
end)

-- ---------------------------------------------------------------- slash

SLASH_QUICKTOGGLE1 = "/qt"
SLASH_QUICKTOGGLE2 = "/quicktoggle"
SlashCmdList.QUICKTOGGLE = function(msg)
    msg = strtrim(string.lower(msg or ""))
    local db = ns.db
    if msg == "lock" then
        db.locked = not db.locked
        ns.Print(db.locked and L.LOCKED or L.UNLOCKED)
        ns.RefreshUI()
    elseif msg == "reset" then
        ns.ResetPosition()
        ns.Print(L.RESET)
    elseif msg == "options" or msg == "config" then
        ns.OpenOptions()
    elseif msg == "help" then
        ns.Print(L.HELP)
    else
        db.shown = not db.shown
        ns.RefreshUI()
    end
end
