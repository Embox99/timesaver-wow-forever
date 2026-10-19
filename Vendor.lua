-- Selling junk and repairing when a vendor window opens.
-- Junk goes in small batches: the server drops sell requests that come too
-- fast. Repairs wait until the sales are done, so the money from the junk
-- is already there.
local _, ns = ...
local L = ns.L

local POOR = Enum.ItemQuality.Poor
local Money = ns.Money

local PER_PASS = 10     -- items sold per batch
local PASS_DELAY = 0.3  -- seconds between batches
local MAX_PASSES = 20   -- safety stop
local MONEY_DELAY = 0.5 -- wait for the last sale's money to arrive

local merchantOpen = false

local function Repair()
    if not merchantOpen or not CanMerchantRepair() then return end
    local cost, canRepair = GetRepairAllCost()
    if not canRepair or cost <= 0 then return end

    if GetMoney() >= cost then
        RepairAllItems()
        ns.stats.repairs = ns.stats.repairs + cost
        ns.Print(string.format(L.REPAIRED, Money(cost)))
    else
        ns.Print(string.format(L.NO_MONEY_REPAIR, Money(cost)))
    end
end

-- One batch: sells up to PER_PASS grey items, then comes back while items
-- are still being sold (locked) or left over. The game itself reports the
-- money received, so no chat message here.
local function SellPass(pass, onDone)
    if not merchantOpen then return end
    local sold, waiting = 0, false
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if item and item.quality == POOR and not item.hasNoValue then
                if item.isLocked or sold >= PER_PASS then
                    waiting = true
                else
                    C_Container.UseContainerItem(bag, slot)
                    sold = sold + 1
                end
            end
        end
    end
    if (sold > 0 or waiting) and pass < MAX_PASSES then
        C_Timer.After(PASS_DELAY, function() SellPass(pass + 1, onDone) end)
    else
        onDone(pass > 1 or sold > 0)
    end
end

ns.On("MERCHANT_SHOW", function()
    merchantOpen = true
    if ns.Skip() then return end
    local db = ns.db
    if not db.sellJunk then
        if db.autoRepair then Repair() end
        return
    end
    local before = GetMoney()
    SellPass(1, function(soldAny)
        if not soldAny then
            if db.autoRepair then Repair() end
            return
        end
        C_Timer.After(MONEY_DELAY, function()
            ns.stats.junk = ns.stats.junk + math.max(GetMoney() - before, 0)
            if db.autoRepair then Repair() end
        end)
    end)
end)

ns.On("MERCHANT_CLOSED", function()
    merchantOpen = false
end)
