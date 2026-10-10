-- Auto loot, auto accept and auto turn in of quests, best reward choice.
local _, ns = ...
local L = ns.L

ns.On("LOOT_OPENED", function()
    if not ns.db.autoLoot or ns.Skip() then return end
    for i = GetNumLootItems(), 1, -1 do
        LootSlot(i)
    end
end)

ns.On("QUEST_DETAIL", function()
    if not ns.db.autoQuest or ns.Skip() then return end
    -- quests the server already accepted only need the window closed
    if QuestGetAutoAccept() then
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
        local q = C_GossipInfo.GetAvailableQuests()[1]
        if q then C_GossipInfo.SelectAvailableQuest(q.questID) end
    end
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
    if db.autoQuest and GetNumAvailableQuests() > 0 then
        SelectAvailableQuest(1)
    end
end)
