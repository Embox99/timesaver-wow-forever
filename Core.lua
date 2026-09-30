-- Settings, automation and slash commands. The visual part lives in UI.lua.
local ADDON, ns = ...
local L = ns.L

-- Order here is the order of rows in the menu.
ns.toggles = {
    { key = "autoLoot",   label = L.AUTO_LOOT },
    { key = "autoQuest",  label = L.AUTO_ACCEPT },
    { key = "autoTurnIn", label = L.AUTO_TURN_IN },
}

ns.defaultPosition = { point = "CENTER", relPoint = "CENTER", x = 0, y = 200 }

local defaults = {
    autoLoot = false,
    autoQuest = false,
    autoTurnIn = false,
    locked = false,
    shown = true,
    point = ns.defaultPosition.point,
    relPoint = ns.defaultPosition.relPoint,
    x = ns.defaultPosition.x,
    y = ns.defaultPosition.y,
}

function ns.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100" .. L.TITLE .. "|r: " .. msg)
end

function ns.Toggle(key)
    ns.db[key] = not ns.db[key]
    ns.RefreshUI()
end

function ns.AnyEnabled()
    local db = ns.db
    return db.autoLoot or db.autoQuest or db.autoTurnIn
end

local function InitDB()
    QuickToggleDB = QuickToggleDB or {}
    local db = QuickToggleDB
    for k, v in pairs(defaults) do
        if db[k] == nil then db[k] = v end
    end
    -- drop settings left over from older versions
    for k in pairs(db) do
        if defaults[k] == nil then db[k] = nil end
    end
    ns.db = db
end

-- ---------------------------------------------------------------- automation

-- Holding Shift skips any automation once.
local function Skip()
    return IsShiftKeyDown()
end

local function LootAll()
    for i = GetNumLootItems(), 1, -1 do
        LootSlot(i)
    end
end

-- NPC with several options (gossip window): open the first finished quest
-- to turn in, otherwise the first new quest to accept. Each accept/turn-in
-- brings the window back, so the next quest gets picked up on the next event.
local function HandleGossip()
    local db = ns.db
    if db.autoTurnIn then
        for _, q in ipairs(C_GossipInfo.GetActiveQuests()) do
            if q.isComplete then
                C_GossipInfo.SelectActiveQuest(q.questID)
                return
            end
        end
    end
    if db.autoQuest then
        local q = C_GossipInfo.GetAvailableQuests()[1]
        if q then C_GossipInfo.SelectAvailableQuest(q.questID) end
    end
end

-- Same thing for the older quest-greeting window (quest-only NPCs, boards).
local function HandleGreeting()
    local db = ns.db
    if db.autoTurnIn then
        for i = 1, GetNumActiveQuests() do
            local _, isComplete = GetActiveTitle(i)
            if isComplete then
                SelectActiveQuest(i)
                return
            end
        end
    end
    if db.autoQuest and GetNumAvailableQuests() > 0 then
        SelectAvailableQuest(1)
    end
end

local handlers = {}

function handlers.ADDON_LOADED(name)
    if name ~= ADDON then return end
    InitDB()
    ns.InitUI()
    return true -- unregister
end

function handlers.LOOT_OPENED()
    if ns.db.autoLoot and not Skip() then LootAll() end
end

function handlers.QUEST_DETAIL()
    if not ns.db.autoQuest or Skip() then return end
    -- quests the server already accepted only need the window closed
    if QuestGetAutoAccept() then
        CloseQuest()
    else
        AcceptQuest()
    end
end

-- escort quests started by another player
function handlers.QUEST_ACCEPT_CONFIRM()
    if not ns.db.autoQuest or Skip() then return end
    ConfirmAcceptQuest()
    StaticPopup_Hide("QUEST_ACCEPT")
end

-- "Do you have the items?" page: continue if everything is collected
function handlers.QUEST_PROGRESS()
    if ns.db.autoTurnIn and not Skip() and IsQuestCompletable() then
        CompleteQuest()
    end
end

-- reward page: take it automatically only when there is nothing to choose
function handlers.QUEST_COMPLETE()
    if not ns.db.autoTurnIn or Skip() then return end
    local choices = GetNumQuestChoices()
    if choices <= 1 then GetQuestReward(choices) end
end

function handlers.GOSSIP_SHOW()
    if not Skip() then HandleGossip() end
end

function handlers.QUEST_GREETING()
    if not Skip() then HandleGreeting() end
end

local events = CreateFrame("Frame")
for event in pairs(handlers) do
    events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(self, event, ...)
    -- nothing but ADDON_LOADED may run before settings are loaded
    if not ns.db and event ~= "ADDON_LOADED" then return end
    if handlers[event](...) then self:UnregisterEvent(event) end
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
    elseif msg == "reset" then
        ns.ResetPosition()
        ns.Print(L.RESET)
    elseif msg == "help" then
        ns.Print(L.HELP)
    else
        db.shown = not db.shown
        ns.RefreshUI()
    end
end
