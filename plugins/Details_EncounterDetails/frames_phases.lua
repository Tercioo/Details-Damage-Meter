
local addonId, edTable = ...
local Details = _G._detalhes
local AceLocale = LibStub("AceLocale-3.0")
local Loc = AceLocale:GetLocale("Details_EncounterDetails")
local Graphics = LibStub:GetLibrary("LibGraph-2.0")
local ipairs = ipairs
local _GetSpellInfo = Details.getspellinfo
local unpack = unpack
local detailsFramework = DetailsFramework
local CreateFrame = CreateFrame
local GameCooltip = GameCooltip
local wipe = table.wipe
local _

local encounterDetails = _G.EncounterDetailsGlobal
local edFrame = encounterDetails.Frame

local phaseFrame = CreateFrame("frame", "EncounterDetailsPhaseFrame", edFrame, "BackdropTemplate")
phaseFrame:SetAllPoints()
phaseFrame:SetFrameLevel(edFrame:GetFrameLevel()+1)
phaseFrame.DamageTable = {}
phaseFrame.HealingTable = {}
phaseFrame.LastPhaseSelected = 1
phaseFrame.CurrentSegment = {}
phaseFrame.PhaseButtons = {}
EncounterDetailsPhaseFrame:Hide()

local phaseButtonTemplateHighlight = {
    backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
    backdropcolor = {.7, .7, .7, .5},
    onentercolor = {1, 1, 1, .5},
    backdropbordercolor = {.70, .70, .70, 1},
}

local phaseButtonTemplate = {
    backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
    backdropcolor = {.7, .7, .7, .5},
    onentercolor = {1, 1, 1, .5},
    backdropbordercolor = {0, 0, 0, 1},
}

local scrollWidth, scrollHeight, scrollLineAmount, scrollLineHeight = 250, 420, 20, 20
local phasesY = -88
local anchorY = -120

phaseFrame:SetScript("OnShow", function()
	phaseFrame.OnSelectPhase(1)
end)

function phaseFrame:ClearAll()
	--disable all buttons
	for i = 1, #phaseFrame.PhaseButtons do
		phaseFrame.PhaseButtons[i]:SetTemplate(phaseButtonTemplate)
		phaseFrame.PhaseButtons[i]:Disable()
	end

	--update damage and healing scrolls
	wipe(phaseFrame.DamageTable)
	wipe(phaseFrame.HealingTable)

	--refresh the scroll
	phaseFrame.Damage_Scroll:Refresh()
	phaseFrame.Heal_Scroll:Refresh()

	--clear phase bars
	phaseFrame:ClearPhaseBars()
end

local selectSegment = function(_, _, phaseSelected)
	phaseFrame["OnSelectPhase"](phaseSelected)
end

function phaseFrame.OnSelectPhase(phaseSelected)

	phaseFrame:ClearAll()

	--get the selected segment
	phaseFrame.CurrentSegment = encounterDetails:GetCombat(encounterDetails._segment)
	if (not phaseFrame.CurrentSegment) then
		return
	end

	--get the heal and damage for phase selected
	local phaseData = phaseFrame.CurrentSegment.PhaseData
	if (not phaseData) then
		return
	end

	phaseSelected = phaseSelected or phaseFrame.LastPhaseSelected
	phaseFrame.LastPhaseSelected = phaseSelected

	local phases = phaseFrame:GetPhaseTimers(phaseFrame.CurrentSegment, true)
	for buttonIndex, phase in ipairs(phases) do
		local button = phaseFrame.PhaseButtons[buttonIndex]
		if (phase == phaseSelected) then
			button:SetTemplate(phaseButtonTemplateHighlight)
		else
			button:SetTemplate(phaseButtonTemplate)
			if (phaseFrame.CurrentSegment.PhaseData.damage[phase]) then
				button:Enable()
			else
				button:Disable()
			end
		end
		button:SetText(phase)
		button:SetClickFunction(selectSegment, phase)
	end

	if (not phaseData.damage[phaseSelected]) then
		phaseFrame:ClearAll()
		return
	end

	--update damage and healing scrolls
	wipe(phaseFrame.DamageTable)
	for charName, amount in pairs(phaseData.damage[phaseSelected]) do
		table.insert(phaseFrame.DamageTable, {charName, amount})
	end
	table.sort(phaseFrame.DamageTable, function(a, b) return a[2] > b[2] end)

	wipe(phaseFrame.HealingTable)
	for charName, amount in pairs(phaseData.heal[phaseSelected]) do
		table.insert(phaseFrame.HealingTable, {charName, amount})
	end
	table.sort(phaseFrame.HealingTable, function(a, b) return a[2] > b[2] end)

	--refresh the scroll
	phaseFrame.Damage_Scroll:Refresh()
	phaseFrame.Heal_Scroll:Refresh()

	phaseFrame:UpdatePhaseBars()
