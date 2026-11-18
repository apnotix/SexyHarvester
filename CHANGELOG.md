# Changelog

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
