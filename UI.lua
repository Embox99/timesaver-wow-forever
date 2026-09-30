-- Clock icon (20x20) and the toggle menu it opens.
local _, ns = ...
local L = ns.L

local ICON = "Interface\\Icons\\INV_Misc_PocketWatch_01"
local CHECK_ON = "Interface\\RaidFrame\\ReadyCheck-Ready"
local CHECK_OFF = "Interface\\RaidFrame\\ReadyCheck-NotReady"
local ICON_CROP = { 0.08, 0.92, 0.08, 0.92 }

local GOLD = { 1, 0.82, 0 }
local BORDER_GOLD = { 0.8, 0.65, 0.2 }
local GREEN = { 0.25, 1, 0.25 }
local RED = { 1, 0.3, 0.3 }
local WHITE = { 1, 1, 1 }
local GREY = { 0.6, 0.6, 0.6 }

local ICON_SIZE = 20
local MENU_WIDTH = 196
local ROW_HEIGHT = 20
local HEADER_HEIGHT = 34
local FOOTER_HEIGHT = 30

local clock, menu
local rows = {}

-- ---------------------------------------------------------------- clock

local function CreateClock()
    local f = CreateFrame("Button", "QuickToggleIcon", UIParent)
    f:SetSize(ICON_SIZE, ICON_SIZE)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:RegisterForClicks("LeftButtonUp")

    -- 1px frame around the icon: gold while anything is on, grey otherwise
    f.border = f:CreateTexture(nil, "BACKGROUND")
    f.border:SetAllPoints()

    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetPoint("TOPLEFT", 1, -1)
    f.icon:SetPoint("BOTTOMRIGHT", -1, 1)
    f.icon:SetTexture(ICON)
    f.icon:SetTexCoord(unpack(ICON_CROP))

    f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    return f
end

local function PaintClock()
    if ns.AnyEnabled() then
        clock.border:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 1)
        clock.icon:SetDesaturated(false)
    else
        clock.border:SetColorTexture(0.25, 0.25, 0.25, 1)
        clock.icon:SetDesaturated(true)
    end
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

-- ---------------------------------------------------------------- menu

local function AddSeparator(parent, y)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(BORDER_GOLD[1], BORDER_GOLD[2], BORDER_GOLD[3], 0.35)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 8, y)
    line:SetPoint("TOPRIGHT", -8, y)
end

local function PaintRow(row)
    local on = ns.db[row.key]
    local text = on and WHITE or GREY
    local state = on and GREEN or RED
    row.check:SetTexture(on and CHECK_ON or CHECK_OFF)
    row.label:SetTextColor(text[1], text[2], text[3])
    row.state:SetText(on and L.ON or L.OFF)
    row.state:SetTextColor(state[1], state[2], state[3])
end

local function CreateRow(parent, index, toggle)
    local y = -HEADER_HEIGHT - (index - 1) * ROW_HEIGHT
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", 6, y)
    row:SetPoint("TOPRIGHT", -6, y)
    row.key = toggle.key

    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.12)

    row.check = row:CreateTexture(nil, "ARTWORK")
    row.check:SetSize(14, 14)
    row.check:SetPoint("LEFT", 6, 0)

    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.label:SetPoint("LEFT", row.check, "RIGHT", 7, 0)
    row.label:SetText(toggle.label)

    row.state = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.state:SetPoint("RIGHT", -6, 0)

    row:SetScript("OnClick", function() ns.Toggle(row.key) end)
    return row
end

local function CreateMenu()
    local f = CreateFrame("Frame", "QuickToggleMenu", UIParent, "BackdropTemplate")
    f:SetSize(MENU_WIDTH, HEADER_HEIGHT + ROW_HEIGHT * #ns.toggles + FOOTER_HEIGHT)
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
    -- Escape closes the menu
    tinsert(UISpecialFrames, f:GetName())

    local titleIcon = f:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(16, 16)
    titleIcon:SetPoint("TOPLEFT", 10, -9)
    titleIcon:SetTexture(ICON)
    titleIcon:SetTexCoord(unpack(ICON_CROP))

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleIcon, "RIGHT", 6, 0)
    title:SetText(L.TITLE)

    AddSeparator(f, -30)
    for i, t in ipairs(ns.toggles) do
        rows[i] = CreateRow(f, i, t)
    end
    AddSeparator(f, -HEADER_HEIGHT - ROW_HEIGHT * #ns.toggles - 4)

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("BOTTOM", 0, 10)
    hint:SetText(L.HINT_MENU)
    return f
end

-- open towards the middle of the screen so the menu never hides off-edge
local function PlaceMenu()
    local x, y = clock:GetCenter()
    local vertical, anchorV, dy = "BOTTOM", "TOP", 4
    if y > UIParent:GetHeight() / 2 then
        vertical, anchorV, dy = "TOP", "BOTTOM", -4
    end
    local side = x > UIParent:GetWidth() / 2 and "RIGHT" or "LEFT"
    menu:ClearAllPoints()
    menu:SetPoint(vertical .. side, clock, anchorV .. side, 0, dy)
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

local function SetupScripts()
    clock:SetScript("OnDragStart", function(self)
        if ns.db.locked then return end
        menu:Hide()
        GameTooltip:Hide()
        self:StartMoving()
    end)
    clock:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    clock:SetScript("OnClick", function()
        GameTooltip:Hide()
        menu:SetShown(not menu:IsShown())
    end)
    clock:SetScript("OnEnter", function()
        if not menu:IsShown() then ShowClockTooltip() end
    end)
    clock:SetScript("OnLeave", GameTooltip_Hide)

    -- a click anywhere outside the menu and the clock closes the menu
    menu:SetScript("OnShow", function(self)
        PlaceMenu()
        self:RegisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    menu:SetScript("OnHide", function(self)
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    menu:SetScript("OnEvent", function(self)
        if not self:IsMouseOver() and not clock:IsMouseOver() then
            self:Hide()
        end
    end)
end

-- ---------------------------------------------------------------- API used by Core.lua

function ns.InitUI()
    clock = CreateClock()
    menu = CreateMenu()
    SetupScripts()
    ApplyPosition()
    ns.RefreshUI()
end

function ns.RefreshUI()
    clock:SetShown(ns.db.shown)
    if not ns.db.shown then menu:Hide() end
    PaintClock()
    for _, row in ipairs(rows) do PaintRow(row) end
end

function ns.ResetPosition()
    local db, p = ns.db, ns.defaultPosition
    db.point, db.relPoint, db.x, db.y = p.point, p.relPoint, p.x, p.y
    ApplyPosition()
end