end

local PhaseSelectLabel = detailsFramework:CreateLabel(phaseFrame, "Select Phase:", 12, "orange")
local DamageLabel = detailsFramework:CreateLabel(phaseFrame, "Damage Done")
local HealLabel = detailsFramework:CreateLabel(phaseFrame, "Healing Done")
local PhaseTimersLabel = detailsFramework:CreateLabel(phaseFrame, "Time Spent on Each Phase")

local report_damage = function(IsCurrent, IsReverse, AmtLines)
	local result = {}
	local reportFunc = function(IsCurrent, IsReverse, AmtLines)
		AmtLines = AmtLines + 1
		if (#result > AmtLines) then
			for i = #result, AmtLines+1, -1 do
				table.remove(result, i)
			end
		end
		encounterDetails:SendReportLines(result)
	end

	table.insert(result, "Details!: Damage for Phase " .. phaseFrame.LastPhaseSelected .. " of " ..(phaseFrame.CurrentSegment and phaseFrame.CurrentSegment.is_boss and phaseFrame.CurrentSegment.is_boss.name or "Unknown") .. ":")
	for i = 1, #phaseFrame.DamageTable do
		table.insert(result, encounterDetails:GetOnlyName(phaseFrame.DamageTable[i][1]) .. ": " .. Details:ToK(math.floor(phaseFrame.DamageTable[i][2])))
	end

	encounterDetails:SendReportWindow(reportFunc, nil, nil, true)
end

local Report_DamageButton = detailsFramework:CreateButton(phaseFrame, report_damage, 16, 16, "report")
Report_DamageButton:SetPoint("left", DamageLabel, "left", scrollWidth-44, 0)
Report_DamageButton.textcolor = "gray"
Report_DamageButton.textsize = 9

local report_healing = function()
	local result = {}
	local reportFunc = function(IsCurrent, IsReverse, AmtLines)
		AmtLines = AmtLines + 1
		if (#result > AmtLines) then
			for i = #result, AmtLines+1, -1 do
				table.remove(result, i)
			end
		end
		encounterDetails:SendReportLines(result)
	end

	table.insert(result, "Details!: Healing for Phase " .. phaseFrame.LastPhaseSelected .. " of " ..(phaseFrame.CurrentSegment and phaseFrame.CurrentSegment.is_boss and phaseFrame.CurrentSegment.is_boss.name or "Unknown") .. ":")
	for i = 1, #phaseFrame.HealingTable do
		table.insert(result, encounterDetails:GetOnlyName(phaseFrame.HealingTable[i][1]) .. ": " .. Details:ToK(math.floor(phaseFrame.HealingTable[i][2])))
	end

	encounterDetails:SendReportWindow(reportFunc, nil, nil, true)
end
local Report_HealingButton = detailsFramework:CreateButton(phaseFrame, report_healing, 16, 16, "report")
Report_HealingButton:SetPoint("left", HealLabel, "left", scrollWidth-44, 0)
Report_HealingButton.textcolor = "gray"
Report_HealingButton.textsize = 9


PhaseSelectLabel:SetPoint("topleft", phaseFrame, "topleft", 10, phasesY)

DamageLabel:SetPoint("topleft", phaseFrame, "topleft", 10, anchorY)
HealLabel:SetPoint("topleft", phaseFrame, "topleft", scrollWidth + 40, anchorY)
PhaseTimersLabel:SetPoint("topleft", phaseFrame, "topleft",(scrollWidth * 2) +(40*2), anchorY)

for i = 1, 10 do
	local button = detailsFramework:CreateButton(phaseFrame, phaseFrame.OnSelectPhase, 60, 20, "", i)
	button:SetPoint("left", PhaseSelectLabel, "right", 8 +((i-1) * 61), 0)
	table.insert(phaseFrame.PhaseButtons, button)
end



local ScrollRefresh = function(self, data, offset, total_lines)
	local formatToK = Details:GetCurrentToKFunction()
	local removeRealm = Details.GetOnlyName

	local topValue = data[1] and data[1][2]

	for i = 1, scrollLineAmount do
		local index = i + offset
		local player = data[index]
		if (player) then
			local line = self:GetLine(i)
			local texture, L, R, T, B = Details:GetPlayerIcon(player[1], phaseFrame.CurrentSegment)

			line.icon:SetTexture(texture)
			line.icon:SetTexCoord(L, R, T, B)
			line.name:SetText(index .. ". " .. removeRealm(_, player[1]))
			line.done:SetText(formatToK(_, player[2]) .. " (" .. string.format("%.1f", player[2] / topValue * 100) .. "%)")
			line.statusbar:SetValue(player[2] / topValue * 100)
			local actorClass = Details:GetClass(player[1])
			if (actorClass) then
				line.statusbar:SetColor(actorClass)
			else
				line.statusbar:SetColor("silver")
			end
		end
	end
end

local onEnterLine = function(self)
	self:SetBackdropColor(unpack(edTable.defaultBackgroundColor_OnEnter))
end

local onLeaveLine = function(self)
	self:SetBackdropColor(unpack(edTable.defaultBackgroundColor))
end

local scrollCreateLine = function(self, index)
	local line = CreateFrame("button", "$parentLine" .. index, self,"BackdropTemplate")
	line:SetPoint("topleft", self, "topleft", 0, -((index-1)*(scrollLineHeight+1)))
	line:SetSize(scrollWidth, scrollLineHeight)
	line:SetScript("OnEnter", onEnterLine)
	line:SetScript("OnLeave", onLeaveLine)
	line:SetScript("OnClick", line_onclick)

	line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
	line:SetBackdropColor(unpack(edTable.defaultBackgroundColor))

	local statusBar = detailsFramework:CreateBar(line, encounterDetails.Frame.DefaultBarTexture, 1, 1, 100)
	statusBar:SetAllPoints(line)
	statusBar.backgroundtexture = encounterDetails.Frame.DefaultBarTexture
	statusBar.backgroundcolor = {.3, .3, .3, .3}

	local icon = statusBar:CreateTexture("$parentIcon", "overlay")
	icon:SetSize(scrollLineHeight, scrollLineHeight)

	local name = statusBar:CreateFontString("$parentName", "overlay", "GameFontNormal")
	detailsFramework:SetFontSize(name, 10)
	icon:SetPoint("left", line, "left", 2, 0)
	name:SetPoint("left", icon, "right", 2, 0)
	detailsFramework:SetFontColor(name, "white")

	local done = statusBar:CreateFontString("$parentDone", "overlay", "GameFontNormal")
	detailsFramework:SetFontSize(done, 10)
	detailsFramework:SetFontColor(done, "white")
	done:SetPoint("right", line, "right", -2, 0)

	line.icon = icon
	line.name = name
	line.done = done
	line.statusbar = statusBar
	name:SetHeight(10)
	name:SetJustifyH("left")
	return line
end

local damageScroll = detailsFramework:CreateScrollBox(phaseFrame, "$parentDamageScroll", ScrollRefresh, phaseFrame.DamageTable, scrollWidth, scrollHeight, scrollLineAmount, scrollLineHeight)
local healScroll = detailsFramework:CreateScrollBox(phaseFrame, "$parentHealScroll", ScrollRefresh, phaseFrame.HealingTable, scrollWidth, scrollHeight, scrollLineAmount, scrollLineHeight)

damageScroll:SetPoint("topleft", DamageLabel.widget, "bottomleft", 0, -4)
healScroll:SetPoint("topleft", HealLabel.widget, "bottomleft", 0, -4)

detailsFramework:ReskinSlider(damageScroll, 4)
detailsFramework:ReskinSlider(healScroll, 4)

for i = 1, scrollLineAmount do
	damageScroll:CreateLine(scrollCreateLine)
end

phaseFrame.Damage_Scroll = damageScroll
damageScroll:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
damageScroll:SetBackdropColor(0, 0, 0, .4)

for i = 1, scrollLineAmount do
	healScroll:CreateLine(scrollCreateLine)
end

phaseFrame.Heal_Scroll = healScroll
healScroll:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
healScroll:SetBackdropColor(0, 0, 0, .4)


phaseFrame.PhasesBars = {}
phaseFrame.PhasesSegmentCompare = {}

local PhaseBarOnEnter = function(self)
	phaseFrame:UpdateSegmentCompareBars(self.phase)
	self:SetBackdropColor(unpack(edTable.defaultBackgroundColor_OnEnter))
end

local PhaseBarOnLeave = function(self)
	phaseFrame:ClearSegmentCompareBars()
	self:SetBackdropColor(unpack(edTable.defaultBackgroundColor))
end

local PhaseBarOnClick = function(self)
	--report
end

--cria as linhas mostrando o tempo decorride de cada phase
for i = 1, 10 do
	local line = CreateFrame("button", "$parentPhaseBar" .. i, phaseFrame,"BackdropTemplate")
	line:SetPoint("topleft", PhaseTimersLabel.widget, "bottomleft", 0, -((i-1)*(31)) - 4)
	line:SetSize(175, 30)
	line:SetScript("OnEnter", PhaseBarOnEnter)
	line:SetScript("OnLeave", PhaseBarOnLeave)
	line:SetScript("OnClick", PhaseBarOnClick)

	line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
	line:SetBackdropColor(unpack(edTable.defaultBackgroundColor))

	local icon = line:CreateTexture("$parentIcon", "overlay")
	icon:SetSize(16, 16)
	icon:SetTexture([[Interface\AddOns\Details\images\clock]])
	local name = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
	detailsFramework:SetFontSize(name, 10)
	local done = line:CreateFontString("$parentDone", "overlay", "GameFontNormal")
	detailsFramework:SetFontSize(done, 10)

	icon:SetPoint("left", line, "left", 2, 0)
	name:SetPoint("left", icon, "right", 2, 0)
	done:SetPoint("right", line, "right", -3, 0)

	line.icon = icon
	line.name = name
	line.done = done
	name:SetHeight(10)
	name:SetJustifyH("left")

	table.insert(phaseFrame.PhasesBars, line)
end

--cria a linha do segmento para a compara��o, � o que fica na parte direita da tela
--ele � acessado para mostrar quando passar o mouse sobre uma das barras de phase
for i = 1, 20 do
	local line = CreateFrame("button", "$parentSegmentCompareBar" .. i, phaseFrame,"BackdropTemplate")
	line:SetPoint("topleft", PhaseTimersLabel.widget, "bottomleft", 175+10, -((i-1)*(scrollLineHeight+1)) - 4)
	line:SetSize(150, scrollLineHeight)

	line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
	line:SetBackdropColor(unpack(edTable.defaultBackgroundColor))
	line:Hide()
	local name = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
	detailsFramework:SetFontSize(name, 9)
	name:SetPoint("left", line, "left", 2, 0)

	local done = line:CreateFontString("$parentDone", "overlay", "GameFontNormal")
	detailsFramework:SetFontSize(done, 9)
	done:SetPoint("right", line, "right", -2, 0)

	line.name = name
	line.done = done
	name:SetHeight(10)
	name:SetJustifyH("left")

	table.insert(phaseFrame.PhasesSegmentCompare, line)
end

function phaseFrame:ClearPhaseBars()
	for i = 1, #phaseFrame.PhasesBars do
		local bar = phaseFrame.PhasesBars[i]
		bar.name:SetText("")
		bar.done:SetText("")
		bar.phase = nil
		bar:Hide()
	end
end
function phaseFrame:ClearSegmentCompareBars()
	for i = 1, #phaseFrame.PhasesSegmentCompare do
		phaseFrame.PhasesSegmentCompare[i]:Hide()
	end
end

function phaseFrame:GetPhaseTimers(segment, ordered)
	local t = {}

	segment = segment or phaseFrame.CurrentSegment

	for phaseIT = 1, #segment.PhaseData do
		local phase, startAt = unpack(segment.PhaseData[phaseIT]) --phase iterator
		local endAt = segment.PhaseData[phaseIT+1] and segment.PhaseData[phaseIT+1][2] or segment:GetCombatTime()
		local elapsed = endAt - startAt
		t[phase] = (t[phase] or 0) + elapsed
	end

	if (ordered) then
		local order = {}
		for phase, _ in pairs(t) do
			table.insert(order, phase)
		end
		table.sort(order, function(a, b) return a < b end)
		return order, t
	end

	return t
end

--executa quando atualizar o segment geral
function phaseFrame:UpdatePhaseBars()
	local timers, hash = phaseFrame:GetPhaseTimers(phaseFrame.CurrentSegment, true)
	local i = 1
	for index, phase in ipairs(timers) do
		local timer = hash[phase]
		phaseFrame.PhasesBars[i].name:SetText("|cFFC0C0C0Phase:|r |cFFFFFFFF" .. phase)
		phaseFrame.PhasesBars[i].done:SetText(detailsFramework:IntegerToTimer(timer))
		phaseFrame.PhasesBars[i].phase = phase
		phaseFrame.PhasesBars[i]:Show()
		i = i + 1
	end
end

--executa quando passar o mouse sobre uma bnarra de phase
function phaseFrame:UpdateSegmentCompareBars(phase)
	--segmento atual(numero)
	local segmentNumber = encounterDetails._segment
	local segmentTable = phaseFrame.CurrentSegment
	local bossID = segmentTable:GetBossInfo() and segmentTable:GetBossInfo().id

	local index = 1
	for i, segment in ipairs(Details:GetCombatSegments()) do
		if (segment:GetBossInfo() and segment:GetBossInfo().id == bossID) then

			local bar = phaseFrame.PhasesSegmentCompare [index]
			local timers = phaseFrame:GetPhaseTimers(segment)

			if (timers [phase]) then
				if (segment ~= segmentTable) then
					bar.name:SetText("Segment " .. i .. ":")
					detailsFramework:SetFontColor(bar.name, "orange")
					bar.done:SetText(detailsFramework:IntegerToTimer(timers [phase]))
					detailsFramework:SetFontColor(bar.done, "orange")
				else
					bar.name:SetText("Segment " .. i .. ":")
					detailsFramework:SetFontColor(bar.name, "white")
					bar.done:SetText(detailsFramework:IntegerToTimer(timers [phase]))
					detailsFramework:SetFontColor(bar.done, "white")
				end
			else
				bar.name:SetText("Segment " .. i .. ":")
				detailsFramework:SetFontColor(bar.name, "red")
				bar.done:SetText("--x--x--")
			end

			bar:Show()
			index = index + 1
		end
	end

end