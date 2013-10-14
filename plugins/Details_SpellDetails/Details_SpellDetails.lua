local Loc = LibStub ("AceLocale-3.0"):GetLocale ("Details_SpellDetails")
local Graphics = LibStub:GetLibrary("LibGraph-2.0")

--> Main Plugin Object
local SpellDetails = _detalhes:NewPluginObject ("Details_SpellDetails")
--> Main Frame
local SpellDetailsFrame = SpellDetails.Frame

--> Needed locals
local _GetTime = GetTime --> wow api local
local _UFC = UnitAffectingCombat --> wow api local
local _IsInRaid = IsInRaid --> wow api local
local _IsInGroup = IsInGroup --> wow api local
local _UnitAura = UnitAura --> wow api local
local _CreateFrame = CreateFrame --> wow api local
local _ipairs = ipairs --> lua library local
local _pairs = pairs --> lua library local
local _string_len = string.len --> lua library local
local _math_floor = math.floor --> lua library local
local _cstr = string.format --> lua library local
local _string_format = string.format
local _table_sort = table.sort
local _tostring = tostring
local _GetSpellInfo =_detalhes.getspellinfo --> details spell cache
local _string_lower = string.lower
local _string_sub = string.sub

--> this function will run when the plugin receives the Addon_Loaded event, ["data"] = previus saved player rank
local function CreatePluginFrames (data)

	--> catch Details! main object
	local _detalhes = _G._detalhes
	local DetailsFrameWork = _detalhes.gump
	
	if (not _detalhes) then
		--> details isn't active
		return
	end

	--> Saved Data
	SpellDetails.data = data or {}
	SpellDetails.updating = false

	local timeCaptureFunction = function (second, myTimeTable, myAttributesTable)
		--> second: number of the tick
		--> myTimeTable: is the table wich will contain the data
		--> myAttributesTable: table wich your custom parameters
		
		if (SpellDetails.playerActor) then
			--> get player total damage
			local actorTotalDamage = SpellDetails.playerActor.total
			--> calculate the diferente between last tick
			local currentDamage = actorTotalDamage - myAttributesTable.lastDamage
			--> record damage
			myTimeTable [second] = currentDamage
			--> check if this tick was greater then before
			if (currentDamage > myAttributesTable.maxDamage) then
				myAttributesTable.maxDamage = currentDamage
			end
			--> record tick total damage
			myAttributesTable.lastDamage = actorTotalDamage
		end
	end
	
	function SpellDetails:OnDetailsEvent (event, ...)
		if (event == "SHOW") then --> plugin shown on screen, actived
		
			--> register a custom time capture // time capture is a custom function wich will run every second and grab any kind of data.
			--> here we want to capture the damage of "player".
			--> _detalhes:RegisterTimeCapture ( function, give a name, parameters table )

			_detalhes:RegisterTimeCapture (timeCaptureFunction, "SpellDetails_PlayerDamage", {lastDamage = 0, maxDamage = 0})
			
		elseif (event == "HIDE") then --> plugin hidded, disabled
			SpellDetailsFrame:SetScript ("OnUpdate", nil)
			_detalhes:UnregisterTimeCapture ("SpellDetails_PlayerDamage")
			SpellDetails.playerActor = nil
		
		elseif (event == "REFRESH") then --> requested a refresh window
			SpellDetails:Refresh()
			
		elseif (event == "COMBAT_PLAYER_TIMESTARTED") then --> combat started
			if (not SpellDetailsFrame:GetScript ("OnUpdate")) then
				_detalhes:RegisterEvent (SpellDetails, "BUFF_UPDATE") --> register buffs on player
				_detalhes:RegisterEvent (SpellDetails, "BUFF_UPDATE_DEBUFFPOWER") --> register debuffs wich player cast on oponents
				SpellDetails:RefreshBuffs()
				SpellDetails:JanelaSoloUpdate (1)
				SpellDetails.playerActor = select (2, ...)
			end
			
		elseif (event == "BUFF_UPDATE") then
			--> trigger when a buff is applyed on player
			SpellDetails:RefreshBuffs()
		
		end
	end
	
	function SpellDetails:CombatEnd()
		_detalhes:UnregisterEvent (SpellDetails, "BUFF_UPDATE")
		_detalhes:UnregisterEvent (SpellDetails, "BUFF_UPDATE_DEBUFFPOWER")
		SpellDetailsFrame:SetScript ("OnUpdate", nil)
		SpellDetails:RefreshBuffs()
	end
	
--------> Build Frame and Widgets ---------------------------------------------------------------------------------------------------------------------------
	SpellDetailsFrame:SetResizable (false)
	SpellDetailsFrame:SetPoint ("TOPLEFT", UIParent, "TOPLEFT")
	SpellDetailsFrame:SetWidth (1)
	SpellDetailsFrame:SetHeight (1)
	
	--> Widgets Container
	SpellDetails.SummaryLine = {}
	SpellDetails.SpellButtons = {}
	SpellDetails.SpellInfoLabels = {}
	SpellDetails.BuffTextEntry = {}	
	
	--> reset all labels
	function SpellDetails:ResetWindow()
		SpellDetails.SummaryLine:Reset()
		SpellDetails.SpellButtons:Reset()
		SpellDetails.SpellInfoLabels:Reset()
		SpellDetails:ClearBuffTexts()
	end

--------> Build head displays -----------------------------------------------------------------------------------------	
	local y = -5
	local x = {
		25, 55, --> total de feito
		120, 158, --> media
		200, 240 --> tempo decorrido
	}

	--> background
	SpellDetailsFrame.bg_status = SpellDetailsFrame:CreateTexture (nil, "BACKGROUND")
	SpellDetailsFrame.bg_status:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", -35, y+5)
	SpellDetailsFrame.bg_status:SetWidth (370)
	SpellDetailsFrame.bg_status:SetHeight (30)
	SpellDetailsFrame.bg_status:SetTexture ("Interface\\UNITPOWERBARALT\\WowUI_Horizontal_Frame")
		
	local TotalLabel = DetailsFrameWork:NewLabel (SpellDetailsFrame, SpellDetailsFrame, nil, "SummaryDmg", Loc ["STRING_DAMAGE"]..": ".." 0", "GameFontHighlightSmall")
	TotalLabel:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", x[1]-5, y-5)

	local TotalDpsLabel = DetailsFrameWork:NewLabel (SpellDetailsFrame, SpellDetailsFrame, nil, "SummaryDps", Loc ["STRING_DPS"]..":".." 0", "GameFontHighlightSmall")
	TotalDpsLabel:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", x[3], y-5)
	
	local TotalTimeLabel = DetailsFrameWork:NewLabel (SpellDetailsFrame, SpellDetailsFrame, nil, "SummaryTime", Loc ["STRING_TEMPO"]..":".." 0.0", "GameFontHighlightSmall")
	TotalTimeLabel:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", x[5]+10, y-5)
	
	SpellDetails.SummaryLine.total = TotalLabel
	SpellDetails.SummaryLine.dps = TotalDpsLabel
	SpellDetails.SummaryLine.time = TotalTimeLabel
	
	function SpellDetails.SummaryLine:Reset()
		SpellDetails.SummaryLine.total:SetText (Loc ["STRING_DAMAGE"]..": 0")
		SpellDetails.SummaryLine.dps:SetText (Loc ["STRING_DPS"]..":".." 0")
		SpellDetails.SummaryLine.time:SetText (Loc ["STRING_TEMPO"]..":".." 0")
	end
	
