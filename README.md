# SexyHarvester

Ein Addon für **World of Warcraft: Forever**, das für jeden Sammelberuf-Rohstoff
(Kräuter, Erz, Leder) in deinem Inventar ein Icon mit der aktuellen Stückzahl
anzeigt – daneben ein grünes `+N`, das zeigt, wie viel du davon in der
aktuellen Session dazugesammelt hast.

## Features

- Automatische Erkennung von Kräuterkunde-, Bergbau- und Kürschnerei-Rohstoffen
  über den Item-Subtyp (keine feste Item-Liste, funktioniert also auch mit
  neuen Rohstoffen)
- Icon + aktuelle Menge pro Rohstoff
- Grüner `+N`-Zähler für die in dieser Login-Session gesammelte Menge
- Tooltip mit Item-Namen beim Hovern
- Verschiebbar über Blizzards eigenen Edit-Modus (`Esc` → Edit-Modus)

## Installation

1. Repo als ZIP herunterladen oder klonen.
2. Den Ordner `SexyHarvester` (mit `SexyHarvester.toc` direkt darin) nach
   `World of Warcraft\_forever_\Interface\AddOns\` kopieren.
   *(Ordnername ggf. an den tatsächlichen Client-Pfad anpassen.)*
3. Client starten, Addon in der Charakterauswahl aktivieren.

## Nutzung

- Fenster erscheint automatisch, sobald du Sammelberuf-Rohstoffe im
  Inventar hast.
- `/sh reset` – Session-Zähler (`+N`) zurücksetzen.

### Einstellungen über den Edit-Mode

`Esc` → Edit-Modus → **„Sammelberufe“** anwählen. Dort einstellbar:

- **Position** – Fenster direkt per Drag&Drop verschieben.
- **Am Bildschirmrand einklemmen** – Checkbox, verhindert, dass das Fenster
  über den Bildschirmrand hinausgezogen wird.
- **Größe** – Skalierungs-Regler (50 %–200 %).
- **Titel ausblenden** – Checkbox, blendet das Label „Sammelberufe“ oben aus
  (standardmäßig sichtbar).
- **Menge ausblenden** – Checkbox, blendet die Stückzahl am Icon aus
  (standardmäßig sichtbar).
- **Session-Zähler ausblenden** – Checkbox, blendet das grüne `+N` aus
  (standardmäßig sichtbar).
- **Anzahl-Position wechseln** – Button, schaltet die Position der Stückzahl
  am Icon durch: unten rechts → oben rechts → unten links → oben links →
  außerhalb rechts → außerhalb links → außerhalb oben → außerhalb unten.
  Bei den „außerhalb“-Positionen rückt der Session-Zähler entsprechend mit,
  bei Overlay-Positionen hängt er direkt am Icon.
- **Icon-Layout wechseln** – Button, schaltet zwischen Icons untereinander
  (Standard) und Icons nebeneinander in einer horizontalen Reihe um.

## Kompatibilität

Der genaue Lua-API-Stand von World of Warcraft: Forever war zum Zeitpunkt der
Entwicklung nicht zuverlässig zu verifizieren. Das Addon enthält deshalb eine
Kompatibilitätsschicht, die sowohl klassische (`GetContainerItemInfo`,
`GetItemInfo`, …) als auch modernere API-Varianten (`C_Container.*`,
`C_Item.*`) unterstützt. Interface-Version in der `.toc`: `16001`.

Falls beim Laden ein Lua-Fehler auftritt, bitte als
[Issue](https://github.com/apnotix/SexyHarvester/issues) mit der genauen
Fehlermeldung melden.

## Verwendete Bibliotheken

- [EditModeExpanded-1.0](https://github.com/teelolws/EditModeExpanded) von
  **Teelo** – bindet das Addon-Fenster in Blizzards nativen Edit-Modus ein.
  Eingebettet unter `Libs/EditModeExpanded-1.0/`.
- [LibStub](https://www.wowace.com/wiki/LibStub) (Public Domain) – Versionierungs-Stub
  für obige Library. Eingebettet unter `Libs/LibStub.lua`.
