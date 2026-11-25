# Changelog

## 1.0.6

- Reset-Knopf („Reset Session“): Fußleiste mit Linie, Bandfarbe, goldene Schrift, 28 px hoch und ein dünner goldener Rand, der immer genau ein Bildschirmpixel stark ist (gleicher Look in der Vorschau und im echten Fenster).

- Einstellungsfenster: Die Vorschau ist ein eigenes Fenster mit eigener Logik (neue Datei Samples.lua, braucht einen vollständigen Neustart): Beispiel-Rohstoffe mit Session-Zähler, Mengen und Zähler zählen laufend hoch; Icon-Layout, Wachstumsrichtung, Anzahl-Position, Icon-Rahmen, Schrift und Ausblenden wirken sofort. Alle Einstellungen liegen in einer Gruppe „Aussehen“ (Abschnitte Anzeige, Größe und Fläche, Schrift). Neu: Icon-Größe, Zeilenhöhe, Deckkraft des Fensters, Zeilen als Karten, Summe im Titel, Summen der Gruppen und Reset-Knopf lassen sich einstellen; jede Fläche der Vorschau springt zu ihrer Einstellung.
- SexyEditMode ist jetzt eine Pflichtabhängigkeit (CurseForge installiert es automatisch).
- Andocken: Das Fenster lässt sich an ein anderes Fenster andocken (auch anderer Sexy-Addons), mit Seite und Ausrichtung (mit SexyEditMode).
- Minimap-Knopf, Rechtsklick: Edit Mode nur für die Fenster von SexyHarvester (mit SexyEditMode).
- Minimap-Knopf: Linksklick öffnet das Einstellungsfenster (SexyEditMode) beim Bereich von SexyHarvester, Rechtsklick den Edit Mode.
- Icon-Layout: Die drei Bezeichner sind kurz (Kompakt, Reihe, Gruppiert), damit sie im Einstellungsfenster nebeneinander passen.
- Meldet sich beim neuen Addon SexyEditMode an: Ist es installiert, erscheint das Fenster auch im gemeinsamen Einstellungsfenster (/sem). Ohne das Addon ändert sich nichts.
- Schriftauswahl: Jede Schrift in der Liste wird in ihrer eigenen Schrift angezeigt, ebenso die aktuelle Auswahl.

## 1.0.4

- Neuer Minimap-Knopf: Linksklick öffnet bzw. schließt den Edit Mode. Ausblenden mit `/sh minimap`.
- Positionen: Beim Umstieg auf den neuen Edit-Mode-Dialog wurde die alte Position mancher Spieler nicht übernommen (Fenster stand wieder an der Startposition). Die Übernahme prüft jetzt später erneut, nimmt notfalls das Layout, in dem das Fenster verschoben wurde, und löscht die alten Daten nicht mehr. Bereits zurückgesetzte Fenster müssen einmal neu platziert werden

## 1.0.3

- Ansicht "Mit Namen": Die Summe je Berufsgruppe steht jetzt in derselben Spalte wie die Anzahlen der Items darunter.
- Ansicht "Als Reihe": Die Fächer sind nur noch so breit wie ihr Inhalt (Icon, Anzahl, Session-Etikett), die Icons sitzen enger beieinander.
- Neuer Edit-Mode-Dialog im Look der Sexy-Addons mit einklappbaren Abschnitten (Ansicht, Aussehen, Position und Größe, Sichtbarkeit) aus der eigenen Bibliothek SexyEditMode. Im Edit Mode zeigt das Fenster Beispiel-Rohstoffe. Neu: im Kampf ausblenden und nur bei Mouseover zeigen. EditModeExpanded und LibUIDropDownMenu entfallen.
- Der Quest-Look-Rahmen ist jetzt derselbe Tooltip-Rand wie bei SexyQuestHelper (abgerundete Ecken, gold gefärbt) statt einer flachen Linie. Titelband und Zeilen sitzen entsprechend weiter innen. Die älteren Rahmen-Stile bleiben unverändert.
- Hintergrund und Fensterrahmen sind fest (Quest-Look) und lassen sich nicht mehr einstellen; die Auswahllisten "Hintergrund" und "Rahmen" entfallen, gespeicherte Wahlen werden nicht mehr benutzt. "Icon-Rahmen" bleibt wählbar.

## 1.0.2

- Läuft jetzt auch auf Retail: Die `.toc` führt neben Forever (16001) auch Retail (120100). Dadurch heißt das Release-Paket nicht mehr "...-forever.zip".
- Rohstoff-Erkennung kennt die Subtyp-Namen von Retail (z. B. "Kräuter" und "Metall & Stein" auf deutschen Clients, "Herbes" und "Métal et pierre" auf französischen). Die Listen für Erkennung und Berufsgruppen kommen jetzt aus einer gemeinsamen Tabelle.

## 1.0.1

- Neuer Look im Stil von SexyQuestHelper und SexyLoot: dunkelbraune Fläche, 2-px-Goldrand, Titelband mit Badge (gesamte Session-Ausbeute), Karten mit Trennlinien und das `+N` als grünes Etikett. Wer schon einen eigenen Stil für Hintergrund, Rahmen oder Schrift gespeichert hat, behält ihn; die Quest-Look-Einträge stehen am Ende der Auswahllisten.
- Die Option "Icon-Layout" kennt jetzt drei Ansichten: Kompakt, Als Reihe (Anzahl unter dem Icon) und neu "Mit Namen und Berufsgruppen" (Gruppenzeilen für Kräuter, Erz, Leder und Stoff mit Summe, Name, Anzahl und Session-Etikett).
- Neuer Knopf "Session zurücksetzen" in der Ansicht "Mit Namen und Berufsgruppen" (wie `/sh reset`).
- Neue Schriften: Marcellus für den Titel, Inter für den übrigen Text (mitgeliefert, SIL Open Font License). Russische, koreanische und chinesische Clients behalten die Spielschrift.
- Neues Addon-Symbol (`icon.tga`) und englische README.
- Automatische Versionierung: Jeder Push auf master erhöht die Version in der `.toc`, legt einen Tag an und baut das Paket.
