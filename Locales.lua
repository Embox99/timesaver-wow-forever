local _, ns = ...

local L = {
    TITLE = "Timesaver",
    SETTINGS = "Settings",

    AUTO_LOOT = "Auto loot",
    AUTO_ACCEPT = "Accept quests",
    SKIP_TRIVIAL = "Skip grey quests",
    AUTO_TURN_IN = "Turn in quests",
    BEST_REWARD = "Best reward",
    SKIP_GOSSIP = "Skip NPC chatter",
    SELL_JUNK = "Sell junk",
    AUTO_REPAIR = "Auto repair",
    MAIL_TAKE_ALL = "Mail: take all",
    BAG_WARNING = "Bags full warning",
    ACCEPT_INVITES = "Friend invites",
    ACCEPT_RES = "Friend res/summon",
    DECLINE_DUELS = "Decline duels",
    DECLINE_GUILD = "Decline guild inv.",
    DECLINE_TRADES = "Decline trades",
    MAIL_BUTTON = "Take all",
    BINDING_PREFIX = "Toggle: ",

    ICON_SIZE = "Icon size",
    OPACITY = "Opacity",
    SHOW_ICON = "Show clock icon",
    LOCK = "Lock position",
    TOOLTIP = "Show tooltip",
    SESSION_STATS = "Session stats",
    MINIMAP_BUTTON = "Minimap button",
    RESET_POSITION = "Reset position",
    MENU_ITEMS = "Show in menu:",
    ALL_SETTINGS = "All settings...",
    KEYBINDINGS = "Fast bind",
    ALL_KEYBINDINGS = "All key bindings...",
    PRESS_KEY = "press a key...",
    NOT_BOUND = "-",
    BIND_HINT = "Click a feature, press a key. Esc: cancel, Del: remove",
    BIND_SET = "%s: key %s",
    BIND_CLEARED = "%s: key removed",
    BIND_REPLACED = "%s was used for \"%s\" - reassigned",
    DESC_FAST_BIND = "Show the Fast bind row at the bottom of the clock menu: assign keys to features right there.",
    RESET_BUTTON = "Reset",

    -- options page (Esc > Options > AddOns)
    SECTION_FEATURES = "Features",
    SECTION_MENU = "Show in clock menu",
    SECTION_ICON = "Clock icon",
    DESC_MENU = "List this feature in the clock menu. Hiding a feature also switches it off.",
    DESC_SHOW_ICON = "Hide it if you use the minimap or Titan Panel button. /tsv brings it back.",
    DESC_STATS = "Show quests accepted and turned in, money from junk and repair costs of this session in the tooltip.",
    DESC_MINIMAP = "A button on the edge of the minimap with the same menus. Drag it around the minimap.",
    DESC = {
        autoLoot = "Loot everything when the loot window opens. Hold Shift to loot manually.",
        autoQuest = "Accept quests from NPCs, quest boards and escort quests. Hold Shift to read the quest first.",
        skipTrivial = "With \"Accept quests\" on: don't accept grey quests that are too low for your level.",
        autoTurnIn = "Turn in finished quests. Stops when you have to choose a reward.",
        bestReward = "When a quest offers a choice of rewards, take the one that sells for the most. Hold Shift to choose yourself.",
        skipGossip = "When an NPC has no quests and only one dialogue option (flight master, innkeeper), pick it. Hold Shift to skip.",
        sellJunk = "Sell grey items when a vendor window opens. Hold Shift to skip.",
        autoRepair = "Repair everything at vendors who can repair. Hold Shift to skip.",
        mailTakeAll = "Adds a \"Take all\" button to the mailbox: collects money and items from all letters. Letters with COD are skipped.",
        bagWarning = "Warn in chat and on screen when only 2 free bag slots are left.",
        acceptInvites = "Accept group invites from friends and guild members.",
        acceptRes = "Accept resurrections and summons from friends and guild members.",
        declineDuels = "Decline duels from players who are neither friends nor guild members.",
        declineGuild = "Decline guild invites from players who are not your friends.",
        declineTrades = "Cancel trades opened by players who are neither friends nor guild members.",
    },

    CHOSE_REWARD = "chose %s (sells for %s)",
    MAIL_DONE = "mail: collected %s and %d item(s)",
    MAIL_FAILED = "mail: %d item(s) could not be taken",
    MAIL_MORE = "mail: more letters are waiting - close and reopen the mailbox",
    MAIL_BAGS_FULL = "mail: bags are full",
    BAGS_LOW = "bags almost full: %d free slot(s) left",
    BAGS_FULL = "bags are full",

    ON = "ON",
    OFF = "OFF",
    ALL_OFF = "Everything is off",
    HINT_ICON = "Left: menu   Right: settings   Drag: move",
    HINT_BROKER = "Left: menu   Right: settings",
    HINT_MINIMAP = "Left: menu   Right: settings   Drag: move",
    STATS_TITLE = "This session",
    STATS_QUESTS = "Quests accepted / turned in",
    STATS_JUNK = "Junk sold",
    STATS_REPAIRS = "Repairs",

    REPAIRED = "repaired for %s",
    NO_MONEY_REPAIR = "not enough money to repair (%s)",
    ACCEPTED_INVITE = "accepted group invite from %s",
    ACCEPTED_RES = "accepted resurrection from %s",
    ACCEPTED_SUMMON = "accepted summon from %s",
    DECLINED_DUEL = "declined duel from %s",
    DECLINED_GUILD = "declined guild invite from %s (%s)",
    DECLINED_TRADE = "declined trade from %s",

    IN_COMBAT = "not available in combat",
    INTRO = "the clock icon is in the middle of the screen. Left click: features, right click: settings, drag to move. /tsv help for commands.",
    LOCKED = "icon locked",
    UNLOCKED = "icon unlocked",
    RESET = "position reset",
    HELP = "/tsv - show/hide icon,  /tsv options - settings,  /tsv lock - lock position,  /tsv reset - reset position",
}

