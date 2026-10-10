local _, ns = ...

local L = {
    TITLE = "Timesaver",
    SETTINGS = "Settings",

    AUTO_LOOT = "Auto loot",
    AUTO_ACCEPT = "Accept quests",
    AUTO_TURN_IN = "Turn in quests",
    SELL_JUNK = "Sell junk",
    AUTO_REPAIR = "Auto repair",
    ACCEPT_INVITES = "Friend invites",
    DECLINE_DUELS = "Decline duels",
    DECLINE_GUILD = "Decline guild inv.",
    DECLINE_TRADES = "Decline trades",
    BEST_REWARD = "Best reward",
    MAIL_TAKE_ALL = "Mail: take all",
    MAIL_BUTTON = "Take all",
    BINDING_PREFIX = "Toggle: ",

    ICON_SIZE = "Icon size",
    OPACITY = "Opacity",
    SHOW_ICON = "Show clock icon",
    LOCK = "Lock position",
    TOOLTIP = "Show tooltip",
    RESET_POSITION = "Reset position",
    MENU_ITEMS = "Show in menu:",
    ALL_SETTINGS = "All settings...",
    KEYBINDINGS = "Fast bind",
    DESC_FAST_BIND = "Show the Fast bind row (opens key bindings) at the bottom of the clock menu.",
    RESET_BUTTON = "Reset",

    -- options page (Esc > Options > AddOns)
    SECTION_FEATURES = "Features",
    SECTION_MENU = "Show in clock menu",
    SECTION_ICON = "Clock icon",
    DESC_MENU = "List this feature in the clock menu. Hiding a feature also switches it off.",
    DESC_SHOW_ICON = "Hide it if you use the Titan Panel button. /tsv brings it back.",
    DESC = {
        autoLoot = "Loot everything when the loot window opens. Hold Shift to loot manually.",
        autoQuest = "Accept quests from NPCs, quest boards and escort quests. Hold Shift to read the quest first.",
        autoTurnIn = "Turn in finished quests. Stops when you have to choose a reward.",
        sellJunk = "Sell grey items when a vendor window opens. Hold Shift to skip.",
        autoRepair = "Repair everything at vendors who can repair. Hold Shift to skip.",
        acceptInvites = "Accept group invites from friends and guild members.",
        declineDuels = "Decline duels from players who are neither friends nor guild members.",
        declineGuild = "Decline guild invites from players who are not your friends.",
        declineTrades = "Cancel trades opened by players who are neither friends nor guild members.",
        bestReward = "When a quest offers a choice of rewards, take the one that sells for the most. Hold Shift to choose yourself.",
        mailTakeAll = "Adds a \"Take all\" button to the mailbox: collects money and items from all letters. Letters with COD are skipped.",
    },

    CHOSE_REWARD = "chose %s (sells for %s)",
    MAIL_DONE = "mail: collected %s and %d item(s)",
    MAIL_BAGS_FULL = "mail: bags are full",

    ON = "ON",
    OFF = "OFF",
    ALL_OFF = "Everything is off",
    HINT_ICON = "Left: menu   Right: settings   Drag: move",
    HINT_BROKER = "Left: menu   Right: settings",

    REPAIRED = "repaired for %s",
    NO_MONEY_REPAIR = "not enough money to repair (%s)",
    ACCEPTED_INVITE = "accepted group invite from %s",
    DECLINED_DUEL = "declined duel from %s",
    DECLINED_GUILD = "declined guild invite from %s (%s)",
    DECLINED_TRADE = "declined trade from %s",

    LOCKED = "icon locked",
    UNLOCKED = "icon unlocked",
    RESET = "position reset",
    HELP = "/tsv - show/hide icon,  /tsv options - settings,  /tsv lock - lock position,  /tsv reset - reset position",
}

