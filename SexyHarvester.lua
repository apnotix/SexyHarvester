-- SexyHarvester
-- Zeigt für jeden Sammelberuf-Rohstoff (Kraut, Erz, Leder) im Inventar ein Icon mit
-- aktueller Menge und einem "+N" für die in dieser Session gesammelte Menge an.

local ADDON_NAME = ...

------------------------------------------------------------------------------
-- Lokalisierung (DE/EN) - Client-Sprache über GetLocale() erkannt, alles außer
-- Deutsch fällt auf Englisch zurück.
------------------------------------------------------------------------------

local LOCALE = (GetLocale() == "deDE") and "de" or "en"

local STRINGS = {
    title           = { de = "Sammelberufe",              en = "Professions" },
    hideTitle       = { de = "Titel ausblenden",           en = "Hide Title" },
    hideCount       = { de = "Menge ausblenden",           en = "Hide Count" },
    hideGained      = { de = "Session-Zähler ausblenden",  en = "Hide Session Counter" },
    background      = { de = "Hintergrund",                en = "Background" },
    border          = { de = "Rahmen",                     en = "Border" },
    iconBorder      = { de = "Icon-Rahmen",                en = "Icon Border" },
    font            = { de = "Schriftart",                 en = "Font" },
    fontSize        = { de = "Schriftgröße",               en = "Font Size" },
    countPosition   = { de = "Anzahl-Position",             en = "Count Position" },
    listLayout      = { de = "Icon-Layout",                en = "Icon Layout" },
    growthDirection = { de = "Wachstumsrichtung",          en = "Growth Direction" },

    bgDark          = { de = "Schwarz (dezent)",           en = "Black (subtle)" },
    bgNone          = { de = "Kein Hintergrund",            en = "No Background" },
    bgBlack         = { de = "Schwarz (kräftig)",          en = "Black (strong)" },
    bgGray          = { de = "Grau",                        en = "Gray" },
    bgBrown         = { de = "Braun/Pergament",            en = "Brown/Parchment" },
    bgTooltip       = { de = "Tooltip-Textur",             en = "Tooltip Texture" },
    bgDialog        = { de = "Pergament-Textur",           en = "Parchment Texture" },

    edgeThinDark    = { de = "Dünn (Dunkel)",              en = "Thin (Dark)" },
    edgeNone        = { de = "Kein Rahmen",                 en = "No Border" },
    edgeThinLight   = { de = "Dünn (Hell)",                en = "Thin (Light)" },
    edgeThickDark   = { de = "Dick (Dunkel)",              en = "Thick (Dark)" },
    edgeGold        = { de = "Gold",                        en = "Gold" },

    fontStandard    = { de = "Standard (Friz Quadrata)",   en = "Default (Friz Quadrata)" },
    fontArial       = { de = "Arial",                       en = "Arial" },
    fontSkurri      = { de = "Skurri",                      en = "Skurri" },
    fontMorpheus    = { de = "Morpheus",                    en = "Morpheus" },
    fontNimrod      = { de = "Nimrod",                      en = "Nimrod" },

    posCenter       = { de = "Icon: mittig",               en = "Icon: Center" },
    posBottomRight  = { de = "Icon: unten rechts",         en = "Icon: Bottom Right" },
    posTopRight     = { de = "Icon: oben rechts",          en = "Icon: Top Right" },
    posBottomLeft   = { de = "Icon: unten links",          en = "Icon: Bottom Left" },
    posTopLeft      = { de = "Icon: oben links",           en = "Icon: Top Left" },
    posOutsideRight = { de = "Außerhalb rechts",           en = "Outside Right" },
    posOutsideLeft  = { de = "Außerhalb links",            en = "Outside Left" },
    posOutsideTop   = { de = "Außerhalb oben",             en = "Outside Top" },
    posOutsideBottom= { de = "Außerhalb unten",            en = "Outside Bottom" },

    layoutVertical  = { de = "Kompakt (untereinander)",    en = "Compact (stacked)" },
    layoutHorizontal= { de = "Als Reihe (nebeneinander)",  en = "As row (side by side)" },
    layoutGrouped   = { de = "Mit Namen und Berufsgruppen", en = "With names and profession groups" },

    bgQuest         = { de = "Quest-Look (dunkelbraun)",   en = "Quest look (dark brown)" },
    edgeQuest       = { de = "Quest-Look (Gold)",          en = "Quest look (gold)" },
    fontQuest       = { de = "Marcellus + Inter",          en = "Marcellus + Inter" },

    groupHerb       = { de = "Kräuter",                    en = "Herbs" },
    groupOre        = { de = "Erz",                        en = "Ore" },
    groupLeather    = { de = "Leder",                      en = "Leather" },
    groupCloth      = { de = "Stoff",                      en = "Cloth" },
    groupOther      = { de = "Sonstiges",                  en = "Other" },
    session         = { de = "Session",                    en = "Session" },
    resetButton     = { de = "Session zurücksetzen",       en = "Reset session" },

    growthDown      = { de = "Nach unten",                  en = "Downward" },
    growthUp        = { de = "Nach oben",                   en = "Upward" },
    growthRight     = { de = "Nach rechts",                 en = "Rightward" },
    growthLeft      = { de = "Nach links",                  en = "Leftward" },

    resetConfirm    = { de = "Session-Zähler zurückgesetzt.", en = "Session counter reset." },
    helpHeader      = { de = "Befehle:",                    en = "Commands:" },
    helpReset       = { de = "/sh reset - Session-Zähler zurücksetzen", en = "/sh reset - reset the session counter" },
    helpDebug       = { de = "/sh debug - internen Zustand in den Chat ausgeben (zur Fehlersuche)", en = "/sh debug - print internal state to chat (for troubleshooting)" },
    helpMove        = { de = "Position verschieben: Esc -> Edit-Modus -> 'Sammelberufe' anwählen und ziehen.", en = "Move: Esc -> Edit Mode -> select 'Professions' and drag." },
    helpAppearance  = { de = "Aussehen/Layout (Hintergrund, Rahmen, Schriftart, Position, uvm.): Esc -> Edit-Modus -> 'Sammelberufe' -> Dropdowns.", en = "Appearance/Layout (background, border, font, position, etc.): Esc -> Edit Mode -> 'Professions' -> dropdowns." },
}

local function L(key)
    local entry = STRINGS[key]
    return entry and (entry[LOCALE] or entry.en) or key
end

------------------------------------------------------------------------------
-- Kompatibilitäts-Layer
-- "World of Warcraft: Forever" scheint eine eher Retail-artige API (C_Container /
-- C_Item) zu verwenden, evtl. aber auch noch die klassischen globalen Funktionen.
-- Wir probieren beides, damit das Addon auf möglichst vielen Client-Versionen läuft.
------------------------------------------------------------------------------

local function GetBagSlots(bag)
    if C_Container and C_Container.GetContainerNumSlots then
        return C_Container.GetContainerNumSlots(bag)
    elseif _G.GetContainerNumSlots then
        return _G.GetContainerNumSlots(bag)
    end
    return 0
end

local function GetBagItemID(bag, slot)
    if C_Container and C_Container.GetContainerItemID then
        return C_Container.GetContainerItemID(bag, slot)
    elseif _G.GetContainerItemID then
        return _G.GetContainerItemID(bag, slot)
    elseif C_Container and C_Container.GetContainerItemInfo then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        return info and info.itemID
    elseif _G.GetContainerItemInfo then
        local _, _, _, _, _, _, _, _, _, itemID = _G.GetContainerItemInfo(bag, slot)
        return itemID
    end
end

local function GetItemData(itemID)
    -- Reihenfolge (klassisch & retail identisch):
    -- name, link, quality, iLevel, reqLevel, type, subType, stackCount,
    -- equipLoc, icon, sellPrice, classID, subClassID
    if C_Item and C_Item.GetItemInfo then
        return C_Item.GetItemInfo(itemID)
    end
    return GetItemInfo(itemID)
end

