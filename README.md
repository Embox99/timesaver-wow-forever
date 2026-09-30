# QuickToggle

A tiny clock icon for **World of Warcraft: Forever** that switches three
quality-of-life automations on and off.

## Features

- **Auto loot** – takes everything from the loot window at once.
- **Auto accept quests** – accepts quests from NPCs, gossip menus, quest
  boards and escort quests shared by other players.
- **Auto turn in quests** – completes finished quests. If the quest offers a
  choice of rewards, it stops and lets you pick.
- **Hold Shift** while talking to an NPC or opening loot to skip the
  automation once.

The round clock icon can be dragged anywhere. Its ring turns gold while at
least one toggle is on.

- **Left click** – menu with the three toggles.
- **Right click** – settings: icon size, opacity, lock position, tooltip,
  reset position.
- Click outside or press Escape to close a menu.

Everything is saved between sessions.

## Commands

| Command | Action |
|---|---|
| `/qt` | Show or hide the icon |
| `/qt lock` | Lock or unlock the icon position |
| `/qt reset` | Move the icon back to the center of the screen |
| `/qt help` | Print the command list |

## Languages

English, Russian.

## Development

- The repository root is the addon folder. For local testing, link it into
  the game (run `cmd` as usual, adjust the game path):
  `mklink /J "<WoW>\_forever_beta_\Interface\AddOns\QuickToggle" "<this repo>"`
- `build.ps1` builds `dist\QuickToggle-<version>.zip` locally.
- Releases: update `CHANGELOG.md`, then push an annotated tag
  (`git tag -a v1.0.1 -m "v1.0.1"` and `git push --tags`). GitHub Actions runs
  the BigWigs packager, which uploads the zip to CurseForge and GitHub Releases.

## License

MIT
