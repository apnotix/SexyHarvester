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

    layoutVertical  = { de = "Vertikal (untereinander)",   en = "Vertical (stacked)" },
    layoutHorizontal= { de = "Horizontal (nebeneinander)", en = "Horizontal (side by side)" },

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
-- Deckt Kräuterkunde, Bergbau und Kürschnerei ab (Deutsch + Englisch, sowie ein
-- paar weitere Sprachen als Best-Effort-Fallback).
------------------------------------------------------------------------------

local GATHERING_SUBTYPES = {
    -- Kräuterkunde
    ["herb"] = true, ["kraut"] = true, ["herbe"] = true, ["hierba"] = true, ["erba"] = true,
    -- Bergbau
    ["metal & stone"] = true, ["erz und stein"] = true, ["minerai et pierre"] = true,
    ["metal y piedra"] = true, ["metallo e pietra"] = true,
    -- Kürschnerei
    ["leather"] = true, ["leder"] = true, ["cuir"] = true, ["cuero"] = true, ["pelle"] = true,
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

local ROW_HEIGHT = 26
local ICON_SIZE = 20
local FRAME_WIDTH = 130
local FRAME_PADDING = 8
local HEADER_HEIGHT = 20

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
}

-- Auswählbare Rahmen-Stile, gemeinsam genutzt vom Fensterrahmen ("Rahmen wechseln")
-- und den einzelnen Icon-Rahmen ("Icon-Rahmen wechseln").
local EDGE_STYLES = {
    { id = "thin_dark",  label = L("edgeThinDark"),  r = 0,   g = 0,    b = 0,   a = 0.9,  thickness = 1 },
    { id = "none",       label = L("edgeNone") },
    { id = "thin_light", label = L("edgeThinLight"), r = 1,   g = 1,    b = 1,   a = 0.5,  thickness = 1 },
    { id = "thick_dark", label = L("edgeThickDark"), r = 0,   g = 0,    b = 0,   a = 0.95, thickness = 2 },
    { id = "gold",       label = L("edgeGold"),      r = 0.8, g = 0.65, b = 0.2, a = 0.9,  thickness = 1 },
}
local BORDER_STYLES = EDGE_STYLES

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
local fontIndex = 1
local fontSize = 11 -- Standardgröße von GameFontNormalSmall/NumberFontNormalSmall

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOPLEFT", frame, "TOPLEFT", FRAME_PADDING, -6)
title:SetText(L("title"))
title:SetTextColor(0.9, 0.9, 0.9)

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

