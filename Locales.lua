local _, ns = ...

local L = {
    TITLE = "QuickToggle",
    SETTINGS = "Settings",
    AUTO_LOOT = "Auto loot",
    AUTO_ACCEPT = "Auto accept quests",
    AUTO_TURN_IN = "Auto turn in quests",
    ICON_SIZE = "Icon size",
    OPACITY = "Opacity",
    LOCK = "Lock position",
    TOOLTIP = "Show tooltip",
    RESET_POSITION = "Reset position",
    ON = "ON",
    OFF = "OFF",
    HINT_MENU = "Shift: skip once  -  Right click: settings",
    HINT_SETTINGS = "/qt help - chat commands",
    HINT_ICON = "Left: menu   Right: settings   Drag: move",
    LOCKED = "icon locked",
    UNLOCKED = "icon unlocked",
    RESET = "position reset",
    HELP = "/qt - show/hide icon,  /qt lock - lock position,  /qt reset - reset position",
}

if GetLocale() == "ruRU" then
    L.SETTINGS = "Настройки"
    L.AUTO_LOOT = "Автолут"
    L.AUTO_ACCEPT = "Принимать квесты"
    L.AUTO_TURN_IN = "Сдавать квесты"
    L.ICON_SIZE = "Размер иконки"
    L.OPACITY = "Видимость"
    L.LOCK = "Закрепить"
    L.TOOLTIP = "Подсказка"
    L.RESET_POSITION = "Сбросить позицию"
    L.ON = "ВКЛ"
    L.OFF = "ВЫКЛ"
    L.HINT_MENU = "Shift: пропустить  -  ПКМ: настройки"
    L.HINT_SETTINGS = "/qt help - команды чата"
    L.HINT_ICON = "ЛКМ: меню   ПКМ: настройки   Тянуть: двигать"
    L.LOCKED = "иконка закреплена"
    L.UNLOCKED = "иконка откреплена"
    L.RESET = "позиция сброшена"
    L.HELP = "/qt - показать/скрыть,  /qt lock - закрепить,  /qt reset - сбросить позицию"
end

ns.L = L
