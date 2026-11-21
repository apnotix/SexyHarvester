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

    layoutVertical  = { de = "Kompakt",                     en = "Compact" },
    layoutHorizontal= { de = "Reihe",                       en = "Row" },
    layoutGrouped   = { de = "Gruppiert",                  en = "Grouped" },

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
    sectionView     = { de = "Anzeige",                    en = "Display" },
    sectionLook     = { de = "Darstellung",                en = "Appearance" },
    previewHerb     = { de = "Friedensblume",              en = "Peacebloom" },
    previewOre      = { de = "Kupfererz",                  en = "Copper Ore" },
    previewLeather  = { de = "Leichtes Leder",             en = "Light Leather" },

    growthDown      = { de = "Nach unten",                  en = "Downward" },
    growthUp        = { de = "Nach oben",                   en = "Upward" },
    growthRight     = { de = "Nach rechts",                 en = "Rightward" },
    growthLeft      = { de = "Nach links",                  en = "Leftward" },

    resetConfirm    = { de = "Session-Zähler zurückgesetzt.", en = "Session counter reset." },
    helpHeader      = { de = "Befehle:",                    en = "Commands:" },
    helpReset       = { de = "/sh reset - Session-Zähler zurücksetzen", en = "/sh reset - reset the session counter" },
    helpDebug       = { de = "/sh debug - internen Zustand in den Chat ausgeben (zur Fehlersuche)", en = "/sh debug - print internal state to chat (for troubleshooting)" },
    helpMove        = { de = "Position verschieben: Esc -> Edit-Modus -> 'Sammelberufe' anwählen und ziehen.", en = "Move: Esc -> Edit Mode -> select 'Professions' and drag." },
    helpAppearance  = { de = "Aussehen/Layout (Ansicht, Schrift, Position, Größe, Sichtbarkeit): Esc -> Edit-Modus -> Fenster 'Sammelberufe' anklicken.", en = "Appearance/Layout (view, font, position, size, visibility): Esc -> Edit Mode -> click the 'Professions' window." },
}

local SEM = LibStub("SexyEditMode-1.0")

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



-- Hintergrund und die älteren Rahmen-Stile sind einfache Textur-Flächen mit
-- Vertex-Farbe. Nur der Quest-Look-Rahmen (Tooltip-Rand wie in SexyQuestHelper) nutzt
-- BackdropTemplate; fehlt es, bleibt der Rahmen eine flache Linie.
local frame = CreateFrame("Frame", "SexyHarvesterFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
frame:SetSize(FRAME_WIDTH, HEADER_HEIGHT + FRAME_PADDING * 2)
frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
-- Verschieben im Edit Mode, Größe und Sichtbarkeit übernimmt SexyEditMode-1.0
-- (siehe ADDON_LOADED weiter unten); der Anker ist BOTTOMLEFT.

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

-- Abstand des Inhalts zum Fensterrand: 3 px beim Tooltip-Rand des Quest-Looks, sonst 2 px.
-- Titelband und Zeilen richten sich danach (siehe ApplyInset weiter unten).
local inset = 2
local ApplyInset

local QUEST_BACKDROP = {
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

-- Setzt den per borderIndex gewählten Fensterrahmen-Stil (siehe BORDER_STYLES).
local function ApplyFrameBorder()
    local style = BORDER_STYLES[borderIndex] or BORDER_STYLES[1]
    local quest = style.id == "quest" and frame.SetBackdrop ~= nil
    inset = quest and 3 or 2

    if frame.SetBackdrop then
        if quest then
            frame:SetBackdrop(QUEST_BACKDROP)
            frame:SetBackdropBorderColor(style.r, style.g, style.b, style.a)
        else
            frame:SetBackdrop(nil)
        end
    end

    -- Fläche unter dem runden Tooltip-Rand einrücken, sonst ragen ihre Ecken heraus
    background:ClearAllPoints()
    if quest then
        background:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -3)
        background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 3)
    else
        background:SetAllPoints(frame)
    end
    if ApplyInset then ApplyInset() end

    if quest or style.id == "none" then
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
band:SetColorTexture(0.15, 0.12, 0.07, 0.96)