if GetLocale() == "ruRU" then
    L.SETTINGS = "Настройки"

    L.AUTO_LOOT = "Автолут"
    L.AUTO_ACCEPT = "Принимать квесты"
    L.AUTO_TURN_IN = "Сдавать квесты"
    L.SELL_JUNK = "Продавать хлам"
    L.AUTO_REPAIR = "Авторемонт"
    L.ACCEPT_INVITES = "Инвайты друзей"
    L.DECLINE_DUELS = "Отказ: дуэли"
    L.DECLINE_GUILD = "Отказ: гильдии"
    L.DECLINE_TRADES = "Отказ: обмен"
    L.BEST_REWARD = "Лучшая награда"
    L.MAIL_TAKE_ALL = "Почта: забрать всё"
    L.MAIL_BUTTON = "Забрать всё"
    L.BINDING_PREFIX = "Переключить: "

    L.ICON_SIZE = "Размер иконки"
    L.OPACITY = "Видимость"
    L.SHOW_ICON = "Иконка часов"
    L.LOCK = "Закрепить"
    L.TOOLTIP = "Подсказка"
    L.RESET_POSITION = "Сбросить позицию"
    L.MENU_ITEMS = "Показывать в меню:"
    L.ALL_SETTINGS = "Все настройки..."
    L.KEYBINDINGS = "Fast bind"
    L.DESC_FAST_BIND = "Показывать внизу меню часов строку Fast bind (открывает назначение клавиш)."
    L.RESET_BUTTON = "Сбросить"

    L.SECTION_FEATURES = "Функции"
    L.SECTION_MENU = "Показывать в меню часов"
    L.SECTION_ICON = "Иконка часов"
    L.DESC_MENU = "Показывать функцию в меню часов. Скрытая функция заодно выключается."
    L.DESC_SHOW_ICON = "Можно скрыть, если пользуешься кнопкой в Titan Panel. Вернуть: /tsv"
    L.DESC = {
        autoLoot = "Забирать всю добычу при открытии окна лута. Shift: лутать вручную.",
        autoQuest = "Принимать квесты у НПС, с досок объявлений и сопровождения. Shift: сначала прочитать.",
        autoTurnIn = "Сдавать выполненные квесты. Останавливается, если нужно выбрать награду.",
        sellJunk = "Продавать серые вещи при открытии окна торговца. Shift: пропустить.",
        autoRepair = "Чинить всё у торговцев, которые умеют чинить. Shift: пропустить.",
        acceptInvites = "Принимать приглашения в группу от друзей и согильдийцев.",
        declineDuels = "Отклонять дуэли от тех, кто не друг и не согильдиец.",
        declineGuild = "Отклонять приглашения в гильдию не от друзей.",
        declineTrades = "Отменять обмен от тех, кто не друг и не согильдиец.",
        bestReward = "Если в квесте нужно выбрать награду, брать ту, что дороже продаётся. Shift: выбрать самому.",
        mailTakeAll = "Кнопка «Забрать всё» в почте: собирает деньги и вещи из всех писем. Письма с наложенным платежом пропускаются.",
    }

    L.CHOSE_REWARD = "выбрана награда %s (продаётся за %s)"
    L.MAIL_DONE = "почта: собрано %s и %d предм."
    L.MAIL_BAGS_FULL = "почта: сумки заполнены"

    L.ON = "ВКЛ"
    L.OFF = "ВЫКЛ"
    L.ALL_OFF = "Всё выключено"
    L.HINT_ICON = "ЛКМ: меню   ПКМ: настройки   Тянуть: двигать"
    L.HINT_BROKER = "ЛКМ: меню   ПКМ: настройки"

    L.REPAIRED = "ремонт за %s"
    L.NO_MONEY_REPAIR = "не хватает денег на ремонт (%s)"
    L.ACCEPTED_INVITE = "принято приглашение в группу от %s"
    L.DECLINED_DUEL = "отклонена дуэль от %s"
    L.DECLINED_GUILD = "отклонено приглашение в гильдию от %s (%s)"
    L.DECLINED_TRADE = "отклонён обмен от %s"

    L.LOCKED = "иконка закреплена"
    L.UNLOCKED = "иконка откреплена"
    L.RESET = "позиция сброшена"
    L.HELP = "/tsv - показать/скрыть,  /tsv options - настройки,  /tsv lock - закрепить,  /tsv reset - сбросить позицию"
end

ns.L = L
