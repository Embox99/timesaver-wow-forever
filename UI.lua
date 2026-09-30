-- Round clock icon, the toggle menu (left click) and the settings menu (right click).
local _, ns = ...
local L = ns.L

local ICON = "Interface\\Icons\\INV_Misc_PocketWatch_01"
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local CHECK_ON = "Interface\\RaidFrame\\ReadyCheck-Ready"
local CHECK_OFF = "Interface\\RaidFrame\\ReadyCheck-NotReady"
local RESET_ICON = "Interface\\Buttons\\UI-RefreshButton"
local ICON_CROP = { 0.08, 0.92, 0.08, 0.92 }

local GOLD = { 1, 0.82, 0 }
local BORDER_GOLD = { 0.8, 0.65, 0.2 }
local RING_OFF = { 0.3, 0.3, 0.3 }
local GREEN = { 0.25, 1, 0.25 }
local RED = { 1, 0.3, 0.3 }
local WHITE = { 1, 1, 1 }
local GREY = { 0.6, 0.6, 0.6 }

local MENU_WIDTH = 196
local ROW_HEIGHT = 20
local HEADER_HEIGHT = 34
local FOOTER_HEIGHT = 30
-- labels of all rows start here, right after the 14px check/icon
local LABEL_X = 27

local clock, menu, settings
local popups = {}   -- only one popup is open at a time
local painted = {}  -- rows repainted by ns.RefreshUI

local function SetColor(texture, c, alpha)
    texture:SetColorTexture(c[1], c[2], c[3], alpha or 1)
end

local function CircleMask(parent)
    local mask = parent:CreateMaskTexture()
    mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    return mask
end

-- ---------------------------------------------------------------- clock

local function CreateClock()
    local f = CreateFrame("Button", "QuickToggleIcon", UIParent)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- a filled circle behind a slightly smaller round icon reads as a ring
    f.ringMask = CircleMask(f)
    f.ringMask:SetAllPoints()
    f.ring = f:CreateTexture(nil, "BACKGROUND")
    f.ring:SetAllPoints()
    f.ring:AddMaskTexture(f.ringMask)

    f.iconMask = CircleMask(f)
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetTexture(ICON)
    f.icon:SetTexCoord(unpack(ICON_CROP))
    f.icon:AddMaskTexture(f.iconMask)

    f.highlight = f:CreateTexture(nil, "HIGHLIGHT")
    f.highlight:SetAllPoints(f.icon)
    f.highlight:SetColorTexture(1, 1, 1, 0.2)
    f.highlight:AddMaskTexture(f.iconMask)
    return f
end

local function PaintClock()
    local db = ns.db
    clock:SetSize(db.size, db.size)
    clock:SetAlpha(db.alpha / 100)

    -- ring stays about 1/14 of the icon: 1px at 20px, 2px at 28px and up
    local ring = math.max(1, math.floor(db.size / 14))
    for _, t in ipairs({ clock.icon, clock.iconMask }) do
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", ring, -ring)
        t:SetPoint("BOTTOMRIGHT", -ring, ring)
    end

    local on = ns.AnyEnabled()
    SetColor(clock.ring, on and GOLD or RING_OFF)
    clock.icon:SetDesaturated(not on)
end

local function ShowClockTooltip()
    GameTooltip:SetOwner(clock, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:SetText(L.TITLE)
    for _, t in ipairs(ns.toggles) do
        local on = ns.db[t.key]
        local left = on and WHITE or GREY
        local right = on and GREEN or RED
        GameTooltip:AddDoubleLine(t.label, on and L.ON or L.OFF,
            left[1], left[2], left[3], right[1], right[2], right[3])
    end
    GameTooltip:AddLine(L.HINT_ICON, 0.7, 0.7, 0.7)
    GameTooltip:Show()
end

-- ---------------------------------------------------------------- popup frame

local function AddSeparator(parent, y)
    local line = parent:CreateTexture(nil, "ARTWORK")
    SetColor(line, BORDER_GOLD, 0.35)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 8, y)
    line:SetPoint("TOPRIGHT", -8, y)
end

