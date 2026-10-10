-- Round clock icon, the toggle menu (left click) and the settings menu (right click).
-- Both menus can also be opened from a Titan Panel / LDB button (Broker.lua).
-- Menu style: flat dark panel, an icon per feature, a glowing dot for "on".
local ADDON, ns = ...
local L = ns.L

-- own round clock texture, drawn by tools\render-icon.ps1
local ICON = "Interface\\AddOns\\" .. ADDON .. "\\Media\\icon"
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local KEYS_ICON = "Interface\\Icons\\INV_Misc_Key_03"
local ICON_CROP = { 0.08, 0.92, 0.08, 0.92 }
ns.ICON = ICON

-- clock
local GOLD = { 1, 0.82, 0 }
local RING_OFF = { 0.3, 0.3, 0.3 }
-- tooltip
local GREEN = { 0.25, 1, 0.25 }
local GREY = { 0.6, 0.6, 0.6 }
-- menus
local PANEL_BG = { 0.055, 0.055, 0.07, 0.92 }
local PANEL_EDGE = { 1, 1, 1, 0.08 }
local TITLE_COLOR = { 0.79, 0.65, 0.29 }
local TEXT_ON = { 0.9, 0.9, 0.9 }
local TEXT_OFF = { 0.5, 0.5, 0.5 }
local DOT_ON = { 0.3, 0.85, 0.4 }
local DOT_OFF = { 0.33, 0.33, 0.33 }
local OFF_ALPHA = 0.45

local MENU_WIDTH = 196
local PAD_X = 12
local HEADER_HEIGHT = 24
local FOOTER_HEIGHT = 6
local ROW_HEIGHT = 22
local SMALL_ROW_HEIGHT = 18
local CAPTION_HEIGHT = 24
local DIVIDER_HEIGHT = 9
local ROW_ICON = 16
local SMALL_ROW_ICON = 14

local clock, menu, settings
local popups = {}   -- only one popup is open at a time
local painted = {}  -- rows repainted by ns.RefreshUI

local function SetColor(texture, c, alpha)
    texture:SetColorTexture(c[1], c[2], c[3], alpha or c[4] or 1)
end

local function CircleMask(parent)
    local mask = parent:CreateMaskTexture()
    mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    return mask
end

-- "INV_Misc_Bag_10" -> Interface\Icons\..., full paths stay as they are
local function IconPath(icon)
    if string.find(icon, "\\", 1, true) then return icon end
    return "Interface\\Icons\\" .. icon
end

-- ---------------------------------------------------------------- clock

local function CreateClock()
    local f = CreateFrame("Button", "TimesaverIcon", UIParent)
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

-- shared by the clock and the Titan/LDB button
function ns.FillTooltip(tooltip, hint)
    tooltip:SetText(L.TITLE)
    -- only what is switched on, to keep the tooltip short
    if ns.AnyEnabled() then
        for _, t in ipairs(ns.toggles) do
            if ns.db[t.key] then
                tooltip:AddDoubleLine(t.label, L.ON, 1, 1, 1, GREEN[1], GREEN[2], GREEN[3])
            end
        end
    else
        tooltip:AddLine(L.ALL_OFF, GREY[1], GREY[2], GREY[3])
    end
    tooltip:AddLine(hint, 0.7, 0.7, 0.7)
end

-- ---------------------------------------------------------------- popup frame

local function CreateLine(parent)
    local line = parent:CreateTexture(nil, "ARTWORK")
    SetColor(line, PANEL_EDGE)
    line:SetHeight(1)
    return line
end