local function GetItemIcon(itemID)
    if C_Item and C_Item.GetItemIconByID then
        local icon = C_Item.GetItemIconByID(itemID)
        if icon then return icon end
    end
    if _G.GetItemIcon then
        local icon = _G.GetItemIcon(itemID)
        if icon then return icon end
    end
    return 134400 -- INV_Misc_QuestionMark, Fallback
end

local function GetTotalItemCount(itemID)
    if C_Item and C_Item.GetItemCount then
        return C_Item.GetItemCount(itemID, false)
    end
    return GetItemCount(itemID, false)
end

------------------------------------------------------------------------------
-- Erkennung von Sammelberuf-Rohstoffen anhand des lokalisierten Subtyps.
-- Deckt Kräuterkunde, Bergbau, Kürschnerei und Stoff (Leinenstoff, Wollstoff,
-- ...) ab. Die Namen gelten für Forever und Retail (Deutsch + Englisch, sowie
-- ein paar weitere Sprachen als Best-Effort-Fallback). Aus derselben Liste
-- entsteht die Berufsgruppe für die Ansicht "Mit Namen und Berufsgruppen".
------------------------------------------------------------------------------

local SUBTYPES_BY_GROUP = {
    -- Kräuterkunde
    herb = { "herb", "kraut", "kräuter", "herbe", "herbes", "hierba", "hierbas", "erba" },
    -- Bergbau
    ore = { "metal & stone", "erz und stein", "metall & stein", "minerai et pierre", "métal et pierre",
        "metal y piedra", "metallo e pietra" },
    -- Kürschnerei
    leather = { "leather", "leder", "cuir", "cuero", "pelle" },
    -- Stoff (Leinenstoff, Wollstoff, ...)
    cloth = { "cloth", "stoff", "tissu", "tela", "stoffa" },
}

local GATHERING_SUBTYPES, GROUP_BY_SUBTYPE = {}, {}
for group, names in pairs(SUBTYPES_BY_GROUP) do
    for _, name in ipairs(names) do
        GATHERING_SUBTYPES[name] = true
        GROUP_BY_SUBTYPE[name] = group
    end
end
local GROUP_ORDER = { herb = 1, ore = 2, leather = 3, cloth = 4, other = 5 }
local GROUP_TONE = { herb = "ok", ore = "they", leather = "warn", cloth = "grey", other = "grey" }
local GROUP_LABEL = { herb = "groupHerb", ore = "groupOre", leather = "groupLeather", cloth = "groupCloth", other = "groupOther" }

local function GroupOf(itemID)
    local _, _, _, _, _, _, subType = GetItemData(itemID)
    return subType and GROUP_BY_SUBTYPE[string.lower(subType)] or "other"
end

-- Etikettenfarben wie in SexyQuestHelper und SexyLoot
local TONES = {
    ok = { bg = { 0.082, 0.188, 0.11 }, fg = { 0.48, 0.88, 0.56 } },
    warn = { bg = { 0.227, 0.173, 0.063 }, fg = { 0.94, 0.75, 0.29 } },
    grey = { bg = { 0.16, 0.145, 0.12 }, fg = { 0.66, 0.61, 0.54 } },
    they = { bg = { 0.078, 0.157, 0.227 }, fg = { 0.53, 0.8, 1 } },
}

local function IsGatheringMaterial(itemID)
    local name, _, _, _, _, _, subType, _, equipLoc = GetItemData(itemID)
    if not name then
        return nil -- noch nicht im Client-Cache, muss später erneut geprüft werden
    end
    -- Anrüstbare Gegenstände (z. B. Lederrüstung) haben denselben Subtyp-Text
    -- ("Leder") wie das Krafting-Material, aber immer einen Ausrüstungsplatz -
    -- Sammelrohstoffe haben nie einen. Verhindert Fehltreffer wie Lederstiefel.
    -- "INVTYPE_NON_EQUIP_IGNORE" ist Blizzards eigener Wert für nicht anlegbare
    -- Items (auf manchen Clients statt eines leeren Strings) und zählt NICHT
    -- als Ausrüstungsplatz.
    if equipLoc and equipLoc ~= "" and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" then
        return false
    end
    if subType and GATHERING_SUBTYPES[string.lower(subType)] then
        return true
    end
    return false
end

------------------------------------------------------------------------------
-- State
------------------------------------------------------------------------------

SexyHarvesterDB = SexyHarvesterDB or {}

local currentCounts = {}   -- [itemID] = aktuelle Menge im Inventar
local sessionGained = {}   -- [itemID] = in dieser Session dazugewonnene Menge
local pendingItemIDs = {}  -- itemIDs, deren Info noch nicht gecacht war
local initialized = false

-- Über den Edit Mode umschaltbare Anzeige-Optionen (siehe RegisterCustomCheckbox weiter unten)
local hideTitle = false
local hideCount = false
local hideGained = false
local backgroundIndex = 1
local borderIndex = 1
local iconBorderIndex = 1

------------------------------------------------------------------------------
-- UI
------------------------------------------------------------------------------

local ROW_HEIGHT = 30        -- Karte in der Ansicht "Kompakt"
local ICON_SIZE = 22
local FRAME_WIDTH = 130
local FRAME_PADDING = 8
local HEADER_HEIGHT = 30     -- Rahmen oben plus Titelband
local GROUP_ROW_H = 28       -- Item-Zeile mit Namen
local GROUP_HEADER_H = 22    -- Gruppenzeile (Beruf)
local SLOT_ICON = 28         -- Icon in der Ansicht "Als Reihe"
local FOOTER_H = 38          -- Fußleiste mit Reset-Knopf (nur "Mit Namen")
local PILL_MIN = 34          -- Mindestbreite des Session-Etiketts

-- Kein BackdropTemplate/SetBackdrop verwendet, da dessen Verfügbarkeit je nach
-- Client-Generation unsicher ist. Stattdessen einfache, überall funktionierende
-- Textur-Flächen mit Vertex-Farbe.
local frame = CreateFrame("Frame", "SexyHarvesterFrame", UIParent)
frame:SetSize(FRAME_WIDTH, HEADER_HEIGHT + FRAME_PADDING * 2)
frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
-- Beweglichkeit, Klemmen an den Bildschirmrand und das Ziehen selbst übernimmt
-- ab hier die EditModeExpanded-1.0 Library (siehe ADDON_LOADED weiter unten).

local background = frame:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(frame)
background:SetTexture("Interface\\Buttons\\WHITE8x8")

