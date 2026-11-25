-- Vorschau im Einstellungsfenster (SexyEditMode-Hub): ein eigenes Fenster mit eigener Logik, kein Abbild des echten.
-- Es zeichnet sich wie das echte Fenster (Quest-Look, Titelband, Karten, Etiketten) mit Beispiel-Rohstoffen, folgt allen
-- Einstellungen (Icon-Layout, Wachstumsrichtung, Anzahl-Position, Icon-Rahmen, Schrift, Titel/Menge/Session-Zähler
-- ausblenden) und lässt die Mengen und den Session-Zähler laufend hochzählen. Die Maße entsprechen RenderRows() in
-- SexyHarvester.lua. Klickbereiche springen zur passenden Einstellung (jump = Name der Einstellung).

local S = {}
SexyHarvesterSamples = S

local ROW_HEIGHT, ICON_SIZE, FRAME_PADDING, HEADER_HEIGHT = 30, 22, 8, 30
local GROUP_ROW_H, GROUP_HEADER_H, SLOT_ICON, FOOTER_H, PILL_MIN = 28, 22, 28, 46, 34
local INSET = 3   -- Quest-Look: Tooltip-Rand
local STEP, CYCLE = 2.4, 24   -- Sekunden bis zur nächsten Aufnahme, dann beginnt der Ablauf von vorn

local function API() return SexyHarvesterAPI end

local function Redraw()
	local SEM = LibStub("SexyEditMode-1.0", true)
	if SEM and SEM.RedrawSample then SEM:RedrawSample() end
end
S.Redraw = Redraw

-- Schrift setzen und dabei den Stil (z. B. OUTLINE) der Vorlage behalten
local function Font(fs, path, size)
	local _, _, flags = fs:GetFont()
	fs:SetFont(path, size, flags)
end

local function NewData(st)
	local list = {}
	for i, e in ipairs(st.preview) do
		list[i] = { name = e.name, count = e.count, gained = e.gained, group = e.group, icon = e.icon }
	end
	return list
end

local function MakeRow(w)
	local r = CreateFrame("Frame", nil, w)
	r.bg = r:CreateTexture(nil, "BACKGROUND")
	r.bg:SetAllPoints()
	r.bg:SetColorTexture(0.145, 0.125, 0.10, 1)
	r.divider = r:CreateTexture(nil, "BORDER")
	r.divider:SetPoint("TOPLEFT")
	r.divider:SetPoint("TOPRIGHT")
	r.divider:SetHeight(1)
	r.divider:SetColorTexture(0.21, 0.19, 0.14, 1)
	r.icon = r:CreateTexture(nil, "ARTWORK")
	r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	r.iconBorder = r:CreateTexture(nil, "ARTWORK", nil, -1)
	r.iconBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
	r.count = r:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
	r.gainedBg = r:CreateTexture(nil, "ARTWORK")
	r.gained = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	r.name = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	r.name:SetJustifyH("LEFT")
	r.name:SetWordWrap(false)
	return r
end

local function MakeHeader(w)
	local h = CreateFrame("Frame", nil, w)
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
	return h
end

