-- "Take all" button in the mailbox: collects money and items from every
-- letter. One request at a time with a short pause, because the server
-- drops requests that come too fast. Letters with cash on delivery (COD)
-- are skipped: taking them costs money.
local _, ns = ...
local L = ns.L

local STEP_DELAY = 0.4
local MAX_TRIES = 3   -- tries per item/money before it is skipped
local MAX_ATTACHMENTS = ATTACHMENTS_MAX_RECEIVE or 16

local button
local running = false
local startMoney, takenItems, failedItems = 0, 0, 0
local skipped = {}        -- [key] = true: could not be taken, leave it
local lastKey, lastIsItem, tries

-- Identifies one money or item slot of one letter. Letter indexes shift as
-- letters disappear, so sender, subject and expiry time are used instead.
local function SlotKey(i, a)
    local _, _, sender, subject, _, _, daysLeft = GetInboxHeaderInfo(i)
    local itemID = 0
    if a > 0 then itemID = select(2, GetInboxItem(i, a)) or 0 end
    return string.format("%s|%s|%.5f|%d|%d", sender or "", subject or "", daysLeft or 0, a, itemID)
end

-- next thing to take: letter index, attachment (0 = money), its key
local function NextTarget()
    for i = 1, GetInboxNumItems() do
        local _, _, _, _, money, cod, _, hasItem = GetInboxHeaderInfo(i)
        if not cod or cod == 0 then
            if money and money > 0 then
                local key = SlotKey(i, 0)
                if not skipped[key] then return i, 0, key end
            end
            if hasItem then
                for a = 1, MAX_ATTACHMENTS do
                    if GetInboxItem(i, a) then
                        local key = SlotKey(i, a)
                        if not skipped[key] then return i, a, key end
                    end
                end
            end
        end
    end
end

local function Finish(reason)
    running = false
    if button then button:SetEnabled(true) end
    -- the last thing taken is gone from the inbox by now
    if lastKey and lastIsItem then takenItems = takenItems + 1 end
    lastKey = nil

    local money = GetMoney() - startMoney
    if money > 0 or takenItems > 0 then
        ns.Print(string.format(L.MAIL_DONE, ns.Money(math.max(money, 0)), takenItems))
    end
    if failedItems > 0 then ns.Print(string.format(L.MAIL_FAILED, failedItems)) end
    if reason then ns.Print(reason) end

    -- the inbox lists at most 50 letters; the rest arrive after reopening
    local shown, total = GetInboxNumItems()
    if total and total > shown then ns.Print(L.MAIL_MORE) end
end

-- takes one thing (money or one attachment) and schedules the next step
local function Step()
    if not running then return end
    local i, a, key = NextTarget()
    if not i then
        Finish()
        return
    end

    if key == lastKey then
        -- still there after the last try: the game refused it
        tries = tries + 1
        if tries >= MAX_TRIES then
            skipped[key] = true
            if a > 0 then failedItems = failedItems + 1 end
            lastKey = nil
            Step()
            return
        end
    else
        -- a new target means the previous one was taken
        if lastKey and lastIsItem then takenItems = takenItems + 1 end
        lastKey, lastIsItem, tries = key, a > 0, 1
    end

    if a == 0 then
        TakeInboxMoney(i)
    else
        if ns.FreeBagSlots() == 0 then
            lastKey = nil
            Finish(L.MAIL_BAGS_FULL)
            return
        end
        TakeInboxItem(i, a)
    end
    C_Timer.After(STEP_DELAY, Step)
end

local function CreateButton()
    button = CreateFrame("Button", "TimesaverMailButton", InboxFrame, "UIPanelButtonTemplate")
    button:SetSize(110, 22)
    button:SetText(L.MAIL_BUTTON)
    button:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -12, -30)
    button:SetScript("OnClick", function(self)
        if running then return end
        running = true
        startMoney, takenItems, failedItems = GetMoney(), 0, 0
        skipped, lastKey, tries = {}, nil, 0
        self:SetEnabled(false)
        Step()
    end)
end

function ns.UpdateMailButton()
    if button then button:SetShown(ns.db.mailTakeAll) end
end

ns.On("MAIL_SHOW", function()
    if not button then CreateButton() end
    ns.UpdateMailButton()
end)

ns.On("MAIL_CLOSED", function()
    if running then Finish() end
end)