--------> Build 9 spells boxes -----------------------------------------------------------------------------------------

	function SpellDetails:ChangeSpellBox (id, spellid, icon, line1, line2, tooltip)
		local BoxTable = SpellDetails.SpellButtons [id]
		
		if (BoxTable) then
			if (icon) then
				BoxTable.icon:SetTexture (icon)
			end
			
			if (line1) then
				BoxTable.label1:SetText (line1)
			end
			
			if (line2) then
				BoxTable.label2:SetText (line2)
			end
			
			if (tooltip) then
				BoxTable.button.tooltip = tooltip
			end
			
			BoxTable.spellid = spellid
		end
	end
	
	function SpellDetails.ShowSpellDetails (id)
		if (SpellDetails.CurrentSpellSlot) then
			SpellDetails.SpellButtons [SpellDetails.CurrentSpellSlot].background:Hide()
		end
		return SpellDetails:DetalhesDaMagia (id)
	end
	
	local CreateSpellBox = function (x, y, w, h, id, framelevel)
	
		local button = DetailsFrameWork:NewDetailsButton (SpellDetailsFrame, SpellDetailsFrame, _, SpellDetails.ShowSpellDetails, id, _, w, h+10, "Interface\\BUTTONS\\UI-DialogBox-Button-Disabled.blp")
		button:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", x, y)
		button:SetFrameLevel (framelevel)
		
		local icon = button:CreateTexture (nil, "OVERLAY")
		icon:SetPoint ("TOPLEFT", button, "TOPLEFT", 6, -5)
		icon:SetWidth (18)
		icon:SetHeight (18)
		
		local label2 = DetailsFrameWork:NewLabel (button, button, nil, "text2", "", "GameFontHighlightSmall", 9.2)
		label2:SetPoint ("LEFT", icon, "RIGHT", 5, 4)
		local label1 = DetailsFrameWork:NewLabel (button, button, nil, "text1", "", "GameFontHighlightSmall", 9.2)
		label1:SetPoint ("LEFT", icon, "RIGHT", 5, -5)
		
		local box = button:CreateTexture (nil, "artwork")
		box:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", x, y)
		box:SetWidth (w)
		box:SetHeight (h+10)
		box:SetTexture ("Interface\\BUTTONS\\UI-DialogBox-Button-Disabled.blp")
		box:SetBlendMode ("ADD")
		box:Hide()
		
		SpellDetails.SpellButtons [id] = {background = box, button = button, icon = icon, label1 = label1, label2 = label2, selected = false}
	end
	
	SpellDetails.SpellButtons.LastSelected = nil
	SpellDetails.SpellButtons.selected = SpellDetailsFrame:CreateTexture (nil, "background")
	SpellDetails.SpellButtons.selected:SetDrawLayer ("background", 1)
	SpellDetails.SpellButtons.selected:SetWidth (98)
	SpellDetails.SpellButtons.selected:SetHeight (36)
	
	function SpellDetails:ClearSpellBox (id)
		local BoxTable = SpellDetails.SpellButtons [id]
		if (BoxTable) then
			BoxTable.icon:SetTexture (nil)
			BoxTable.label1:SetText ("")
			BoxTable.label2:SetText ("")
			BoxTable.button.tooltip = nil
			BoxTable.selected = false
		end
	end	
	
	function SpellDetails.SpellButtons:Reset()
		for i = 1, 9 do
			SpellDetails:ClearSpellBox (i)
			SpellDetails.SpellButtons.LastSelected = nil
			SpellDetails.SpellButtons.selected:ClearAllPoints()
		end
	end
	
	--> Call the build function for the 9 spell boxes
	local ROWX = {6, 106, 206} --> up
	
	for i = 1, 3 do 
		CreateSpellBox (ROWX[i], -32, 90, 30, i, 5)
	end
	for i = 4, 6 do 
		CreateSpellBox (ROWX[i-3], -62, 90, 30, i, 6)
	end
	for i = 7, 9 do 
		CreateSpellBox (ROWX[i-6], -92, 90, 30, i, 7)
	end
	
