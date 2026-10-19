# Changelog

## 1.1.0

New:
- Fast bind opens its own window: click a feature, press a key, done
  (Esc cancels, Del removes the key). "All key bindings..." still opens
  the game screen.

New (all off by default):
- Minimap button with the same menus; drag it around the minimap.
- Skip grey quests when accepting quests automatically.
- Skip NPC chatter: picks the only dialogue option of NPCs without quests.
- Accept resurrections and summons from friends and guild members.
- Warning when the bags are almost full.
- Session statistics in the tooltip: quests, money from junk, repairs.
- One-time hint on first login; version number in the tooltip and /tsv help.

Fixes:
- Mail "Take all" no longer gets stuck on an item that can't be taken; it
  skips it and reports it. The item counter is now exact.
- Mail: tells you when more letters are waiting than the inbox shows.
- Junk is sold in batches, so nothing is left behind with many grey items.
- Repairs wait until the junk is sold, so its money counts.
- Quest accepting no longer depends on a function that may be missing.
- Options page: sliders keep whole steps; checkboxes follow changes made
  in the clock menu while the page is open.
- Options and key bindings can't be opened in combat (the game blocks them).
- An error in one part of the addon no longer stops the others.

## 1.0.0

- First public release for WoW Forever (interface 16001).
- Movable round clock icon with its own texture; left click opens the
  feature menu, right click the quick settings.
- Features: auto loot, accept quests, turn in quests, best reward, sell junk,
  auto repair, mail "Take all", friend invites, decline duels / guild
  invites / trades from strangers.
- Hold Shift to skip automation once.
- Options page in the game settings, key bindings for every feature,
  Titan Panel / LibDataBroker button.
- Features can be hidden from the menu.
- English and Russian localization.
