local _detalhes = 		_G._detalhes

local AceComm = LibStub ("AceComm-3.0")
local AceSerializer = LibStub ("AceSerializer-3.0")

local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

local gump = 			_detalhes.gump
local _
local atributos = _detalhes.atributos
local sub_atributos = _detalhes.sub_atributos
--lua locals
local _cstr = string.format
local _math_ceil = math.ceil
local _math_floor = math.floor
local _ipairs = ipairs
local _pairs = pairs
local _string_lower = string.lower
local _table_sort = table.sort
local _table_insert = table.insert
local _unpack = unpack

--api locals
local _GetSpellInfo = _detalhes.getspellinfo
local _CreateFrame = CreateFrame
local _GetTime = GetTime
local _GetCursorPosition = GetCursorPosition
local _GameTooltip = GameTooltip
local _UIParent = UIParent
local _GetScreenWidth = GetScreenWidth
local _GetScreenHeight = GetScreenHeight
local _IsAltKeyDown = IsAltKeyDown
local _IsShiftKeyDown = IsShiftKeyDown
local _IsControlKeyDown = IsControlKeyDown

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS

local class_type_dano = _detalhes.atributos.dano
local class_type_misc = _detalhes.atributos.misc
local tabela_do_combate

local master_container

local function CreateCustomWindow()
	
	local gump_fundo_backdrop = {
		bgFile = "Interface\\AddOns\\Details\\images\\background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 16, edgeSize = 4,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}

	local frame = CreateFrame ("frame", "DetailsCustomPanel", UIParent)
	frame:SetPoint ("center", UIParent, "center", 100, -300)
	frame:SetWidth (512)
	frame:SetHeight (150)
	frame:EnableMouse (true)
	frame:SetMovable (true)
	frame:SetFrameLevel (1)
	
	frame.fundo = frame:CreateTexture (nil, "border")
	frame.fundo:SetTexture ("Interface\\AddOns\\Details\\images\\custom_bg")
	frame.fundo:SetPoint ("topleft", frame, "topleft")
	
	frame.move = gump:NewDetailsButton (frame, frame, _, function() end, nil, nil, 1, 1, "", "", "", "", nil, "DetailsCustomPanelMoveFrame")
	frame.move:SetPoint ("topleft", frame, "topleft")
	frame.move:SetPoint ("bottomright", frame, "bottomright")
	frame.move:SetFrameLevel (frame:GetFrameLevel()+1)
	
	--> botão de fechar
	frame.fechar = _CreateFrame ("Button", nil, frame, "UIPanelCloseButton")
	frame.fechar:SetWidth (32)
	frame.fechar:SetHeight (32)
	frame.fechar:SetPoint ("TOPRIGHT", frame, "TOPRIGHT", -1, -8)
	frame.fechar:SetText ("X")
	frame.fechar:SetFrameLevel (frame:GetFrameLevel()+2)
	
	frame.fechar:SetScript ("OnClick", function() 
		_detalhes:CloseCustomWindow()
	end)
	
	frame:SetScript ("OnHide", function()
		_detalhes:CloseCustomWindow()
	end)
	
	--> help button
	local helpButton = CreateFrame ("button", "DetailsCustomPanelHelpButton", frame, "MainHelpPlateButton")
	helpButton:SetWidth (36)
	helpButton:SetHeight (36)
	helpButton.I:SetWidth (25)
	helpButton.I:SetHeight (25)
	helpButton.Ring:SetWidth (36)
	helpButton.Ring:SetHeight (36)
	helpButton.Ring:SetPoint ("center", 7, -7)
	helpButton:SetPoint ("topright", frame, "topright", -20, -7)
	helpButton:SetFrameLevel (frame.fechar:GetFrameLevel())

	local customHelp =  {
		FramePos = {x = 0, y = -30},
		FrameSize = {width = 512, height = 120},
		
		[1] ={HighLightBox = {x = 15, y = -39, width = 100, height = 70},
			ButtonPos = { x = 43, y = -50},
			ToolTipDir = "LEFT",
			ToolTipText = Loc ["STRING_CUSTOM_HELP1"]
		},
		[2] ={HighLightBox = {x = 120, y = -9, width = 170, height = 95},
			ButtonPos = { x = 182, y = -30},
			ToolTipDir = "RIGHT",
			ToolTipText = Loc ["STRING_CUSTOM_HELP2"]
		},
		[3] ={HighLightBox = {x = 295, y = -9, width = 170, height = 75},
			ButtonPos = { x = 363, y = -25},
			ToolTipDir = "RIGHT",
			ToolTipText = Loc ["STRING_CUSTOM_HELP3"]
		},
		[4] ={HighLightBox = {x = 470, y = -25, width = 30, height = 25},
			ButtonPos = { x = 485, y = -15},
			ToolTipDir = "RIGHT",
			ToolTipText = Loc ["STRING_CUSTOM_HELP4"]
		}
	}
	
	helpButton:SetScript ("OnClick", function() 
		if (not HelpPlate_IsShowing (customHelp)) then
			HelpPlate_Show (customHelp, frame, helpButton, true)
		else
			HelpPlate_Hide (true)
		end
	end)
	
	--> titulo
	gump:NewLabel (frame, frame, nil, "titulo", "Custom Display", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	frame.titulo:SetPoint ("center", frame, "center")
	frame.titulo:SetPoint ("top", frame, "top", 0, -18)
	
	--> icone no canto esquerdo superior
	frame.classe_icone = frame:CreateTexture (nil, "BACKGROUND")
	frame.classe_icone:SetPoint ("TOPLEFT", frame, "TOPLEFT", 4, 0)
	frame.classe_icone:SetWidth (64)
	frame.classe_icone:SetHeight (64)
	frame.classe_icone:SetDrawLayer ("BACKGROUND", 1)
	frame.classe_icone:SetTexture ("Interface\\AddOns\\Details\\images\\classes_plus")
	frame.classe_icone:SetTexCoord (0, 0.25, 0.25, 0.5)
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------
	
	frame.atributo = nil
	frame.sub_atributo = nil

	local SubMenu = function (atributo) 
		frame.sub_atributo = atributo

	end
	
	
	local LeftButtons = frame.fechar:CreateTexture (nil, "overlay")
	LeftButtons:SetWidth (56)
	LeftButtons:SetHeight (70)
	LeftButtons:SetPoint ("left", frame, "left", 15, -29)
	LeftButtons:SetTexture ("Interface\\Glues\\CHARACTERCREATE\\AlternateForm")
	LeftButtons:SetTexCoord (0, 1, 0, 0.62890625)
	LeftButtons:SetDrawLayer ("overlay", 4)
	
	--> botão de deletar um custom
	local DeleteButton = gump:NewDetailsButton (frame, frame, _, function()end, nil, nil, 60, 15, "", "", "", "", nil, "DetailsCustomPanelDeleteButton")
	DeleteButton.text:SetText (Loc ["STRING_CUSTOM_REMOVE"])
	DeleteButton.text:SetJustifyH ("left")
	DeleteButton.text:SetPoint ("left", DeleteButton, "left", 0, -1)
	DeleteButton:SetPoint ("topleft", LeftButtons, "topleft", 34, -10)
	DeleteButton:SetFrameLevel (frame:GetFrameLevel()+2)
	DeleteButton:InstallCustomTexture (_, {x1 = -20, x2 = 0, y1 = -2, y2 = -2})
	--DeleteButton.
	
	local removeTexture = frame.fechar:CreateTexture (nil, "overlay")
	removeTexture:SetWidth (23)
	removeTexture:SetHeight (23)
	removeTexture:SetTexture ("Interface\\ICONS\\Spell_BrokenHeart")
	removeTexture:SetTexCoord (5/64, 60/64, 4/64, 62/64)
	removeTexture:SetPoint ("topleft", LeftButtons, "topleft", 6, -8)
	removeTexture:SetDrawLayer ("overlay", 3)
	
	--> botão de dar broadcast em um custom
	local BroadcastButton = gump:NewDetailsButton (frame, frame, _, function()end, nil, nil, 60, 15, "", "", "", "", nil, "DetailsCustomPanelBroadcastButton")
	BroadcastButton.text:SetText (Loc ["STRING_CUSTOM_BROADCAST"])
	BroadcastButton.text:SetJustifyH ("left")
	BroadcastButton.text:SetPoint ("left", BroadcastButton, "left", 0, -1)
	BroadcastButton:SetPoint ("topleft", LeftButtons, "topleft", 34, -42)
	BroadcastButton:SetFrameLevel (frame:GetFrameLevel()+2)
	BroadcastButton:InstallCustomTexture (_, {x1 = -20, x2 = 0, y1 = -2, y2 = -2})
	
	local broadcastTexture = frame.fechar:CreateTexture (nil, "overlay")
	broadcastTexture:SetWidth (23)
	broadcastTexture:SetHeight (23)
	broadcastTexture:SetTexture ("Interface\\ICONS\\Ability_Warrior_RallyingCry")
	broadcastTexture:SetTexCoord (5/64, 60/64, 4/64, 62/64)
	broadcastTexture:SetPoint ("topleft", LeftButtons, "topleft", 6, -40)
	broadcastTexture:SetDrawLayer ("overlay", 3)
	
	
	local fundoBrilha = frame:CreateTexture (nil, "overlay")
	fundoBrilha:SetWidth (140)
	fundoBrilha:SetHeight (36)
	fundoBrilha:SetTexture ("Interface\\PetBattles\\Weather-Sunlight")
	fundoBrilha:SetTexCoord (.3, 1, 0, 1)	
	
	local MainMenu = function (atributo) 
		
		frame.atributo = atributo
		frame.sub_atributo = 1
		
		fundoBrilha:SetPoint ("left", frame.MainMenu [atributo].icon , "right", -20, -10)
		
		--[[
		for i = 1, 5 do 
			if (sub_atributos [atributo].lista[i]) then
				frame.SubMenu [i].text:SetText (sub_atributos [atributo].lista[i])
				frame.SubMenu [i]:Show()
			else
				frame.SubMenu [i]:Hide()
			end
		end
		--]]
	end
	
	frame.MainMenu = {}
	frame.SubMenu = {}

	do
	
		local x = 140
		local x2 = 170
		
		local y = -17
		
		local OnEnterHook = function (button)
			button.text:SetTextColor (1, 1, 1)
		end
		
		local OnLeaveHook = function (button)
			button.text:SetTextColor (button.textColor.r, button.textColor.g, button.textColor.b )
		end

		--> 4 atributos principais
		
		local half = 0.00048828125
		local size = 0.03125
		
		for i = 1, 4 do
		
			local button = gump:NewDetailsButton (frame, frame, _, MainMenu, i, nil, 120, 15, "", "", "", "", nil, "DetailsCustomPanelAttributeButton"..i)
			button.MouseOnEnterHook = OnEnterHook
			button.MouseOnLeaveHook = OnLeaveHook
			
			button.textura = button:CreateTexture (nil, "overlay")
			button.textura:SetPoint ("right", button, "left", 60, 0)
			button.icon = button:CreateTexture (nil, "background")
			button.icon:SetPoint ("center", button.textura, "center", 2, 0)
			button.icon:SetTexture ("Interface\\AddOns\\Details\\images\\skins\\default_skin")
			button.icon:SetWidth (22)
			button.icon:SetHeight (22)
			
			button.icon:SetTexCoord ( (0.03125 * (i-1)) + half, (0.03125 * i) - half, 0.35693359375, 0.38720703125)
			
			if (i == 1) then
				button.textura:SetTexture ("Interface\\ExtraButton\\ChampionLight")
				--button.icon:SetTexCoord (32/256 * (1-1), 32/256 * 1, 0, 1)

			elseif (i == 2) then
				button.textura:SetTexture ("Interface\\ExtraButton\\Ysera")
				--button.icon:SetTexCoord (32/256 * (2-1), 32/256 * 2, 0, 1)
				--button.icon:SetPoint ("center", button.textura, "center", 3, 0)

			elseif (i == 3) then
				button.textura:SetTexture ("Interface\\ExtraButton\\FengShroud")
				--button.icon:SetTexCoord (32/256 * (3-1), 32/256 * 3, 0, 1)				
			
			elseif (i == 4) then
				button.textura:SetTexture ("Interface\\ExtraButton\\BrewmoonKeg")
				--button.icon:SetTexCoord (32/256 * (4-1), 32/256 * 4, 0, 1)				
			
			end
			
			button.textura:SetWidth (76)
			button.textura:SetHeight (40)
			button:SetPoint ("topleft", frame, "topleft", x, i*-25 + (y))
			button.text:SetText (atributos.lista [i])
			button.text:SetPoint ("left", button, "left", 65, 0)
			button:SetFrameLevel (frame:GetFrameLevel()+2)
			
			frame.MainMenu [i] = button
		end
		
		frame.atributo = 1
		frame.sub_atributo = 1
		fundoBrilha:SetPoint ("left", frame.MainMenu [1].icon , "right", -20, -10)
		
		--> 5 atributos secundarios
		
		--[[
		for i = 1, 5 do 
			local button = gump:NewDetailsButton (frame, frame, _, SubMenu, i, nil, 60, 15, "", "", "", "")
			button:SetPoint ("topleft", frame, "topleft", x2, i*-15)
			button.text:SetPoint ("left", button, "left", 5, 0)
			button.text:SetText ("sub menu "..i)
			button:SetFrameLevel (frame:GetFrameLevel()+2)
			frame.SubMenu [i] = button
		end
		--]]
	end
	
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--> Edit Boxes
	
	local xStart = 290
	local WidthMax = 220
	
----------> The name of the custom
	local MyNameSelected = function (param1, param2, texto, editbox) --print (param1, param2, texto, editbox) 
	end
	gump:NewTextBox (frame, frame, "TextMyNameEntry", SpellIDSelected, "param_1", "param_2", 100, 15, {TabOnEnterPress = true, MySpace = WidthMax})
	frame ["TextMyNameEntry"]:SetFrameLevel (frame:GetFrameLevel()+2)
	frame ["TextMyNameEntry"]:SetPointAndSpace ("topleft", frame, "topleft", xStart, -45, WidthMax)
	frame ["TextMyNameEntry"]:SetLabelText (Loc ["STRING_CUSTOM_NAME"]..":")
	
----------> Spell Name ou ID
	local SpellIDSelected = function (param1, param2, texto, editbox) 
		local _ThisSpellName, _, _ThisSpellIcon  = _GetSpellInfo (tonumber (texto))
		if (_ThisSpellName) then 
			frame.IconTexture = _ThisSpellIcon
			frame.icon:SetTexture (frame.IconTexture)
			
			if (frame ["TextMyNameEntry"].text == "") then 
				frame ["TextMyNameEntry"].text = _ThisSpellName
				frame ["TextMyNameEntry"]:SetText (_ThisSpellName) 
			end
		end
	end
	
	gump:NewTextBox (frame, frame, "TextSpellIDEntry", SpellIDSelected, "param_1", "param_2", 80, 15, {TabOnEnterPress = true, MySpace = WidthMax-20})
	frame ["TextSpellIDEntry"]:SetFrameLevel (frame:GetFrameLevel()+2)
	frame ["TextSpellIDEntry"]:SetPointAndSpace ("topleft", frame, "topleft", xStart, -62, WidthMax-20)
	frame ["TextSpellIDEntry"]:SetLabelText (Loc ["STRING_CUSTOM_SPELLID"])
	
	local openSpellEncounter = function() 
		
	end
	
	local frameEncounterSkill = CreateFrame ("frame", nil, frame)
	frameEncounterSkill:SetPoint ("left", frame ["TextSpellIDEntry"], "right")
	frameEncounterSkill:SetWidth (20)
	frameEncounterSkill:SetHeight (20)
	frameEncounterSkill:SetFrameLevel (frame:GetFrameLevel()+2)
	local frameEncounterSkillImage = frameEncounterSkill:CreateTexture (nil, "overlay")
	frameEncounterSkillImage:SetPoint ("center", frameEncounterSkill)
	frameEncounterSkillImage:SetTexture ("Interface\\Buttons\\UI-MicroButton-Raid-Up")
	frameEncounterSkillImage:SetTexCoord (0.046875, 0.90625, 0.40625, 0.953125)
	frameEncounterSkillImage:SetWidth (20)
	frameEncounterSkillImage:SetHeight (16)
	
	local GameCooltip = GameCooltip
	
	local spellsFrame = gump:NewPanel (frame, _, "DetailsCustomSpellsFrame", "spellsFrame", 1, 1)
	spellsFrame:SetPoint ("bottomleft", frame, "topleft", 62, -14)
	spellsFrame:Hide()
	
	local selectedEncounterSpell = function (spellId)
		local nome_magia, _, icone_magia = _GetSpellInfo (spellId)
		frame ["TextMyNameEntry"]:SetText (nome_magia)
		frame ["TextMyNameEntry"]:PressEnter()
		frame ["TextSpellIDEntry"]:SetText (spellId)
		frame ["TextSpellIDEntry"]:PressEnter()
		frame ["TextSourceEntry"]:SetText ("[all]")
		frame ["TextSourceEntry"]:PressEnter()
		frame.icon:SetTexture (icone_magia)
		spellsFrame:Hide()
	end
	
	local spellsFrameButtons = {}

	local buttonMouseOver = function (button)
		button.MyObject.image:SetBlendMode ("ADD")
		button.MyObject.line:SetBlendMode ("ADD")
		button.MyObject.label:SetTextColor (1, 1, 1, 1)
		local OnEnterColors = button:GetParent().Gradient.OnEnter
		local _r, _g, _b, _a = button:GetParent():GetBackdropColor()
		gump:GradientEffect (button:GetParent(), "frame", _r, _g, _b, _a, OnEnterColors[1], OnEnterColors[2], OnEnterColors[3], OnEnterColors[4], .3)
	end
	local buttonMouseOut = function (button)
		button.MyObject.image:SetBlendMode ("BLEND")
		button.MyObject.line:SetBlendMode ("BLEND")
		button.MyObject.label:SetTextColor (.8, .8, .8, .8)
		local _r, _g, _b, _a = button:GetParent():GetBackdropColor()
		if (_r) then
			local OnLeaveColors = button:GetParent().Gradient.OnLeave
			gump:GradientEffect (button:GetParent(), "frame", _r, _g, _b, _a, OnLeaveColors[1], OnLeaveColors[2], OnLeaveColors[3], OnLeaveColors[4], .3)
		end
	end
	
	local EncounterSelect = function (_, _, instanceId, bossIndex)
		
		spellsFrame:Show()
		
		local spells = _detalhes:GetEncounterSpells (instanceId, bossIndex)
		
		local x = 10
		local y = 10
		local i = 1
		
		for spell, _ in pairs (spells) do 
		
			local thisButton = spellsFrameButtons [i]
			
			if (not thisButton) then
				thisButton = gump:NewButton (spellsFrame.frame, spellsFrame.frame, "DetailsCustomSpellsFrameButton"..i, "button"..i, 80, 20, selectedEncounterSpell)
				thisButton:SetPoint ("topleft", "DetailsCustomSpellsFrame", "topleft", x, -y)
				local t = gump:NewImage (thisButton, nil, 20, 20, nil, nil, "image", "DetailsCustomEncounterImageButton"..i)
				t:SetPoint ("left", thisButton)
				thisButton:SetHook ("OnEnter", buttonMouseOver)
				thisButton:SetHook ("OnLeave", buttonMouseOut)

				local text = gump:NewLabel (thisButton, nil, "DetailsCustomSpellsFrameButton"..i.."Label", "label", "Spell", nil, 9.5, {.8, .8, .8, .8})
				text:SetPoint ("left", t.image, "right", 2, 0)
				text:SetWidth (73)
				text:SetHeight (10)
				
				local border = gump:NewImage (thisButton, "Interface\\SPELLBOOK\\Spellbook-Parts", 40, 38, nil, nil, "border", "DetailsCustomEncounterBorderButton"..i)
				border:SetTexCoord (0.00390625, 0.27734375, 0.44140625,0.69531250)
				border:SetDrawLayer ("background")
				border:SetPoint ("topleft", thisButton.button, "topleft", -9, 9)
				
				local line = gump:NewImage (thisButton, "Interface\\SPELLBOOK\\Spellbook-Parts", 84, 25, nil, nil, "line", "DetailsCustomEncounterLineButton"..i)
				line:SetTexCoord (0.31250000, 0.96484375, 0.37109375, 0.52343750)
				line:SetDrawLayer ("background")
				line:SetPoint ("left", thisButton.button, "right", -60, -3)
				
				table.insert (spellsFrameButtons, #spellsFrameButtons+1, thisButton)
			end
			
			y = y + 20
			if (y >= 110) then
				y = 10
				x = x + 100
			end
			
			local nome_magia, _, icone_magia = _GetSpellInfo (spell)
			thisButton.image:SetTexture (icone_magia)
			thisButton.label:SetText (nome_magia)
			thisButton:SetClickFunction (selectedEncounterSpell, spell)
			thisButton:Show()
			i = i + 1
		end
		
		for maxIndex = i, #spellsFrameButtons do
			spellsFrameButtons [maxIndex]:Hide()
		end
		
		i = i-1
		spellsFrame:SetSize (math.ceil (i/5)*110, math.min (i*20 + 10, 120))
		
	end
	
	local BuildEncounterMenu = function()
	
		GameCooltip:Reset()
		GameCooltip:SetType ("menu")
		GameCooltip:SetOwner (frameEncounterSkill)
		
		for instanceId, instanceTable in pairs (_detalhes.EncounterInformation) do 
		
			GameCooltip:AddLine (instanceTable.name, _, 1, "white")
			GameCooltip:AddIcon (instanceTable.icon, 1, 1, 64, 32)

			for index, encounterName in ipairs (instanceTable.boss_names) do 
				GameCooltip:AddMenu (2, EncounterSelect, instanceId, index, nil, encounterName, nil, true)
				local L, R, T, B, Texture = _detalhes:GetBossIcon (instanceId, index)
				GameCooltip:AddIcon (Texture, 2, 1, 20, 20, L, R, T, B)
			end
		end
		
		GameCooltip:SetOption ("HeightAnchorMod", -10)
		GameCooltip:ShowCooltip()
		
		--_detalhes.EncounterInformation [instanceTable.id] = InstanceTable
	end
	
	frameEncounterSkill:SetScript ("OnEnter", function() 
		frameEncounterSkillImage:SetBlendMode ("ADD")
		BuildEncounterMenu()
	end)
	
	frameEncounterSkill:SetScript ("OnLeave", function() 
		frameEncounterSkillImage:SetBlendMode ("BLEND")
	end)
	
	frame ["TextSpellIDEntry"].HaveMenu = false
	
	frame ["TextSpellIDEntry"].OnLeaveHook = function()
		_detalhes.popup.buttonOver = false
		if (_detalhes.popup.ativo) then
			local passou = 0
			frame ["TextSpellIDEntry"]:SetScript ("OnUpdate", function (self, elapsed)
				passou = passou+elapsed
				if (passou > 0.3) then
					if (not _detalhes.popup.mouseOver and not _detalhes.popup.buttonOver) then
						_detalhes.popup:ShowMe (false)
					end
					frame ["TextSpellIDEntry"]:SetScript ("OnUpdate", nil)
				end
			end)
		else
			frame ["TextSpellIDEntry"]:SetScript ("OnUpdate", nil)
		end
	end
	
	frame ["TextSpellIDEntry"].OnFocusLostHook = function()
		frame ["TextSpellIDEntry"].HaveMenu = false
	end

	local OnClickMenu = function (_, _, SpellID)
		frame ["TextSpellIDEntry"]:SetText (SpellID)
		frame ["TextSpellIDEntry"]:PressEnter()
		frame ["TextSpellIDEntry"].HaveMenu = false
		_detalhes.popup:ShowMe (false)
	end
	
	local _string_lower = string.lower
	local _string_sub = string.sub
	
	frame ["TextSpellIDEntry"].TextChangeedHook = function (userChanged) 
		if (not userChanged) then
			return
		end
		
		local texto = frame ["TextSpellIDEntry"]:GetText()
		texto = _detalhes:trim (texto)
		texto = _string_lower (texto)
		
		local index = _string_sub (texto, 1, 1)
		local cached = _detalhes.spellcachefull [index]

		if (cached) then
		
			local CoolTip = _G.GameCooltip
		
			CoolTip:Reset()
			CoolTip:SetType ("menu")
			CoolTip:SetColor ("main", "transparent")
			CoolTip:SetOwner (frame ["TextSpellIDEntry"])
			CoolTip:SetOption ("NoLastSelectedBar", true)
			CoolTip:SetOption ("TextSize", 9.5)
		
			local CoolTipTable = {}
			local texcoord = {0, 1, 0, 1}
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
			
			frame ["TextSpellIDEntry"].HaveMenu = true
			CoolTip.buttonOver = true
			CoolTip:ShowCooltip()
		end
	end
	
----------> Source
	local SourceSelected = function (param1, param2, texto, editbox) end
	gump:NewTextBox (frame, frame, "TextSourceEntry", SourceSelected, "param_1", "param_2", 100, 15, {TabOnEnterPress = true, MySpace = WidthMax})
	frame ["TextSourceEntry"]:SetFrameLevel (frame:GetFrameLevel()+2)
	frame ["TextSourceEntry"]:SetPointAndSpace ("topleft", frame, "topleft", xStart, -79, WidthMax)
	frame ["TextSourceEntry"]:SetLabelText (Loc ["STRING_CUSTOM_SOURCE"]..":")
	frame ["TextSourceEntry"].InputHook = function() 
		local texto = frame ["TextSourceEntry"]:GetText()
		texto:gsub ("[raid]", "|cFFFF00FF|r[raid]")
		texto:gsub ("[all]", "|cFF0000FF|r[all]")
		texto:gsub ("[player]", "|cFFFF0000|r[player]")
		frame ["TextSourceEntry"]:SetText (texto)
	end
	frame ["TextSourceEntry"].EnterHook = function() 
		local texto = frame ["TextSourceEntry"]:GetText()
		if (texto:find ("%[raid%]")) then
			frame ["TextSourceEntry"]:SetText ("[raid]")
		elseif (texto:find ("%[all%]")) then
			frame ["TextSourceEntry"]:SetText ("[all]")
		elseif (texto:find ("%[player%]")) then
			frame ["TextSourceEntry"]:SetText ("[player]")
		end
	end
	
---------> Actor Name
	local ActorNameSelected = function (param1, param2, texto, editbox) end
	gump:NewTextBox (frame, frame, "TextActorNameEntry", ActorNameSelected, "param_1", "param_2", 100, 15, {TabOnEnterPress = true})
	frame ["TextActorNameEntry"]: SetFrameLevel (frame:GetFrameLevel()+2)
	frame ["TextActorNameEntry"]:SetPointAndSpace ("topleft", frame, "topleft", xStart, -96, WidthMax)
	frame ["TextActorNameEntry"]:SetLabelText (Loc ["STRING_CUSTOM_TARGET"]..":")
	
	--> Tab Order
	frame ["TextMyNameEntry"]:SetNext (frame ["TextSpellIDEntry"])
	frame ["TextSpellIDEntry"]:SetNext (frame ["TextSourceEntry"])
	frame ["TextSourceEntry"]:SetNext (frame ["TextActorNameEntry"])
	frame ["TextActorNameEntry"]:SetNext (frame ["TextMyNameEntry"])
	frame ["TextActorNameEntry"]:Disable()

	--> Tooltips
	--> localize-me
	frame ["TextMyNameEntry"].tooltip = Loc ["STRING_CUSTOM_TOOLTIPNAME"]
	frame ["TextSpellIDEntry"].tooltip = Loc ["STRING_CUSTOM_TOOLTIPSPELL"]
	frame ["TextSourceEntry"].tooltip = Loc ["STRING_CUSTOM_TOOLTIPSOURCE"]
	frame ["TextActorNameEntry"].tooltip = Loc ["STRING_CUSTOM_TOOLTIPTARGET"].."\n|cFFFF0000"..Loc ["STRING_CUSTOM_TOOLTIPNOTWORKING"]
	
	frame.IconTexture = "Interface\\Icons\\TEMP"
	
	local ChooseIcon = function()
		if (not frame.IconFrame) then 
		
			frame.IconFrame = CreateFrame ("frame", "DetailsCustomPanelIcons", frame)
			
			frame.IconFrame:SetPoint ("bottomright", frame, "topright", 0, 0)
			frame.IconFrame:SetWidth (182)
			frame.IconFrame:SetHeight (160)
			frame.IconFrame:EnableMouse (true)
			frame.IconFrame:SetMovable (true)
			frame.IconFrame:SetBackdrop (gump_fundo_backdrop)
			frame.IconFrame:SetBackdropBorderColor (170/255, 170/255, 170/255)
			frame.IconFrame:SetBackdropColor (24/255, 24/255, 24/255, .8)
			frame.IconFrame:SetFrameLevel (1)
			
			local MACRO_ICON_FILENAMES = {};
			frame.IconFrame:SetScript ("OnShow", function()
			
				MACRO_ICON_FILENAMES = {};
				MACRO_ICON_FILENAMES[1] = "INV_MISC_QUESTIONMARK";
				local index = 2;
				local numFlyouts = 0;
			
				for i = 1, GetNumSpellTabs() do
					local tab, tabTex, offset, numSpells, _ = GetSpellTabInfo(i);
					offset = offset + 1;
					local tabEnd = offset + numSpells;
					for j = offset, tabEnd - 1 do
						--to get spell info by slot, you have to pass in a pet argument
						local spellType, ID = GetSpellBookItemInfo(j, "player"); 
						if (spellType ~= "FUTURESPELL") then
							local spellTexture = strupper(GetSpellBookItemTexture(j, "player"));
							if ( not string.match( spellTexture, "INTERFACE\\BUTTONS\\") ) then
								MACRO_ICON_FILENAMES[index] = gsub( spellTexture, "INTERFACE\\ICONS\\", "");
								index = index + 1;
							end
						end
						if (spellType == "FLYOUT") then
							local _, _, numSlots, isKnown = GetFlyoutInfo(ID);
							if (isKnown and numSlots > 0) then
								for k = 1, numSlots do 
									local spellID, overrideSpellID, isKnown = GetFlyoutSlotInfo(ID, k)
									if (isKnown) then
										MACRO_ICON_FILENAMES[index] = gsub( strupper(GetSpellTexture(spellID)), "INTERFACE\\ICONS\\", ""); 
										index = index + 1;
									end
								end
							end
						end
					end
				end
				
				GetMacroIcons (MACRO_ICON_FILENAMES)
				GetMacroItemIcons (MACRO_ICON_FILENAMES )
				
			end)
			
			frame.IconFrame:SetScript ("OnHide", function()
				MACRO_ICON_FILENAMES = nil;
				collectgarbage()
			end)
			
			frame.IconFrame.buttons = {}
			
			local OnClickFunction = function (index) 
				local button = frame.IconFrame.buttons [index]
				local texture = button:GetNormalTexture()
				frame.IconTexture = "INTERFACE\\ICONS\\"..MACRO_ICON_FILENAMES [button.IconID]
				frame.icon:SetTexture (frame.IconTexture)
				frame.IconFrame:Hide()
			end
			
			for i = 0, 4 do 
				local newcheck = gump:NewDetailsButton (frame.IconFrame, frame.IconFrame, _, OnClickFunction, i+1, i+1, 30, 28, "", "", "", "", _, "DetailsIconCheckFrame"..(i+1))
				newcheck:SetPoint ("topleft", frame.IconFrame, "topleft", 3+(i*30), -13)
				newcheck:SetID (i+1)
				frame.IconFrame.buttons [#frame.IconFrame.buttons+1] = newcheck
			end
			for i = 6, 10 do 
				local newcheck = gump:NewDetailsButton (frame.IconFrame, frame.IconFrame, _, OnClickFunction, i, i, 30, 28, "", "", "", "", _, "DetailsIconCheckFrame"..i)
				newcheck:SetPoint ("topleft", "DetailsIconCheckFrame"..(i-5), "bottomleft", 0, -1)
				newcheck:SetID (i)
				frame.IconFrame.buttons [#frame.IconFrame.buttons+1] = newcheck
			end
			for i = 11, 15 do 
				local newcheck = gump:NewDetailsButton (frame.IconFrame, frame.IconFrame, _, OnClickFunction, i, i, 30, 28, "", "", "", "", _, "DetailsIconCheckFrame"..i)
				newcheck:SetPoint ("topleft", "DetailsIconCheckFrame"..(i-5), "bottomleft", 0, -1)
				newcheck:SetID (i)
				frame.IconFrame.buttons [#frame.IconFrame.buttons+1] = newcheck
			end
			for i = 16, 20 do 
				local newcheck = gump:NewDetailsButton (frame.IconFrame, frame.IconFrame, _, OnClickFunction, i, i, 30, 28, "", "", "", "", _, "DetailsIconCheckFrame"..i)
				newcheck:SetPoint ("topleft", "DetailsIconCheckFrame"..(i-5), "bottomleft", 0, -1)
				newcheck:SetID (i)
				frame.IconFrame.buttons [#frame.IconFrame.buttons+1] = newcheck
			end
			for i = 21, 25 do 
				local newcheck = gump:NewDetailsButton (frame.IconFrame, frame.IconFrame, _, OnClickFunction, i, i, 30, 28, "", "", "", "", _, "DetailsIconCheckFrame"..i)
				newcheck:SetPoint ("topleft", "DetailsIconCheckFrame"..(i-5), "bottomleft", 0, -1)
				newcheck:SetID (i)
				frame.IconFrame.buttons [#frame.IconFrame.buttons+1] = newcheck
			end
			
			local scroll = CreateFrame ("ScrollFrame", "DetailsIconsFrame", frame.IconFrame, "ListScrollFrameTemplate")

			local ChecksFrame_Update = function (self)
				--self = self or MacroPopupFrame;
				local numMacroIcons = #MACRO_ICON_FILENAMES;
				local macroPopupIcon, macroPopupButton;
				local macroPopupOffset = FauxScrollFrame_GetOffset (scroll);
				local index;
				
				-- Icon list
				local texture;
				for i = 1, 25 do
					macroPopupIcon = _G["DetailsIconCheckFrame"..i];
					macroPopupButton = _G["DetailsIconCheckFrame"..i];
					index = (macroPopupOffset * 5) + i;
					texture = MACRO_ICON_FILENAMES [index]
					if ( index <= numMacroIcons and texture ) then
						macroPopupButton:ChangeIcon ("INTERFACE\\ICONS\\"..texture, "INTERFACE\\ICONS\\"..texture, "INTERFACE\\ICONS\\"..texture, "INTERFACE\\ICONS\\"..texture)
						macroPopupButton.IconID = index
						macroPopupButton:Show();
					else
						macroPopupButton:Hide();
					end

				end
				
				-- Scrollbar stuff
				FauxScrollFrame_Update (scroll, ceil (numMacroIcons / 5) , 5, 20 );
			end
			
			
			scroll:SetPoint ("topleft", frame.IconFrame, "topleft", -18, -10)
			scroll:SetWidth (170)
			scroll:SetHeight (148)
			scroll:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (scroll, offset, 20, ChecksFrame_Update) end)
			scroll.update = ChecksFrame_Update
			frame.IconFrameScroll = scroll
			frame.IconFrame:Hide()
		end
		
		frame.IconFrame:Show()
		frame.IconFrameScroll.update (frame.IconFrameScroll)
		
	end

	local Icon
	
	local reset = function()
		frame ["TextMyNameEntry"]:SetText ("")
		frame ["TextSpellIDEntry"]:SetText ("")
		frame ["TextActorNameEntry"]:SetText ("")
		frame ["TextSourceEntry"]:SetText ("")
		Icon:SetTexture ("Interface\\Icons\\TEMP")
		frame.atributo = 1
		frame.sub_atributo = 1
		fundoBrilha:SetPoint ("left", frame.MainMenu [1].icon , "right", -20, -10)
	end	
	
	--> Create Button
	local CreateFunction = function()

		local Atributo = frame.atributo --> healing
		local SubAtributo = frame.sub_atributo --> healing done
		
		if (not Atributo or not SubAtributo) then 
			print (Loc ["STRING_CUSTOM_NOATTRIBUTO"])
			return
		end
		
		if (frame ["TextMyNameEntry"]:HasFocus()) then
			frame ["TextMyNameEntry"]:PressEnter()
		elseif (frame ["TextSpellIDEntry"]:HasFocus())then
			frame ["TextSpellIDEntry"]:PressEnter()
		elseif (frame ["TextActorNameEntry"]:HasFocus())then
			frame ["TextActorNameEntry"]:PressEnter()
		elseif (frame ["TextSourceEntry"]:HasFocus())then
			frame ["TextSourceEntry"]:PressEnter()
		end
		
		local CustomName = frame ["TextMyNameEntry"].text
		local SpellID = frame ["TextSpellIDEntry"].text
		local Actor = frame ["TextActorNameEntry"].text
		local Source = frame ["TextSourceEntry"].text

		if (not CustomName or string.len (CustomName) < 5) then 
			print (Loc ["STRING_CUSTOM_SHORTNAME"])
			--print ("Nome da customizacao precisa ter pelo menos 5 letras")
			frame ["TextMyNameEntry"]:Blink()
			return
		elseif (string.len (CustomName) > 32) then
			--print ("Nome da customizacao nao pode ter mais de 32 letras")
			print (Loc ["STRING_CUSTOM_LONGNAME"])
			frame ["TextMyNameEntry"]:Blink()
			return
		end
		
		if (string.len (SpellID) < 1) then
			--print ("Sem id da magia")
			print (Loc ["STRING_CUSTOM_NOSPELL"])
			frame ["TextSpellIDEntry"]:Blink()
			return
		end
		
		_detalhes.custom [#_detalhes.custom+1] = {name = CustomName, spell = SpellID, target = Actor, source = Source, inout = InOut, icon = frame.IconTexture, attribute = Atributo, sattribute = SubAtributo}
		print (Loc ["STRING_CUSTOM_CREATED"])
		_detalhes:CloseCustomWindow()
		reset()
	end	

	local IconButton = gump:NewDetailsButton (frame, frame, _, ChooseIcon, nil, nil, 80, 15, "", "", "", "", nil, "DetailsCustomPanelIconButton")
	IconButton.text:SetText (Loc ["STRING_CUSTOM_ICON"])
	IconButton.text:SetPoint ("left", IconButton, "left", 3, 0)
	IconButton:SetPoint ("topleft", frame, "topleft", xStart+21, -118)
	IconButton:SetFrameLevel (frame:GetFrameLevel()+2)
	IconButton:InstallCustomTexture (_, {x1 = -20, x2 = 0, y1 = 0, y2 = 0})
	frame.iconbutton = IconButton
	
	Icon = IconButton:CreateTexture (nil, "overlay")
	Icon:SetTexture (frame.IconTexture)
	Icon:SetPoint ("right", IconButton, "left", 0, 0)
	Icon:SetWidth (22)
	Icon:SetHeight (22)
	frame.icon = Icon

	local CreateButton = gump:NewDetailsButton (frame, frame, _, CreateFunction, nil, nil, 80, 15, "", "", "", "", nil, "DetailsCustomPanelCreateButton")
	CreateButton.text:SetText (Loc ["STRING_CUSTOM_CREATE"])
	CreateButton:SetPoint ("topleft", frame, "topleft", 413, -118)
	CreateButton:SetFrameLevel (frame:GetFrameLevel()+2)
	CreateButton:InstallCustomTexture (_, {x1 = -20, x2 = 0, y1 = 0, y2 = 0})
	
	local CreateIcon = CreateButton:CreateTexture (nil, "overlay")
	CreateIcon:SetTexture ("Interface\\Icons\\Ability_Paladin_HammeroftheRighteous")
	CreateIcon:SetWidth (22)
	CreateIcon:SetHeight (22)
	CreateIcon:SetPoint ("right", CreateButton, "left")
	
--------> Install CoolTip on Remove Button
		local DeleteFunc = function (_, _, CustomIndex) 
			table.remove (_detalhes.custom, CustomIndex)
			for _, instancia in _ipairs (_detalhes.tabela_instancias) do 
				if (instancia.atributo == 5 and instancia.sub_atributo == CustomIndex) then 
					if (instancia.iniciada) then 
						instancia:TrocaTabela (nil, 1, 1, true)
					else
						instancia.atributo = 1
						instancia.sub_atributo = 1
					end
				elseif (instancia.atributo == 5 and instancia.sub_atributo > CustomIndex) then
					instancia.sub_atributo = instancia.sub_atributo - 1
					instancia.sub_atributo_last [5] = 1
				else
					instancia.sub_atributo_last [5] = 1
				end
			end
			if (#_detalhes.custom > 0) then 
				_detalhes.popup:ExecFunc (DeleteButton)
			else
				GameCooltip:Close()
			end
			_detalhes.switch:OnRemoveCustom (CustomIndex)
		end

		local CreateCustomList = function() 
			for index, custom in _ipairs (_detalhes.custom) do 
				GameCooltip:AddMenu (1, DeleteFunc, index, nil, nil, custom.name, _, true)
				GameCooltip:AddIcon (custom.icon, 1, 1, 20, 20, 0, 1, 0, 1)
			end
		end
		
		DeleteButton.CoolTip = { 
			Type = "menu",
			BuildFunc = CreateCustomList, 
			Options = {NoLastSelectedBar = true, TextSize = 9.5, HeightAnchorMod = -10}}
		_detalhes.popup:CoolTipInject (DeleteButton, true)

	-------------------------
	
	-------------------------> Install CoolTip on Shout Button

		local addCustomReceived = function (param1)
			_detalhes.custom [#_detalhes.custom+1] = param1
			print (Loc ["STRING_CUSTOM_CREATED"])
		end
	
		function _detalhes:OnReceiveCustom (source, realm, dversion, _customTable)
		
			if (dversion ~= _detalhes.realversion) then
				print (Loc ["STRING_TOOOLD2"])
				return
			end
		
			for index, custom in _ipairs (_detalhes.custom) do 
				if (_customTable.name == custom.name) then
					return
				end
			end
			_detalhes:Ask (source .. "-" .. realm .. " " .. Loc ["STRING_CUSTOM_ACCETP_CUSTOM"], addCustomReceived, _customTable)
		end
	
		--> testing
		local ShoutFunc = function (_, _, CustomIndex)
			GameCooltip:Close()
			_detalhes:SendRaidData ("custom_broadcast", _detalhes.custom [CustomIndex])
			print (Loc ["STRING_CUSTOM_BROADCASTSENT"])
		end

		local CreateCustomListForShout = function() 
			for index, custom in _ipairs (_detalhes.custom) do 
				GameCooltip:AddMenu (1, ShoutFunc, index, nil, nil, custom.name, _, true)
				GameCooltip:AddIcon (custom.icon, 1, 1, 20, 20, 0, 1, 0, 1)
			end
		end
		
		BroadcastButton.CoolTip = { 
			Type = "menu",
			BuildFunc = CreateCustomListForShout, 
			Options = {NoLastSelectedBar = true, TextSize = 9.5, HeightAnchorMod = -10}}
			
		GameCooltip:CoolTipInject (BroadcastButton, true)

		function _detalhes:CommReceive (prefix, Msgs, distribution, target)
			--print (prefix, Msgs, distribution, target)
		end
		_detalhes:RegisterComm ("DETAILS", "CommReceive")
		
	-------------------------
	
	_detalhes.CustomFrame = frame
	
	tinsert (UISpecialFrames, "DetailsCustomPanel")
	_detalhes.CustomFrame.oponed = false
	frame:Hide()
end

function _detalhes:InitCustom()
	CreateCustomWindow()
	return true
end

function _detalhes:OpenCustomWindow()
	if (InCombatLockdown()) then
		print ("|cffFF2222"..Loc ["STRING_CUSTOM_INCOMBAT"])
		return
	end
	
	if (not _detalhes.CustomFrame.oponed) then
		_detalhes.CustomFrame.oponed = true
		_detalhes:BuildSpellList()
		_detalhes.CustomFrame:Show()
	end
end

function _detalhes:CloseCustomWindow()
	_detalhes.CustomFrame.oponed = false
	_detalhes:ClearSpellList()
	_detalhes.CustomFrame:Hide()
end

