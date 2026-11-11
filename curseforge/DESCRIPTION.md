# SexyHarvester

**Everything you gather, at a glance.**

SexyHarvester shows every gathering material in your bags (herbs, ore, leather and cloth) with its current count and a green **+N** for how much you picked up in this session. It stays out of the way when your bags hold nothing to show and appears by itself as soon as you gather.

Built for **World of Warcraft: Forever**. Styled like the rest of the Sexy addons: dark brown panel, gold frame, title band with a badge, card rows and colored labels.

## Features

- **Detects materials by itself** - herbs, ore, leather and cloth are recognised through the item subtype, there is no fixed item list. New materials just work.
- **Count and session counter** - the amount in your bags plus a green **+N** label for what you gathered since login (or since the last reset).
- **Three views** - switch with one option:
  - **Compact** - one card per material with icon, count and session label.
  - **As row** - materials side by side, count under the icon.
  - **With names and profession groups** - group rows for Herbs, Ore, Leather and Cloth with a total, then icon, name, count and session label, plus a **Reset session** button.
- **Title band with a badge** - the badge shows everything you gathered this session.
- **Item tooltips** - hover an icon to see the normal item tooltip.
- **Edit Mode** - move and scale the window with Blizzard's own Edit Mode. All options live there.
- **English and German** localization.

## Settings (Esc > Edit Mode > select "Professions")

| Option | Effect |
|---|---|
| Position, clamp to screen, size (50 - 200 %) | Placement and scale of the window |
| Icon layout | Compact, as row, or with names and profession groups |
| Growth direction | Down, up, right or left |
| Count position | On the icon (center and four corners) or outside it (right, left, above, below), in the compact view |
| Hide title / count / session counter | Turn single parts off |
| Background, border, icon border | Dark brown quest look (default), plus the older black, gray, parchment, tooltip and gold styles |
| Font and font size | Marcellus + Inter (default) or one of the game fonts, size 8 - 24 |

## Slash commands

| Command | Description |
|---|---|
| `/sh reset` | Reset the session counter (the **+N** labels) |
| `/sh debug` | Print the raw bag data and the window state to chat (for troubleshooting) |
| `/sh` | Show the command list |

Long form: `/sexyharvester`

## Notes

- The session counter starts at your login. Items you already carry when you log in count as the baseline, not as gathered.
- The window hides itself when no gathering material is in your bags.
- Equippable leather armor is ignored. Only real materials are counted.
- Fonts: Marcellus and Inter are bundled (SIL Open Font License). Russian, Korean and Chinese clients keep the game font.
- If you hit a Lua error, please report it via the issue tracker with the exact message.

## Credits

- [EditModeExpanded](https://github.com/teelolws/EditModeExpanded) by Teelo (embedded)
- LibStub (public domain) and LibUIDropDownMenu (embedded)
- Fonts: Marcellus and Inter (SIL Open Font License 1.1)
