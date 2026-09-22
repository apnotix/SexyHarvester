-- SexyHarvester
-- Zeigt für jeden Sammelberuf-Rohstoff (Kraut, Erz, Leder) im Inventar ein Icon mit
-- aktueller Menge und einem "+N" für die in dieser Session gesammelte Menge an.

local ADDON_NAME = ...

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
    local name, _, _, _, _, _, subType = GetItemData(itemID)
    if not name then
        return nil -- noch nicht im Client-Cache, muss später erneut geprüft werden
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

------------------------------------------------------------------------------
-- UI
------------------------------------------------------------------------------

local ROW_HEIGHT = 26
local ICON_SIZE = 20
local FRAME_WIDTH = 130
local FRAME_PADDING = 8
local HEADER_HEIGHT = 20

-- Kein BackdropTemplate/SetBackdrop verwendet, da dessen Verfügbarkeit je nach
-- Client-Generation unsicher ist. Stattdessen ein simples, überall funktionierendes
-- Textur-Hintergrundbild mit Vertex-Farbe.
local frame = CreateFrame("Frame", "SexyHarvesterFrame", UIParent)
frame:SetSize(FRAME_WIDTH, HEADER_HEIGHT + FRAME_PADDING * 2)
frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
-- Beweglichkeit, Klemmen an den Bildschirmrand und das Ziehen selbst übernimmt
-- ab hier die EditModeExpanded-1.0 Library (siehe ADDON_LOADED weiter unten).

local background = frame:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(frame)
background:SetTexture("Interface\\Buttons\\WHITE8x8")
background:SetVertexColor(0, 0, 0, 0.55)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOPLEFT", frame, "TOPLEFT", FRAME_PADDING, -6)
title:SetText("Sammelberufe")
title:SetTextColor(0.9, 0.9, 0.9)

local rowPool = {}

local function CreateRow(index)
    local row = CreateFrame("Frame", nil, frame)
    row:SetSize(FRAME_WIDTH - FRAME_PADDING * 2, ROW_HEIGHT)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("LEFT", row, "LEFT", 0, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.icon = icon

    local iconBorder = row:CreateTexture(nil, "OVERLAY")
    iconBorder:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    iconBorder:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
    iconBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
    iconBorder:SetVertexColor(0, 0, 0, 0.6)
    iconBorder:SetDrawLayer("ARTWORK", -1)

    local count = row:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
    count:SetJustifyH("RIGHT")
    row.count = count

    local gained = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    gained:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    gained:SetTextColor(0.2, 1.0, 0.2)
    gained:SetJustifyH("LEFT")
    row.gained = gained

    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        if not self.itemID then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
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

local function RenderRows()
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

        local gained = sessionGained[entry.itemID]
        if gained and gained > 0 then
            row.gained:SetText("+" .. gained)
            row.gained:Show()
        else
            row.gained:SetText("")
            row.gained:Hide()
        end

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", FRAME_PADDING, -(HEADER_HEIGHT + FRAME_PADDING) - (i - 1) * ROW_HEIGHT)
        row:Show()
    end

    for i = #entries + 1, #rowPool do
        rowPool[i]:Hide()
    end

    if #entries == 0 then
        frame:Hide()
    else
        frame:SetHeight(HEADER_HEIGHT + FRAME_PADDING * 2 + #entries * ROW_HEIGHT)
        frame:Show()
    end
end

------------------------------------------------------------------------------
-- Inventar-Scan
------------------------------------------------------------------------------

local function ScanBags()
    local newCounts = {}
    local numBags = NUM_BAG_SLOTS or 4

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
            -- SexyHarvesterDB.editMode persistiert.
            lib:RegisterFrame(frame, "Sammelberufe", SexyHarvesterDB.editMode, UIParent, "CENTER", true)
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
        print("|cff1eff00SexyHarvester|r: Session-Zähler zurückgesetzt.")
    else
        print("|cff1eff00SexyHarvester|r Befehle:")
        print("  /sh reset - Session-Zähler zurücksetzen")
        print("  Position verschieben: Esc -> Edit-Modus -> 'Sammelberufe' anwählen und ziehen.")
    end
end