-- Rahmen aus vier Kantentexturen (statt BackdropTemplate, siehe Kommentar oben).
-- Farbe/Dicke werden erst per ApplyFrameBorder() gesetzt, sobald ein Stil gewählt ist.
local border = {}
for _, edge in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
    local tex = frame:CreateTexture(nil, "BORDER")
    tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    tex.edge = edge
    border[#border + 1] = tex
end

-- Auswählbare Hintergründe (siehe "Hintergrund"-Dropdown im Edit Mode). Die
-- ersten fünf sind eingefärbte Flächen (WHITE8x8 + Vertex-Farbe), die letzten
-- beiden echte Blizzard-Texturen (siehe "texture") mit eigener Bild-Vorschau
-- im Dropdown statt nur einem Farbfeld.
local BACKGROUND_STYLES = {
    { id = "dark",     label = L("bgDark"),    r = 0,    g = 0,    b = 0,    a = 0.55 },
    { id = "none",     label = L("bgNone") },
    { id = "black",    label = L("bgBlack"),   r = 0,    g = 0,    b = 0,    a = 0.9 },
    { id = "gray",     label = L("bgGray"),    r = 0.15, g = 0.15, b = 0.15, a = 0.65 },
    { id = "brown",    label = L("bgBrown"),   r = 0.2,  g = 0.15, b = 0.08, a = 0.75 },
    { id = "tooltip",  label = L("bgTooltip"), texture = "Interface\\Tooltips\\UI-Tooltip-Background", a = 0.95 },
    { id = "dialog",   label = L("bgDialog"),  texture = "Interface\\DialogFrame\\UI-DialogBox-Background", a = 1 },
    -- Neuer Standard im Stil von SexyQuestHelper (hinten angehängt, damit gespeicherte Indizes gültig bleiben)
    { id = "quest",    label = L("bgQuest"),   r = 0.08, g = 0.065, b = 0.05, a = 0.96 },
}
local DEFAULT_BACKGROUND = #BACKGROUND_STYLES

-- Auswählbare Rahmen-Stile, gemeinsam genutzt vom Fensterrahmen ("Rahmen wechseln")
-- und den einzelnen Icon-Rahmen ("Icon-Rahmen wechseln").
local EDGE_STYLES = {
    { id = "thin_dark",  label = L("edgeThinDark"),  r = 0,   g = 0,    b = 0,   a = 0.9,  thickness = 1 },
    { id = "none",       label = L("edgeNone") },
    { id = "thin_light", label = L("edgeThinLight"), r = 1,   g = 1,    b = 1,   a = 0.5,  thickness = 1 },
    { id = "thick_dark", label = L("edgeThickDark"), r = 0,   g = 0,    b = 0,   a = 0.95, thickness = 2 },
    { id = "gold",       label = L("edgeGold"),      r = 0.8, g = 0.65, b = 0.2, a = 0.9,  thickness = 1 },
    { id = "quest",      label = L("edgeQuest"),     r = 0.42, g = 0.34, b = 0.15, a = 1, thickness = 2 },
}
local BORDER_STYLES = EDGE_STYLES
local DEFAULT_BORDER = #EDGE_STYLES    -- Fensterrahmen: Quest-Look
local DEFAULT_ICON_BORDER = 3          -- Icon-Rahmen: dünn, hell

-- Setzt den per backgroundIndex gewählten Hintergrund (siehe BACKGROUND_STYLES).
-- Bei "texture" wird die echte Bild-Textur verwendet, sonst die eingefärbte
-- WHITE8x8-Fläche.
local function ApplyBackground()
    local style = BACKGROUND_STYLES[backgroundIndex] or BACKGROUND_STYLES[1]
    if style.id == "none" then
        background:Hide()
        return
    end
    background:SetTexture(style.texture or "Interface\\Buttons\\WHITE8x8")
    if style.r then
        background:SetVertexColor(style.r, style.g, style.b, style.a or 1)
    else
        background:SetVertexColor(1, 1, 1, style.a or 1)
    end
    background:Show()
end

-- Setzt den per borderIndex gewählten Fensterrahmen-Stil (siehe BORDER_STYLES).
local function ApplyFrameBorder()
    local style = BORDER_STYLES[borderIndex] or BORDER_STYLES[1]
    if style.id == "none" then
        for _, tex in ipairs(border) do tex:Hide() end
        return
    end
    for _, tex in ipairs(border) do
        tex:ClearAllPoints()
        tex:SetVertexColor(style.r, style.g, style.b, style.a)
        if tex.edge == "TOP" then
            tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
            tex:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
            tex:SetHeight(style.thickness)
        elseif tex.edge == "BOTTOM" then
            tex:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
            tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
            tex:SetHeight(style.thickness)
        elseif tex.edge == "LEFT" then
            tex:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
            tex:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
            tex:SetWidth(style.thickness)
        else
            tex:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
            tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
            tex:SetWidth(style.thickness)
        end
        tex:Show()
    end
end

-- Setzt den per iconBorderIndex gewählten Rahmen-Stil einer einzelnen Icon-Zeile
-- (siehe EDGE_STYLES). Technik: eine eingefärbte Fläche knapp hinter dem Icon,
-- die als Rahmen um das Icon herum sichtbar bleibt.
local function ApplyIconBorderStyle(row)
    local style = EDGE_STYLES[iconBorderIndex] or EDGE_STYLES[1]
    if style.id == "none" then
        row.iconBorder:Hide()
        return
    end
    row.iconBorder:ClearAllPoints()
    row.iconBorder:SetPoint("TOPLEFT", row.icon, "TOPLEFT", -style.thickness, style.thickness)
    row.iconBorder:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", style.thickness, -style.thickness)
    row.iconBorder:SetVertexColor(style.r, style.g, style.b, style.a)
    row.iconBorder:Show()
end

-- Vom Edit Mode durchschaltbare Schriftarten für Titel, Mengenanzahl und Session-Zähler.
local FONTS = {
    { label = L("fontStandard"), path = "Fonts\\FRIZQT__.TTF" },
    { label = L("fontArial"),    path = "Fonts\\ARIALN.TTF" },
    { label = L("fontSkurri"),   path = "Fonts\\SKURRI.TTF" },
    { label = L("fontMorpheus"), path = "Fonts\\MORPHEUS.TTF" },
    { label = L("fontNimrod"),   path = "Fonts\\NIM_____.TTF" },
}
-- Neuer Standard: Marcellus für den Titel, Inter für den übrigen Text (SIL OFL, siehe
-- media/fonts). Russische, koreanische und chinesische Clients brauchen andere Zeichen
-- und behalten die Spielschrift.
do
    local loc = GetLocale()
    local plain = loc == "ruRU" or loc == "koKR" or loc == "zhCN" or loc == "zhTW"
    local dir = "Interface\\AddOns\\SexyHarvester\\media\\fonts\\"
    FONTS[#FONTS + 1] = {
        label = L("fontQuest"),
        path = plain and "Fonts\\FRIZQT__.TTF" or (dir .. "Inter.ttf"),
        titlePath = plain and "Fonts\\FRIZQT__.TTF" or (dir .. "Marcellus-Regular.ttf"),
    }
end
local DEFAULT_FONT = #FONTS
local fontIndex = DEFAULT_FONT
local fontSize = 11 -- Standardgröße von GameFontNormalSmall/NumberFontNormalSmall

-- Titelband (Quest-Look) mit Titel links und Badge rechts
local band = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
band:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
band:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
band:SetHeight(HEADER_HEIGHT - 2)
band:SetColorTexture(0.15, 0.12, 0.07, 0.96)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("LEFT", band, "LEFT", 10, 0)
title:SetText(L("title"))
title:SetTextColor(0.91, 0.76, 0.42)

local badgeBg = frame:CreateTexture(nil, "ARTWORK")
badgeBg:SetPoint("RIGHT", band, "RIGHT", -6, 0)
badgeBg:SetHeight(18)
badgeBg:SetColorTexture(0.165, 0.14, 0.10, 1)
local badgeText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
badgeText:SetPoint("CENTER", badgeBg, "CENTER")
badgeText:SetTextColor(0.78, 0.73, 0.64)

-- Badge im Band, "" blendet es aus
local function SetBadge(text)
    local show = text ~= nil and text ~= ""
    badgeBg:SetShown(show)
    badgeText:SetShown(show)
    if show then
        badgeText:SetText(text)
        badgeBg:SetWidth(badgeText:GetStringWidth() + 18)
    end
end
SetBadge("")

-- Positionen der Mengenanzahl relativ zum Icon, per Edit-Mode-Dropdown wählbar.
-- "outside = true" heißt: die Zahl sitzt außerhalb des Icons (nicht als Overlay
-- darauf). Die vier "Außerhalb"-Einträge bekommen zusätzlich eine Pfeil-Vorschau
-- (siehe "texture"), die vier "Icon: ..."-Ecken haben keine sinnvolle einfache
-- Pfeil-Entsprechung und bleiben ohne Icon-Vorschau.
local COUNT_POSITIONS = {
    { label = L("posCenter"),        anchor = "CENTER",      relPoint = "CENTER",      x = 0,  y = 0,  outside = false, justify = "CENTER" },
    { label = L("posBottomRight"),   anchor = "BOTTOMRIGHT", relPoint = "BOTTOMRIGHT", x = 1,  y = -1, outside = false, justify = "RIGHT" },
    { label = L("posTopRight"),      anchor = "TOPRIGHT",    relPoint = "TOPRIGHT",    x = 1,  y = 1,  outside = false, justify = "RIGHT" },
    { label = L("posBottomLeft"),    anchor = "BOTTOMLEFT",  relPoint = "BOTTOMLEFT",  x = -1, y = -1, outside = false, justify = "LEFT" },
    { label = L("posTopLeft"),       anchor = "TOPLEFT",     relPoint = "TOPLEFT",     x = -1, y = 1,  outside = false, justify = "LEFT" },
    { label = L("posOutsideRight"),  anchor = "LEFT",        relPoint = "RIGHT",       x = 4,  y = 0,  outside = true,  justify = "LEFT",   texture = "Interface\\Buttons\\Arrow-Right-Up" },
    { label = L("posOutsideLeft"),   anchor = "RIGHT",       relPoint = "LEFT",        x = -4, y = 0,  outside = true,  justify = "RIGHT",  texture = "Interface\\Buttons\\Arrow-Left-Up" },
    { label = L("posOutsideTop"),    anchor = "BOTTOM",      relPoint = "TOP",         x = 0,  y = 4,  outside = true,  justify = "CENTER", texture = "Interface\\Buttons\\Arrow-Up-Up" },
    { label = L("posOutsideBottom"), anchor = "TOP",         relPoint = "BOTTOM",      x = 0,  y = -4, outside = true,  justify = "CENTER", texture = "Interface\\Buttons\\Arrow-Down-Up" },
}
local countPositionIndex = 1

-- Ansicht der Liste (Option "Icon-Layout"): kompakt untereinander, als Reihe
-- nebeneinander oder mit Namen nach Berufsgruppen sortiert. Pfeil-Icon zeigt die
-- Stapelrichtung. Neue Einträge nur hinten anhängen (gespeicherte Indizes).
local LIST_LAYOUTS = {
    { id = "vertical",   label = L("layoutVertical"),   texture = "Interface\\Buttons\\Arrow-Down-Up" },
    { id = "horizontal", label = L("layoutHorizontal"), texture = "Interface\\Buttons\\Arrow-Right-Up" },
    { id = "grouped",    label = L("layoutGrouped"),    texture = "Interface\\Buttons\\Arrow-Down-Up" },
}
local listLayoutIndex = 1
local ITEM_SLOT_WIDTH = 64 -- horizontaler Abstand zwischen Icons im Horizontal-Layout

-- Richtung, in die die Icon-Liste wächst, wenn weitere Rohstoffe dazukommen.
-- Als flache Liste (nicht mehr abhängig vom aktuellen LIST_LAYOUTS-Modus): eine
-- nicht zum aktuellen Layout passende Richtung (z. B. "Nach oben" im Horizontal-
-- Layout) hat einfach keine sichtbare Wirkung, bis das Layout dazu passt.
local GROWTH_STYLES = {
    { id = "down",  label = L("growthDown"),  texture = "Interface\\Buttons\\Arrow-Down-Up" },
    { id = "up",    label = L("growthUp"),    texture = "Interface\\Buttons\\Arrow-Up-Up" },
    { id = "right", label = L("growthRight"), texture = "Interface\\Buttons\\Arrow-Right-Up" },
    { id = "left",  label = L("growthLeft"),  texture = "Interface\\Buttons\\Arrow-Left-Up" },
}
local growthDirectionIndex = 1

local rowPool = {}

-- Positioniert die Mengenanzahl und den Session-Zähler relativ zum Icon neu,
-- entsprechend der aktuell gewählten COUNT_POSITIONS-Einstellung.
-- Wird in der Ansicht "Kompakt" benutzt; die anderen Ansichten setzen die Anzahl
-- selbst (siehe RenderRows).
local function ApplyCountPosition(row)
    local pos = COUNT_POSITIONS[countPositionIndex] or COUNT_POSITIONS[1]
    row.count:ClearAllPoints()
    row.count:SetPoint(pos.anchor, row.icon, pos.relPoint, pos.x, pos.y)
    row.count:SetJustifyH(pos.justify)
end

-- Gruppenzeile und Reset-Knopf der Ansicht "Mit Namen" (der Knopf wird nach RenderRows
-- erzeugt, ApplyFont kennt ihn deshalb schon vorab)
local resetButton
local headerPool = {}

-- Wendet die aktuell gewählte Schriftart (siehe FONTS) und Schriftgröße
-- (fontSize) auf Titel, Badge sowie Mengen-, Session-Zähler- und Namenstext einer
-- Zeile an. Der Stil (z. B. OUTLINE) der bisherigen Font-Vorlage bleibt erhalten,
-- nur Pfad und Größe werden überschrieben. Der Titel nutzt, falls vorhanden, die
-- Titelschrift (Marcellus).
local function ApplyFont(row)
    local font = FONTS[fontIndex] or FONTS[1]
    local _, _, titleFlags = title:GetFont()
    title:SetFont(font.titlePath or font.path, fontSize + 3, titleFlags)
    local _, _, badgeFlags = badgeText:GetFont()
    badgeText:SetFont(font.path, fontSize, badgeFlags)
    if resetButton then
        local _, _, flags = resetButton.text:GetFont()
        resetButton.text:SetFont(font.path, fontSize, flags)
    end
    for _, h in ipairs(headerPool) do
        for _, fs in ipairs({ h.label, h.sum }) do
            local _, _, flags = fs:GetFont()
            fs:SetFont(font.path, fontSize, flags)
        end
    end
    if row then
        local _, _, countFlags = row.count:GetFont()
        row.count:SetFont(font.path, fontSize, countFlags)
        local _, _, gainedFlags = row.gained:GetFont()
        row.gained:SetFont(font.path, fontSize, gainedFlags)
        local _, _, nameFlags = row.name:GetFont()
        row.name:SetFont(font.path, fontSize + 1, nameFlags)
    end
end

local function CreateRow(index)
    local row = CreateFrame("Frame", nil, frame)
    row:SetHeight(ROW_HEIGHT)

    -- Karte mit Trennlinie (nur in den Listenansichten sichtbar)
    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()
    row.bg:SetColorTexture(0.145, 0.125, 0.10, 1)
    row.divider = row:CreateTexture(nil, "BORDER")
    row.divider:SetPoint("TOPLEFT")
    row.divider:SetPoint("TOPRIGHT")
    row.divider:SetHeight(1)
    row.divider:SetColorTexture(0.21, 0.19, 0.14, 1)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("LEFT", row, "LEFT", 8, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.icon = icon

    local iconBorder = row:CreateTexture(nil, "OVERLAY")
    iconBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
    iconBorder:SetDrawLayer("ARTWORK", -1)
    row.iconBorder = iconBorder

    local count = row:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    row.count = count

    -- Session-Zähler als grünes Etikett
    row.gainedBg = row:CreateTexture(nil, "ARTWORK")
    row.gainedBg:SetColorTexture(TONES.ok.bg[1], TONES.ok.bg[2], TONES.ok.bg[3], 1)
    local gained = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    gained:SetTextColor(TONES.ok.fg[1], TONES.ok.fg[2], TONES.ok.fg[3])
    row.gained = gained

    -- Name (nur in der Ansicht "Mit Namen")
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    row.name = name

    ApplyCountPosition(row)
    ApplyFont(row)
    ApplyIconBorderStyle(row)

    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        if not self.itemID then return end
        -- Am Icon verankern, nicht an der Row selbst: die Row-Hitbox ist im
        -- Vertikal-Layout auf die feste FRAME_WIDTH-Konstante breit gesetzt
        -- (siehe RenderRows), die vom tatsächlich berechneten, meist viel
        -- schmaleren Fenster abweicht - ANCHOR_RIGHT relativ zur Row landete
        -- dadurch weit außerhalb des sichtbaren Icons.
        GameTooltip:SetOwner(self.icon, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(self.itemID)
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return row
end

local function GetRow(index)
    local row = rowPool[index]
    if not row then
        row = CreateRow(index)
        rowPool[index] = row
    end
    return row
end

------------------------------------------------------------------------------
-- Rendering
------------------------------------------------------------------------------

-- Ändert die Fenstergröße. Der Ankerpunkt ist BOTTOMLEFT (siehe RegisterFrame-
-- Aufruf), daher hält WoW die untere linke Ecke bei SetSize() automatisch fest -
-- keine manuelle Nachjustierung nötig.
local function ResizeFramePreservingPosition(width, height)
    frame:SetSize(width, height)
    local db = SexyHarvesterDB.editMode
    if db then
        db.x, db.y = frame:GetRect()
    end
end

-- Gruppenzeile (Beruf) der Ansicht "Mit Namen": Etikett links, Summe rechts
local function GetHeader(i)
    local h = headerPool[i]
    if h then return h end
    h = CreateFrame("Frame", nil, frame)
    h:SetHeight(GROUP_HEADER_H)
    h.bg = h:CreateTexture(nil, "BACKGROUND")
    h.bg:SetAllPoints()
    h.bg:SetColorTexture(0.15, 0.12, 0.07, 0.96)
    h.pill = h:CreateTexture(nil, "ARTWORK")
    h.pill:SetPoint("LEFT", h, "LEFT", 8, 0)
    h.pill:SetHeight(16)
    h.label = h:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    h.label:SetPoint("CENTER", h.pill, "CENTER")
    h.sum = h:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    h.sum:SetPoint("RIGHT", h, "RIGHT", -8, 0)
    h.sum:SetTextColor(0.61, 0.57, 0.5)
    headerPool[i] = h
    ApplyFont() -- Schrift auch auf die neue Gruppenzeile anwenden
    return h
end

-- Setzt das Session-Etikett (Fläche und Text darauf) an einen Ankerpunkt
local function PlaceGained(row, point, relTo, relPoint, x, y, width)
    row.gainedBg:ClearAllPoints()
    row.gainedBg:SetPoint(point, relTo, relPoint, x, y)
    row.gainedBg:SetSize(width, 16)
    row.gained:ClearAllPoints()
    row.gained:SetPoint("CENTER", row.gainedBg, "CENTER", 0, 0)
end

local function RenderRows()
    local layout = LIST_LAYOUTS[listLayoutIndex] or LIST_LAYOUTS[1]
    local horizontal, grouped = layout.id == "horizontal", layout.id == "grouped"
    local growthStyle = GROWTH_STYLES[growthDirectionIndex] or GROWTH_STYLES[1]
    local up = growthStyle.id == "up"

    title:SetShown(not hideTitle)
    band:SetShown(not hideTitle)
    local topOffset = hideTitle and FRAME_PADDING or (HEADER_HEIGHT + 4)

    -- Sortierte Liste der aktuell gehaltenen Sammelrohstoffe aufbauen. In der Ansicht
    -- "Mit Namen" zuerst nach Berufsgruppe, sonst nur nach Name.
    local entries = {}
    for itemID, count in pairs(currentCounts) do
        if count and count > 0 then
            local name = GetItemData(itemID)
            entries[#entries + 1] = {
                itemID = itemID, count = count, name = name or tostring(itemID),
                group = grouped and GroupOf(itemID) or nil,
            }
        end
    end
    table.sort(entries, function(a, b)
        if grouped and a.group ~= b.group then return GROUP_ORDER[a.group] < GROUP_ORDER[b.group] end
        return a.name < b.name
    end)

    -- Badge im Band: in dieser Session gesammelte Menge insgesamt
    local totalGained = 0
    for _, e in ipairs(entries) do totalGained = totalGained + (sessionGained[e.itemID] or 0) end
    if not hideTitle and not hideGained and totalGained > 0 then
        SetBadge("+" .. totalGained .. (grouped and (" " .. L("session")) or ""))
    else
        SetBadge("")
    end

    -- Inhalt der Zeilen; dabei die Breiten der Spalten messen
    local maxGainW, maxCountW, maxNameW, anyGained = 0, 0, 0, false
    for i, entry in ipairs(entries) do
        local row = GetRow(i)
        row.itemID = entry.itemID
        row.icon:SetTexture(GetItemIcon(entry.itemID))
        row.count:SetText(entry.count)
        row.count:SetShown(not hideCount)
        row.name:SetText(entry.name)
        row.name:SetShown(grouped)
        row.bg:SetShown(not horizontal)
        row.divider:SetShown(not horizontal)

        local gained = sessionGained[entry.itemID]
        local showGained = (not hideGained) and gained and gained > 0
        row.gained:SetText(showGained and ("+" .. gained) or "")
        row.gained:SetShown(showGained and true or false)
        row.gainedBg:SetShown(showGained and true or false)
        if showGained then
            anyGained = true
            maxGainW = math.max(maxGainW, row.gained:GetStringWidth())
        end
        maxCountW = math.max(maxCountW, row.count:GetStringWidth())
        maxNameW = math.max(maxNameW, row.name:GetStringWidth())
    end
    local pillW = anyGained and math.max(PILL_MIN, maxGainW + 18) or 0

    for _, h in ipairs(headerPool) do h:Hide() end
    for i = #entries + 1, #rowPool do
        rowPool[i]:Hide()
    end
    resetButton:SetShown(grouped and #entries > 0)

    if #entries == 0 then
        frame:Hide()
        return
    end

    local width, height
    if horizontal then
        -- Als Reihe: je Rohstoff ein Fach mit Icon, Anzahl darunter und Session-Etikett
        local slotH = 6 + SLOT_ICON + (hideCount and 0 or 16) + (anyGained and 22 or 0) + 6
        for i = 1, #entries do
            local row = rowPool[i]
            row:ClearAllPoints()
            row:SetSize(ITEM_SLOT_WIDTH, slotH)
            -- feste, schmale Spalten, damit sich die Mauszeiger-Trefferflächen nicht überlappen
            if growthStyle.id == "left" then
                row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4 - (i - 1) * ITEM_SLOT_WIDTH, -topOffset)
            else
                row:SetPoint("TOPLEFT", frame, "TOPLEFT", 4 + (i - 1) * ITEM_SLOT_WIDTH, -topOffset)
            end
            row.icon:SetSize(SLOT_ICON, SLOT_ICON)
            row.icon:ClearAllPoints()
            row.icon:SetPoint("TOP", row, "TOP", 0, -6)
            row.count:ClearAllPoints()
            row.count:SetPoint("TOP", row.icon, "BOTTOM", 0, -3)
            row.count:SetWidth(0)
            row.count:SetJustifyH("CENTER")
            PlaceGained(row, "TOP", hideCount and row.icon or row.count, "BOTTOM", 0, -4, pillW)
            row:Show()
        end
        width = 8 + #entries * ITEM_SLOT_WIDTH
        height = topOffset + slotH
    elseif not grouped then
        -- Kompakt: Icon mit Anzahl (Position wählbar), Session-Etikett rechts
        local pos = COUNT_POSITIONS[countPositionIndex] or COUNT_POSITIONS[1]
        local outsideLeft = pos.outside and pos.anchor == "RIGHT" and not hideCount
        local outsideRight = pos.outside and pos.anchor == "LEFT" and not hideCount
        local leftExtra = outsideLeft and (maxCountW + 4) or 0
        local rightExtra = outsideRight and (maxCountW + 4) or 0
        for i = 1, #entries do
            local row = rowPool[i]
            row:ClearAllPoints()
            row:SetHeight(ROW_HEIGHT)
            if up then
                row:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 2, FRAME_PADDING + (i - 1) * ROW_HEIGHT)
                row:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, FRAME_PADDING + (i - 1) * ROW_HEIGHT)
            else
                row:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -topOffset - (i - 1) * ROW_HEIGHT)
                row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -topOffset - (i - 1) * ROW_HEIGHT)
            end
            row.icon:SetSize(ICON_SIZE, ICON_SIZE)
            row.icon:ClearAllPoints()
            row.icon:SetPoint("LEFT", row, "LEFT", 8 + leftExtra, 0)
            row.count:SetWidth(0)
            ApplyCountPosition(row)
            PlaceGained(row, "RIGHT", row, "RIGHT", -8, 0, pillW)
            row:Show()
        end
        width = math.max(120, 8 + leftExtra + ICON_SIZE + rightExtra + 8 + (anyGained and (12 + pillW) or 0))
        height = topOffset + #entries * ROW_HEIGHT + FRAME_PADDING
    else
        -- Mit Namen: Gruppenzeile je Beruf, darunter Icon, Name, Anzahl und Session-Etikett
        local colW = anyGained and (pillW + 8) or 0
        local countRight = 8 + colW
        local countW = hideCount and 0 or (maxCountW + 2)
        local groupSums = {}
        for _, e in ipairs(entries) do groupSums[e.group] = (groupSums[e.group] or 0) + e.count end

        local elements, lastGroup, headers = {}, nil, 0
        for i, e in ipairs(entries) do
            if e.group ~= lastGroup then
                lastGroup = e.group
                headers = headers + 1
                local h = GetHeader(headers)
                local tone = TONES[GROUP_TONE[e.group]]
                h.label:SetText(L(GROUP_LABEL[e.group]))
                h.label:SetTextColor(tone.fg[1], tone.fg[2], tone.fg[3])
                h.pill:SetColorTexture(tone.bg[1], tone.bg[2], tone.bg[3], 1)
                h.pill:SetWidth(h.label:GetStringWidth() + 18)
                h.sum:SetText(groupSums[e.group])
                elements[#elements + 1] = { h, GROUP_HEADER_H }
            end
            local row = rowPool[i]
            row:SetHeight(GROUP_ROW_H)
            row.icon:SetSize(ICON_SIZE, ICON_SIZE)
            row.icon:ClearAllPoints()
            row.icon:SetPoint("LEFT", row, "LEFT", 8, 0)
            row.count:ClearAllPoints()
            row.count:SetPoint("RIGHT", row, "RIGHT", -countRight, 0)
            row.count:SetWidth(countW)
            row.count:SetJustifyH("RIGHT")
            row.name:ClearAllPoints()
            row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
            row.name:SetPoint("RIGHT", row, "RIGHT", -(countRight + (hideCount and 0 or countW + 8)), 0)
            PlaceGained(row, "RIGHT", row, "RIGHT", -8, 0, pillW)
            elements[#elements + 1] = { row, GROUP_ROW_H }
        end

        local offset = 0
        for _, el in ipairs(elements) do
            local f, h = el[1], el[2]
            f:ClearAllPoints()
            if up then
                f:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 2, FOOTER_H + offset)
                f:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, FOOTER_H + offset)
            else
                f:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -(topOffset + offset))
                f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -(topOffset + offset))
            end
            f:Show()
            offset = offset + h
        end
        width = math.min(340, math.max(220, 8 + ICON_SIZE + 8 + maxNameW + (hideCount and 0 or (8 + countW)) + 8 + colW))
        height = topOffset + offset + FOOTER_H
    end

    -- Titel und Badge müssen ins Band passen
    if not hideTitle then
        local need = 10 + title:GetStringWidth() + 12
        if badgeBg:IsShown() then need = need + badgeBg:GetWidth() + 12 end
        width = math.max(width, need)
    end
    ResizeFramePreservingPosition(width, height)
    frame:Show()
