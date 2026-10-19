-- Page in the game's own options: Esc > Options > AddOns > Timesaver.
-- Built from the same settings as the clock menus; every change goes through
-- the same functions, so both stay in sync.
local _, ns = ...
local L = ns.L

local category
local variables = {}  -- every registered setting, refreshed by ns.NotifyOptions
local applying = false -- a change made on this page is being applied

local function Var(id)
    return "Timesaver_" .. id
end

-- runs a change coming from the page itself; the page already shows it
local function Apply(fn, value)
    applying = true
    local ok, err = pcall(fn, value)
    applying = false
    if not ok then geterrorhandler()(err) end
end

local function Register(cat, id, varType, name, default, get, set)
    local variable = Var(id)
    variables[#variables + 1] = variable
    return Settings.RegisterProxySetting(cat, variable, varType, name, default,
        get, function(value) Apply(set, value) end)
end

local function AddCheckbox(cat, id, name, tooltip, default, get, set)
    local setting = Register(cat, id, Settings.VarType.Boolean, name, default, get, set)
    Settings.CreateCheckbox(cat, setting, tooltip)
end

-- checkbox for a plain on/off value in ns.db
local function AddDBCheckbox(cat, key, name, tooltip)
    AddCheckbox(cat, key, name, tooltip, ns.defaults[key],
        function() return ns.db[key] end,
        function(value)
            if ns.db[key] ~= value then ns.Toggle(key) end
        end)
end

local function AddSlider(cat, key, name, tooltip, min, max, step, suffix)
    local setting = Register(cat, key, Settings.VarType.Number, name, ns.defaults[key],
        function() return ns.db[key] end,
        function(value)
            -- sliders can report 21.9999; keep whole steps
            value = min + math.floor((value - min) / step + 0.5) * step
            ns.db[key] = math.min(max, math.max(min, value))
            ns.RefreshUI()
        end)
    local options = Settings.CreateSliderOptions(min, max, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
        function(value) return math.floor(value + 0.5) .. suffix end)
    Settings.CreateSlider(cat, setting, options, tooltip)
end

local function AddHeader(layout, text)
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
end

function ns.InitOptions()
    if not (Settings and Settings.RegisterVerticalLayoutCategory) then return end
    local cat, layout = Settings.RegisterVerticalLayoutCategory(L.TITLE)

    AddHeader(layout, L.SECTION_FEATURES)
    for _, t in ipairs(ns.toggles) do
        AddDBCheckbox(cat, t.key, t.label, L.DESC[t.key])
    end

    AddHeader(layout, L.SECTION_MENU)
    for _, t in ipairs(ns.toggles) do
        AddCheckbox(cat, "menu_" .. t.key, t.label, L.DESC_MENU, true,
            function() return not ns.db.hidden[t.key] end,
            function(value) ns.SetHidden(t.key, not value) end)
    end
    AddCheckbox(cat, "menu_fastBind", L.KEYBINDINGS, L.DESC_FAST_BIND, true,
        ns.IsFastBindShown, ns.SetFastBindShown)

    AddHeader(layout, L.SECTION_ICON)
    AddDBCheckbox(cat, "shown", L.SHOW_ICON, L.DESC_SHOW_ICON)
    AddDBCheckbox(cat, "locked", L.LOCK, nil)
    AddDBCheckbox(cat, "tooltip", L.TOOLTIP, nil)
    AddDBCheckbox(cat, "stats", L.SESSION_STATS, L.DESC_STATS)
    AddDBCheckbox(cat, "minimap", L.MINIMAP_BUTTON, L.DESC_MINIMAP)
    AddSlider(cat, "size", L.ICON_SIZE, nil, 16, 40, 2, " px")
    AddSlider(cat, "alpha", L.OPACITY, nil, 30, 100, 10, "%")
    layout:AddInitializer(CreateSettingsButtonInitializer(L.RESET_POSITION,
        L.RESET_BUTTON, function() ns.ResetPosition() end, nil, true))

    Settings.RegisterAddOnCategory(cat)
    category = cat
end

-- Changes made in the clock menus, by key or by command: refresh the
-- checkboxes and sliders here in case the page is open right now.
function ns.NotifyOptions()
    if applying or not category or not Settings.NotifyUpdate then return end
    for _, variable in ipairs(variables) do
        Settings.NotifyUpdate(variable)
    end
end

-- the game's key binding screen (the Timesaver section is under AddOns)
function ns.OpenKeybindings()
    if not ns.CanOpenWindows() then return end
    if Settings and Settings.KEYBINDINGS_CATEGORY_ID then
        Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID)
    elseif KeyBindingFrame_LoadUI then
        KeyBindingFrame_LoadUI()
        ShowUIPanel(KeyBindingFrame)
    end
end

function ns.OpenOptions()
    if not category or not ns.CanOpenWindows() then return end
    Settings.OpenToCategory(category:GetID())
end
