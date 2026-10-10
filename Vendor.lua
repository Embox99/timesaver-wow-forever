-- Selling junk and repairing when a vendor window opens.
local _, ns = ...
local L = ns.L

local POOR = Enum.ItemQuality.Poor
local Money = ns.Money

-- the game itself reports the money received, so no chat message here
local function SellJunk()
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if item and item.quality == POOR and not item.hasNoValue and not item.isLocked then
                C_Container.UseContainerItem(bag, slot)
            end
        end
    end
end

local function Repair()
    if not CanMerchantRepair() then return end
    local cost, canRepair = GetRepairAllCost()
    if not canRepair or cost <= 0 then return end

    if GetMoney() >= cost then
        RepairAllItems()
        ns.Print(string.format(L.REPAIRED, Money(cost)))
    else
        ns.Print(string.format(L.NO_MONEY_REPAIR, Money(cost)))
    end
end

ns.On("MERCHANT_SHOW", function()
    if ns.Skip() then return end
    if ns.db.sellJunk then SellJunk() end
    if ns.db.autoRepair then Repair() end
end)