end

-- Session-Zähler zurücksetzen (Knopf in der Ansicht "Mit Namen" und /sh reset)
local function ResetSession()
    wipe(sessionGained)
    RenderRows()
    print("|cff1eff00SexyHarvester|r: " .. L("resetConfirm"))
end

resetButton = CreateFrame("Button", nil, frame)
resetButton:SetHeight(22)
resetButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", FRAME_PADDING, 8)
resetButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -FRAME_PADDING, 8)
resetButton:RegisterForClicks("LeftButtonUp")
resetButton.bg = resetButton:CreateTexture(nil, "BACKGROUND")
resetButton.bg:SetAllPoints()
resetButton.bg:SetColorTexture(0.184, 0.42, 0.235, 1)
resetButton.hl = resetButton:CreateTexture(nil, "HIGHLIGHT")
resetButton.hl:SetAllPoints()
resetButton.hl:SetColorTexture(1, 1, 1, 0.25)
resetButton.text = resetButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
resetButton.text:SetAllPoints()
resetButton.text:SetText(L("resetButton"))
resetButton:SetScript("OnClick", ResetSession)
resetButton:Hide()
ApplyFont()

------------------------------------------------------------------------------
-- Inventar-Scan
------------------------------------------------------------------------------

-- Reagenztasche (Retail-Feature, Container-Index 5) wird auf Clients ohne dieses
-- Feature einfach mit 0 Slots übersprungen - GetContainerNumSlots(5) liefert
-- dort harmlos 0, kein Fehler. Explizit mitscannen, da Crafting-Reagenzien wie
-- Sammelrohstoffe dort automatisch einsortiert werden können.
local REAGENT_BAG_INDEX = 5