-- Gesamt-Layout der Icon-Liste: Icons untereinander (klassisch) oder
-- nebeneinander in einer horizontalen Reihe. Pfeil-Icon zeigt die Stapelrichtung.
local LIST_LAYOUTS = {
    { id = "vertical",   label = L("layoutVertical"),   texture = "Interface\\Buttons\\Arrow-Down-Up" },
    { id = "horizontal", label = L("layoutHorizontal"), texture = "Interface\\Buttons\\Arrow-Right-Up" },
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
local function ApplyCountPosition(row)
    local pos = COUNT_POSITIONS[countPositionIndex] or COUNT_POSITIONS[1]
    row.count:ClearAllPoints()
    row.count:SetPoint(pos.anchor, row.icon, pos.relPoint, pos.x, pos.y)
    row.count:SetJustifyH(pos.justify)

    -- Außerhalb des Icons hängt der Session-Zähler an der Mengenanzahl,
    -- als Overlay auf dem Icon hängt er stattdessen direkt am Icon.
    local anchorFrame = pos.outside and row.count or row.icon
    row.gained:ClearAllPoints()
    row.gained:SetPoint("LEFT", anchorFrame, "RIGHT", 6, 0)
end

-- Wendet die aktuell gewählte Schriftart (siehe FONTS) und Schriftgröße
-- (fontSize) auf Titel sowie Mengen- und Session-Zähler-Text einer Zeile an.
-- Der Stil (z. B. OUTLINE) der bisherigen Font-Vorlage bleibt erhalten, nur
-- Pfad und Größe werden überschrieben.
local function ApplyFont(row)
    local font = FONTS[fontIndex] or FONTS[1]
    local _, _, titleFlags = title:GetFont()
    title:SetFont(font.path, fontSize, titleFlags)
    if row then
        local _, _, countFlags = row.count:GetFont()
        row.count:SetFont(font.path, fontSize, countFlags)
        local _, _, gainedFlags = row.gained:GetFont()
        row.gained:SetFont(font.path, fontSize, gainedFlags)
    end
end

local function CreateRow(index)
    local row = CreateFrame("Frame", nil, frame)
    row:SetSize(FRAME_WIDTH - FRAME_PADDING * 2, ROW_HEIGHT)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("LEFT", row, "LEFT", 0, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.icon = icon

    local iconBorder = row:CreateTexture(nil, "OVERLAY")
    iconBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
    iconBorder:SetDrawLayer("ARTWORK", -1)
    row.iconBorder = iconBorder

    local count = row:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    row.count = count

    local gained = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    gained:SetTextColor(0.2, 1.0, 0.2)
    row.gained = gained

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

local function RenderRows()
    title:SetShown(not hideTitle)
    local topOffset = hideTitle and FRAME_PADDING or (HEADER_HEIGHT + FRAME_PADDING)
    local layout = LIST_LAYOUTS[listLayoutIndex] or LIST_LAYOUTS[1]
    local horizontal = layout.id == "horizontal"
    local growthStyle = GROWTH_STYLES[growthDirectionIndex] or GROWTH_STYLES[1]

    -- Sortierte Liste der aktuell gehaltenen Sammelrohstoffe aufbauen.
    local entries = {}
    for itemID, count in pairs(currentCounts) do
        if count and count > 0 then
            local name = GetItemData(itemID)
            entries[#entries + 1] = { itemID = itemID, count = count, name = name or tostring(itemID) }
        end
    end
    table.sort(entries, function(a, b) return a.name < b.name end)

    for i, entry in ipairs(entries) do
        local row = GetRow(i)
        row.itemID = entry.itemID
        row.icon:SetTexture(GetItemIcon(entry.itemID))
        row.count:SetText(entry.count)
        row.count:SetShown(not hideCount)

        local gained = sessionGained[entry.itemID]
        if (not hideGained) and gained and gained > 0 then
            row.gained:SetText("+" .. gained)
            row.gained:Show()
        else
            row.gained:SetText("")
            row.gained:Hide()
        end

        row:ClearAllPoints()
        if horizontal then
            -- Icons nebeneinander in schmalen, festen Spalten, damit sich die
            -- Mauszeiger-Trefferflächen benachbarter Icons nicht überlappen.
            row:SetWidth(ITEM_SLOT_WIDTH)
            if growthStyle.id == "left" then
                row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -FRAME_PADDING - (i - 1) * ITEM_SLOT_WIDTH, -topOffset)
            else
                row:SetPoint("TOPLEFT", frame, "TOPLEFT", FRAME_PADDING + (i - 1) * ITEM_SLOT_WIDTH, -topOffset)
            end
        else
            -- Trefferfläche auf die Icon-Breite begrenzen (statt der festen
            -- FRAME_WIDTH-Konstante, die nichts mehr mit der tatsächlichen,
            -- dynamisch berechneten Fensterbreite zu tun hat und die Row weit
            -- über das sichtbare Fenster hinausragen ließ).
            row:SetWidth(ICON_SIZE)
            if growthStyle.id == "up" then
                row:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", FRAME_PADDING, FRAME_PADDING + (i - 1) * ROW_HEIGHT)
            else
                row:SetPoint("TOPLEFT", frame, "TOPLEFT", FRAME_PADDING, -topOffset - (i - 1) * ROW_HEIGHT)
            end
        end
        row:Show()
    end

    for i = #entries + 1, #rowPool do
        rowPool[i]:Hide()
    end

    if #entries == 0 then
        frame:Hide()
    elseif horizontal then
        ResizeFramePreservingPosition(FRAME_PADDING * 2 + #entries * ITEM_SLOT_WIDTH, topOffset + FRAME_PADDING + ROW_HEIGHT)
        frame:Show()
    else
        -- Breite im Vertikal-Layout an den tatsächlich benötigten Inhalt anpassen
        -- (Icon + ggf. außerhalb liegende Mengenanzahl/Session-Zähler), statt
        -- immer die feste FRAME_WIDTH zu nutzen, die für den Titeltext gedacht war.
        local pos = COUNT_POSITIONS[countPositionIndex] or COUNT_POSITIONS[1]
        local outsideHorizontal = pos.outside and (pos.anchor == "LEFT" or pos.anchor == "RIGHT")
        local contentWidth = ICON_SIZE
        for i = 1, #entries do
            local row = rowPool[i]
            local w = ICON_SIZE
            if outsideHorizontal and not hideCount then
                w = w + 4 + row.count:GetStringWidth()
            end
            if row.gained:IsShown() then
                w = w + 6 + row.gained:GetStringWidth()
            end
            if w > contentWidth then
                contentWidth = w
            end
        end

        local width = FRAME_PADDING * 2 + contentWidth
        if not hideTitle then
            width = math.max(width, FRAME_PADDING * 2 + title:GetStringWidth())
        end

        ResizeFramePreservingPosition(width, topOffset + FRAME_PADDING + #entries * ROW_HEIGHT)
        frame:Show()
    end
end

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
    for _, row in ipairs(rowPool) do
        ApplyCountPosition(row)
    end
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
            backgroundIndex = SexyHarvesterDB.style.background or 1
            borderIndex = SexyHarvesterDB.style.border or 1
            iconBorderIndex = SexyHarvesterDB.style.iconBorder or 1
            fontIndex = SexyHarvesterDB.style.font or 1
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
        wipe(sessionGained)
        RenderRows()
        print("|cff1eff00SexyHarvester|r: " .. L("resetConfirm"))
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