-- Open towards the middle of the screen so a popup never hides off-edge.
-- Works for the clock and for buttons on other bars (other UI scale).
local function PlacePopup(f)
    local anchor = f.anchor or clock
    local x, y = anchor:GetCenter()
    local scale = anchor:GetEffectiveScale() / UIParent:GetEffectiveScale()
    x, y = x * scale, y * scale
    local vertical, anchorV, dy = "BOTTOM", "TOP", 4
    if y > UIParent:GetHeight() / 2 then
        vertical, anchorV, dy = "TOP", "BOTTOM", -4
    end
    local side = x > UIParent:GetWidth() / 2 and "RIGHT" or "LEFT"
    f:ClearAllPoints()
    f:SetPoint(vertical .. side, anchor, anchorV .. side, 0, dy)
end

-- Items are stacked top to bottom; hidden items take no space.
local function Layout(f)
    local y = -HEADER_HEIGHT
    for _, item in ipairs(f.items) do
        local visible = not item.isVisible or item.isVisible()
        item.frame:SetShown(visible)
        if visible then
            item.frame:ClearAllPoints()
            item.frame:SetPoint("TOPLEFT", 1, y)
            item.frame:SetPoint("TOPRIGHT", -1, y)
            item.frame:SetHeight(item.height)
            y = y - item.height
        end
    end
    f:SetHeight(-y + FOOTER_HEIGHT)
end