local function ScanBags()
    local newCounts = {}
    local numBags = math.max(NUM_BAG_SLOTS or 4, REAGENT_BAG_INDEX)

    for bag = 0, numBags do
        local slots = GetBagSlots(bag) or 0
        for slot = 1, slots do
            local itemID = GetBagItemID(bag, slot)
            if itemID then
                local isGathering = IsGatheringMaterial(itemID)
                if isGathering == nil then
                    -- Item-Info noch nicht gecacht -> merken und später erneut prüfen
                    pendingItemIDs[itemID] = true
                elseif isGathering then
                    newCounts[itemID] = GetTotalItemCount(itemID)
                end
            end
        end
    end

    if not initialized then
        -- Erster Scan dieser Session: aktuelle Bestände sind die Baseline,
        -- noch keine "in dieser Session gesammelt"-Werte.
        currentCounts = newCounts
        initialized = true
        RenderRows()
        return
    end

    for itemID, newCount in pairs(newCounts) do
        local oldCount = currentCounts[itemID] or 0
        if newCount > oldCount then
            sessionGained[itemID] = (sessionGained[itemID] or 0) + (newCount - oldCount)
        end
    end

    currentCounts = newCounts
    RenderRows()
end

------------------------------------------------------------------------------
-- Event-Handling mit Entprellung (mehrere BAG_UPDATE-Events pro Klick abfedern)
------------------------------------------------------------------------------