local function Create(host, c)
	local w = CreateFrame("Frame", nil, host, BackdropTemplateMixin and "BackdropTemplate" or nil)
	w:SetPoint("TOPLEFT", host, "TOPLEFT")
	if w.SetBackdrop then
		w:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
			insets = { left = 3, right = 3, top = 3, bottom = 3 },
		})
		w:SetBackdropBorderColor(0.42, 0.34, 0.15, 1)
	end
	w.bg = w:CreateTexture(nil, "BACKGROUND")
	w.bg:SetPoint("TOPLEFT", 3, -3)
	w.bg:SetPoint("BOTTOMRIGHT", -3, 3)
	w.bg:SetColorTexture(0.08, 0.065, 0.05, 0.96)
	w.band = w:CreateTexture(nil, "BACKGROUND", nil, 1)
	w.band:SetColorTexture(0.15, 0.12, 0.07, 0.96)
	w.band:SetPoint("TOPLEFT", w, "TOPLEFT", INSET, -INSET)
	w.band:SetPoint("TOPRIGHT", w, "TOPRIGHT", -INSET, -INSET)
	w.band:SetHeight(HEADER_HEIGHT - INSET)
	w.title = w:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	w.title:SetPoint("LEFT", w.band, "LEFT", 10, 0)
	w.title:SetTextColor(0.91, 0.76, 0.42)
	w.badgeBg = w:CreateTexture(nil, "ARTWORK")
	w.badgeBg:SetPoint("RIGHT", w.band, "RIGHT", -6, 0)
	w.badgeBg:SetHeight(18)
	w.badgeBg:SetColorTexture(0.165, 0.14, 0.10, 1)
	w.badgeText = w:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	w.badgeText:SetPoint("CENTER", w.badgeBg, "CENTER")
	w.badgeText:SetTextColor(0.78, 0.73, 0.64)
	w.rows, w.headers = {}, {}

	-- Reset-Knopf der Ansicht "Gruppiert" (nur Abbild)
	w.reset = CreateFrame("Frame", nil, w)
	w.reset:SetHeight(28)
	w.reset:SetPoint("BOTTOMLEFT", w, "BOTTOMLEFT", FRAME_PADDING, 8)
	w.reset:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", -FRAME_PADDING, 8)
	w.reset.bg = w.reset:CreateTexture(nil, "BACKGROUND")
	w.reset.bg:SetAllPoints()
	w.reset.bg:SetColorTexture(0.15, 0.12, 0.07, 1)
	w.reset.text = w.reset:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	w.reset.text:SetAllPoints()
	w.reset.text:SetTextColor(0.91, 0.76, 0.42)
	-- Fußleiste und Rand wie im echten Fenster
	do
		local strip = w.reset:CreateTexture(nil, "BACKGROUND", nil, -2)
		strip:SetColorTexture(0.114, 0.078, 0.05, 1)
		strip:SetPoint("BOTTOMLEFT", w, "BOTTOMLEFT", 3, 3)
		strip:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", -3, 3)
		strip:SetHeight(FOOTER_H - 3)
		local line = w.reset:CreateTexture(nil, "BACKGROUND", nil, -1)
		line:SetColorTexture(0.24, 0.185, 0.122, 1)
		line:SetPoint("BOTTOMLEFT", strip, "TOPLEFT")
		line:SetPoint("BOTTOMRIGHT", strip, "TOPRIGHT")
		line:SetHeight(1)
		-- dünner Rand, immer genau ein Bildschirmpixel stark (unabhängig von der Fenstergröße), damit Vorschau und Fenster gleich aussehen
		local edges = {}
		for i, e in ipairs({ { "TOPLEFT", "TOPRIGHT", true }, { "BOTTOMLEFT", "BOTTOMRIGHT", true },
			{ "TOPLEFT", "BOTTOMLEFT", false }, { "TOPRIGHT", "BOTTOMRIGHT", false } }) do
			local t = w.reset:CreateTexture(nil, "BORDER")
			t:SetColorTexture(0.6, 0.49, 0.22, 1)
			t:SetPoint(e[1])
			t:SetPoint(e[2])
			edges[i] = { tex = t, horizontal = e[3] }
		end
		local function Pixel()
			local px = 1 / math.max(0.2, w.reset:GetEffectiveScale())
			for _, e in ipairs(edges) do
				if e.horizontal then e.tex:SetHeight(px) else e.tex:SetWidth(px) end
			end
		end
		Pixel()
		w.reset:HookScript("OnShow", Pixel)
	end

	c.t0, c.step, c.k = GetTime(), GetTime(), 0
	w:SetScript("OnUpdate", function()
		local now = GetTime()
		if not c.data then return end
		if now - c.t0 > CYCLE then
			c.t0, c.step, c.k = now, now, 0
			c.data = NewData(API().Sample())
			Redraw()
		elseif now - c.step >= STEP then
			c.step = now
			c.k = (c.k % #c.data) + 1
			local e = c.data[c.k]
			e.count, e.gained = e.count + 1, e.gained + 1
			Redraw()
		end
	end)
	return w
end

-- Platz und Größe einer echten Zeichenfläche relativ zum Fenster (nil, solange das Layout noch nicht berechnet ist)
local function Measure(w, region)
	if not (region and region:IsShown()) then return end
	local fl, ft = w:GetLeft(), w:GetTop()
	local l, t, r, b = region:GetLeft(), region:GetTop(), region:GetRight(), region:GetBottom()
	if not (fl and ft and l and t and r and b) then return end
	return l - fl, ft - t, r - l, t - b
end

function S.harvester(host, c)
	local api = API()
	if not api then return nil end
	local st = api.Sample()
	local L = st.L
	-- Größen kommen aus den Einstellungen (wie im echten Fenster)
	ICON_SIZE, SLOT_ICON, ROW_HEIGHT, GROUP_ROW_H = st.iconSize, st.slotIcon, st.rowHeight, st.groupRowH

	if not c.win then c.win = Create(host, c) end
	if not c.data then c.data = NewData(st) end
	local w = c.win

	local layout, growth, pos = st.layout.id, st.growth.id, st.pos
	local horizontal, grouped = layout == "horizontal", layout == "grouped"
	local up = growth == "up"
	local fpath = st.font.path

	-- Titel, Schrift
	Font(w.title, st.font.titlePath or fpath, st.fontSize + 3)
	Font(w.badgeText, fpath, st.fontSize)
	Font(w.reset.text, fpath, st.fontSize)
	w.bg:SetColorTexture(0.08, 0.065, 0.05, st.opacity)
	w.title:SetText(L("title"))
	w.reset.text:SetText(L("resetButton"))
	w.title:SetShown(not st.hideTitle)
	w.band:SetShown(not st.hideTitle)
	local topOffset = st.hideTitle and FRAME_PADDING or (HEADER_HEIGHT + 4)

	-- Einträge sortieren (gruppiert: erst nach Beruf)
	local entries = {}
	for i, e in ipairs(c.data) do
		entries[i] = { name = e.name, count = e.count, gained = e.gained, group = grouped and e.group or nil, icon = e.icon }
	end
	table.sort(entries, function(a, b)
		if grouped and a.group ~= b.group then return st.GROUP_ORDER[a.group] < st.GROUP_ORDER[b.group] end
		return a.name < b.name
	end)

	-- Badge: Summe der Session
	local total = 0
	for _, e in ipairs(entries) do total = total + e.gained end
	if not st.hideTitle and not st.hideGained and st.total and total > 0 then
		w.badgeText:SetText("+" .. total .. (grouped and (" " .. L("session")) or ""))
		w.badgeBg:SetWidth(w.badgeText:GetStringWidth() + 18)
		w.badgeBg:Show()
		w.badgeText:Show()
	else
		w.badgeBg:Hide()
		w.badgeText:Hide()
	end

	-- Zeilen füllen und die Spaltenbreiten messen
	local maxGainW, maxCountW, maxNameW, anyGained = 0, 0, 0, false
	local tone = st.TONES.ok
	for i, e in ipairs(entries) do
		local r = w.rows[i]
		if not r then r = MakeRow(w); w.rows[i] = r end
		Font(r.count, fpath, st.fontSize)
		Font(r.gained, fpath, st.fontSize)
		Font(r.name, fpath, st.fontSize + 1)
		r.icon:SetTexture(e.icon)
		r.count:SetText(e.count)
		r.count:SetShown(not st.hideCount)
		r.name:SetText(e.name)
		r.name:SetShown(grouped)
		r.bg:SetShown(not horizontal and st.cards)
		r.divider:SetShown(not horizontal and st.cards)
		r.gainedBg:SetColorTexture(tone.bg[1], tone.bg[2], tone.bg[3], 1)
		r.gained:SetTextColor(tone.fg[1], tone.fg[2], tone.fg[3])
		local show = not st.hideGained and e.gained > 0
		r.gained:SetText(show and ("+" .. e.gained) or "")
		r.gained:SetShown(show)
		r.gainedBg:SetShown(show)
		if show then
			anyGained = true
			maxGainW = math.max(maxGainW, r.gained:GetStringWidth())
		end
		maxCountW = math.max(maxCountW, r.count:GetStringWidth())
		maxNameW = math.max(maxNameW, r.name:GetStringWidth())

		-- Icon-Rahmen
		local b = st.iconBorder
		if b.id == "none" then
			r.iconBorder:Hide()
		else
			r.iconBorder:ClearAllPoints()
			r.iconBorder:SetPoint("TOPLEFT", r.icon, "TOPLEFT", -b.thickness, b.thickness)
			r.iconBorder:SetPoint("BOTTOMRIGHT", r.icon, "BOTTOMRIGHT", b.thickness, -b.thickness)
			r.iconBorder:SetVertexColor(b.r, b.g, b.b, b.a)
			r.iconBorder:Show()
		end
	end
	local pillW = anyGained and math.max(PILL_MIN, maxGainW + 18) or 0
	for i = #entries + 1, #w.rows do w.rows[i]:Hide() end
	for _, h in ipairs(w.headers) do h:Hide() end
	w.reset:SetShown(grouped and st.reset)
	local footer = st.reset and FOOTER_H or FRAME_PADDING

	local function PlaceGained(r, point, relTo, relPoint, x, y, width)
		r.gainedBg:ClearAllPoints()
		r.gainedBg:SetPoint(point, relTo, relPoint, x, y)
		r.gainedBg:SetSize(width, 16)
		r.gained:ClearAllPoints()
		r.gained:SetPoint("CENTER", r.gainedBg, "CENTER", 0, 0)
	end

	local width, height
	if horizontal then
		local slotW = math.ceil(math.max(SLOT_ICON, st.hideCount and 0 or maxCountW, pillW)) + 14
		local slotH = 6 + SLOT_ICON + (st.hideCount and 0 or 16) + (anyGained and 22 or 0) + 6
		for i = 1, #entries do
			local r = w.rows[i]
			r:ClearAllPoints()
			r:SetSize(slotW, slotH)
			if growth == "left" then
				r:SetPoint("TOPRIGHT", w, "TOPRIGHT", -4 - (i - 1) * slotW, -topOffset)
			else
				r:SetPoint("TOPLEFT", w, "TOPLEFT", 4 + (i - 1) * slotW, -topOffset)
			end
			r.icon:SetSize(SLOT_ICON, SLOT_ICON)
			r.icon:ClearAllPoints()
			r.icon:SetPoint("TOP", r, "TOP", 0, -6)
			r.count:ClearAllPoints()
			r.count:SetPoint("TOP", r.icon, "BOTTOM", 0, -3)
			r.count:SetWidth(0)
			r.count:SetJustifyH("CENTER")
			PlaceGained(r, "TOP", st.hideCount and r.icon or r.count, "BOTTOM", 0, -4, pillW)
			r:Show()
		end
		width = 8 + #entries * slotW
		height = topOffset + slotH
	elseif not grouped then
		local outsideLeft = pos.outside and pos.anchor == "RIGHT" and not st.hideCount
		local outsideRight = pos.outside and pos.anchor == "LEFT" and not st.hideCount
		local leftExtra = outsideLeft and (maxCountW + 4) or 0
		local rightExtra = outsideRight and (maxCountW + 4) or 0
		for i = 1, #entries do
			local r = w.rows[i]
			r:ClearAllPoints()
			r:SetHeight(ROW_HEIGHT)
			if up then
				r:SetPoint("BOTTOMLEFT", w, "BOTTOMLEFT", INSET, FRAME_PADDING + (i - 1) * ROW_HEIGHT)
				r:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", -INSET, FRAME_PADDING + (i - 1) * ROW_HEIGHT)
			else
				r:SetPoint("TOPLEFT", w, "TOPLEFT", INSET, -topOffset - (i - 1) * ROW_HEIGHT)
				r:SetPoint("TOPRIGHT", w, "TOPRIGHT", -INSET, -topOffset - (i - 1) * ROW_HEIGHT)
			end
			r.icon:SetSize(ICON_SIZE, ICON_SIZE)
			r.icon:ClearAllPoints()
			r.icon:SetPoint("LEFT", r, "LEFT", 8 + leftExtra, 0)
			r.count:SetWidth(0)
			r.count:ClearAllPoints()
			r.count:SetPoint(pos.anchor, r.icon, pos.relPoint, pos.x, pos.y)
			r.count:SetJustifyH(pos.justify)
			PlaceGained(r, "RIGHT", r, "RIGHT", -8, 0, pillW)
			r:Show()
		end
		width = math.max(120, 8 + leftExtra + ICON_SIZE + rightExtra + 8 + (anyGained and (12 + pillW) or 0))
		height = topOffset + #entries * ROW_HEIGHT + FRAME_PADDING
	else
		local colW = anyGained and (pillW + 8) or 0
		local countRight = 8 + colW
		local countW = st.hideCount and 0 or (maxCountW + 2)
		local sums = {}
		for _, e in ipairs(entries) do sums[e.group] = (sums[e.group] or 0) + e.count end

		local elements, last, headers = {}, nil, 0
		for i, e in ipairs(entries) do
			if e.group ~= last then
				last = e.group
				headers = headers + 1
				local h = w.headers[headers]
				if not h then h = MakeHeader(w); w.headers[headers] = h end
				local t = st.TONES[st.GROUP_TONE[e.group]]
				Font(h.label, fpath, st.fontSize)
				Font(h.sum, fpath, st.fontSize)
				h.label:SetText(L(st.GROUP_LABEL[e.group]))
				h.label:SetTextColor(t.fg[1], t.fg[2], t.fg[3])
				h.pill:SetColorTexture(t.bg[1], t.bg[2], t.bg[3], 1)
				h.pill:SetWidth(h.label:GetStringWidth() + 18)
				h.sum:SetText(sums[e.group])
				h.sum:SetShown(st.sums)
				h.sum:ClearAllPoints()
				h.sum:SetPoint("RIGHT", h, "RIGHT", -(st.hideCount and 8 or countRight), 0)
				elements[#elements + 1] = { h, GROUP_HEADER_H }
			end
			local r = w.rows[i]
			r:SetHeight(GROUP_ROW_H)
			r.icon:SetSize(ICON_SIZE, ICON_SIZE)
			r.icon:ClearAllPoints()
			r.icon:SetPoint("LEFT", r, "LEFT", 8, 0)
			r.count:ClearAllPoints()
			r.count:SetPoint("RIGHT", r, "RIGHT", -countRight, 0)
			r.count:SetWidth(countW)
			r.count:SetJustifyH("RIGHT")
			r.name:ClearAllPoints()
			r.name:SetPoint("LEFT", r.icon, "RIGHT", 8, 0)
			r.name:SetPoint("RIGHT", r, "RIGHT", -(countRight + (st.hideCount and 0 or countW + 8)), 0)
			PlaceGained(r, "RIGHT", r, "RIGHT", -8, 0, pillW)
			elements[#elements + 1] = { r, GROUP_ROW_H }
		end

		local offset = 0
		for _, el in ipairs(elements) do
			local f, h = el[1], el[2]
			f:ClearAllPoints()
			if up then
				f:SetPoint("BOTTOMLEFT", w, "BOTTOMLEFT", INSET, footer + offset)
				f:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", -INSET, footer + offset)
			else
				f:SetPoint("TOPLEFT", w, "TOPLEFT", INSET, -(topOffset + offset))
				f:SetPoint("TOPRIGHT", w, "TOPRIGHT", -INSET, -(topOffset + offset))
			end
			f:Show()
			offset = offset + h
		end
		width = math.min(340, math.max(220, 8 + ICON_SIZE + 8 + maxNameW + (st.hideCount and 0 or (8 + countW)) + 8 + colW))
		height = topOffset + offset + footer
	end

	-- Titel und Badge müssen ins Band passen
	if not st.hideTitle then
		local need = 10 + w.title:GetStringWidth() + 12
		if w.badgeBg:IsShown() then need = need + w.badgeBg:GetWidth() + 12 end
		width = math.max(width, need)
	end
	w:SetSize(width, height)

	-- Klickbereiche (gemessen an den echten Teilen; beim ersten Mal ist das Layout oft noch nicht berechnet).
	-- Später genannte liegen oben.
	local top = st.hideTitle and FRAME_PADDING or HEADER_HEIGHT
	local parts = {
		{ name = L("title"), x = 0, y = 0, w = width, h = height, jump = "_pos" },
		{ name = L("windowOpacity"), x = 0, y = 0, w = 4, h = height, jump = L("windowOpacity") },
		{ name = L("windowOpacity"), x = width - 4, y = 0, w = 4, h = height, jump = L("windowOpacity") },
		{ name = L("listLayout"), x = 0, y = top, w = width, h = math.max(8, height - top), jump = L("listLayout") },
		{ name = L("hideTitle"), x = 0, y = 0, w = width, h = top, jump = L("hideTitle") },
	}
	local function Add(name, jump, x, y, rw, rh)
		if x then parts[#parts + 1] = { name = name, x = x, y = y, w = rw, h = rh, jump = jump } end
	end
	local failed = false

	if w.badgeBg:IsShown() then
		local bx, by, bw, bh = Measure(w, w.badgeBg)
		Add(L("showTotal"), L("showTotal"), bx, by, bw, bh)
	end

	-- Karten (Zeilenhöhe), dann Icon-Rahmen und Icon, Anzahl, Session-Etikett
	for i = 1, #entries do
		local r = w.rows[i]
		local rx, ry, rw, rh = Measure(w, r)
		if rx then
			if not horizontal then
				Add(L("rowHeight"), L("rowHeight"), rx, ry, rw, rh)
				Add(L("rowCards"), L("rowCards"), rx, ry - 2, rw, 5)
			end
		else
			failed = true
		end
		local ix, iy, iw, ih = Measure(w, r.icon)
		if ix then
			Add(L("iconBorder"), L("iconBorder"), ix - 3, iy - 3, iw + 6, ih + 6)
			Add(L("iconSize"), L("iconSize"), ix, iy, iw, ih)
		else
			failed = true
		end
		if not st.hideCount then
			local cx, cy, cw, ch = Measure(w, r.count)
			Add(L("countPosition"), L("countPosition"), cx and cx - 2, cy and cy - 2, cw and cw + 4, ch and ch + 4)
		end
		local gx, gy, gw, gh = Measure(w, r.gainedBg)
		Add(L("hideGained"), L("hideGained"), gx, gy, gw, gh)
	end

	-- Gruppen: Summen; Reset-Knopf
	if grouped then
		for _, h in ipairs(w.headers) do
			if h:IsShown() and h.sum:IsShown() then
				local sx, sy, sw, sh = Measure(w, h.sum)
				Add(L("groupSums"), L("groupSums"), sx and sx - 2, sy and sy - 2, sw and sw + 4, sh and sh + 4)
			end
		end
		local bx, by, bw, bh = Measure(w, w.reset)
		Add(L("showReset"), L("showReset"), bx, by, bw, bh)
	end

	if failed and not c.retry then
		c.retry = true
		C_Timer.After(0.1, Redraw)
	elseif not failed then
		c.retry = nil
	end

	return { w = width, h = height, parts = parts }
end
