# SexyHarvester

![WoW Forever](https://img.shields.io/badge/WoW-Forever-e8c26a?style=for-the-badge) ![WoW Retail](https://img.shields.io/badge/WoW-Retail-c8a24a?style=for-the-badge) ![Interface](https://img.shields.io/badge/Interface-120100%20%7C%2016001-3b2b12?style=for-the-badge)

**Everything you gather, at a glance.**

SexyHarvester shows every gathering material in your bags (herbs, ore, leather and cloth) with its count and a green **+N** for what you picked up this session. It appears by itself as soon as you gather and hides when there is nothing to show.

Works on **World of Warcraft: Forever** and **Retail**. Styled like the other Sexy addons: dark brown panel, gold frame, title band with a badge.

## Features

- 🌿 **Finds materials by itself** - herbs, ore, leather and cloth are recognised by item type, no fixed item list. New materials just work.
- ➕ **Session counter** - a green **+N** for everything gathered since login (or since the last reset). The title badge shows the total.
- 🧩 **Three views** - switch with one option:
  - **Compact** - one card per material.
  - **As row** - materials side by side, count under the icon.
  - **With names and profession groups** - group rows with a total, then icon, name, count and session label, plus a **Reset session** button.
- 🖱️ **Item tooltips** - hover an icon for the normal tooltip.

## Edit Mode

Click the window in Edit Mode: the dialog has collapsible sections and shows sample materials while you edit.

- View, growth direction, count position, icon border, font and size
- Hide title, count or session counter separately
- Position, size (50 - 200 %) and visibility (hide, hide in combat, mouseover)

## Commands

| Command | Description |
|---|---|
| `/sh reset` | Reset the session counter |
| `/sh debug` | Print bag data and window state (for troubleshooting) |

Long form: `/sexyharvester`

## Notes

- Items you already carry at login count as the baseline, not as gathered.
- Equippable leather armor is ignored, only real materials are counted.
- Fonts: Marcellus and Inter are bundled (SIL Open Font License). Russian, Korean and Chinese clients keep the game font.
- Bug reports are welcome on GitHub.

## Credits

LibStub (public domain), the own SexyEditMode library (embedded), fonts Marcellus and Inter (SIL Open Font License 1.1).

## 🇩🇪 Deutsch

**SexyHarvester** zeigt Kräuter, Erz, Leder und Stoff aus deinen Taschen mit Stückzahl und einem grünen +N für die Beute dieser Sitzung.

- Drei Ansichten: kompakt, als Reihe oder mit Namen und Berufsgruppen
- Erkennt Materialien selbstständig, Titel-Etikett mit der Gesamtausbeute
- Alles im Edit Mode einstellbar, funktioniert auf Deutsch und Englisch

Ausführliche deutsche Beschreibung: https://github.com/apnotix/SexyHarvester