local pendingScan = false
local scanTicker = CreateFrame("Frame")
local elapsedSinceRequest = 0

local function RequestScan()
    pendingScan = true
end

scanTicker:SetScript("OnUpdate", function(self, elapsed)
    if not pendingScan then return end
    elapsedSinceRequest = elapsedSinceRequest + elapsed
    if elapsedSinceRequest >= 0.2 then
        elapsedSinceRequest = 0
        pendingScan = false
        ScanBags()
    end
end)

------------------------------------------------------------------------------
-- Darstellungs-Dropdowns im Edit-Mode-Dialog
-- LibUIDropDownMenu (Fork "LibUIDropDownMenuQuestie-4.0", siehe Libs) statt
-- Blizzards eigenem UIDropDownMenuTemplate: Letzteres lässt sich laut
-- EditModeExpanded-Autor nicht taint-frei innerhalb des Edit-Mode-Dialogs
-- verwenden, lib:RegisterDropdown verlangt deshalb eine externe Dropdown-Lib.
------------------------------------------------------------------------------

-- Je eine Font-Vorschau pro FONTS-Eintrag, damit die Auswahlliste die Schriftart
-- direkt im echten Look zeigt, statt nur den Namen in der Standardschrift.
local FONT_OBJECTS = {}
for i, font in ipairs(FONTS) do
    local fontObject = CreateFont("SexyHarvesterFontPreview" .. i)
    fontObject:SetFont(font.path, 12, "")
    fontObject:SetTextColor(1, 1, 1)
    FONT_OBJECTS[i] = fontObject
end

local function SetBackgroundIndex(index)
    backgroundIndex = index
    SexyHarvesterDB.style.background = index
    ApplyBackground()
end

local function SetBorderIndex(index)
    borderIndex = index
    SexyHarvesterDB.style.border = index
    ApplyFrameBorder()
end

local function SetIconBorderIndex(index)
    iconBorderIndex = index
    SexyHarvesterDB.style.iconBorder = index
    for _, row in ipairs(rowPool) do
        ApplyIconBorderStyle(row)
    end
end

local function SetFontIndex(index)
    fontIndex = index
    SexyHarvesterDB.style.font = index
    ApplyFont()
    for _, row in ipairs(rowPool) do
        ApplyFont(row)
    end
end

