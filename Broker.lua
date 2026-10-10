-- Button for Titan Panel and other LibDataBroker displays (ChocolateBar,
-- Bazooka, ...). The library ships with those addons; without one of them
-- there is nothing to register and this file does nothing.
local _, ns = ...
local L = ns.L

ns.On("PLAYER_LOGIN", function()
    local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
    if not LDB then return end

    LDB:NewDataObject("QuickToggle", {
        type = "launcher",
        label = L.TITLE,
        icon = ns.ICON,
        OnClick = function(frame, button)
            GameTooltip:Hide()
            ns.TogglePopup(button == "RightButton" and "settings" or "menu", frame)
        end,
        OnTooltipShow = function(tooltip)
            ns.FillTooltip(tooltip, L.HINT_BROKER)
        end,
    })
end)