local function AddItem(f, frame, height, isVisible)
    f.items[#f.items + 1] = { frame = frame, height = height, isVisible = isVisible }
end

local function CreatePopup(name, title)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetWidth(MENU_WIDTH)
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:Hide()
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(PANEL_BG[1], PANEL_BG[2], PANEL_BG[3], PANEL_BG[4])
    f:SetBackdropBorderColor(PANEL_EDGE[1], PANEL_EDGE[2], PANEL_EDGE[3], PANEL_EDGE[4])
    -- Escape closes the popup
    tinsert(UISpecialFrames, name)
    f.items = {}

    -- soft shadow: a slightly bigger dark frame drawn behind the panel
    local shadow = CreateFrame("Frame", nil, f)
    shadow:SetFrameLevel(math.max(0, f:GetFrameLevel() - 1))
    shadow:SetPoint("TOPLEFT", -3, 3)
    shadow:SetPoint("BOTTOMRIGHT", 3, -4)
    local shade = shadow:CreateTexture(nil, "BACKGROUND")
    shade:SetAllPoints()
    shade:SetColorTexture(0, 0, 0, 0.35)

    local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("TOPLEFT", PAD_X, -9)
    text:SetText(title)
    text:SetTextColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3])

    f:SetScript("OnShow", function(self)
        for _, other in ipairs(popups) do
            if other ~= self then other:Hide() end
        end
        Layout(self)
        PlacePopup(self)
        self:RegisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    f:SetScript("OnHide", function(self)
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    -- a click anywhere outside the popup and the button that opened it closes it
    f:SetScript("OnEvent", function(self)
        local anchor = self.anchor or clock
        if not self:IsMouseOver() and not anchor:IsMouseOver() then
            self:Hide()
        end
    end)

    popups[#popups + 1] = f
    return f
end

-- ---------------------------------------------------------------- rows

-- opts.icon: icon name or path; opts.small: shorter row, smaller icon/text;
-- opts.isVisible: function deciding whether the row is listed at all
local function CreateRow(f, clickable, opts)
    opts = opts or {}
    local row = CreateFrame(clickable and "Button" or "Frame", nil, f)
    AddItem(f, row, opts.small and SMALL_ROW_HEIGHT or ROW_HEIGHT, opts.isVisible)

    if clickable then
        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(1, 1, 1, 0.06)
    end

    local labelX = PAD_X
    if opts.icon then
        local size = opts.small and SMALL_ROW_ICON or ROW_ICON
        local path = IconPath(opts.icon)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(size, size)
        row.icon:SetPoint("LEFT", PAD_X, 0)
        row.icon:SetTexture(path)
        -- real icons get their border cropped; the quest glyphs are used whole
        if string.find(path, "Interface\\Icons\\", 1, true) then
            row.icon:SetTexCoord(unpack(ICON_CROP))
        end
        labelX = PAD_X + size + 9
    end

    row.label = row:CreateFontString(nil, "OVERLAY",
        opts.small and "GameFontHighlightSmall" or "GameFontHighlight")
    row.label:SetPoint("LEFT", labelX, 0)
    row.label:SetTextColor(TEXT_ON[1], TEXT_ON[2], TEXT_ON[3])
    return row
end

-- small round status light on the right, with a soft glow while on
local function CreateDot(row, small)
    local size = small and 6 or 8
    local dot = row:CreateTexture(nil, "ARTWORK")
    dot:SetSize(size, size)
    dot:SetPoint("RIGHT", -PAD_X, 0)
    local mask = CircleMask(row)
    mask:SetAllPoints(dot)
    dot:AddMaskTexture(mask)

    local glow = row:CreateTexture(nil, "BORDER")
    glow:SetSize(size * 2, size * 2)
    glow:SetPoint("CENTER", dot)
    local glowMask = CircleMask(row)
    glowMask:SetAllPoints(glow)
    glow:AddMaskTexture(glowMask)
    SetColor(glow, DOT_ON, 0.3)

    return dot, glow
end

-- [icon] Label ............ (•)
local function CreateToggleRow(f, label, get, set, opts)
    local row = CreateRow(f, true, opts)
    row.label:SetText(label)
    row.dot, row.glow = CreateDot(row, opts and opts.small)

    function row.Paint()
        local on = get()
        SetColor(row.dot, on and DOT_ON or DOT_OFF)
        row.glow:SetShown(on)
        local text = on and TEXT_ON or TEXT_OFF
        row.label:SetTextColor(text[1], text[2], text[3])
        if row.icon then
            row.icon:SetDesaturated(not on)
            row.icon:SetAlpha(on and 1 or OFF_ALPHA)
        end
    end

    row:SetScript("OnClick", set)
    painted[#painted + 1] = row
    return row
end

-- toggle row for a plain on/off setting in ns.db
local function CreateSettingRow(f, label, key)
    return CreateToggleRow(f, label,
        function() return ns.db[key] end,
        function() ns.Toggle(key) end)
end

local function CreateStepButton(row, text)
    local b = CreateFrame("Button", nil, row)
    b:SetSize(16, 16)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("CENTER", 0, 1)
    b.text:SetText(text)
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.1)
    return b
end

-- Label ........ -  20 px  +
local function CreateStepperRow(f, label, key, min, max, step, format)
    local row = CreateRow(f, false)
    row.label:SetText(label)

    row.plus = CreateStepButton(row, "+")
    row.plus:SetPoint("RIGHT", -PAD_X + 4, 0)
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
        local c = enabled and TITLE_COLOR or DOT_OFF
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
local function CreateActionRow(f, label, onClick, opts)
    local row = CreateRow(f, true, opts)
    row.label:SetText(label)
    row:SetScript("OnClick", onClick)
    return row
end

-- thin line between groups of rows
local function CreateDivider(f, isVisible)
    local row = CreateFrame("Frame", nil, f)
    AddItem(f, row, DIVIDER_HEIGHT, isVisible)
    local line = CreateLine(row)
    line:SetPoint("LEFT", PAD_X, 0)
    line:SetPoint("RIGHT", -PAD_X, 0)
    return row
end

-- thin line with a small caption under it
local function CreateCaption(f, text)
    local row = CreateFrame("Frame", nil, f)
    AddItem(f, row, CAPTION_HEIGHT)
    local line = CreateLine(row)
    line:SetPoint("TOPLEFT", PAD_X, -4)
    line:SetPoint("TOPRIGHT", -PAD_X, -4)
    local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOMLEFT", PAD_X, 3)
    label:SetText(text)
    label:SetTextColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3])
    return row
end

-- ---------------------------------------------------------------- popups

local function CreateToggleMenu()
    local f = CreatePopup("TimesaverMenu", L.TITLE)
    for _, t in ipairs(ns.toggles) do
        CreateToggleRow(f, t.label,
            function() return ns.db[t.key] end,
            function() ns.Toggle(t.key) end,
            { icon = t.icon, isVisible = function() return ns.IsInMenu(t) end })
    end
    CreateDivider(f, ns.IsFastBindShown)
    CreateActionRow(f, L.KEYBINDINGS, function()
        f:Hide()
        ns.OpenKeybindings()
    end, { icon = KEYS_ICON, isVisible = ns.IsFastBindShown })
    return f
end

local function CreateSettingsMenu()
    local f = CreatePopup("TimesaverSettings", L.SETTINGS)
    CreateStepperRow(f, L.ICON_SIZE, "size", 16, 40, 2, "%d px")
    CreateStepperRow(f, L.OPACITY, "alpha", 30, 100, 10, "%d%%")
    CreateSettingRow(f, L.SHOW_ICON, "shown")
    CreateSettingRow(f, L.LOCK, "locked")
    CreateSettingRow(f, L.TOOLTIP, "tooltip")
    CreateActionRow(f, L.RESET_POSITION, function()
        ns.ResetPosition()
        PlacePopup(f)
    end)
    CreateActionRow(f, L.ALL_SETTINGS, function()
        f:Hide()
        ns.OpenOptions()
    end)

    -- which features are listed in the main menu
    CreateCaption(f, L.MENU_ITEMS)
    for _, t in ipairs(ns.toggles) do
        CreateToggleRow(f, t.label,
            function() return not ns.db.hidden[t.key] end,
            function() ns.SetHidden(t.key, not ns.db.hidden[t.key]) end,
            { icon = t.icon, small = true })
    end
    CreateToggleRow(f, L.KEYBINDINGS, ns.IsFastBindShown,
        function() ns.SetFastBindShown(not ns.IsFastBindShown()) end,
        { icon = KEYS_ICON, small = true })
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

local function HideClockPopups()
    for _, f in ipairs(popups) do
        if (f.anchor or clock) == clock then f:Hide() end
    end
end

local function SetupClockScripts()
    clock:SetScript("OnDragStart", function(self)
        if ns.db.locked then return end
        HideClockPopups()
        GameTooltip:Hide()
        self:StartMoving()
    end)
    clock:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    clock:SetScript("OnClick", function(self, button)
        GameTooltip:Hide()
        ns.TogglePopup(button == "RightButton" and "settings" or "menu", self)
    end)
    clock:SetScript("OnEnter", function(self)
        if not ns.db.tooltip or AnyPopupShown() then return end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        ns.FillTooltip(GameTooltip, L.HINT_ICON)
        GameTooltip:Show()
    end)
    clock:SetScript("OnLeave", GameTooltip_Hide)
end

-- ---------------------------------------------------------------- API

function ns.InitUI()
    clock = CreateClock()
    menu = CreateToggleMenu()
    settings = CreateSettingsMenu()
    SetupClockScripts()
    ApplyPosition()
    ns.RefreshUI()
end

-- which: "menu" or "settings"; anchor: the button that was clicked
function ns.TogglePopup(which, anchor)
    local f = which == "settings" and settings or menu
    if f:IsShown() and f.anchor == anchor then
        f:Hide()
        return
    end
    f.anchor = anchor
    if f:IsShown() then
        PlacePopup(f)
    else
        f:Show()
    end
end

function ns.RefreshUI()
    clock:SetShown(ns.db.shown)
    if not ns.db.shown then HideClockPopups() end
    PaintClock()
    for _, row in ipairs(painted) do row.Paint() end
    for _, f in ipairs(popups) do
        if f:IsShown() then Layout(f) end
    end
    ns.UpdateMailButton()
end

function ns.ResetPosition()
    local db, p = ns.db, ns.defaultPosition
    db.point, db.relPoint, db.x, db.y = p.point, p.relPoint, p.x, p.y
    ApplyPosition()
end