local function SetFontSize(size)
    fontSize = size
    SexyHarvesterDB.style.fontSize = size
    ApplyFont()
    for _, row in ipairs(rowPool) do
        ApplyFont(row)
    end
    RenderRows() -- Breite/Höhe hängen u. a. von der Titel-Textbreite ab
end

local function SetCountPositionIndex(index)
    countPositionIndex = index
    SexyHarvesterDB.style.countPosition = index
    RenderRows() -- setzt Anzahl und Breite je nach Ansicht neu
end

local function SetListLayoutIndex(index)
    listLayoutIndex = index
    SexyHarvesterDB.style.listLayout = index
    RenderRows()
end

local function SetGrowthDirectionIndex(index)
    growthDirectionIndex = index
    SexyHarvesterDB.style.growthDirection = index
    RenderRows()
end

-- Setzt Farbfeld- oder Bild-Vorschau eines Dropdown-Eintrags: "texture" zeigt
-- die echte Textur/das Icon (Hintergrund-Texturen, Pfeil-Icons für Position/
-- Layout/Wachstumsrichtung), sonst - falls vorhanden - ein Farbfeld aus r/g/b.
local function ApplyDropdownEntryPreview(info, style)
    if style.texture then
        info.icon = style.texture
    elseif style.r then
        info.colorSwatch = true
        info.swatchFunc = function() end
        info.r, info.g, info.b = style.r, style.g, style.b
    end
end

-- lib:RegisterDropdown hat - anders als RegisterCustomCheckbox/RegisterSlider/
-- RegisterCustomButton - keinen "name"-Parameter und dementsprechend keine
-- eingebaute Zeilenbeschriftung im Edit-Mode-Dialog (SetupSetting ist dort ein
-- reines no-op). Fügt daher wie SexyInterrupter ein eigenes Label links neben
-- dem Dropdown ein, in derselben Schriftart (GameFontHighlightMedium) wie
-- Blizzards eigene Checkbox-/Slider-Zeilen.
local function AddEditModeDropdownLabel(dropdown, label)
    local layoutFrame = dropdown:GetParent()

    local labelText = layoutFrame:CreateFontString(nil, nil, "GameFontHighlightMedium")
    labelText:SetPoint("LEFT", layoutFrame, "LEFT", 0, 0)
    labelText:SetJustifyH("LEFT")
    labelText:SetWidth(100)
    labelText:SetText(label)

    dropdown:ClearAllPoints()
    dropdown:SetPoint("LEFT", labelText, "RIGHT", 5, -2)
end

-- Registriert ein Dropdown für eine Options-Liste (BACKGROUND_STYLES/BORDER_STYLES/
-- EDGE_STYLES/COUNT_POSITIONS/LIST_LAYOUTS/GROWTH_STYLES) im Edit-Mode-Dialog,
-- inkl. Label, Farbfeld- oder Bild-Vorschau und Häkchen bei der aktuell
-- gewählten Option.
local function RegisterEditModeStyleDropdown(lib, LibDD, frame, internalName, label, styles, getIndex, setIndex)
    local dropdown = lib:RegisterDropdown(frame, LibDD, internalName)
    AddEditModeDropdownLabel(dropdown, label)

    local function RefreshText()
        LibDD:UIDropDownMenu_SetText(dropdown, styles[getIndex()].label)
    end

    LibDD:UIDropDownMenu_Initialize(dropdown, function(self, level)
        for i, style in ipairs(styles) do
            local info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = style.label
            info.checked = (i == getIndex())
            ApplyDropdownEntryPreview(info, style)
            info.func = function()
                setIndex(i)
                RefreshText()
            end
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end)

    LibDD:UIDropDownMenu_SetWidth(dropdown, 150)
    RefreshText()
end

-- Wie oben, aber für die Schriftarten-Liste (FONTS) mit Live-Vorschau je Eintrag
-- über FONT_OBJECTS.
local function RegisterEditModeFontDropdown(lib, LibDD, frame, internalName, label)
    local dropdown = lib:RegisterDropdown(frame, LibDD, internalName)
    AddEditModeDropdownLabel(dropdown, label)

    local function RefreshText()
        LibDD:UIDropDownMenu_SetText(dropdown, FONTS[fontIndex].label)
    end

    LibDD:UIDropDownMenu_Initialize(dropdown, function(self, level)
        for i, font in ipairs(FONTS) do
            local info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = font.label
            info.fontObject = FONT_OBJECTS[i]
            info.checked = (i == fontIndex)
            info.func = function()
                SetFontIndex(i)
                RefreshText()
            end
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end)

    LibDD:UIDropDownMenu_SetWidth(dropdown, 150)
    RefreshText()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == ADDON_NAME then
            SexyHarvesterDB.editMode = SexyHarvesterDB.editMode or {}
            local lib = LibStub("EditModeExpanded-1.0")
            -- Registriert unser Fenster in Blizzards Edit Mode (Esc -> Edit-Modus):
            -- Position/Klemmen wird von der Library verwaltet und in
            -- SexyHarvesterDB.editMode persistiert. Ankerpunkt BOTTOMLEFT: die
            -- Umrechnungsformel dafür in EditModeExpanded-1.0.lua (getOffsetXY)
            -- ist die einzige, die OHNE die aktuelle Fensterbreite/-höhe auskommt.
            -- Alle anderen Ankerpunkte (u. a. TOPLEFT, CENTER) beziehen die Größe
            -- mit ein - da sich unsere Fenstergröße laufend ändert (Itemanzahl,
            -- Schriftgröße, Layout) und beim Registrieren/beim "Frame Size"-Regler
            -- (RegisterResizable, läuft bei JEDEM Reload) noch die winzige
            -- Platzhaltergröße gilt statt der späteren Inhaltsgröße, sprang das
            -- Fenster damit bei jedem Reload an eine andere/falsche Position.
            lib:RegisterFrame(frame, L("title"), SexyHarvesterDB.editMode, UIParent, "BOTTOMLEFT", true)

            -- Hintergrund/Rahmen/Icon-Rahmen/Schriftart/Position/Layout/Wachstumsrichtung:
            -- eigener Zustand geladen aus SexyHarvesterDB.style, Auswahl erfolgt über
            -- echte Dropdowns weiter unten. Vor der Frame-Size/Schriftgröße-
            -- Registrierung geladen, da deren Anfangswert (fontSize) davon abhängt.
            SexyHarvesterDB.style = SexyHarvesterDB.style or {}
            -- Ohne gespeicherte Wahl gilt der Quest-Look (Fläche, Goldrand, Marcellus + Inter)
            backgroundIndex = SexyHarvesterDB.style.background or DEFAULT_BACKGROUND
            borderIndex = SexyHarvesterDB.style.border or DEFAULT_BORDER
            iconBorderIndex = SexyHarvesterDB.style.iconBorder or DEFAULT_ICON_BORDER
            fontIndex = SexyHarvesterDB.style.font or DEFAULT_FONT
            fontSize = SexyHarvesterDB.style.fontSize or 11
            countPositionIndex = SexyHarvesterDB.style.countPosition or 1
            listLayoutIndex = SexyHarvesterDB.style.listLayout or 1
            growthDirectionIndex = SexyHarvesterDB.style.growthDirection or 1
            ApplyBackground()
            ApplyFrameBorder()
            ApplyFont()
            for _, row in ipairs(rowPool) do
                ApplyIconBorderStyle(row)
                ApplyFont(row)
                ApplyCountPosition(row)
            end

            -- Größe: Skalierungs-Regler (50%-200%) im Edit-Mode-Einstellungsdialog
            lib:RegisterResizable(frame, 50, 200, 10)

            -- Schriftgröße-Regler direkt unter "Frame Size". lib:RegisterSlider zeigt
            -- beim ersten Öffnen des Dialogs standardmäßig 100 an, falls noch kein
            -- Wert in der Library-eigenen DB gespeichert ist - deshalb hier vorab mit
            -- unserem tatsächlichen fontSize-Wert seeden (siehe
            -- ENUM_EDITMODEACTIONBARSETTING_SLIDER = 18 in EditModeExpanded-1.0.lua).
            local EME_SETTING_TYPE_SLIDER = 18
            SexyHarvesterDB.editMode.settings = SexyHarvesterDB.editMode.settings or {}
            SexyHarvesterDB.editMode.settings[EME_SETTING_TYPE_SLIDER] = SexyHarvesterDB.editMode.settings[EME_SETTING_TYPE_SLIDER] or {}
            SexyHarvesterDB.editMode.settings[EME_SETTING_TYPE_SLIDER]["fontSize"] = fontSize
            lib:RegisterSlider(frame, L("fontSize"), "fontSize", SetFontSize, 8, 24, 1)

            -- Zusätzliche Checkboxen im selben Dialog: Titel und Mengenanzeige
            -- lassen sich einzeln ausblenden, sind aber standardmäßig an.
            lib:RegisterCustomCheckbox(frame, L("hideTitle"),
                function() hideTitle = true; RenderRows() end,
                function() hideTitle = false; RenderRows() end,
                "hideTitle")
            lib:RegisterCustomCheckbox(frame, L("hideCount"),
                function() hideCount = true; RenderRows() end,
                function() hideCount = false; RenderRows() end,
                "hideCount")
            lib:RegisterCustomCheckbox(frame, L("hideGained"),
                function() hideGained = true; RenderRows() end,
                function() hideGained = false; RenderRows() end,
                "hideGained")

            -- Echte Dropdowns mit Vorschau im Edit-Mode-Dialog (siehe LibUIDropDownMenu
            -- oben, gleiches Vorgehen wie bei SexyInterrupter).
            local LibDD = LibStub("LibUIDropDownMenuQuestie-4.0")
            RegisterEditModeStyleDropdown(lib, LibDD, frame, "background", L("background"), BACKGROUND_STYLES,
                function() return backgroundIndex end, SetBackgroundIndex)
            RegisterEditModeStyleDropdown(lib, LibDD, frame, "border", L("border"), BORDER_STYLES,
                function() return borderIndex end, SetBorderIndex)
            RegisterEditModeStyleDropdown(lib, LibDD, frame, "iconBorder", L("iconBorder"), EDGE_STYLES,
                function() return iconBorderIndex end, SetIconBorderIndex)
            RegisterEditModeFontDropdown(lib, LibDD, frame, "font", L("font"))
            RegisterEditModeStyleDropdown(lib, LibDD, frame, "countPosition", L("countPosition"), COUNT_POSITIONS,
                function() return countPositionIndex end, SetCountPositionIndex)
            RegisterEditModeStyleDropdown(lib, LibDD, frame, "listLayout", L("listLayout"), LIST_LAYOUTS,
                function() return listLayoutIndex end, SetListLayoutIndex)
            RegisterEditModeStyleDropdown(lib, LibDD, frame, "growthDirection", L("growthDirection"), GROWTH_STYLES,
                function() return growthDirectionIndex end, SetGrowthDirectionIndex)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        RequestScan()
    elseif event == "BAG_UPDATE" then
        RequestScan()
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        local itemID, success = ...
        if success and pendingItemIDs[itemID] then
            pendingItemIDs[itemID] = nil
            RequestScan()
        end
    end
