-- Minimap-Knopf (LibDBIcon): Linksklick öffnet das Einstellungsfenster (Addon SexyEditMode) beim ersten Bereich
-- von SexyHarvester, Rechtsklick startet bzw. beendet den Verschiebe-Modus (SexyEditMode ist Pflichtabhängigkeit). Ein-/Ausblenden: /sh minimap
local DE = GetLocale() == "deDE"

local function ToggleEditMode()
    -- Verschiebe-Modus nur für die Fenster dieses Addons
    LibStub("SexyEditMode-1.0"):ToggleEditMode("SexyHarvester")
end

local function Settings()
    local db = _G.SexyHarvesterDB
    if not db then return end
    db.minimap = db.minimap or {}
    -- eigener Startwinkel je Addon, damit die Knöpfe nicht übereinanderliegen (verschiebbar per Ziehen)
    if not db.minimap.minimapPos then db.minimap.minimapPos = 200 end
    return db.minimap
end

function SexyHarvester_ToggleMinimapButton()
    local icon = LibStub("LibDBIcon-1.0", true)
    local s = Settings()
    if not (icon and s) then return end
    s.hide = not s.hide
    if s.hide then icon:Hide("SexyHarvester") else icon:Show("SexyHarvester") end
    print("|cffe8c26aSexyHarvester|r: " .. (DE and (s.hide and "Minimap-Knopf ausgeblendet" or "Minimap-Knopf eingeblendet")
        or (s.hide and "minimap button hidden" or "minimap button shown")))
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    local ldb = LibStub("LibDataBroker-1.1", true)
    local icon = LibStub("LibDBIcon-1.0", true)
    local s = Settings()
    if not (ldb and icon and s) then return end
    local obj = ldb:NewDataObject("SexyHarvester", {
        type = "launcher",
        label = "SexyHarvester",
        text = "SexyHarvester",
        icon = "Interface/AddOns/SexyHarvester/icon.tga",
        OnClick = function(_, button)
            if button == "RightButton" then
                ToggleEditMode()
            else
                LibStub("SexyEditMode-1.0"):OpenHub("SexyHarvester")
            end
        end,
        OnTooltipShow = function(tip)
            if not (tip and tip.AddLine) then return end
            tip:AddLine("SexyHarvester")
            tip:AddLine(DE and "Linksklick: Einstellungen" or "Left click: settings", 1, 1, 1)
            tip:AddLine(DE and "Rechtsklick: Fenster verschieben" or "Right click: move windows", 1, 1, 1)
        end,
    })
    if obj and not icon:IsRegistered("SexyHarvester") then icon:Register("SexyHarvester", obj, s) end
end)
