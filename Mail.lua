-- "Take all" button in the mailbox: collects money and items from every
-- letter. One request at a time with a short pause, because the server
-- drops requests that come too fast. Letters with cash on delivery (COD)
-- are skipped: taking them costs money.
local _, ns = ...
local L = ns.L

local STEP_DELAY = 0.4
local MAX_ATTACHMENTS = ATTACHMENTS_MAX_RECEIVE or 16

local button
local running = false
local startMoney, takenItems = 0, 0

-- only normal bags: quivers and soul bags can't hold mail items
local function FreeBagSlots()
    local free = 0
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local slots, bagType = C_Container.GetContainerNumFreeSlots(bag)
        if bagType == 0 then free = free + (slots or 0) end
    end
    return free
end

local function Finish(reason)
    running = false
    if button then button:SetEnabled(true) end
    local money = GetMoney() - startMoney
    if money > 0 or takenItems > 0 then
        ns.Print(string.format(L.MAIL_DONE, ns.Money(math.max(money, 0)), takenItems))
    end
    if reason then ns.Print(reason) end
end

-- takes one thing (money or one attachment) and schedules the next step
local function Step()
    if not running then return end
    for i = 1, GetInboxNumItems() do
        local _, _, _, _, money, cod, _, hasItem = GetInboxHeaderInfo(i)
        if not cod or cod == 0 then
            if money and money > 0 then
                TakeInboxMoney(i)
                C_Timer.After(STEP_DELAY, Step)
                return
            end
            if hasItem then
                if FreeBagSlots() == 0 then
                    Finish(L.MAIL_BAGS_FULL)
                    return
                end
                for a = 1, MAX_ATTACHMENTS do
                    if GetInboxItem(i, a) then
                        TakeInboxItem(i, a)
                        takenItems = takenItems + 1
                        C_Timer.After(STEP_DELAY, Step)
                        return
                    end
                end
            end
        end
    end
    Finish()
end

local function CreateButton()
    button = CreateFrame("Button", "TimesaverMailButton", InboxFrame, "UIPanelButtonTemplate")
    button:SetSize(110, 22)
    button:SetText(L.MAIL_BUTTON)
    button:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -12, -30)
    button:SetScript("OnClick", function(self)
        if running then return end
        running = true
        startMoney, takenItems = GetMoney(), 0
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