-- open towards the middle of the screen so a popup never hides off-edge
local function PlacePopup(f)
    local x, y = clock:GetCenter()
    local vertical, anchorV, dy = "BOTTOM", "TOP", 4
    if y > UIParent:GetHeight() / 2 then
        vertical, anchorV, dy = "TOP", "BOTTOM", -4
    end
    local side = x > UIParent:GetWidth() / 2 and "RIGHT" or "LEFT"
    f:ClearAllPoints()
    f:SetPoint(vertical .. side, clock, anchorV .. side, 0, dy)
end

local function CreatePopup(name, title, hint, rowCount)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(MENU_WIDTH, HEADER_HEIGHT + ROW_HEIGHT * rowCount + FOOTER_HEIGHT)
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:Hide()
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0.04, 0.04, 0.06, 0.94)
    f:SetBackdropBorderColor(BORDER_GOLD[1], BORDER_GOLD[2], BORDER_GOLD[3], 1)
    -- Escape closes the popup
    tinsert(UISpecialFrames, name)

    local titleMask = CircleMask(f)
    local titleIcon = f:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(16, 16)
    titleIcon:SetPoint("TOPLEFT", 10, -9)
    titleIcon:SetTexture(ICON)
    titleIcon:SetTexCoord(unpack(ICON_CROP))
    titleMask:SetAllPoints(titleIcon)
    titleIcon:AddMaskTexture(titleMask)

    local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", titleIcon, "RIGHT", 6, 0)
    text:SetText(title)

    AddSeparator(f, -30)
    AddSeparator(f, -HEADER_HEIGHT - ROW_HEIGHT * rowCount - 4)

    local hintText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hintText:SetPoint("BOTTOM", 0, 10)
    hintText:SetText(hint)

    f:SetScript("OnShow", function(self)
        for _, other in ipairs(popups) do
            if other ~= self then other:Hide() end
        end
        PlacePopup(self)
        self:RegisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    f:SetScript("OnHide", function(self)
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    -- a click anywhere outside the popup and the clock closes it
    f:SetScript("OnEvent", function(self)
        if not self:IsMouseOver() and not clock:IsMouseOver() then
            self:Hide()
        end
    end)

    popups[#popups + 1] = f
    return f
end

-- ---------------------------------------------------------------- rows

local function CreateRow(parent, index, clickable)
    local y = -HEADER_HEIGHT - (index - 1) * ROW_HEIGHT
    local row = CreateFrame(clickable and "Button" or "Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", 6, y)
    row:SetPoint("TOPRIGHT", -6, y)

    if clickable then
        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        SetColor(hl, GOLD, 0.12)
    end

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(14, 14)
    row.icon:SetPoint("LEFT", 6, 0)

    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.label:SetPoint("LEFT", LABEL_X, 0)
    return row
end

-- [check] Label ........ ON
local function CreateToggleRow(parent, index, label, key)
    local row = CreateRow(parent, index, true)
    row.label:SetText(label)

    row.state = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.state:SetPoint("RIGHT", -6, 0)

    function row.Paint()
        local on = ns.db[key]
        local text = on and WHITE or GREY
        local state = on and GREEN or RED
        row.icon:SetTexture(on and CHECK_ON or CHECK_OFF)
        row.label:SetTextColor(text[1], text[2], text[3])
        row.state:SetText(on and L.ON or L.OFF)
        row.state:SetTextColor(state[1], state[2], state[3])
    end

    row:SetScript("OnClick", function() ns.Toggle(key) end)
    painted[#painted + 1] = row
    return row
end

local function CreateStepButton(row, text)
    local b = CreateFrame("Button", nil, row)
    b:SetSize(16, 16)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("CENTER", 0, 1)
    b.text:SetText(text)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    SetColor(hl, GOLD, 0.2)
    return b
end

-- Label ........ [-] 20 px [+]
local function CreateStepperRow(parent, index, label, key, min, max, step, format)
    local row = CreateRow(parent, index, false)
    row.label:SetText(label)

    row.plus = CreateStepButton(row, "+")
    row.plus:SetPoint("RIGHT", -2, 0)
    row.value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.value:SetWidth(40)
    row.value:SetPoint("RIGHT", row.plus, "LEFT", -2, 0)
    row.minus = CreateStepButton(row, "-")
    row.minus:SetPoint("RIGHT", row.value, "LEFT", -2, 0)

    local function Change(delta)
        local v = ns.db[key] + delta
        ns.db[key] = math.min(max, math.max(min, v))
        ns.RefreshUI()
    end
    row.minus:SetScript("OnClick", function() Change(-step) end)
    row.plus:SetScript("OnClick", function() Change(step) end)

    local function PaintButton(b, enabled)
        b:SetEnabled(enabled)
        local c = enabled and GOLD or GREY
        b.text:SetTextColor(c[1], c[2], c[3])
    end

    function row.Paint()
        local v = ns.db[key]
        row.value:SetText(string.format(format, v))
        PaintButton(row.minus, v > min)
        PaintButton(row.plus, v < max)
    end

    painted[#painted + 1] = row
    return row
end

-- [icon] Label   (click runs an action)
local function CreateActionRow(parent, index, label, icon, onClick)
    local row = CreateRow(parent, index, true)
    row.label:SetText(label)
    row.icon:SetTexture(icon)
    row:SetScript("OnClick", onClick)
    return row
end

-- ---------------------------------------------------------------- popups

local function CreateToggleMenu()
    local f = CreatePopup("QuickToggleMenu", L.TITLE, L.HINT_MENU, #ns.toggles)
    for i, t in ipairs(ns.toggles) do
        CreateToggleRow(f, i, t.label, t.key)
    end
    return f
end

local function CreateSettingsMenu()
    local f = CreatePopup("QuickToggleSettings", L.SETTINGS, L.HINT_SETTINGS, 5)
    CreateStepperRow(f, 1, L.ICON_SIZE, "size", 16, 40, 2, "%d px")
    CreateStepperRow(f, 2, L.OPACITY, "alpha", 30, 100, 10, "%d%%")
    CreateToggleRow(f, 3, L.LOCK, "locked")
    CreateToggleRow(f, 4, L.TOOLTIP, "tooltip")
    CreateActionRow(f, 5, L.RESET_POSITION, RESET_ICON, function()
        ns.ResetPosition()
        PlacePopup(f)
    end)
    return f
end

-- ---------------------------------------------------------------- behaviour

local function SavePosition()
    local point, _, relPoint, x, y = clock:GetPoint()
    local db = ns.db
    db.point, db.relPoint, db.x, db.y = point, relPoint, x, y
end

local function ApplyPosition()
    local db = ns.db
    clock:ClearAllPoints()
    clock:SetPoint(db.point, UIParent, db.relPoint, db.x, db.y)
end

local function AnyPopupShown()
    for _, f in ipairs(popups) do
        if f:IsShown() then return true end
    end
    return false
end

local function SetupClockScripts()
    clock:SetScript("OnDragStart", function(self)
        if ns.db.locked then return end
        for _, f in ipairs(popups) do f:Hide() end
        GameTooltip:Hide()
        self:StartMoving()
    end)
    clock:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    clock:SetScript("OnClick", function(_, button)
        GameTooltip:Hide()
        local target = button == "RightButton" and settings or menu
        target:SetShown(not target:IsShown())
    end)
    clock:SetScript("OnEnter", function()
        if ns.db.tooltip and not AnyPopupShown() then ShowClockTooltip() end
    end)
    clock:SetScript("OnLeave", GameTooltip_Hide)
end

-- ---------------------------------------------------------------- API used by Core.lua

function ns.InitUI()
    clock = CreateClock()
    menu = CreateToggleMenu()
    settings = CreateSettingsMenu()
    SetupClockScripts()
    ApplyPosition()
    ns.RefreshUI()
end

function ns.RefreshUI()
    clock:SetShown(ns.db.shown)
    if not ns.db.shown then
        for _, f in ipairs(popups) do f:Hide() end
    end
    PaintClock()
    for _, row in ipairs(painted) do row.Paint() end
end

function ns.ResetPosition()
    local db, p = ns.db, ns.defaultPosition
    db.point, db.relPoint, db.x, db.y = p.point, p.relPoint, p.x, p.y
    ApplyPosition()
end
