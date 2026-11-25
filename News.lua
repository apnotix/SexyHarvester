-- Neuigkeiten für das gemeinsame Fenster (SexyEditMode, /sem news). Neueste Version zuerst.
-- Eintrag: { deutscher Titel, deutscher Text, englischer Titel, englischer Text }
local SEM = LibStub and LibStub("SexyEditMode-1.0", true)
if not (SEM and SEM.RegisterNews) then return end

SEM:RegisterNews("SexyHarvester", {
	color = { 0.43, 0.94, 0.54 },
	{ v = "1.0.6",
		{ "Reset-Knopf", "Der Knopf unten hat den Look der anderen Sexy-Fenster: Fußleiste, Bandfarbe, goldene Schrift und ein dünner goldener Rand, in der Vorschau wie im Fenster gleich.",
		  "Reset button", "The button at the bottom has the look of the other Sexy windows: footer, band color, gold text and a thin gold border, the same in the preview and in the window." },
		{ "Vorschau", "Eigene Vorschau mit zählenden Beispiel-Rohstoffen. Neue Einstellungen für Symbolgröße, Zeilenhöhe, Deckkraft, Karten, Summe im Titel und Reset-Knopf.",
		  "Preview", "Own preview with counting sample materials. New settings for icon size, row height, opacity, cards, total in the title and reset button." },
		{ "Andocken", "Das Fenster lässt sich an andere Fenster andocken, auch an die anderer Sexy-Addons.",
		  "Docking", "The window can be docked to other windows, including those of other Sexy addons." },
		{ "SexyEditMode", "SexyEditMode ist jetzt eine Pflichtabhängigkeit; die Einstellungen stehen im gemeinsamen Fenster (/sem).",
		  "SexyEditMode", "SexyEditMode is now a required dependency; the settings are in the shared window (/sem)." },
	},
})
