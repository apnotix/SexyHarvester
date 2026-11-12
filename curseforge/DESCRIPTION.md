# 🌿 SexyHarvester

![WoW Forever](https://img.shields.io/badge/WoW-Forever-e8c26a?style=for-the-badge) ![Retail](https://img.shields.io/badge/WoW-Retail-c8a24a?style=for-the-badge) ![Interface](https://img.shields.io/badge/Interface-120100%20%7C%2016001-3b2b12?style=for-the-badge) ![Edit Mode](https://img.shields.io/badge/Edit%20Mode-yes-4fc16a?style=for-the-badge)

**Everything you gather, at a glance.**

Herbs, ore, leather and cloth from your bags with their counts and a green **+N** for this session's haul. Three views, fully adjustable in Edit Mode.

Works on **World of Warcraft: Forever** and **Retail**.

---

## ✨ What SexyHarvester does

### 🧺 Materials at a glance

The window appears by itself as soon as your bags hold gathering materials.

- 🔎 **Detects materials by itself:** Herbalism, Mining, Skinning and cloth through the item subtype, no fixed item list. New materials work right away. Equippable items such as leather armor are ignored.
- 🔢 **Count** per material, from all bags including the reagent bag.
- ➕ **Session counter:** a green **+N** shows how much you picked up since login. The title band shows the total as a badge.
- 🖱️ **Tooltip:** hover an icon to see the normal item tooltip.
- 🔄 **Reset** with `/sh reset` or the button in the window.

### 🪟 Three views

The **Icon layout** option switches between them:

- 🗂️ **Compact (stacked):** icon, count and session label, the default.
- ↔️ **As row (side by side):** one slot per material with the icon, the count below and the session label.
- 📚 **With names and profession groups:** group rows for Herbs, Ore, Leather and Cloth with a total, then icon, name, count and session label, plus the "Reset session" button.

### 🎨 Look

Dark brown surface, gold frame, title band with a badge, card rows with dividers and the **+N** as a green label, matching **SexyLoot** and **SexyQuestHelper**. Fonts: **Marcellus** for the title, **Inter** for text. Background, border and font can still be changed.

---

## 🛠️ Everything adjustable in Edit Mode

**Esc** → **Edit Mode** → select **"Professions"**. SexyHarvester uses the [EditModeExpanded](https://github.com/teelolws/EditModeExpanded) library for this.

| Option | Effect |
| --- | --- |
| 📍 Position | Drag and drop, can be clamped to the screen edge |
| 🔍 Size | 50 to 200 % |
| 🧩 Icon layout | Compact, as row, or with names and profession groups |
| ⬇️ Growth direction | Down, up, right or left |
| 🔢 Count position | On the icon (center, four corners) or outside it (right, left, above, below), in the Compact view |
| 👁️ Hide | Title, count or session counter individually |
| 🖼️ Background, border, icon border | Lists, the default is the quest look |
| 🔤 Font and size | Marcellus + Inter or a game font, size 8 to 24 |

If you already saved your own background, border or font style, it is kept. The new quest look entries sit at the end of the lists.

---

## 🌍 Languages

German and English. German clients show German, every other client shows English.

## 🔤 Fonts

Marcellus and Inter are bundled (SIL Open Font License). On Russian, Korean and Chinese clients SexyHarvester uses the game font.

---

## ⌨️ Commands

| Command | Effect |
| --- | --- |
| `/sh` | Command list |
| `/sh reset` | Reset the session counter (**+N**) |
| `/sh debug` | Print the raw bag data and the window state to chat |

Long form: `/sexyharvester`

---

## ⚠️ Good to know

- 🧪 The addon runs on **World of Warcraft: Forever** and **Retail** and supports both the classic and the modern bag and item API.
- 🕒 The haul counts from login. What you already carry when you log in is the baseline, not a **+N**.
- 🫥 If there are no materials in your bags, the window hides.
- 🎛️ **Count position** only applies to the Compact view.

## 🐞 Reporting bugs

Please report bugs and requests as an [issue on GitHub](https://github.com/apnotix/SexyHarvester/issues). Enable `/console scriptErrors 1` first and include the Lua error message.

## 🙏 Credits

- [EditModeExpanded](https://github.com/teelolws/EditModeExpanded) by **Teelo** (library EditModeExpanded-1.0, embedded, author credited as its license requires)
- **LibStub** (public domain) and **LibUIDropDownMenu** (fork from Questie), embedded
- Fonts [Marcellus](https://fonts.google.com/specimen/Marcellus) and [Inter](https://fonts.google.com/specimen/Inter) (SIL Open Font License 1.1)

---

Made by **apnotix** · Also by me: **SexyLoot**, **SexyQuestHelper**, **SexyInterrupter**
