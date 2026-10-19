-- Warning when the bags are almost full: once, when the free space drops
-- to the threshold, not on every change after that.
local _, ns = ...
local L = ns.L

local THRESHOLD = 2 -- free slots left
local wasLow = false

ns.On("BAG_UPDATE_DELAYED", function()
    if not ns.db.bagWarning then
        wasLow = false
        return
    end
    local free = ns.FreeBagSlots()
    local low = free <= THRESHOLD
    if low and not wasLow then
        local msg = free == 0 and L.BAGS_FULL or string.format(L.BAGS_LOW, free)
        ns.Print(msg)
        UIErrorsFrame:AddMessage(msg, 1, 0.3, 0.3)
    end
    wasLow = low
end)