-- Band passend zum Rand (inset) setzen; wird bei jedem Rahmenwechsel aufgerufen
ApplyInset = function()
    band:ClearAllPoints()
    band:SetPoint("TOPLEFT", frame, "TOPLEFT", inset, -inset)
    band:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -inset, -inset)
    band:SetHeight(HEADER_HEIGHT - inset)
end
ApplyInset()

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
end

-- Beispiel-Einträge, die das Fenster im Edit Mode zeigt (auch ohne gehaltene Rohstoffe)
local function PreviewEntries()
    local list = {
        { name = L("previewHerb"), count = 24, gained = 6, group = "herb", icon = 134187 },
        { name = L("previewOre"), count = 15, gained = 3, group = "ore", icon = 134574 },
        { name = L("previewLeather"), count = 8, gained = 2, group = "leather", icon = 134352 },
    }
    return list
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
    if #entries == 0 and SEM:IsEditing("SexyHarvester") then
        entries = PreviewEntries()
        if not grouped then for _, e in ipairs(entries) do e.group = nil end end
    end
    table.sort(entries, function(a, b)
        if grouped and a.group ~= b.group then return GROUP_ORDER[a.group] < GROUP_ORDER[b.group] end
        return a.name < b.name
    end)

    -- Badge im Band: in dieser Session gesammelte Menge insgesamt
    local totalGained = 0
    for _, e in ipairs(entries) do totalGained = totalGained + (e.gained or sessionGained[e.itemID] or 0) end
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
        row.icon:SetTexture(entry.icon or GetItemIcon(entry.itemID))
        row.count:SetText(entry.count)
        row.count:SetShown(not hideCount)
        row.name:SetText(entry.name)
        row.name:SetShown(grouped)
        row.bg:SetShown(not horizontal)
        row.divider:SetShown(not horizontal)

        local gained = entry.gained or sessionGained[entry.itemID]
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
        -- Fachbreite passt sich dem breitesten Inhalt an (Icon, Anzahl, Session-Etikett)
        local slotW = math.ceil(math.max(SLOT_ICON, hideCount and 0 or maxCountW, pillW)) + 14
        local slotH = 6 + SLOT_ICON + (hideCount and 0 or 16) + (anyGained and 22 or 0) + 6
        for i = 1, #entries do
            local row = rowPool[i]
            row:ClearAllPoints()
            row:SetSize(slotW, slotH)
            -- feste, schmale Spalten, damit sich die Mauszeiger-Trefferflächen nicht überlappen
            if growthStyle.id == "left" then
                row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4 - (i - 1) * slotW, -topOffset)
            else
                row:SetPoint("TOPLEFT", frame, "TOPLEFT", 4 + (i - 1) * slotW, -topOffset)
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
        width = 8 + #entries * slotW
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
                row:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", inset, FRAME_PADDING + (i - 1) * ROW_HEIGHT)
                row:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -inset, FRAME_PADDING + (i - 1) * ROW_HEIGHT)
            else
                row:SetPoint("TOPLEFT", frame, "TOPLEFT", inset, -topOffset - (i - 1) * ROW_HEIGHT)
                row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -inset, -topOffset - (i - 1) * ROW_HEIGHT)
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
                -- Summe in derselben Spalte wie die Anzahlen der Items darunter (rechtsbündig)
                h.sum:ClearAllPoints()
                h.sum:SetPoint("RIGHT", h, "RIGHT", -(hideCount and 8 or countRight), 0)
                h.sum:SetJustifyH("RIGHT")
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
                f:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", inset, FOOTER_H + offset)
                f:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -inset, FOOTER_H + offset)
            else
                f:SetPoint("TOPLEFT", frame, "TOPLEFT", inset, -(topOffset + offset))
                f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -inset, -(topOffset + offset))
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
-- Einstellungen im Edit Mode (SexyEditMode-1.0: eigener Dialog mit Abschnitten)
------------------------------------------------------------------------------

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
    RenderRows()
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

-- Optionen einer Auswahlliste aus einer Stil-Tabelle ({ label = ... }); der Wert ist der Index
-- withFont: jeder Eintrag wird in seiner eigenen Schrift gezeichnet (Schriftauswahl)
local function StyleOptions(styles, withFont)
    local options = {}
    for i, style in ipairs(styles) do options[i] = { value = i, label = style.label, font = withFont and style.path or nil } end
    return options
