local _, ns = ...

local L = {
    TITLE = "QuickToggle",
    AUTO_LOOT = "Auto loot",
    AUTO_ACCEPT = "Auto accept quests",
    AUTO_TURN_IN = "Auto turn in quests",
    ON = "ON",
    OFF = "OFF",
    HINT_MENU = "Shift: skip once  -  Drag clock: move",
    HINT_ICON = "Click: menu   Drag: move",
    LOCKED = "icon locked",
    UNLOCKED = "icon unlocked",
    RESET = "position reset",
    HELP = "/qt - show/hide icon,  /qt lock - lock position,  /qt reset - reset position",
}

if GetLocale() == "ruRU" then
    L.AUTO_LOOT = "Автолут"
    L.AUTO_ACCEPT = "Принимать квесты"
    L.AUTO_TURN_IN = "Сдавать квесты"
    L.ON = "ВКЛ"
    L.OFF = "ВЫКЛ"
    L.HINT_MENU = "Shift: пропустить  -  Тянуть часы: двигать"
    L.HINT_ICON = "Клик: меню   Тянуть: двигать"
    L.LOCKED = "иконка закреплена"
    L.UNLOCKED = "иконка откреплена"
    L.RESET = "позиция сброшена"
    L.HELP = "/qt - показать/скрыть,  /qt lock - закрепить,  /qt reset - сбросить позицию"
end

ns.L = L