end)

------------------------------------------------------------------------------
-- Slash-Commands
------------------------------------------------------------------------------

SLASH_SEXYHARVESTER1 = "/sh"
SLASH_SEXYHARVESTER2 = "/sexyharvester"
SlashCmdList["SEXYHARVESTER"] = function(msg)
    msg = string.lower(strtrim(msg or ""))
    if msg == "reset" then
        ResetSession()
    elseif msg == "debug" then
        print("|cff1eff00SexyHarvester|r Debug: Taschen-Rohdaten")
        local numBags = math.max(NUM_BAG_SLOTS or 4, REAGENT_BAG_INDEX)
        for bag = 0, numBags do
            local slots = GetBagSlots(bag) or 0
            for slot = 1, slots do
                local itemID = GetBagItemID(bag, slot)
                if itemID then
                    local name, _, _, _, _, itemType, subType, _, equipLoc, _, _, classID, subClassID = GetItemData(itemID)
                    print(("  Bag %d Slot %d: itemID=%s name=%s type=%s subType=%s equipLoc=%s classID=%s subClassID=%s isGathering=%s"):format(
                        bag, slot, tostring(itemID), tostring(name), tostring(itemType), tostring(subType),
                        tostring(equipLoc), tostring(classID), tostring(subClassID), tostring(IsGatheringMaterial(itemID))))
                end
            end
        end

        -- Frischen Scan erzwingen (nicht nur RenderRows), damit currentCounts
        -- auch Items berücksichtigt, deren Info erst jetzt im Client-Cache liegt.
        ScanBags()

        local countedItems = 0
        for itemID, count in pairs(currentCounts) do
            if count and count > 0 then
                countedItems = countedItems + 1
                print(("  currentCounts[%d] = %d"):format(itemID, count))
            end
        end
        print("|cff1eff00SexyHarvester|r Debug:")
        print("  initialized=" .. tostring(initialized) .. "  currentCounts-Einträge (>0)=" .. countedItems)
        print("  frame:IsShown()=" .. tostring(frame:IsShown()) .. "  Breite=" .. math.floor(frame:GetWidth() or -1) .. "  Höhe=" .. math.floor(frame:GetHeight() or -1))
        do
            local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(1)
            print(("  frame:GetPoint(1)= point=%s relativePoint=%s x=%s y=%s"):format(
                tostring(point), tostring(relativePoint), tostring(xOfs and math.floor(xOfs)), tostring(yOfs and math.floor(yOfs))))
            print(("  frame Left=%s Right=%s Top=%s Bottom=%s"):format(
                tostring(frame:GetLeft() and math.floor(frame:GetLeft())),
                tostring(frame:GetRight() and math.floor(frame:GetRight())),
                tostring(frame:GetTop() and math.floor(frame:GetTop())),
                tostring(frame:GetBottom() and math.floor(frame:GetBottom()))))
            print(("  title Top=%s Bottom=%s"):format(
                tostring(title:GetTop() and math.floor(title:GetTop())),
                tostring(title:GetBottom() and math.floor(title:GetBottom()))))
            local db = SexyHarvesterDB.editMode
            print(("  db.x=%s db.y=%s db.enabled=%s"):format(
                tostring(db and db.x), tostring(db and db.y), tostring(db and db.enabled)))
            print(("  frame:GetScale()=%s frame:GetEffectiveScale()=%s UIParent:GetEffectiveScale()=%s"):format(
                tostring(frame:GetScale()), tostring(frame:GetEffectiveScale()), tostring(UIParent:GetEffectiveScale())))
            local uiLeft, uiBottom = UIParent:GetRect()
            print(("  UIParent Left=%s Bottom=%s"):format(tostring(uiLeft), tostring(uiBottom)))
        end
        print("  hideTitle=" .. tostring(hideTitle) .. "  hideCount=" .. tostring(hideCount) .. "  hideGained=" .. tostring(hideGained))
        print("  backgroundIndex=" .. backgroundIndex .. "  borderIndex=" .. borderIndex .. "  iconBorderIndex=" .. iconBorderIndex .. "  fontIndex=" .. fontIndex)
        print("  countPositionIndex=" .. countPositionIndex .. "  listLayoutIndex=" .. listLayoutIndex .. "  growthDirectionIndex=" .. growthDirectionIndex)
        print("  rowPool-Anzahl=" .. #rowPool)
        for i, row in ipairs(rowPool) do
            print(("  row %d: shown=%s itemID=%s icon-texture=%s Top=%s Bottom=%s"):format(
                i, tostring(row:IsShown()), tostring(row.itemID), tostring(row.icon:GetTexture()),
                tostring(row:GetTop() and math.floor(row:GetTop())), tostring(row:GetBottom() and math.floor(row:GetBottom()))))
        end
    else
        print("|cff1eff00SexyHarvester|r " .. L("helpHeader"))
        print("  " .. L("helpReset"))
        print("  " .. L("helpDebug"))
        print("  " .. L("helpMove"))
        print("  " .. L("helpAppearance"))
    end
end
