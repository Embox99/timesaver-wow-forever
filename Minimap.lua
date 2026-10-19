-- Optional button on the minimap edge (off by default). Same menus as the
-- clock: left click features, right click settings. Drag it around the
-- minimap; the angle is saved.
local _, ns = ...
local L = ns.L

local button

local function Radius()
    return Minimap:GetWidth() / 2 + 5
end

local function UpdatePosition()
    local angle = math.rad(ns.db.minimapAngle)
    local r = Radius()
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * r, math.sin(angle) * r)
end

-- angle from the minimap center to the cursor, while dragging
local function OnDragUpdate()
    local mx, my = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    cx, cy = cx / scale, cy / scale
    ns.db.minimapAngle = math.deg(math.atan2(cy - my, cx - mx)) % 360
    UpdatePosition()
end

local function Create()
    local b = CreateFrame("Button", "TimesaverMinimapButton", Minimap)
    b:SetSize(31, 31)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(20, 20)
    bg:SetPoint("CENTER")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetSize(19, 19)
    icon:SetPoint("CENTER")
    icon:SetTexture(ns.ICON)
    b.icon = icon

    -- the standard round gold frame of minimap buttons
    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    b:SetScript("OnClick", function(self, mouse)
        GameTooltip:Hide()
        ns.TogglePopup(mouse == "RightButton" and "settings" or "menu", self)
    end)
    b:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:SetScript("OnUpdate", OnDragUpdate)
    end)
    b:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        ns.FillTooltip(GameTooltip, L.HINT_MINIMAP)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", GameTooltip_Hide)
    return b
end

function ns.UpdateMinimapButton()
    if not ns.db.minimap then
        if button then button:Hide() end
        return
    end
    if not button then button = Create() end
    button.icon:SetDesaturated(not ns.AnyEnabled())
    UpdatePosition()
    button:Show()
end

function ns.InitMinimap()
    ns.UpdateMinimapButton()
end
