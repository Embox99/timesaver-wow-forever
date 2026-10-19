-- Auto loot, auto accept and auto turn in of quests, best reward choice,
-- skipping grey quests and single-option NPC chatter.
local _, ns = ...
local L = ns.L

ns.On("LOOT_OPENED", function()
    if not ns.db.autoLoot or ns.Skip() then return end
    for i = GetNumLootItems(), 1, -1 do
        LootSlot(i)
    end
end)

-- Grey quests: too low for your level, they give no experience.
local function IsTrivial(questID)
    if not ns.db.skipTrivial or not questID then return false end
    if C_QuestLog and C_QuestLog.IsQuestTrivial then
        return C_QuestLog.IsQuestTrivial(questID) and true or false
    end
    return false
end

ns.On("QUEST_DETAIL", function()
    if not ns.db.autoQuest or ns.Skip() then return end
    if GetQuestID and IsTrivial(GetQuestID()) then return end
    -- quests the server already accepted only need the window closed
    if QuestGetAutoAccept and QuestGetAutoAccept() then
        CloseQuest()
    else
        AcceptQuest()
    end
end)

-- escort quests started by another player
ns.On("QUEST_ACCEPT_CONFIRM", function()
    if not ns.db.autoQuest or ns.Skip() then return end
    ConfirmAcceptQuest()
    StaticPopup_Hide("QUEST_ACCEPT")
end)

-- "Do you have the items?" page: continue if everything is collected
ns.On("QUEST_PROGRESS", function()
    if ns.db.autoTurnIn and not ns.Skip() and IsQuestCompletable() then
        CompleteQuest()
    end
end)

-- reward page: take it automatically only when there is nothing to choose
-- The reward page is open between QUEST_COMPLETE and QUEST_FINISHED;
-- delayed retries must not fire after it closed.
local rewardPageOpen = false

-- Index of the reward that sells for the most, or nil while item data is
-- still loading (or when nothing can be sold, so the choice stays yours).
local function MostValuableReward(choices)
    local best, bestPrice = nil, 0
    for i = 1, choices do
        local link = GetQuestItemLink("choice", i)
        if not link then return nil end
        local price = select(11, ns.GetItemInfo(link))
        if price == nil then return nil end
        local _, _, count = GetQuestItemInfo("choice", i)
        price = price * math.max(count or 1, 1)
        if price > bestPrice then
            best, bestPrice = i, price
        end
    end
    return best, bestPrice
end

-- item data may arrive a moment later: retry a few times, then give up
local function PickBestReward(choices, attempt)
    if not rewardPageOpen then return end
    local best, price = MostValuableReward(choices)
    if best then
        ns.Print(string.format(L.CHOSE_REWARD, GetQuestItemLink("choice", best), ns.Money(price)))
        GetQuestReward(best)
    elseif attempt < 5 then
        C_Timer.After(0.3, function() PickBestReward(choices, attempt + 1) end)
    end
end

ns.On("QUEST_COMPLETE", function()
    rewardPageOpen = true
    if ns.Skip() then return end
    local choices = GetNumQuestChoices()
    if choices <= 1 then
        if ns.db.autoTurnIn then GetQuestReward(choices) end
    elseif ns.db.bestReward then
        PickBestReward(choices, 1)
    end
end)

ns.On("QUEST_FINISHED", function()
    rewardPageOpen = false
end)

-- session statistics: every quest counts, taken by hand or automatically
ns.On("QUEST_ACCEPTED", function()
    ns.stats.accepted = ns.stats.accepted + 1
end)

ns.On("QUEST_TURNED_IN", function()
    ns.stats.turnedIn = ns.stats.turnedIn + 1
end)

-- NPC with nothing but a single dialogue option (flight master, innkeeper):
-- pick it. Picking the same option again within 3 s means the NPC loops
-- back to the same page, so it is left to you then.
local lastOption, lastOptionTime = nil, 0

local function SkipGossip()
    if #C_GossipInfo.GetActiveQuests() > 0 or #C_GossipInfo.GetAvailableQuests() > 0 then
        return
    end
    local options = C_GossipInfo.GetOptions()
    if #options ~= 1 then return end
    local id = options[1].gossipOptionID
    if not id then return end
    if id == lastOption and GetTime() - lastOptionTime < 3 then return end
    lastOption, lastOptionTime = id, GetTime()
    C_GossipInfo.SelectOption(id)
end

-- NPC with several options (gossip window): open the first finished quest
-- to turn in, otherwise the first new quest to accept. Each accept/turn-in
-- brings the window back, so the next quest gets picked up on the next event.
ns.On("GOSSIP_SHOW", function()
    if ns.Skip() then return end
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
        for _, q in ipairs(C_GossipInfo.GetAvailableQuests()) do
            if not (db.skipTrivial and q.isTrivial) then
                C_GossipInfo.SelectAvailableQuest(q.questID)
                return
            end
        end
    end
    if db.skipGossip then SkipGossip() end
end)

-- Same thing for the older quest-greeting window (quest-only NPCs, boards).
ns.On("QUEST_GREETING", function()
    if ns.Skip() then return end
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
    if db.autoQuest then
        for i = 1, GetNumAvailableQuests() do
            local isTrivial = GetAvailableQuestInfo and GetAvailableQuestInfo(i)
            if not (db.skipTrivial and isTrivial) then
                SelectAvailableQuest(i)
                return
            end
        end
    end
end)