--------> Cria o background da esquerda
	SpellDetails.graphic = {}
	
	SpellDetails.graphic.fundo = _CreateFrame ("frame", nil, SpellDetailsFrame)
	SpellDetails.graphic.fundo:SetPoint ("topleft", SpellDetailsFrame, "topleft", 5, -133)
	SpellDetails.graphic.fundo:SetWidth (288)
	SpellDetails.graphic.fundo:SetHeight (160)
	SpellDetails.graphic.fundo:SetBackdrop ({
		--edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 16, edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 1},
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		
	SpellDetails.graphic.fundo:SetScript ("OnEnter", function() 
		local _r, _g, _b, _a =SpellDetails.graphic.fundo:GetBackdropColor()
		DetailsFrameWork:GradientEffect (SpellDetails.graphic.fundo, "frame", _r, _g, _b, _a, .3, .3, .3, .5, 0.9)
	end)
	
	SpellDetails.graphic.fundo:SetScript ("OnLeave", function()  
		local _r, _g, _b, _a = SpellDetails.graphic.fundo:GetBackdropColor()
		DetailsFrameWork:GradientEffect (SpellDetails.graphic.fundo, "frame", _r, _g, _b, _a, .9, .7, .7, 1, 0.9)
	end)

	
	--> Cria a janela do gráfico
	if (not _G.DetailsSoloDpsGraph) then
		local g = Graphics:CreateGraphLine ("DetailsSoloDpsGraph", SpellDetails.graphic.fundo, "topleft", "topleft", 0, 0, 288, 140)
		g:SetXAxis (-1,1)
		g:SetYAxis (-1,1)
		g:SetGridSpacing (false, 0.105)
		g:SetGridColor ({0.5, 0.5, 0.5, 0.5})
		g:SetAxisDrawing (true, true)
		g:SetAxisColor({1.0, 1.0, 1.0, 1.0})
		g:SetAutoScale (true)
		g.CustomRightBorder = 0.001
		g.max_time = 0
		g.max_damage = 0
		g.BuffLines = {}
		g.LinesContainer = {}
		g.CustomLine = "Interface\\AddOns\\Details\\Libs\\LibGraph-2.0\\smallline"
		--g.LockOnXMax = true
		
		for i = 1, 8, 1 do
			DetailsFrameWork:NewLabel (SpellDetails.graphic.fundo, SpellDetails.graphic.fundo, nil, "dpsamt"..i, "", "GameFontHighlightSmall")
			SpellDetails.graphic.fundo["dpsamt"..i]:SetPoint ("TOPLEFT", SpellDetails.graphic.fundo, "TOPLEFT", -1, -(14.4*i))
			_detalhes:SetFontSize (SpellDetails.graphic.fundo["dpsamt"..i], 9)
		end
		
	end

	function SpellDetails:UpdateDamageGraphic()

		local GraphicObject = _G.DetailsSoloDpsGraph
		
		if (not GraphicObject) then
			print ("Nao ha um grafico criado.")
			return
		end
		
		SpellDetails.LastGraphicDrew = SpellDetails.LastGraphicDrew or {}
		local graphicData = _detalhes.tabela_vigente:GetTimeData()
		
		if (graphicData == SpellDetails.LastGraphicDrew) then
			return
		else
			SpellDetails.LastGraphicDrew = SpellDetails.LastGraphicDrew
		end
		
		if (not graphicData ["SpellDetails_PlayerDamageAttributes"]) then
			return
		elseif (graphicData ["SpellDetails_PlayerDamageAttributes"].maxDamage == 0) then
			return
		end
		
		if (#graphicData ["SpellDetails_PlayerDamageData"] < 2) then
			local timetooshort = SpellDetails.graphic.fundo.timetooshot or DetailsFrameWork:NewLabel (SpellDetails.graphic.fundo, SpellDetails.graphic.fundo, nil, "timetooshort", Loc ["STRING_TOOSHORT"], "GameFontHighlightSmall")
			timetooshort:SetPoint ("TOPLEFT", SpellDetails.graphic.fundo, "TOPLEFT", 40, -55)
			_detalhes:SetFontSize (timetooshort, 10)
			timetooshort:SetJustifyH ("center")
			timetooshort:Show()
			return
		elseif (SpellDetails.graphic.fundo.timetooshort) then
			SpellDetails.graphic.fundo.timetooshort:Hide()
		end
		
		GraphicObject:ResetData()
		
		local _data = {}
		local dps_max = graphicData ["SpellDetails_PlayerDamageAttributes"].maxDamage
		local amount = #graphicData ["SpellDetails_PlayerDamageData"]
		
		local scaleW = 1/288

		local content = graphicData ["SpellDetails_PlayerDamageData"]
		table.insert (content, 1, 0)
		table.insert (content, 1, 0)
		table.insert (content, #content+1, 0)
		table.insert (content, #content+1, 0)
		local _i = 3
		while (_i <= #content-2) do 
			local v = (content[_i-2]+content[_i-1]+content[_i]+content[_i+1]+content[_i+2])/5
			_data [#_data+1] = {scaleW*(_i-2), v/dps_max} -->
			_i = _i + 1
		end

		local BuffTable = _detalhes.Buffs.BuffsTable
		local iconIndex = 1
		
		if (BuffTable) then
		
			local geralLineIndex = 1
			local scaleG = 277/_detalhes.tabela_vigente:GetCombatTime() --288
			
			for spellName, spellTable in _pairs (BuffTable) do
				
				local timeTable = {}
				for index, appliedAt in _ipairs (spellTable.appliedAt) do 
					timeTable [#timeTable+1] = {appliedAt, spellTable.tableIndex}
				end
				
				for index, appliedAt in _ipairs (timeTable) do
					local thisLine = GraphicObject.BuffLines [geralLineIndex]
					if (not thisLine) then
						thisLine = GraphicObject:CreateTexture (nil, "overlay")
						thisLine:SetTexture ("Interface\\AddOns\\Details\\images\\verticalline")
						thisLine:SetWidth (3)
						thisLine:SetHeight (160)
						thisLine:SetPoint ("topleft", SpellDetails.graphic.fundo, "topleft", (appliedAt[1]*scaleG)+25, 0)
						thisLine:SetVertexColor (.4, .4, .4, .8)
						
						thisLine.icon = GraphicObject:CreateTexture (nil, "overlay")
						local _, _, icon = GetSpellInfo (spellName)
						--print (spellName, icon) 
						thisLine.icon:SetTexture (icon)
						thisLine.icon:SetWidth (12)
						thisLine.icon:SetHeight (12)
						
						if (iconIndex == 1) then
							thisLine.icon:SetPoint ("left", thisLine, "right", -2, 0)
							thisLine.icon:SetPoint ("top", thisLine, "bottom", 0, 25)
						elseif (iconIndex == 2) then
							thisLine.icon:SetPoint ("right", thisLine, "left", 2, 0)
							thisLine.icon:SetPoint ("top", thisLine, "bottom", 0, 25)
						elseif (iconIndex == 3) then
							thisLine.icon:SetPoint ("right", thisLine, "left", 2, 0)
							thisLine.icon:SetPoint ("top", thisLine, "bottom", 0, 12)
						elseif (iconIndex == 4) then
							thisLine.icon:SetPoint ("left", thisLine, "right", -2, 0)
							thisLine.icon:SetPoint ("top", thisLine, "bottom", 0, 12)
						end

						GraphicObject.BuffLines [geralLineIndex] = thisLine
					else
						thisLine:SetPoint ("topleft", SpellDetails.graphic.fundo, "topleft", (appliedAt[1]*scaleG)+28, 0)
						local _, _, icon = GetSpellInfo (spellName)
						thisLine.icon:SetTexture (icon)
					end
					
					geralLineIndex = geralLineIndex + 1
				end
				
				iconIndex = iconIndex + 1
				if (iconIndex == 5) then
					iconIndex = 1
				end

			end
		end
		
		local dano_divisao = dps_max/8
		local o = 1
		for i = 8, 1, -1 do
			local d = _detalhes:ToK0 (dano_divisao*i)
			SpellDetails.graphic.fundo["dpsamt"..o]:SetText (d)
			o = o + 1
		end
		
		GraphicObject:AddDataSeries (_data, {1, 1, 1, 1})
		
	end	
	
	--> Hida
	SpellDetails.graphic.fundo:Hide()	

--------> Cria o background
	SpellDetailsFrame.fundo = SpellDetailsFrame:CreateTexture (nil, "background")
	SpellDetailsFrame.fundo:SetTexture ("Interface\\AddOns\\Details_SpellDetails\\images\\solo_bg")
	SpellDetailsFrame.fundo:SetPoint ("topleft", SpellDetailsFrame, "topleft", 0, -125)
	SpellDetailsFrame.fundo:SetWidth (298)
	SpellDetailsFrame.fundo:SetHeight (175)
	SpellDetailsFrame.fundo:SetTexCoord (0, 0.615234375, 0, 0.6640625)
	SpellDetailsFrame.fundo:SetDrawLayer ("background", 1)
	
--------> Cria o background da esquerda
	SpellDetailsFrame.fundoEsq = _CreateFrame ("frame", nil, SpellDetailsFrame)
	--SpellDetailsFrame.fundoEsq:SetTexture ("Interface\\Tooltips\\UI-Tooltip-Background")
	SpellDetailsFrame.fundoEsq:SetPoint ("topleft", SpellDetailsFrame, "topleft", 5, -133)
	SpellDetailsFrame.fundoEsq:SetWidth (120)
	SpellDetailsFrame.fundoEsq:SetHeight (160)
	SpellDetailsFrame.fundoEsq:SetBackdrop ({
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 16, edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 1},
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		
	SpellDetailsFrame.fundoEsq:SetScript ("OnEnter", function() 
		local _r, _g, _b, _a =SpellDetailsFrame.fundoEsq:GetBackdropColor()
		DetailsFrameWork:GradientEffect (SpellDetailsFrame.fundoEsq, "frame", _r, _g, _b, _a, .3, .3, .3, .5, .9)
		
	end)
	
	SpellDetailsFrame.fundoEsq:SetScript ("OnLeave", function()  
		local _r, _g, _b, _a = SpellDetailsFrame.fundoEsq:GetBackdropColor()
		DetailsFrameWork:GradientEffect (SpellDetailsFrame.fundoEsq, "frame", _r, _g, _b, _a, .9, .7, .7, 1, .9)
	end)

--------> Cria o background da direita
	SpellDetailsFrame.fundoDir = _CreateFrame ("frame", nil, SpellDetailsFrame)
	SpellDetailsFrame.fundoDir:SetPoint ("topleft", SpellDetailsFrame, "topright", 127, -138+5)
	SpellDetailsFrame.fundoDir:SetWidth (166)
	SpellDetailsFrame.fundoDir:SetHeight (160)
	SpellDetailsFrame.fundoDir:SetBackdrop ({
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 16, edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 1},
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
	SpellDetailsFrame.fundoDir:SetScript ("OnEnter", function() 
		local _r, _g, _b, _a =SpellDetailsFrame.fundoDir:GetBackdropColor()
		DetailsFrameWork:GradientEffect (SpellDetailsFrame.fundoDir, "frame", _r, _g, _b, _a, .3, .3, .3, .5, .9)
	end)
	SpellDetailsFrame.fundoDir:SetScript ("OnLeave", function()  
		local _r, _g, _b, _a = SpellDetailsFrame.fundoDir:GetBackdropColor()
		DetailsFrameWork:GradientEffect (SpellDetailsFrame.fundoDir, "frame", _r, _g, _b, _a, .9, .7, .7, 1, .9)
	end)
	
-----------------------------------------------------------------------------------------------------------------------------------------------
--> botão switch

	SpellDetails.Detalhes = 1 --> normal
	function SpellDetails:ShowGraphic() 
		--> hidar os 2 blocos em baixo:
		
		if (SpellDetails.Detalhes == 1) then --> show graphic
			
			if (InCombatLockdown()) then
				print ("|cffFF2222"..Loc ["STRING_INCOMBAT"])
				return
			end
			
			SpellDetailsFrame.fundoEsq:Hide()
			SpellDetailsFrame.fundoDir:Hide()
			SpellDetails.Detalhes = 2
			SpellDetails.SwitchButton.text:SetText ("X") --> localize-me
			SpellDetails.SwitchButton:SetWidth (15)
			SpellDetails.graphic.fundo:Show()
			SpellDetails:UpdateDamageGraphic (SpellDetailsFrame)
			SpellDetails.SwitchButton:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", 275, -136)
			
		elseif (SpellDetails.Detalhes == 2) then --> show normal details
			SpellDetailsFrame.fundoEsq:Show()
			SpellDetailsFrame.fundoDir:Show()
			SpellDetails.Detalhes = 1
			SpellDetails.SwitchButton.text:SetText ("Graphic") --> localize-me
			SpellDetails.SwitchButton:SetWidth (110)
			SpellDetails.graphic.fundo:Hide()
			SpellDetails.SwitchButton:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", 10, -274)
			
		end
	end
	
	--> botão para o gráfico:
	local SwitchButton = DetailsFrameWork:NewDetailsButton (SpellDetailsFrame, SpellDetailsFrame, _, SpellDetails.ShowGraphic, _, _, 110, 15)
	SwitchButton:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", 10, -274)
	SwitchButton:SetFrameLevel (6)
	SwitchButton:InstallCustomTexture()
	SwitchButton.text:SetText ("Graphic") --> localize-me
	
	SpellDetails.SwitchButton = SwitchButton	

	
--------------------------------------------------------------------------------------------------------------------------------------------
 --> painel da esquerda inferior (informações da magia)

	local loc_y = {-140, -150, -160, -170, -180, -190, -200, -210, -220, -230, -240}
	local xStart = 10
	
	local total = DetailsFrameWork:NewLabel (SpellDetailsFrame.fundoEsq, SpellDetailsFrame.fundoEsq, nil, "total", Loc ["STRING_DAMAGE"]..":", "GameFontHighlightSmall")
	SpellDetailsFrame.fundoEsq.total:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", xStart, loc_y[1])
	SpellDetails.SpellInfoLabels.total = total
	
	local dps = DetailsFrameWork:NewLabel (SpellDetailsFrame.fundoEsq, SpellDetailsFrame.fundoEsq, nil, "dps", Loc ["STRING_DPS"]..":", "GameFontHighlightSmall")
	SpellDetailsFrame.fundoEsq.dps:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", xStart, loc_y[2])
	SpellDetails.SpellInfoLabels.dps = dps

	local media = DetailsFrameWork:NewLabel (SpellDetailsFrame.fundoEsq, SpellDetailsFrame.fundoEsq, nil, "porcento", Loc ["STRING_PERCENT"]..":", "GameFontHighlightSmall")
	SpellDetailsFrame.fundoEsq.porcento:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", xStart, loc_y[3])
	SpellDetails.SpellInfoLabels.porcento = media

	local uptime = DetailsFrameWork:NewLabel (SpellDetailsFrame.fundoEsq, SpellDetailsFrame.fundoEsq, nil, "tempo_em_uso", Loc ["STRING_UPTIME"]..":", "GameFontHighlightSmall")
	SpellDetailsFrame.fundoEsq.tempo_em_uso:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", xStart, loc_y[4])
	SpellDetails.SpellInfoLabels.uptime = uptime
	
	local critical = DetailsFrameWork:NewLabel (SpellDetailsFrame.fundoEsq, SpellDetailsFrame.fundoEsq, nil, "critico", Loc ["STRING_CRIT"]..":", "GameFontHighlightSmall")
	SpellDetailsFrame.fundoEsq.critico:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", xStart, loc_y[5])
	SpellDetails.SpellInfoLabels.critical = critical

	local miss = DetailsFrameWork:NewLabel (SpellDetailsFrame.fundoEsq, SpellDetailsFrame.fundoEsq, nil, "miss", Loc ["STRING_MISS"]..":", "GameFontHighlightSmall")
	SpellDetailsFrame.fundoEsq.miss:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", xStart, loc_y[6])
	SpellDetails.SpellInfoLabels.miss = miss
	
	local block = DetailsFrameWork:NewLabel (SpellDetailsFrame.fundoEsq, SpellDetailsFrame.fundoEsq, nil, "blocked", Loc ["STRING_BLOCKED"]..":", "GameFontHighlightSmall")
	SpellDetailsFrame.fundoEsq.blocked:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", xStart, loc_y[7])
	SpellDetails.SpellInfoLabels.block = block
	
	local glancing = DetailsFrameWork:NewLabel (SpellDetailsFrame.fundoEsq, SpellDetailsFrame.fundoEsq, nil, "glancing", "Glancing: ", "GameFontHighlightSmall")
	SpellDetailsFrame.fundoEsq.glancing:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPLEFT", xStart, loc_y[8])
	SpellDetails.SpellInfoLabels.glancing = glancing
	
	function SpellDetails.SpellInfoLabels:Reset()
		SpellDetails.SpellInfoLabels.total:SetText (Loc ["STRING_DAMAGE"]..": 0")
		SpellDetails.SpellInfoLabels.dps:SetText (Loc ["STRING_DPS"]..":".." 0")
		SpellDetails.SpellInfoLabels.porcento:SetText (Loc ["STRING_PERCENT"]..":".." 0")
		SpellDetails.SpellInfoLabels.uptime:SetText (Loc ["STRING_UPTIME"]..":".." 0")
		SpellDetails.SpellInfoLabels.critical:SetText (Loc ["STRING_CRIT"]..":".." 0")
		SpellDetails.SpellInfoLabels.miss:SetText (Loc ["STRING_MISS"]..":".." 0")
		SpellDetails.SpellInfoLabels.block:SetText (Loc ["STRING_BLOCKED"]..":".." 0")
		SpellDetails.SpellInfoLabels.glancing:SetText (Loc ["STRING_GLANCING"]..":".." 0")
	end
	

	
--------------------------------------------------------------------------------------------------------------------------------------------
 --> painel da direita inferior (detalhes dos buffs do jogador)
 
	--_detalhes.SoloTables.BuffsTable.BuffIds = _detalhes.SoloTables.BuffsTable.BuffIds or {0, 0, 0, 0}
	--_detalhes.SoloTables.BuffsTableNameCache = _detalhes.SoloTables.BuffsTableNameCache or {"", "", "", ""}

	local BuffIndex = {}
	
	function SpellDetails:ClearBuffTexts()
		for _, BuffInput in _ipairs (SpellDetails.BuffTextEntry) do
			BuffInput.amtdone:SetText ("")
			BuffInput.dps:SetText ("")
			BuffInput.uptime:SetText ("")
		end
	end
	
	function SpellDetails:SetBuffTexts (id, damage, dps)
		local BuffInput = SpellDetails.BuffTextEntry [id]
		BuffInput.amtdone:SetText (Loc ["STRING_DAMAGE"]..": "..damage)
		BuffInput.dps:SetText (Loc ["STRING_DPS"]..":".." "..dps)
	end
	
	local Clear = function (BuffEntryTable)
		--> clicked on X to clear the buff
		_detalhes.Buffs:RemoveBuff (BuffEntryTable.name:GetText())
		
		--_detalhes.SoloTables.BuffsTable.BuffIds [BuffEntryTable.id] = 0
		BuffIndex [BuffEntryTable.name:GetText()] = nil
		
		BuffEntryTable.icon:SetTexture (nil)
		BuffEntryTable.name:SetText ("")
		BuffEntryTable.amtdone:SetText ("")
		BuffEntryTable.dps:SetText ("")
		BuffEntryTable.editbox:SetText (Loc ["STRING_DEBUFFNAME"])
		BuffEntryTable.editbox:Show()
		BuffEntryTable.background:Hide()
		BuffEntryTable.backgroundFrame:Hide()
		BuffEntryTable.button:Hide()
	end
	
	local SetBuff = function (BuffEntryTable, spellid, id)
	
		local spellname, _, spellicon = GetSpellInfo (spellid)

		if (not _detalhes.Buffs:IsRegistred (spellid)) then
			_detalhes.Buffs:NewBuff (spellname, spellid)
		end
		
		BuffIndex [spellname] = BuffEntryTable
		
		BuffEntryTable.icon:SetTexture (spellicon)
		BuffEntryTable.name:SetText (spellname)
		BuffEntryTable.amtdone:SetText (Loc ["STRING_DAMAGE"]..": 0")
		BuffEntryTable.dps:SetText (Loc ["STRING_DPS"]..":".." 0")
		BuffEntryTable.editbox:Hide()
		BuffEntryTable.background:Show()
		BuffEntryTable.backgroundFrame:Show()
		BuffEntryTable.button:Show()
		--print (debugstack())
	end

	local OnEnter = function (_, id, texto, editbox, by)

		if (_string_len (texto) > 0 and texto ~= Loc ["STRING_DEBUFFNAME"]) then
			if (by == editbox) then --> By Enter
				if (_detalhes.popup.NumLines > 0) then
					local texto2 = _detalhes.popup:GetText(1):match ("(.-):")
					texto = texto2
				end
			end
			if (not tonumber (texto)) then
				editbox:SetText (Loc ["STRING_DEBUFFNAME"])
				return
			end
			SetBuff (SpellDetails.BuffTextEntry [id], tonumber (texto), id)
		else 
			editbox:SetText (Loc ["STRING_DEBUFFNAME"])
		end 

		if (_detalhes.popup.active) then
			_detalhes.popup:ShowMe (false)
		end
	end	
	
	local CreateBuffInput = function (y, id)
	
		local backgroundFrame = _CreateFrame ("frame", "SoloBuffEditBox"..id.."Background", SpellDetailsFrame.fundoDir)
		backgroundFrame:SetWidth (166)
		backgroundFrame:SetHeight (40)
		backgroundFrame:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPRIGHT", 127, y+5+8)
		backgroundFrame:SetBackdrop ({edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 1},
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background"})
		backgroundFrame:SetBackdropColor (.3, .3, .3, .5)
		--backgroundFrame:SetBackdropBorderColor (1, 0, 0, 1)
		backgroundFrame:Hide()
		
		backgroundFrame:SetScript ("OnEnter", function() 
			if (not backgroundFrame.Actived) then
				local _r, _g, _b, _a = backgroundFrame:GetBackdropColor()
				DetailsFrameWork:GradientEffect (backgroundFrame, "frame", _r, _g, _b, _a, .9, .7, .7, 1, .9)
			else
				local _r, _g, _b, _a = backgroundFrame:GetBackdropColor()
				DetailsFrameWork:GradientEffect (backgroundFrame, "frame", _r, _g, _b, _a, 75/255, 246/255, 78/255, 1, .9)
			end
		end)
		
		backgroundFrame:SetScript ("OnLeave", function()  
			if (not backgroundFrame.Actived) then
				local _r, _g, _b, _a = backgroundFrame:GetBackdropColor()
				DetailsFrameWork:GradientEffect (backgroundFrame, "frame", _r, _g, _b, _a, .3, .3, .3, .5, .9)
			else
				local _r, _g, _b, _a = backgroundFrame:GetBackdropColor()
				DetailsFrameWork:GradientEffect (backgroundFrame, "frame", _r, _g, _b, _a, 22/255, 155/255, 29/255, .9, .9)
			end
		end)	
		
		function backgroundFrame:Active()
			local _r, _g, _b, _a = backgroundFrame:GetBackdropColor()
			DetailsFrameWork:GradientEffect (backgroundFrame, "frame", _r, _g, _b, _a, 22/255, 155/255, 29/255, .9, .9)
			backgroundFrame.Actived = true
		end
		
		function backgroundFrame:Desactive()
			local _r, _g, _b, _a = backgroundFrame:GetBackdropColor()
			DetailsFrameWork:GradientEffect (backgroundFrame, "frame", _r, _g, _b, _a, .3, .3, .3, .5, .9)
			backgroundFrame.Actived = false
		end
	
		local background = SpellDetailsFrame.fundoDir:CreateTexture (nil, "background")
		--background:SetTexture ("Interface\\DialogFrame\\UI-DialogBox-Background")
		background:SetWidth (166)
		background:SetHeight (36)
		background:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPRIGHT", 127, y+3+8)
		background:SetDrawLayer ("background", 2)
		background:Hide()
	
		--> editbox
		--local editbox = DetailsFrameWork:NewTextBox (SpellDetailsFrame.fundoDir, SpellDetailsFrame.fundoDir, "SoloBuffEditBox"..id, OnEnter, "param_1", id, 120, 14)

		local editbox = DetailsFrameWork:NewTextEntry (SpellDetailsFrame.fundoDir, nil, "DetailsSpellDetailsBox"..id, "SoloBuffEditBox"..id, 120, 14, OnEnter, "param_1", id)

		editbox:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPRIGHT", 150, y)
		editbox.text = Loc ["STRING_DEBUFFNAME"]
		
		local imageLeft = editbox:CreateTexture (nil, "overlay")
		imageLeft:SetPoint ("right", "DetailsSpellDetailsBox"..id, "left", 0.5, -2)
		imageLeft:SetTexture ("Interface\\ARCHEOLOGY\\ArchaeologyParts")
		imageLeft:SetTexCoord (0.119140625, 0.1875, 0.8046875, 0.87890625)
		imageLeft:SetWidth (19)
		imageLeft:SetHeight (10)
		local imageRight = editbox:CreateTexture (nil, "overlay")
		imageRight:SetPoint ("left", "DetailsSpellDetailsBox"..id, "right", -0.5, -2)
		imageRight:SetTexture ("Interface\\ARCHEOLOGY\\ArchaeologyParts")
		imageRight:SetTexCoord (0.0078125, 0.078125, 0.859375, 0.93359375)
		imageRight:SetWidth (19)
		imageRight:SetHeight (10)

		editbox.HaveMenu = false

		local OnClickMenu = function (_, _, SpellID)
			editbox:SetText (SpellID)
			editbox:PressEnter (true)
			editbox.HaveMenu = false
			_detalhes.popup:ShowMe (false)
		end

		editbox.OnTextChangedHook = function (frame, userChanged) 

			if (not userChanged) then
				return
			end
			
			local texto = editbox:GetText()
			texto = _detalhes:trim (texto)
			texto = _string_lower (texto)
			texto = texto:gsub ("%(", "")
			texto = texto:gsub ("%[", "")
			
			local index = _string_sub (texto, 1, 1)
			local cached = _detalhes.spellcachefull [index]
		
			if (cached) then
			
				local CoolTip = _G.GameCooltip
			
				CoolTip:Reset()
				CoolTip:SetType ("menu")
				CoolTip:SetOwner (_G ["DetailsSpellDetailsBox"..id])
				CoolTip:SetOption ("NoLastSelectedBar", true)
				CoolTip:SetOption ("HeightAnchorMod", -8)
				CoolTip:SetOption ("TextSize", 9.5)
			
				local CoolTipTable = {}
				local texcoord = {0,1,0,1}
				local i = 1
				
				for SpellID, SpellTable in _pairs (cached) do 
					
					if (_string_lower (SpellTable[1]):find (texto)) then 
						local rank = SpellTable[3]
						if (not rank or rank == "") then
							rank = ""
						else
							rank = " ("..rank..")"
						end
						
						CoolTip:AddMenu (1, OnClickMenu, SpellID, nil, nil, SpellID..": "..SpellTable[1]..rank, SpellTable[2], true)
						
						if (i > 20) then
							break
						else
							i = i + 1
						end
					end

				end
				
				_detalhes.popup.buttonOver = true
				editbox.HaveMenu = true
				CoolTip:ShowCooltip()
			end
		end
		
		local icon = backgroundFrame:CreateTexture (nil, "OVERLAY")
		icon:SetWidth (16)
		icon:SetHeight (16)
		icon:SetPoint ("TOPLEFT", SpellDetailsFrame, "TOPRIGHT", 133, y+8)
		
		local name = DetailsFrameWork:NewLabel (backgroundFrame, backgroundFrame, nil, "BuffName"..id, "", "GameFontHighlightSmall")
		name:SetPoint ("LEFT", icon, "RIGHT", 3, 4)
		
		local amtdone = DetailsFrameWork:NewLabel (backgroundFrame, backgroundFrame, nil, "BuffDone"..id, "", "GameFontHighlightSmall")
		amtdone:SetPoint ("LEFT", icon, "RIGHT", 3, -6)
		local uptime = DetailsFrameWork:NewLabel (backgroundFrame, backgroundFrame, nil, "BuffUptime"..id, "", "GameFontHighlightSmall")
		uptime:SetPoint ("LEFT", icon, "RIGHT", 55, -6)
		
		local dps = DetailsFrameWork:NewLabel (backgroundFrame, backgroundFrame, nil, "BuffDps"..id, "", "GameFontHighlightSmall")
		dps:SetPoint ("LEFT", icon, "RIGHT", 3, -16)

		local clearbutton = _CreateFrame ("Button", nil, backgroundFrame, "UIPanelCloseButton")
		clearbutton:SetWidth (20)
		clearbutton:SetHeight (20)
		clearbutton:SetPoint ("TOPLEFT", icon, "TOPRIGHT", -18, -15)
		
		SpellDetails.BuffTextEntry [id] = {id = id, editbox = editbox, icon = icon, name = name, amtdone = amtdone, dps = dps, uptime = uptime, button = clearbutton, background = background, backgroundFrame = backgroundFrame}
		
		--clearbutton:SetText ("x")
		
		clearbutton:SetScript ("OnClick", function() Clear (SpellDetails.BuffTextEntry [id]) end)
		clearbutton:Hide()
		
		editbox.OnEscapePressedHook = function() 
			editbox:SetText (Loc ["STRING_DEBUFFNAME"])
			_detalhes.popup:ShowMe (false)
		end
		
		editbox.OnEnterPressedHook = function() 
			if (editbox:GetText() == Loc ["STRING_DEBUFFNAME"]) then 
				editbox:SetText ("") 
			elseif (_string_len (editbox:GetText()) > 0) then
				if (not _detalhes.popup.active) then
					editbox.OnTextChangedHook (true)
				end
			end 
		end
		
		editbox.OnLeaveHook = function()
			if (not editbox:HasFocus()) then 
				if (editbox:GetText() == "") then 
					editbox:SetText (Loc ["STRING_DEBUFFNAME"])
				end 
			end 
			
			_detalhes.popup.buttonOver = false
			if (_detalhes.popup.active) then
				local passou = 0
				editbox:SetScript ("OnUpdate", function (self, elapsed)
					passou = passou+elapsed
					if (passou > 0.3) then
						if (not _detalhes.popup.mouseOver and not _detalhes.popup.buttonOver) then
							_detalhes.popup:ShowMe (false)
						end
						editbox:SetScript ("OnUpdate", nil)
					end
				end)
			elseif (_detalhes.popup.tooltip) then
				_detalhes.popup:ShowMe (false)
			else
				editbox:SetScript ("OnUpdate", nil)
			end			
			
		end

		editbox.OnEditFocusGainedHook = function()
			if (InCombatLockdown()) then
			
				GameCooltip:Reset()
				GameCooltip:AddLine ("|cffFF2222"..Loc ["STRING_INCOMBAT"])
				GameCooltip:AddIcon ("Interface\\Buttons\\LockButton-Locked-Up",_,_, 25, 25)
				GameCooltip:ShowCooltip (_G ["DetailsSpellDetailsBox"..id], "tooltip")
				
				editbox:PressEnter()
			else
				editbox:SetText ("")
				_detalhes:BuildSpellList()
			end
		end
		
		editbox.OnEditFocusLostHook =  function()
			editbox.HaveMenu = false
			local texto = editbox:GetText()
			if (_string_len (texto) > 0 and texto ~= Loc ["STRING_DEBUFFNAME"]) then 
				SetBuff (SpellDetails.BuffTextEntry [id], tonumber (texto), id)
			else 
				editbox:SetText (Loc ["STRING_DEBUFFNAME"])
			end 
			_detalhes:ClearSpellList()
		end		
		
	end

	--> Crias as caixas dos buffs
	local y = {-146, -186, -226, -266} -- +8
	for i = 1, 4 do
		CreateBuffInput (y [i], i)
	end
	
	--> fill with buff information:
	--> inject inside details for ace3 delay
	function _detalhes:SpellDetailsStartupBuffs()
		local buffmax = 4
		local BuffList = _detalhes.Buffs:GetBuffListIds()
		for i = 1, #BuffList do 
			if (i >= 5) then
				break
			end
			SetBuff (SpellDetails.BuffTextEntry [i], BuffList [i], i)
		end
	end
	
	_detalhes:ScheduleTimer ("SpellDetailsStartupBuffs", 5)
	--_detalhes:SpellDetailsStartupBuffs()
	
	function SpellDetails:RefreshBuffs()
		for BuffName, BuffTable in _pairs (_detalhes.Buffs.BuffsTable) do
			if (BuffTable.active and SpellDetails:IsInCombat()) then
				if (BuffIndex [BuffName]) then
					BuffIndex [BuffName].backgroundFrame:Active()
				end
			else
				if (BuffIndex [BuffName]) then
					BuffIndex [BuffName].backgroundFrame:Desactive()
				end
			end
		end
	end

	function SpellDetails:Refresh()
		SpellDetails:AtualizaSoloMode()
		SpellDetails:DetalhesDaMagia (SpellDetails.CurrentSpellSlot)
		SpellDetails:ForceUpdateUpDisplay()
	end
	
	function SpellDetails:JanelaSoloUpdate (OnOff)

		local janela_solo = SpellDetailsFrame
		if (OnOff > 0) then
		
			if (not _detalhes.SoloTables.CombatID) then
				return
			end
			
			local MySelf
			if (_detalhes.SoloTables.CombatID == _detalhes:NumeroCombate()) then
				MySelf = _detalhes.tabela_vigente (_detalhes.SoloTables.Attribute, _detalhes.playername)
			else
				local vigente = _detalhes.tabela_historico.tabelas[_detalhes:NumeroCombate() - _detalhes.SoloTables.CombatID]
				MySelf = vigente (_detalhes.SoloTables.Attribute, _detalhes.playername)
			end

			if (MySelf) then
				janela_solo.SoloInicioCombate = MySelf.start_time
				janela_solo.SoloInicioTimer = _GetTime()
				janela_solo.SoloTimer = 0
				janela_solo.SoloDps = 0
				janela_solo.AtualizarJanelaDetalhes = 0
				janela_solo.MySelf = MySelf
				janela_solo.Instancia = self
				janela_solo:SetScript ("OnUpdate", SpellDetails.SoloUpdater)
			end
		else
			janela_solo.SoloInicioCombate = nil
			janela_solo.SoloTimer = nil
			janela_solo.SoloDps = nil
			janela_solo.AtualizarJanelaDetalhes = nil
			janela_solo.MySelf = nil
			janela_solo.Instancia = nil
			janela_solo:SetScript ("OnUpdate", nil)
		end
	end	

	function SpellDetails:ForceUpdateUpDisplay()
		local MySelf = _detalhes.tabela_vigente (_detalhes.SoloTables.Attribute, _detalhes.playername)
		if (MySelf and MySelf.end_time and MySelf.start_time) then
			local tempo_in_combat = MySelf.end_time - MySelf.start_time
			SpellDetails.SummaryLine.time:SetText (Loc ["STRING_TEMPO"]..":".." ".._string_format ("%.1f", tempo_in_combat))
			SpellDetails.SummaryLine.dps:SetText (Loc ["STRING_DPS"]..":".." ".._cstr ("%.1f", MySelf.total/tempo_in_combat))
			SpellDetails.SummaryLine.total:SetText (Loc ["STRING_DAMAGE"]..": " .. _tostring (MySelf.total))
		else
			SpellDetails.SummaryLine.time:SetText (Loc ["STRING_TEMPO"]..":".." 0.0")
			SpellDetails.SummaryLine.dps:SetText (Loc ["STRING_DPS"]..":".." 0")
			SpellDetails.SummaryLine.total:SetText (Loc ["STRING_DAMAGE"]..": 0")
		end
	end
	
	function SpellDetails:SoloUpdater (elapsed)

		self.SoloTimer = self.SoloTimer + elapsed
		self.SoloDps = self.SoloDps + elapsed
		self.AtualizarJanelaDetalhes = self.AtualizarJanelaDetalhes + elapsed
		
		if (self.SoloTimer > 0.1) then
			local tempo_agora = (_GetTime() - self.SoloInicioTimer)
			SpellDetails.SummaryLine.time:SetText (Loc ["STRING_TEMPO"]..":".." ".._string_format ("%.1f", tempo_agora))
			self.SoloTimer = 0
		end
		
		if (self.SoloDps > 0.2) then
			
			--print (_GetTime() .. " " .._detalhes._tempo .. " " .. time())
			--print (self.MySelf.start_time)
			--_detalhes.SoloTables.SummaryLine.dps:SetText (Loc ["STRING_DPS"]..":".." ".._detalhes:comma_value( _math_floor (self.MySelf.total/(_tempo - self.SoloInicioCombate))) )
			--print (self.MySelf.total .. " / " .. (time() - self.MySelf.start_time))
			SpellDetails.SummaryLine.dps:SetText (Loc ["STRING_DPS"]..":".." ".._detalhes:comma_value( _math_floor (self.MySelf.total/( time() - self.MySelf.start_time))) )
			self.SoloDps = 0
		end
		
		if (self.AtualizarJanelaDetalhes > 1.0) then
			SpellDetails:AtualizaSoloMode()
			SpellDetails:DetalhesDaMagia (SpellDetails.CurrentSpellSlot)
			self.AtualizarJanelaDetalhes = 0
			if (not _UFC ("player")) then
				return SpellDetails:CombatEnd()
			end
		end
	end

	function SpellDetails:AtualizaSoloMode()

		if (not _detalhes.SoloTables.CombatID) then
			return
		end

		-- self.atributo <- retorna o que esta sendo mostrado na instancia
		local atributo = _detalhes.SoloTables.Attribute
		local MySelf
		
		if (_detalhes.SoloTables.CombatID == _detalhes:NumeroCombate()) then
			MySelf = _detalhes.tabela_vigente (atributo, _detalhes.playername)
		else
			local vigente = _detalhes.tabela_historico.tabelas[_detalhes:NumeroCombate() - _detalhes.SoloTables.CombatID]
			if (not vigente) then
				--print ("!Vigente> solo_id = ".._detalhes.SoloTables.CombatID.." <> " .. _detalhes:NumeroCombate() - _detalhes.SoloTables.CombatID)
				return
			end
			MySelf = vigente (atributo, _detalhes.playername)
		end
		
		local janela = SpellDetailsFrame
		
		if (MySelf) then
			local meu_total, dps = MySelf.total, MySelf.last_dps
			
			SpellDetails.SummaryLine.total:SetText (Loc ["STRING_DAMAGE"]..": ".._detalhes:comma_value (meu_total)) --> gravar total
			
			--> pegar as magias que castei
			
			local tabela = MySelf.spell_tables._ActorTable
			local meus_danos = {}
			
			local SpellsTotalHits = 0
			for _spellid, _tabela in _pairs (tabela) do
				meus_danos [#meus_danos+1] = {_spellid, _tabela, _tabela.total}
				SpellsTotalHits = SpellsTotalHits + _tabela.counter
			end
			
			--> spellvalue
			for _, _tabela in _ipairs (meus_danos) do
				local PercentDamage = (_tabela[3]/MySelf.total)+1 -- a escala é de 0.0 a 0.9 + 1 então é de 1 a 1.999
				local PercentHits = ((_tabela[2].counter/SpellsTotalHits)*0.1) + 1 --> 0.1 scale down --> 1.09
				local pow = math.pow (PercentDamage, PercentHits)
				local scaled = _detalhes:Scale (1, 2.15, 1, 100, pow)
				_tabela[4] = scaled
			end
			
			_table_sort (meus_danos, function (_spell1, _spell2) return _spell1[4] > _spell2[4] end)
			
			for i = 1, 9 do
				local esta_magia = meus_danos[i]
				if (esta_magia) then
					local SpellName, _, Icon = _GetSpellInfo (esta_magia[1])				
					local SpellBoxObject = SpellDetails.SpellButtons [i]
					
					SpellDetails:ChangeSpellBox (i, esta_magia[1], Icon, 
					"DPS: ".. _detalhes:ToK (_math_floor (esta_magia[3]/MySelf:Tempo())), 
					"SV: ".. _string_format ("%.1f", esta_magia[4]), 
					nil)
				else
					SpellDetails:ClearSpellBox (i)
				end
			end
		end
	end

	function SpellDetails:DetalhesDaMagia (slot)

		local SoloCombatID =  _detalhes.SoloTables.CombatID
		
		if (not SoloCombatID) then
			return
		end

		if (not slot) then --> slot é qual dos 9 quadros vai mostrar
			slot = 1
			SpellDetails.CurrentSpellSlot = 1
			SpellDetails.SpellButtons.LastSelected = slot
			SpellDetails.SpellButtons.selected:SetPoint ("TOPLEFT", SpellDetails.SpellButtons [slot].background, "TOPLEFT", -5, 3)
			SpellDetails.SpellButtons [slot].background:Show()
		end
		
		if (slot ~= SpellDetails.CurrentSpellSlot) then --> se o player clicou em outro quadro
			SpellDetails.CurrentSpellSlot = slot
			SpellDetails:ClearBuffTexts()
			SpellDetails.SpellButtons.LastSelected = slot
			SpellDetails.SpellButtons.selected:SetPoint ("TOPLEFT", SpellDetails.SpellButtons [slot].background, "TOPLEFT", -5, 3)
			SpellDetails.SpellButtons [slot].background:Show()
		end

		local SpellBoxTable = SpellDetails.SpellButtons [slot]
		local spellid = SpellBoxTable.spellid
		local CombatTable
		
		local MySelf
		if (SoloCombatID == _detalhes:NumeroCombate()) then
			MySelf = _detalhes.tabela_vigente (_detalhes.SoloTables.Attribute, _detalhes.playername)
			CombatTable = _detalhes.tabela_vigente
		else
			if (_detalhes.SoloTables.CombatID == 0) then
				return
			end
			
			local vigente = _detalhes.tabela_historico.tabelas [_detalhes:NumeroCombate() - SoloCombatID]
			if (not vigente) then
				--print ("!Vigente> solo_id = "..SoloCombatID.." <> " .. _detalhes:NumeroCombate() .. " table: " .. (_detalhes:NumeroCombate() - SoloCombatID))
				return
			end
			MySelf = vigente (_detalhes.SoloTables.Attribute, _detalhes.playername)
			CombatTable = vigente
		end

		if (not MySelf) then --> caso o jogador não esteja em combate
			return
		end
		
		local habilidade = MySelf.spell_tables._ActorTable [spellid] --> agora tem o objeto classe_TIPO_habilidade
		if (not habilidade) then --> caso a tabela do jogador não tenha a skill pedida.
			return
		end

		local SpellInfoLabels = SpellDetails.SpellInfoLabels --> shortcut
		
		SpellInfoLabels.total:SetText (Loc ["STRING_DAMAGE"]..": ".._detalhes:comma_value (habilidade.total))
		SpellInfoLabels.dps:SetText (Loc ["STRING_DPS"]..":".." ".._detalhes:comma_value (_math_floor (habilidade.total/(MySelf:Tempo()))))
		SpellInfoLabels.porcento:SetText (Loc ["STRING_PERCENT"]..":".." ".. _detalhes:comma_value ( _math_floor (habilidade.total/MySelf.total*100)).."%")

		local SoloDebuffUptime = CombatTable.SoloDebuffUptime
		if (SoloDebuffUptime) then
			local DebuffTable = SoloDebuffUptime [spellid]
			if (DebuffTable) then
				--SpellInfoLabels.uptime:SetText (Loc ["STRING_UPTIME"]..":".." ".._math_floor (DebuffTable.duration).."s (".._math_floor (DebuffTable.duration/MySelf:Tempo()*100).."%) "..DebuffTable.castedAmt.."/"..DebuffTable.refreshAmt.."/"..DebuffTable.droppedAmt) --> localize-me
				
				local duration = DebuffTable.duration
				if (DebuffTable.Active) then
					duration = duration + (_detalhes._tempo - DebuffTable.start)
				end
				
				SpellInfoLabels.uptime:SetText (Loc ["STRING_UPTIME"]..":".." ".._math_floor (duration).."s (".._math_floor (duration/MySelf:Tempo()*100).."%) ") --> localize-me
			else
				SpellInfoLabels.uptime:SetText (Loc ["STRING_UPTIME"]..":".." 0") --> localize-me
			end
		else
			SpellInfoLabels.uptime:SetText (Loc ["STRING_UPTIME"]..":".." 0") --> localize-me
		end
		
		SpellInfoLabels.critical:SetText (Loc ["STRING_CRIT"]..":".." "..habilidade.c_amt.." (".. _math_floor ( habilidade.c_amt/habilidade.counter*100 ) .."%)") -- /"..habilidade.counter.."
		if (habilidade.c_amt < 1) then
			SpellInfoLabels.critical:SetTextColor (0.5, 0.5, 0.5)
			SpellInfoLabels.critical:SetText (Loc ["STRING_CRIT"]..":".." "..habilidade.c_amt.."/"..habilidade.counter) --> localize-me
		else
			SpellInfoLabels.critical:SetTextColor (1, 1, 1)
		end
		
		local erros = 0
		for _, missType in _ipairs (MySelf.missTypes) do
			local este_erro = habilidade [missType]
			if (este_erro) then
				erros = erros + este_erro
			end
		end
		
		SpellInfoLabels.miss:SetText (Loc ["STRING_MISS"]..":".." "..erros.. " (".._string_format ("%.1f", erros/habilidade.counter*100).."%)") --> localize-me
		if (erros < 1) then
			SpellInfoLabels.miss:SetTextColor (0.5, 0.5, 0.5)
		else
			SpellInfoLabels.miss:SetTextColor (1, 1, 1)
		end
		
		SpellInfoLabels.block:SetText (Loc ["STRING_BLOCKED"]..":".." ".. _string_format ("%.1f", habilidade.b_amt/habilidade.counter*100).."%") --> ..habilidade.b_dmg
		if (habilidade.b_dmg < 1) then
			SpellInfoLabels.block:SetTextColor (0.5, 0.5, 0.5)
		else
			SpellInfoLabels.block:SetTextColor (1, 1, 1)
		end

		SpellInfoLabels.glancing:SetText ("Glancing: "..habilidade.g_amt.. " (".._string_format ("%.1f", habilidade.g_amt/habilidade.counter*100).."%)") --> localize-me
		if (habilidade.g_amt < 1) then
			SpellInfoLabels.glancing:SetTextColor (0.5, 0.5, 0.5)
		else
			SpellInfoLabels.glancing:SetTextColor (1, 1, 1)
		end
		
		--> BUFFS
		
		local HabilidadeDetails = habilidade.BuffTable
		if (not HabilidadeDetails) then
			print ("!buffs -> !habilidade.BuffTable")
			return
		end
		
		local BuffTextEntry = SpellDetails.BuffTextEntry --> { 1,2,3,4 }
		--local SoloBuffUptime = _detalhes.SoloTables.SoloBuffUptime
		local SoloBuffUptime = _detalhes.Buffs.BuffsTable
		
		for BuffName, BuffTable in _pairs (_detalhes.Buffs.BuffsTable) do 
			local tabela = HabilidadeDetails [BuffName]
			if (tabela) then
				local EntryObject = BuffIndex [BuffName]
				if (EntryObject) then
				
					local tempo = MySelf:Tempo()
					local EntryObject = BuffIndex [BuffName]
					EntryObject.amtdone:SetText ("Hits: "..tabela.counter)
					
					local duration = BuffTable.duration
					if (BuffTable.active) then
						if (not BuffTable.start) then
							print ("BUFF " .. BuffTable.name.." sem START")
						else
							duration = duration + (_detalhes._tempo - BuffTable.start)
						end
					end
					tempo = duration

					--SpellInfoLabels.uptime:SetText (Loc ["STRING_UPTIME"]..":".." ".._math_floor (DebuffTable.duration).."s (".._math_floor (DebuffTable.duration/MySelf:Tempo()*100).."%) "..DebuffTable.castedAmt.."/"..DebuffTable.refreshAmt.."/"..DebuffTable.droppedAmt) --> localize-me
					EntryObject.uptime:SetText (Loc ["STRING_UPTIME"]..":" .. " " .. _math_floor (tempo/MySelf:Tempo()*100).."%") --me _math_floor (BuffTable.duration).."s ("..
					EntryObject.dps:SetText ("Dps: ".._detalhes:comma_value (_math_floor (tabela.total/tempo)))
				
				end
			end
		end
		
	end

end

function SpellDetails:OnEvent (_, event, ...)

	if (event == "ADDON_LOADED") then
		local AddonName = select (1, ...)
		if (AddonName == "Details_SpellDetails") then
			
			if (_G._detalhes) then
				
				--> create main plugin object
				CreatePluginFrames (_detalhes_databaseSpellDetails)
				
				local MINIMAL_DETAILS_VERSION_REQUIRED = 1
				
				--> Install plugin inside details
				local install = _G._detalhes:InstallPlugin ("SOLO", Loc ["PLUGIN_NAME"], "Interface\\Icons\\INV_Fabric_Spellweave", SpellDetails, "DETAILS_PLUGIN_SPELL_DETAILS", MINIMAL_DETAILS_VERSION_REQUIRED)
				if (type (install) == "table" and install.error) then
					print (install.error)
				end
				
				--> Register needed events
				_G._detalhes:RegisterEvent (SpellDetails, "COMBAT_PLAYER_TIMESTARTED")
				
			end
		end
		
	elseif (event == "PLAYER_LOGOUT") then
		_detalhes_databaseSpellDetails = SpellDetails.data
	end
end