if GetLocale() == "ruRU" then
    L.SETTINGS = "Настройки"

    L.AUTO_LOOT = "Автолут"
    L.AUTO_ACCEPT = "Принимать квесты"
    L.SKIP_TRIVIAL = "Без серых квестов"
    L.AUTO_TURN_IN = "Сдавать квесты"
    L.BEST_REWARD = "Лучшая награда"
    L.SKIP_GOSSIP = "Пропуск фраз НПС"
    L.SELL_JUNK = "Продавать хлам"
    L.AUTO_REPAIR = "Авторемонт"
    L.MAIL_TAKE_ALL = "Почта: забрать всё"
    L.BAG_WARNING = "Сумки почти полны"
    L.ACCEPT_INVITES = "Инвайты друзей"
    L.ACCEPT_RES = "Рес/призыв друзей"
    L.DECLINE_DUELS = "Отказ: дуэли"
    L.DECLINE_GUILD = "Отказ: гильдии"
    L.DECLINE_TRADES = "Отказ: обмен"
    L.MAIL_BUTTON = "Забрать всё"
    L.BINDING_PREFIX = "Переключить: "

    L.ICON_SIZE = "Размер иконки"
    L.OPACITY = "Видимость"
    L.SHOW_ICON = "Иконка часов"
    L.LOCK = "Закрепить"
    L.TOOLTIP = "Подсказка"
    L.SESSION_STATS = "Статистика сессии"
    L.MINIMAP_BUTTON = "Кнопка у миникарты"
    L.RESET_POSITION = "Сбросить позицию"
    L.MENU_ITEMS = "Показывать в меню:"
    L.ALL_SETTINGS = "Все настройки..."
    L.KEYBINDINGS = "Fast bind"
    L.ALL_KEYBINDINGS = "Все клавиши..."
    L.PRESS_KEY = "нажми клавишу..."
    L.NOT_BOUND = "-"
    L.BIND_HINT = "Клик по функции, затем клавиша. Esc: отмена, Del: убрать"
    L.BIND_SET = "%s: клавиша %s"
    L.BIND_CLEARED = "%s: клавиша убрана"
    L.BIND_REPLACED = "%s была назначена на «%s» - переназначена"
    L.DESC_FAST_BIND = "Показывать внизу меню часов строку Fast bind: назначать клавиши функциям прямо там."
    L.RESET_BUTTON = "Сбросить"

    L.SECTION_FEATURES = "Функции"
    L.SECTION_MENU = "Показывать в меню часов"
    L.SECTION_ICON = "Иконка часов"
    L.DESC_MENU = "Показывать функцию в меню часов. Скрытая функция заодно выключается."
    L.DESC_SHOW_ICON = "Можно скрыть, если пользуешься кнопкой у миникарты или в Titan Panel. Вернуть: /tsv"
    L.DESC_STATS = "Показывать в подсказке за эту сессию: принятые и сданные квесты, деньги с хлама и траты на ремонт."
    L.DESC_MINIMAP = "Кнопка на краю миникарты с теми же меню. Её можно перетаскивать по краю."
    L.DESC = {
        autoLoot = "Забирать всю добычу при открытии окна лута. Shift: лутать вручную.",
        autoQuest = "Принимать квесты у НПС, с досок объявлений и сопровождения. Shift: сначала прочитать.",
        skipTrivial = "Вместе с «Принимать квесты»: не брать серые квесты, слишком лёгкие для твоего уровня.",
        autoTurnIn = "Сдавать выполненные квесты. Останавливается, если нужно выбрать награду.",
        bestReward = "Если в квесте нужно выбрать награду, брать ту, что дороже продаётся. Shift: выбрать самому.",
        skipGossip = "Если у НПС нет квестов и всего одна фраза (распорядитель полётов, трактирщик), выбирать её. Shift: пропустить.",
        sellJunk = "Продавать серые вещи при открытии окна торговца. Shift: пропустить.",
        autoRepair = "Чинить всё у торговцев, которые умеют чинить. Shift: пропустить.",
        mailTakeAll = "Кнопка «Забрать всё» в почте: собирает деньги и вещи из всех писем. Письма с наложенным платежом пропускаются.",
        bagWarning = "Предупреждать в чате и на экране, когда в сумках остаётся 2 свободных места.",
        acceptInvites = "Принимать приглашения в группу от друзей и согильдийцев.",
        acceptRes = "Принимать воскрешение и призыв от друзей и согильдийцев.",
        declineDuels = "Отклонять дуэли от тех, кто не друг и не согильдиец.",
        declineGuild = "Отклонять приглашения в гильдию не от друзей.",
        declineTrades = "Отменять обмен от тех, кто не друг и не согильдиец.",
    }

    L.CHOSE_REWARD = "выбрана награда %s (продаётся за %s)"
    L.MAIL_DONE = "почта: собрано %s и %d предм."
    L.MAIL_FAILED = "почта: не удалось забрать %d предм."
    L.MAIL_MORE = "почта: есть ещё письма - закрой и снова открой почту"
    L.MAIL_BAGS_FULL = "почта: сумки заполнены"
    L.BAGS_LOW = "сумки почти полны: свободно %d"
    L.BAGS_FULL = "сумки заполнены"

    L.ON = "ВКЛ"
    L.OFF = "ВЫКЛ"
    L.ALL_OFF = "Всё выключено"
    L.HINT_ICON = "ЛКМ: меню   ПКМ: настройки   Тянуть: двигать"
    L.HINT_BROKER = "ЛКМ: меню   ПКМ: настройки"
    L.HINT_MINIMAP = "ЛКМ: меню   ПКМ: настройки   Тянуть: двигать"
    L.STATS_TITLE = "За эту сессию"
    L.STATS_QUESTS = "Квесты принято / сдано"
    L.STATS_JUNK = "Хлам продан на"
    L.STATS_REPAIRS = "Ремонт"

    L.REPAIRED = "ремонт за %s"
    L.NO_MONEY_REPAIR = "не хватает денег на ремонт (%s)"
    L.ACCEPTED_INVITE = "принято приглашение в группу от %s"
    L.ACCEPTED_RES = "принято воскрешение от %s"
    L.ACCEPTED_SUMMON = "принят призыв от %s"
    L.DECLINED_DUEL = "отклонена дуэль от %s"
    L.DECLINED_GUILD = "отклонено приглашение в гильдию от %s (%s)"
    L.DECLINED_TRADE = "отклонён обмен от %s"

    L.IN_COMBAT = "недоступно в бою"
    L.INTRO = "иконка часов в центре экрана. ЛКМ: функции, ПКМ: настройки, тяни, чтобы переместить. /tsv help - команды."
    L.LOCKED = "иконка закреплена"
    L.UNLOCKED = "иконка откреплена"
    L.RESET = "позиция сброшена"
    L.HELP = "/tsv - показать/скрыть,  /tsv options - настройки,  /tsv lock - закрепить,  /tsv reset - сбросить позицию"
end

ns.L = L
