<div align="center">

# 🌿 SexyHarvester

**Alles, was du sammelst, auf einen Blick.**
Kräuter, Erz, Leder und Stoff aus deinen Taschen mit Stückzahl und einem grünen `+N` für die Beute dieser Sitzung. Drei Ansichten, frei einstellbar im Edit Mode.

![WoW Forever](https://img.shields.io/badge/WoW-Forever-e8c26a?style=for-the-badge)
![Interface](https://img.shields.io/badge/Interface-16001-3b2b12?style=for-the-badge)
![Edit Mode](https://img.shields.io/badge/Edit%20Mode-ja-4fc16a?style=for-the-badge)

[🇬🇧 English version](README.en.md)

</div>

---

## ✨ Das kann SexyHarvester

### 🧺 Rohstoffe im Blick
Das Fenster erscheint von selbst, sobald du Sammelberuf-Rohstoffe in den Taschen hast.

- 🔎 **Erkennt Rohstoffe selbst:** Kräuterkunde, Bergbau, Kürschnerei und Stoff über den Item-Subtyp, ohne feste Item-Liste. Neue Rohstoffe funktionieren sofort. Anlegbare Gegenstände wie Lederrüstung werden ignoriert.
- 🔢 **Stückzahl** pro Rohstoff, aus allen Taschen samt Reagenztasche.
- ➕ **Session-Zähler:** Ein grünes `+N` zeigt, wie viel du seit dem Login dazugesammelt hast. Im Titelband steht die gesamte Ausbeute als Badge.
- 🖱️ **Tooltip:** Fahr über ein Icon und sieh den normalen Item-Tooltip.
- 🔄 **Zurücksetzen** mit `/sh reset` oder dem Knopf im Fenster.

### 🪟 Drei Ansichten
Die Option **Icon-Layout** schaltet um:

- 🗂️ **Kompakt (untereinander):** Icon, Anzahl und Session-Etikett, Standard.
- ↔️ **Als Reihe (nebeneinander):** je Rohstoff ein Fach mit Icon, Anzahl darunter und Session-Etikett.
- 📚 **Mit Namen und Berufsgruppen:** Gruppenzeilen für Kräuter, Erz, Leder und Stoff mit Summe, darunter Icon, Name, Anzahl und Session-Etikett, dazu der Knopf „Session zurücksetzen“.

### 🎨 Look
Dunkelbraune Fläche, Goldrand, Titelband mit Badge, Karten mit Trennlinien und das `+N` als grünes Etikett, passend zu **SexyLoot** und **SexyQuestHelper**. Schrift: **Marcellus** für den Titel, **Inter** für den Text. Hintergrund, Rahmen und Schrift lassen sich weiter wechseln.

---

## 🛠️ Alles im Edit Mode einstellbar

`Esc` → **Edit Mode** → **„Sammelberufe“** anwählen. SexyHarvester nutzt dafür die Bibliothek [EditModeExpanded](https://github.com/teelolws/EditModeExpanded).

| Option | Wirkung |
| --- | --- |
| 📍 Position | Per Drag & Drop, am Bildschirmrand klemmbar |
| 🔍 Größe | 50 bis 200 % |
| 🧩 Icon-Layout | Kompakt, als Reihe oder mit Namen und Berufsgruppen |
| ⬇️ Wachstumsrichtung | Nach unten, oben, rechts oder links |
| 🔢 Anzahl-Position | Auf dem Icon (Mitte, vier Ecken) oder außerhalb (rechts, links, oben, unten), in der Ansicht „Kompakt“ |
| 👁️ Ausblenden | Titel, Menge oder Session-Zähler einzeln aus |
| 🖼️ Hintergrund, Rahmen, Icon-Rahmen | Auswahllisten, Standard ist der Quest-Look |
| 🔤 Schriftart und Größe | Marcellus + Inter oder eine Spielschrift, Größe 8 bis 24 |

Wer schon einen eigenen Stil für Hintergrund, Rahmen oder Schrift gespeichert hat, behält ihn. Die neuen Quest-Look-Einträge stehen am Ende der Listen.

---

## 🌍 Sprachen
Deutsch und Englisch. Deutsche Clients zeigen Deutsch, alle anderen Englisch.

## 🔤 Schriften
Marcellus und Inter liegen in `media/fonts` (SIL Open Font License, Lizenztexte daneben). Auf russischen, koreanischen und chinesischen Clients nutzt SexyHarvester die Spielschrift.

---

## 📥 Installation

1. Ordner `SexyHarvester` (mit `SexyHarvester.toc` direkt darin) in dein `Interface/AddOns`-Verzeichnis des Forever-Clients kopieren.
2. Spiel starten oder `/reload`.
3. Edit Mode öffnen und das Fenster nach Wunsch platzieren.

## ⌨️ Befehle

| Befehl | Wirkung |
| --- | --- |
| `/sh` | Befehlsliste |
| `/sh reset` | Session-Zähler (`+N`) zurücksetzen |
| `/sh debug` | Rohdaten der Taschen und Fensterzustand in den Chat ausgeben |

Langform: `/sexyharvester`

---

## ⚠️ Gut zu wissen

- 🧪 Der Lua-API-Stand von World of Warcraft: Forever war bei der Entwicklung nicht sicher zu klären. Das Addon unterstützt deshalb klassische (`GetContainerItemInfo`, `GetItemInfo`) und modernere Varianten (`C_Container.*`, `C_Item.*`).
- 🕒 Die Beute zählt ab dem Login. Was du beim Einloggen schon dabeihast, ist der Ausgangswert und kein `+N`.
- 🫥 Sind keine Rohstoffe in den Taschen, blendet sich das Fenster aus.
- 🎛️ Die **Anzahl-Position** gilt nur in der Ansicht „Kompakt“.

## 🐞 Fehler melden

Fehler und Wünsche bitte als [Issue auf GitHub](https://github.com/apnotix/SexyHarvester/issues) melden. Aktiviere vorher `/console scriptErrors 1` und schick die Lua-Fehlermeldung mit.

## 🙏 Danksagung

- [EditModeExpanded](https://github.com/teelolws/EditModeExpanded) von **Teelo** (Bibliothek `EditModeExpanded-1.0`, eingebettet unter `Libs/`, Autor wird wie in der Lizenz gefordert genannt)
- **LibStub** (gemeinfrei) und **LibUIDropDownMenu** (Fork aus Questie), eingebettet unter `Libs/`
- Schriften [Marcellus](https://fonts.google.com/specimen/Marcellus) und [Inter](https://fonts.google.com/specimen/Inter) (SIL Open Font License 1.1)

---

<div align="center">

Gemacht von **apnotix** · Auch von mir: **SexyLoot**, **SexyQuestHelper**, **SexyInterrupter**

</div>