end

-- Titel, Menge und Session-Zähler lassen sich einzeln ausblenden (gespeichert in style)
local function SetHidden(key, value)
    value = value and true or false
    if key == "hideTitle" then hideTitle = value
    elseif key == "hideCount" then hideCount = value
    else hideGained = value end
    SexyHarvesterDB.style[key] = value
    RenderRows()
end

local function BuildSettings()
    return {
        { type = "header", name = L("sectionView"), id = "view" },
        { type = "select", name = L("listLayout"), options = StyleOptions(LIST_LAYOUTS),
            get = function() return listLayoutIndex end, set = SetListLayoutIndex },
        { type = "select", name = L("growthDirection"), options = StyleOptions(GROWTH_STYLES),
            get = function() return growthDirectionIndex end, set = SetGrowthDirectionIndex },
        { type = "select", name = L("countPosition"), options = StyleOptions(COUNT_POSITIONS),
            get = function() return countPositionIndex end, set = SetCountPositionIndex },
        { type = "check", name = L("hideTitle"), get = function() return hideTitle end,
            set = function(v) SetHidden("hideTitle", v) end },
        { type = "check", name = L("hideCount"), get = function() return hideCount end,
            set = function(v) SetHidden("hideCount", v) end },
        { type = "check", name = L("hideGained"), get = function() return hideGained end,
            set = function(v) SetHidden("hideGained", v) end },

        { type = "header", name = L("sectionLook"), id = "look", collapsed = true },
        { type = "select", name = L("iconBorder"), options = StyleOptions(EDGE_STYLES),
            get = function() return iconBorderIndex end, set = SetIconBorderIndex },
        { type = "select", name = L("font"), options = StyleOptions(FONTS, true),
            get = function() return fontIndex end, set = SetFontIndex },
        { type = "slider", name = L("fontSize"), min = 8, max = 24, step = 1,
            get = function() return fontSize end, set = SetFontSize },
    }
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
            SexyHarvesterDB.style = SexyHarvesterDB.style or {}
            local style = SexyHarvesterDB.style

            -- Hintergrund und Rahmen sind fest (Quest-Look) und nicht einstellbar; alte gespeicherte
            -- Wahlen werden nicht mehr benutzt
            backgroundIndex = DEFAULT_BACKGROUND
            borderIndex = DEFAULT_BORDER
            style.background, style.border = nil, nil
            iconBorderIndex = style.iconBorder or DEFAULT_ICON_BORDER
            fontIndex = style.font or DEFAULT_FONT
            fontSize = style.fontSize or 11
            countPositionIndex = style.countPosition or 1
            listLayoutIndex = style.listLayout or 1
            growthDirectionIndex = style.growthDirection or 1
            hideTitle = style.hideTitle and true or false
            hideCount = style.hideCount and true or false
            hideGained = style.hideGained and true or false
            ApplyBackground()
            ApplyFrameBorder()
            ApplyFont()
            for _, row in ipairs(rowPool) do
                ApplyIconBorderStyle(row)
                ApplyFont(row)
                ApplyCountPosition(row)
            end

            -- Fenster im Edit Mode verschiebbar machen; Position, Größe und Sichtbarkeit speichert
            -- die Bibliothek in SexyHarvesterDB.editMode. Im Edit Mode zeigt das Fenster Beispiele.
            if SEM.RegisterAddon then SEM:RegisterAddon("SexyHarvester", { title = "SexyHarvester" }) end
            SEM:Register(frame, {
                name = "SexyHarvester: " .. L("title"),
                addon = "SexyHarvester",
                description = (GetLocale() == "deDE" and "Sammelberuf-Rohstoffe im Inventar mit Zähler für diese Sitzung." or "Gathering materials in your bags with a counter for this session."),
                db = SexyHarvesterDB.editMode,
                settings = BuildSettings(),
                onEditMode = function() RenderRows() end,
            })
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
    elseif msg == "minimap" then
        SexyHarvester_ToggleMinimapButton()
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
